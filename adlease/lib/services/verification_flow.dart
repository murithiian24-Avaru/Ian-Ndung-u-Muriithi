import 'auth_stage.dart';

class GatewayUser {
  const GatewayUser({required this.uid, required this.emailVerified});

  final String uid;
  final bool emailVerified;
}

class IdentityAuthException implements Exception {
  const IdentityAuthException(this.code);

  final String code;

  @override
  String toString() => 'IdentityAuthException($code)';
}

/// Thin seam over Firebase Auth so the transitions below are testable
/// without Firebase. FirebaseIdentityService should implement this.
abstract class IdentityGateway {
  /// Current session user after restoring persisted state, or null.
  Future<GatewayUser?> restoreSession();
  Future<GatewayUser> registerWithEmail(String email, String password);
  Future<GatewayUser> signInWithEmail(String email, String password);
  Future<void> sendVerificationEmail();

  /// Reload the user from Firebase and return fresh state (null if none).
  Future<GatewayUser?> reloadUser();
  Future<void> forceRefreshIdToken();
  Future<void> signOut();
}

enum ResendOutcome { sent, throttled, notApplicable }

class ResendThrottle {
  ResendThrottle({
    this.cooldown = const Duration(seconds: 60),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Duration cooldown;
  final DateTime Function() _now;
  DateTime? _lastSent;

  Duration get remaining {
    final last = _lastSent;
    if (last == null) return Duration.zero;
    final elapsed = _now().difference(last);
    return elapsed >= cooldown ? Duration.zero : cooldown - elapsed;
  }

  bool get canSend => remaining == Duration.zero;

  void markSent() => _lastSent = _now();
}

/// Email-verification state machine. It never creates a profile and never
/// treats verified email as approval: after verification the next stage is
/// `checkingProfile`, and only a server lookup result moves it further.
class VerificationFlow {
  VerificationFlow(this._gateway, {ResendThrottle? throttle})
    : _throttle = throttle ?? ResendThrottle();

  final IdentityGateway _gateway;
  final ResendThrottle _throttle;

  AuthStage _stage = AuthStage.signedOut;
  bool _sending = false;
  bool _verificationEmailFailed = false;

  AuthStage get stage => _stage;
  Duration get resendWait => _throttle.remaining;

  /// True when the email after registration could not be sent. The session
  /// stays recoverable: the user can resend from the pending screen.
  bool get verificationEmailFailed => _verificationEmailFailed;

  static const Set<String> _terminalCodes = {
    'user-disabled',
    'user-not-found',
    'user-token-expired',
    'invalid-user-token',
  };

  Future<AuthStage> restore() async {
    try {
      final user = await _gateway.restoreSession();
      _stage = _stageFor(user);
    } catch (_) {
      await _signOutQuietly();
      _stage = AuthStage.signedOut;
    }
    return _stage;
  }

  Future<AuthStage> register(String email, String password) async {
    final GatewayUser user;
    try {
      user = await _gateway.registerWithEmail(email, password);
    } catch (_) {
      await _signOutQuietly();
      _stage = AuthStage.signedOut;
      rethrow;
    }
    _stage = _stageFor(user);
    if (_stage == AuthStage.verificationPending) {
      try {
        await _gateway.sendVerificationEmail();
        _throttle.markSent();
        _verificationEmailFailed = false;
      } catch (_) {
        _verificationEmailFailed = true;
      }
    }
    return _stage;
  }

  /// An unverified sign-in intentionally keeps the session, but only inside
  /// `verificationPending`. Any failed sign-in leaves no session.
  Future<AuthStage> signIn(String email, String password) async {
    final GatewayUser user;
    try {
      user = await _gateway.signInWithEmail(email, password);
    } catch (_) {
      await _signOutQuietly();
      _stage = AuthStage.signedOut;
      rethrow;
    }
    _stage = _stageFor(user);
    return _stage;
  }

  Future<ResendOutcome> resendVerificationEmail() async {
    if (_stage != AuthStage.verificationPending) {
      return ResendOutcome.notApplicable;
    }
    if (_sending || !_throttle.canSend) return ResendOutcome.throttled;
    _sending = true;
    try {
      await _gateway.sendVerificationEmail();
      _throttle.markSent();
      _verificationEmailFailed = false;
      return ResendOutcome.sent;
    } finally {
      _sending = false;
    }
  }

  /// Reload, and only if verified force-refresh the ID token. A failed
  /// reload or refresh leaves the stage at `verificationPending`, except for
  /// terminal account errors (disabled, deleted, expired), which sign out.
  Future<AuthStage> refreshVerification() async {
    if (_stage != AuthStage.verificationPending) return _stage;
    final GatewayUser? user;
    try {
      user = await _gateway.reloadUser();
    } on IdentityAuthException catch (e) {
      if (_terminalCodes.contains(e.code)) {
        await _signOutQuietly();
        _stage = AuthStage.signedOut;
      }
      rethrow;
    }
    if (user == null) {
      _stage = AuthStage.signedOut;
      return _stage;
    }
    if (!user.emailVerified) return _stage;
    await _gateway.forceRefreshIdToken();
    _stage = AuthStage.checkingProfile;
    return _stage;
  }

  /// Apply the server's profile lookup result. Only valid after email
  /// verification; ignored while signed out or verification is pending.
  AuthStage applyProfileLookup({
    required ProfileLookup lookup,
    String? accountStatus,
  }) {
    const postVerification = {
      AuthStage.checkingProfile,
      AuthStage.profileCompletion,
      AuthStage.customerShell,
      AuthStage.blocked,
    };
    if (!postVerification.contains(_stage)) return _stage;
    _stage = resolveAuthStage(
      signedIn: true,
      emailVerified: true,
      profile: lookup,
      accountStatus: accountStatus,
    );
    return _stage;
  }

  Future<void> signOut() async {
    await _signOutQuietly();
    _stage = AuthStage.signedOut;
  }

  AuthStage _stageFor(GatewayUser? user) {
    if (user == null) return AuthStage.signedOut;
    return resolveAuthStage(
      signedIn: true,
      emailVerified: user.emailVerified,
      profile: ProfileLookup.notChecked,
    );
  }

  Future<void> _signOutQuietly() async {
    try {
      await _gateway.signOut();
    } catch (_) {
      // Sign-out failure is surfaced by the caller's next auth check.
    }
  }
}
