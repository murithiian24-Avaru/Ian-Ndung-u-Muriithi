# AdLease Firebase Authentication integration plan

**Target:** existing staging project 'adlease-staging' only  
**Android application ID:** 'com.adlease.adlease'  
**Status:** implementation prepared; awaiting owner-generated FlutterFire options and project verification.  
**Safety:** do not collect real Kenyan customer data. Use synthetic accounts only until the ODPC cross-border transfer, DPIA, registration and contractual gates are approved.

## Current verified code state

- Firebase SDK dependencies are present in 'pubspec.yaml'.
- 'FirebaseIdentityService' exists with email/password create, sign-in, email verification, password reset, sign-out and a server profile-initialization callable.
- 'FirebaseBootstrap' currently supports only explicit local emulator mode using project 'demo-adlease'; it returns without initializing Firebase when emulator mode is off.
- 'main.dart' still constructs the existing local 'AuthProvider'.
- 'AuthProvider' delegates to 'AuthService', which stores demo accounts in SharedPreferences.
- Local demo auth is not secure production authentication. Do not represent it as such.
- The app must not silently fall back to local accounts if Firebase initialization or sign-in fails.

## Staging integration sequence

### A. Owner configuration prerequisite

1. Confirm Firebase Console project ID 'adlease-staging', project number '268757513757'.
2. Confirm Android package 'com.adlease.adlease'.
3. Register the Android app in the existing Firebase project.
4. Generate 'lib/firebase_options.dart' with FlutterFire CLI.
5. Review that generated options identify 'adlease-staging'. Firebase client config is not a service-account private key; never commit service-account JSON or OAuth secrets.
6. Keep Email/Password enabled. Keep Google provider disabled until SHA fingerprints and OAuth configuration are completed.
7. Keep analytics disabled unless separately approved.

### B. Safe app configuration

Implement an explicit build-mode selector with mutually exclusive modes:
- 'demo': local demo AuthService, clearly labelled as demo, no real customer data.
- 'emulator': Firebase initialized with 'demo-adlease' and all Auth/Firestore/Functions clients pointed at local emulator hosts.
- 'staging': Firebase initialized using 'DefaultFirebaseOptions.currentPlatform' and the verified 'adlease-staging' project. Debug/profile only; release builds must reject this staging mode.

No mode may silently fall back to another. Unknown or conflicting flags must fail closed. Production configuration must be a separate reviewed release change.

### C. Authentication provider and session lifecycle

Use a dedicated Firebase-backed provider/service rather than replacing the demo implementation in place. Inject interfaces so widget tests can use fakes.

Required journeys:
1. Register with email/password, full name, E.164 phone and country.
2. Send email verification.
3. Do not navigate into an authenticated customer area until email is verified.
4. Handle verification-pending UI, resend with throttling, reload current Firebase user and refresh state.
5. On first verified sign-in, call 'initializeUserProfile' (idempotent server-side).
6. Sign in with email/password and restore auth state from Firebase Auth's 'authStateChanges'.
7. Password reset through Firebase Auth; show generic confirmation without disclosing account existence.
8. Sign out and clear local sensitive/session state.
9. Handle disabled/deleted/suspended accounts by reading server-controlled account state; never trust a local 'isActive' or 'isVerified' boolean.
10. Google sign-in remains hidden/disabled until its provider, OAuth configuration and profile onboarding are explicitly enabled.

### D. Data and authorization rules

- Firebase UID is the stable account key.
- User profile creation is callable/server-side; client cannot create or delete 'users/{uid}'.
- Client profile updates are restricted to approved profile fields in Firestore rules.
- Verification status, account status, reviewer decisions, wallet, ledger, payment and financing state are server-controlled.
- Do not store password hashes, identity documents or financial records in SharedPreferences.
- Do not treat email verification as KYC or credit approval.
- No advertising/reward path is enabled; no ad view can create customer value.

### E. Tests required before switching app auth

Unit/service:
- Valid and invalid email/password input.
- Firebase Auth error mapping without leaking provider internals.
- Registration partial failure (Auth account created but profile callable fails); retry must be idempotent and recoverable.
- Email not verified blocks protected routes.
- Password reset generic success and failure handling.
- Sign-out clears session and returns to welcome.
- Staging/emulator/demo mode isolation and release-mode fail-closed behaviour.
- Suspended/closed account is blocked by server state.

Widget/integration (Firebase Emulator Suite):
- Register → verification email action simulated → reload → verified sign-in.
- Existing account sign-in.
- Wrong password and unknown account.
- Password reset.
- Profile initializer called once and retry-safe.
- Cross-user Firestore read denied.
- Client writes to protected verification, ledger, wallet, payment and audit collections denied.
- App restart restores only the Firebase Auth session.
- Network unavailable and emulator unavailable states show recoverable errors; never fall back to demo.

### F. Release gates

Do not switch the default app authentication provider until:
- Owner-generated Firebase options are reviewed.
- All emulator auth and Firestore tests pass.
- Flutter analyze, all tests, formatting and Android debug build pass.
- Privacy notice and ODPC transfer/DPIA requirements are approved before real personal data is processed.
- A separate production project and release configuration are approved.
- Admin role lifecycle, MFA and audit governance are implemented before staff operations.

## Owner action when ready

Run the commands in 'FIREBASE_PROJECT_SETUP.md' on the trusted development computer and commit/share the generated 'lib/firebase_options.dart' through the repository. Never send credentials, keystores or service-account private keys in chat.
