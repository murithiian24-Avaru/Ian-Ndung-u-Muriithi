import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase identity adapter. Keep separate from the local demo AuthService
/// until Firebase project options and emulator wiring are configured.
class FirebaseIdentityService {
  FirebaseIdentityService({
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _functions = functions ?? FirebaseFunctions.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;
  final GoogleSignIn _googleSignIn;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String country,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase did not return a newly created user.');
    }
    await user.sendEmailVerification();
    // Profile creation is deferred until the user verifies their email.
    // The caller retains the onboarding details and invokes
    // initializeProfileAfterVerification after verification is confirmed.
    return credential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.reload();
    final user = _auth.currentUser;
    if (user == null) throw StateError('Firebase session is unavailable.');
    if (!user.emailVerified) {
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Verify your email before continuing.',
      );
    }
    await user.getIdToken(true);
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-cancelled',
        message: 'Google sign-in was cancelled.',
      );
    }
    final tokens = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: tokens.accessToken,
      idToken: tokens.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    await result.user?.reload();
    final user = _auth.currentUser;
    if (user == null || !user.emailVerified) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'A verified email address is required.',
      );
    }
    await user.getIdToken(true);
    return result;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in first.');
    await user.sendEmailVerification();
  }

  Future<void> refreshVerificationState() async {
    final user = _auth.currentUser;
    await user?.reload();
    final refreshedUser = _auth.currentUser;
    if (refreshedUser?.emailVerified == true) {
      await refreshedUser!.getIdToken(true);
    }
  }

  /// Creates the server-controlled profile only after email verification.
  /// Call this after the verification-pending screen confirms the address.
  Future<void> initializeProfileAfterVerification({
    required String fullName,
    required String phoneNumber,
    required String country,
  }) async {
    final user = _auth.currentUser;
    await user?.reload();
    final verifiedUser = _auth.currentUser;
    if (verifiedUser == null || !verifiedUser.emailVerified) {
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Verify your email before creating your profile.',
      );
    }
    await verifiedUser.getIdToken(true);
    await _initializeProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      country: country,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _initializeProfile({
    required String fullName,
    required String phoneNumber,
    required String country,
  }) async {
    await _functions.httpsCallable('initializeUserProfile').call({
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'country': country,
    });
  }
}
