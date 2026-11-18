# Firebase project setup (AdLease)

This guide prepares a **staging/development** Firebase project. Do not point the app at production while emulator integration and security review are still in progress.

## Current repository facts

- Flutter app directory: `adlease/`
- Android application ID currently in Gradle: `com.adlease.adlease`
- Firebase Emulator Suite configuration: `adlease/firebase.json`
- Emulator project used by tests: `demo-adlease`
- Auth emulator: `9099`; Firestore emulator: `8080`; Functions emulator: `5001`
- Cloud Functions runtime: Node.js 20
- Firebase Flutter dependencies and a separate `FirebaseIdentityService` adapter are already present.
- The app's default `AuthProvider` is still the local demo provider. Do not treat Firebase sign-in as active in the app yet.

## Access needed from the owner

1. A Google account you control, with permission to create Firebase projects.
2. Permission to create a new Firebase project for AdLease staging (Project Owner or equivalent project-creation access).
3. Access to the Firebase Console and Google Cloud Console for that project.
4. Later, a project-scoped service account / GitHub Actions identity for deployment. Do not create or share a service-account JSON key for this setup step.
5. If Google sign-in is required, access to configure the OAuth consent screen / support email and the Android SHA fingerprints for the app.

Do not send passwords, OAuth client secrets, service-account private keys, signing keystores, or M-PESA credentials in chat or commit them to GitHub.

## Create the staging project

1. Open https://console.firebase.google.com/ and sign in with your Google account.
2. Create a new project named **AdLease Staging**. Choose a globally unique project ID and save it privately.
3. Keep this separate from any future production project. Do not enable paid production services or deploy functions yet.
4. In **Build → Authentication → Get started**, enable **Email/Password**. Enable Google only after the Android app signing fingerprints and OAuth settings are ready.
5. Create the default Firestore database only when the staging project setup asks for it. Select a region deliberately; changing a Firestore database region later is not straightforward. Confirm the region with the owner before creating it.
6. Do not add real customer data.

## Configure FlutterFire locally

Run these commands from a trusted development machine with Flutter/Dart and Node.js 20 installed:

```bash
cd adlease
firebase login
dart pub global activate flutterfire_cli
firebase projects:list
flutterfire configure --project YOUR_STAGING_PROJECT_ID --platforms android
```

The Android package/application ID to register is currently `com.adlease.adlease`. Do not change it as part of Firebase setup without a separate approved package-ID migration.

FlutterFire generates `lib/firebase_options.dart`. These platform identifiers are not private credentials, but review the generated diff before committing it. Keep service-account credentials and OAuth client secrets out of the repository.

## Emulator-first app connection

The emulator project ID is `demo-adlease`; it must not be replaced with the real staging project ID when running local emulator tests.

- Android Studio emulator host: `10.0.2.2`
- iOS simulator host: `127.0.0.1`
- Physical Android device: use the development computer's LAN IP address, with both devices on the same trusted network and the required ports allowed by the local firewall.

Connect Firebase Auth, Firestore and Functions SDKs to the emulators before any app-level integration test. Never use emulator host settings in a production build. Emulator connection must be guarded by an explicit debug-only configuration flag.

## Run the Flutter app against local emulators

A debug-only bootstrap is included in `lib/services/firebase_bootstrap.dart`. Firebase is not initialized by default. To opt into local emulators explicitly:

```bash
cd adlease
flutter run --dart-define=ADLEASE_USE_FIREBASE_EMULATORS=true
```

For an Android emulator, the default host is `10.0.2.2`; for iOS simulator/desktop it is `127.0.0.1`. For a physical Android device, provide the development computer's LAN address:

```bash
flutter run \
  --dart-define=ADLEASE_USE_FIREBASE_EMULATORS=true \
  --dart-define=ADLEASE_FIREBASE_EMULATOR_HOST=192.168.1.10
```

Replace the example IP with the development computer's actual LAN IP. Start emulators first from the `adlease/` directory:

```bash
firebase emulators:start --project demo-adlease
```

This bootstrap rejects emulator mode in release builds and uses the `demo-adlease` project ID. The app still uses its existing local demo `AuthProvider`; Firebase initialization alone does not switch the login/register screens to Firebase. Do not interpret this as completed app-wide Firebase authentication.

## Before enabling Firebase in the app

- Keep the local demo authentication flow available as a fallback until the Firebase user journey is tested end-to-end.
- Add integration tests for registration, email verification, login, password reset, sign-out, profile initialization, verification request and reviewer decision.
- Ensure user profile status and verification status are read from server-controlled data; never trust a client-side boolean.
- Keep Firestore client writes denied for wallet, ledger, verification decisions, reward claims and admin audit records.
- Deploy rules/functions only to the staging project after explicit review. Never deploy to production from this setup guide.

## Information to return to the engineering team

Share only:
- Firebase staging Project ID (not passwords or private keys).
- Confirmed Firestore region.
- Whether Email/Password provider is enabled.
- Whether the project is staging-only and contains no real customer data.

## Separate partner workstream: M-KOPA

M-KOPA remains the intended first supplier/financing target, not a confirmed partner. Do not configure M-KOPA-specific credentials or hard-code its commercial terms. The integration should use a provider-neutral supplier/financier interface until a signed agreement defines device catalogue, wholesale price, deposit, repayment schedule, settlement account, default/returns, customer data sharing and reconciliation obligations.
