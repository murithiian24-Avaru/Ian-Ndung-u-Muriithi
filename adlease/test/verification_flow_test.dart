import 'package:adlease/services/auth_stage.dart';
import 'package:adlease/services/verification_flow.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeGateway implements IdentityGateway {
  final List<String> calls = [];

  GatewayUser? sessionUser;
  GatewayUser registerResult =
      const GatewayUser(uid: 'u1', emailVerified: false);
  GatewayUser signInResult = const GatewayUser(uid: 'u1', emailVerified: false);
  GatewayUser? reloadResult = const GatewayUser(uid: 'u1', emailVerified: false);

  Object? restoreError;
  Object? registerError;
  Object? signInError;
  Object? sendError;
  Object? reloadError;
  Object? refreshError;

  int get sendCount => calls.where((c) => c == 'send').length;

  @override
  Future<GatewayUser?> restoreSession() async {
    calls.add('restore');
    final e = restoreError;
    if (e != null) throw e;
    return sessionUser;
  }

  @override
  Future<GatewayUser> registerWithEmail(String email, String password) async {
    calls.add('register');
    final e = registerError;
    if (e != null) throw e;
    return registerResult;
  }

  @override
  Future<GatewayUser> signInWithEmail(String email, String password) async {
    calls.add('signIn');
    final e = signInError;
    if (e != null) throw e;
    return signInResult;
  }

  @override
  Future<void> sendVerificationEmail() async {
    calls.add('send');
    await Future<void>.delayed(Duration.zero);
    final e = sendError;
    if (e != null) throw e;
  }

  @override
  Future<GatewayUser?> reloadUser() async {
    calls.add('reload');
    final e = reloadError;
    if (e != null) throw e;
    return reloadResult;
  }

  @override
  Future<void> forceRefreshIdToken() async {
    calls.add('forceRefresh');
    final e = refreshError;
    if (e != null) throw e;
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
  }
}

void main() {
  group('resolveAuthStage', () {
    AuthStage stage({
      bool signedIn = true,
      bool verified = true,
      ProfileLookup profile = ProfileLookup.present,
      String? status,
    }) =>
        resolveAuthStage(
          signedIn: signedIn,
          emailVerified: verified,
          profile: profile,
          accountStatus: status,
        );

    test('signed out', () {
      expect(stage(signedIn: false), AuthStage.signedOut);
    });

    test('unverified email is always verificationPending', () {
      expect(
        stage(verified: false, status: 'active'),
        AuthStage.verificationPending,
      );
    });

    test('verified email alone never reaches the customer shell', () {
      expect(
        stage(profile: ProfileLookup.notChecked),
        AuthStage.checkingProfile,
      );
      expect(
        stage(profile: ProfileLookup.missing),
        AuthStage.profileCompletion,
      );
    });

    test('pending and active profiles reach the shell', () {
      expect(stage(status: 'pending'), AuthStage.customerShell);
      expect(stage(status: 'active'), AuthStage.customerShell);
    });

    test('suspended, closed, unknown and missing status fail closed', () {
      for (final s in ['suspended', 'closed', 'weird', '', null]) {
        expect(stage(status: s), AuthStage.blocked, reason: '$s');
      }
    });
  });

  group('ResendThrottle', () {
    test('blocks until the cooldown has elapsed', () {
      var now = DateTime(2026, 11, 20, 10);
      final t = ResendThrottle(
        cooldown: const Duration(seconds: 60),
        now: () => now,
      );
      expect(t.canSend, isTrue);
      t.markSent();
      expect(t.canSend, isFalse);
      now = now.add(const Duration(seconds: 59));
      expect(t.canSend, isFalse);
      expect(t.remaining, const Duration(seconds: 1));
      now = now.add(const Duration(seconds: 1));
      expect(t.canSend, isTrue);
    });
  });

  group('VerificationFlow', () {
    late FakeGateway gw;
    late DateTime now;
    late VerificationFlow flow;

    setUp(() {
      gw = FakeGateway();
      now = DateTime(2026, 11, 20, 10);
      flow = VerificationFlow(gw, throttle: ResendThrottle(now: () => now));
    });

    test('restore: no session -> signedOut', () async {
      expect(await flow.restore(), AuthStage.signedOut);
    });

    test('restore: unverified session -> verificationPending', () async {
      gw.sessionUser = const GatewayUser(uid: 'u1', emailVerified: false);
      expect(await flow.restore(), AuthStage.verificationPending);
    });

    test('restore: verified session -> checkingProfile, not shell', () async {
      gw.sessionUser = const GatewayUser(uid: 'u1', emailVerified: true);
      expect(await flow.restore(), AuthStage.checkingProfile);
    });

    test('restore failure signs out and leaves no session', () async {
      gw.restoreError = StateError('boom');
      expect(await flow.restore(), AuthStage.signedOut);
      expect(gw.calls, contains('signOut'));
    });

    test('register -> verificationPending and sends one email', () async {
      expect(await flow.register('a@b.co', 'pw'), AuthStage.verificationPending);
      expect(gw.calls, ['register', 'send']);
      expect(flow.verificationEmailFailed, isFalse);
    });

    test('register: email send failure stays recoverable', () async {
      gw.sendError = const IdentityAuthException('network-request-failed');
      expect(await flow.register('a@b.co', 'pw'), AuthStage.verificationPending);
      expect(flow.verificationEmailFailed, isTrue);
      gw.sendError = null;
      expect(await flow.resendVerificationEmail(), ResendOutcome.sent);
      expect(flow.verificationEmailFailed, isFalse);
    });

    test('register failure leaves no session', () async {
      gw.registerError = const IdentityAuthException('email-already-in-use');
      await expectLater(
        flow.register('a@b.co', 'pw'),
        throwsA(isA<IdentityAuthException>()),
      );
      expect(gw.calls, contains('signOut'));
      expect(flow.stage, AuthStage.signedOut);
    });

    test('unverified sign-in keeps session only as verificationPending',
        () async {
      expect(await flow.signIn('a@b.co', 'pw'), AuthStage.verificationPending);
      expect(gw.calls, isNot(contains('signOut')));
    });

    test('failed sign-in leaves no session', () async {
      gw.signInError = const IdentityAuthException('wrong-password');
      await expectLater(
        flow.signIn('a@b.co', 'bad'),
        throwsA(isA<IdentityAuthException>()),
      );
      expect(gw.calls, contains('signOut'));
      expect(flow.stage, AuthStage.signedOut);
    });

    test('verified sign-in -> checkingProfile, not shell', () async {
      gw.signInResult = const GatewayUser(uid: 'u1', emailVerified: true);
      expect(await flow.signIn('a@b.co', 'pw'), AuthStage.checkingProfile);
    });

    test('refresh while still unverified does not refresh the token',
        () async {
      await flow.register('a@b.co', 'pw');
      gw.calls.clear();
      expect(await flow.refreshVerification(), AuthStage.verificationPending);
      expect(gw.calls, ['reload']);
    });

    test('refresh after verification reloads, then force-refreshes token',
        () async {
      await flow.register('a@b.co', 'pw');
      gw.calls.clear();
      gw.reloadResult = const GatewayUser(uid: 'u1', emailVerified: true);
      expect(await flow.refreshVerification(), AuthStage.checkingProfile);
      expect(gw.calls, ['reload', 'forceRefresh']);
    });

    test('token refresh failure stays verificationPending', () async {
      await flow.register('a@b.co', 'pw');
      gw.reloadResult = const GatewayUser(uid: 'u1', emailVerified: true);
      gw.refreshError = const IdentityAuthException('network-request-failed');
      await expectLater(
        flow.refreshVerification(),
        throwsA(isA<IdentityAuthException>()),
      );
      expect(flow.stage, AuthStage.verificationPending);
    });

    test('disabled user on reload signs out', () async {
      await flow.register('a@b.co', 'pw');
      gw.reloadError = const IdentityAuthException('user-disabled');
      await expectLater(
        flow.refreshVerification(),
        throwsA(isA<IdentityAuthException>()),
      );
      expect(flow.stage, AuthStage.signedOut);
      expect(gw.calls, contains('signOut'));
    });

    test('transient reload error keeps the pending session', () async {
      await flow.register('a@b.co', 'pw');
      gw.reloadError = const IdentityAuthException('network-request-failed');
      await expectLater(
        flow.refreshVerification(),
        throwsA(isA<IdentityAuthException>()),
      );
      expect(flow.stage, AuthStage.verificationPending);
    });

    test('resend is throttled, then allowed after the cooldown', () async {
      await flow.register('a@b.co', 'pw');
      expect(await flow.resendVerificationEmail(), ResendOutcome.throttled);
      now = now.add(const Duration(seconds: 60));
      expect(await flow.resendVerificationEmail(), ResendOutcome.sent);
      expect(await flow.resendVerificationEmail(), ResendOutcome.throttled);
      expect(gw.sendCount, 2);
    });

    test('concurrent resend taps send only once', () async {
      await flow.register('a@b.co', 'pw');
      now = now.add(const Duration(seconds: 60));
      gw.calls.clear();
      final results = await Future.wait([
        flow.resendVerificationEmail(),
        flow.resendVerificationEmail(),
      ]);
      expect(results, [ResendOutcome.sent, ResendOutcome.throttled]);
      expect(gw.sendCount, 1);
    });

    test('resend outside verificationPending is not applicable', () async {
      expect(
        await flow.resendVerificationEmail(),
        ResendOutcome.notApplicable,
      );
      expect(gw.sendCount, 0);
    });

    test('profile lookup results apply only after verification', () async {
      await flow.register('a@b.co', 'pw');
      expect(
        flow.applyProfileLookup(
          lookup: ProfileLookup.present,
          accountStatus: 'active',
        ),
        AuthStage.verificationPending,
      );

      gw.reloadResult = const GatewayUser(uid: 'u1', emailVerified: true);
      await flow.refreshVerification();
      expect(
        flow.applyProfileLookup(lookup: ProfileLookup.missing),
        AuthStage.profileCompletion,
      );
      expect(
        flow.applyProfileLookup(
          lookup: ProfileLookup.present,
          accountStatus: 'pending',
        ),
        AuthStage.customerShell,
      );
      expect(
        flow.applyProfileLookup(
          lookup: ProfileLookup.present,
          accountStatus: 'suspended',
        ),
        AuthStage.blocked,
      );
      expect(
        flow.applyProfileLookup(
          lookup: ProfileLookup.present,
          accountStatus: 'something-new',
        ),
        AuthStage.blocked,
      );
    });

    test('signOut clears the stage', () async {
      await flow.register('a@b.co', 'pw');
      await flow.signOut();
      expect(flow.stage, AuthStage.signedOut);
      expect(gw.calls.last, 'signOut');
    });
  });
}
