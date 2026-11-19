# Firebase project setup — AdLease Staging

**Purpose:** configure the existing staging project only. This document does not authorise production deployment, real customer data, live payments or public release.

## Existing project (already created)

| Item | Confirmed state |
|---|---|
| Firebase project name | `AdLease Staging` |
| Project ID | `adlease-staging` |
| Project number | `268757513757` |
| Firestore database | `(default)` |
| Firestore location | `eur3` — Europe multi-region |
| Firestore edition/mode | Standard edition; production mode/security locked |
| Firestore backups | Scheduled backups off |
| Authentication | Email/Password provider enabled |
| Google sign-in | Not enabled |
| Analytics | Disabled |
| Android Firebase app | Not yet registered/confirmed |
| `google-services.json` / `firebase_options.dart` | Not yet generated/committed |
| Firebase CLI login | Not yet confirmed |
| App-wide Firebase auth | Not integrated; app still uses local demo `AuthProvider` |
| Production functions | Not deployed |

The existing `eur3` database location is outside Kenya. Do not put real Kenyan user data, national IDs, financial records or production identity documents into this project until the ODPC cross-border transfer assessment, legal basis, DPA/safeguards and any required DPIA/consultation are complete. Use synthetic test records only.

## Repository configuration

- Flutter project: `adlease/`
- Android application ID: `com.adlease.adlease`
- Firebase project alias: `staging` → `adlease-staging` (no production alias is configured)
- Local emulator project: `demo-adlease` (must remain separate from the real project)
- Auth emulator: `9099`; Firestore emulator: `8080`; Functions emulator: `5001`
- Cloud Functions runtime: Node.js 22. Node.js 20 was decommissioned on 30 October 2026, so it must not be used for new deployments.

## Step 1 — verify the Firebase Console project

Open https://console.firebase.google.com/ and select **AdLease Staging** (`adlease-staging`). Verify the project ID shown in Project settings matches exactly. Do not create another project.

Authentication → Sign-in method:
- Email/Password should remain enabled.
- Google provider remains off until Android app registration, signing fingerprints and OAuth configuration are completed.

Firestore Database:
- Confirm database `(default)`, location `eur3`, Standard edition and locked production rules.
- Do not change the database location; it cannot be casually moved after creation.
- Do not add live user data.

Analytics remains disabled as previously selected.

## Step 2 — register the Android app and generate FlutterFire options

On a trusted development computer with Flutter 3.47.8 / Dart 3.13 and Node.js installed:

```bash
cd adlease
firebase login
dart pub global activate flutterfire_cli
firebase projects:list
flutterfire configure --project=adlease-staging --platforms=android
```

When prompted, select the existing **AdLease Staging** project. Register/select Android package ID exactly as:

```text
com.adlease.adlease
```

Do not change the package ID. The FlutterFire CLI should create/register the Android Firebase app if it does not already exist and generate `lib/firebase_options.dart`. Review the generated diff and ensure the options identify project `adlease-staging` before committing. These app configuration identifiers are not service-account secrets. Never commit service-account JSON private keys, OAuth client secrets, or signing keystores.

Google sign-in is not required for the first staging authentication test. Keep Email/Password only until the Android SHA fingerprints and OAuth consent configuration are deliberately completed.

## Step 3 — keep local emulator tests isolated

The existing debug bootstrap uses an explicit opt-in flag and the demo project ID. It must not silently connect to the real staging project.

From `adlease/`, start local emulators:

```bash
firebase emulators:start --project demo-adlease
```

In a second terminal:

```bash
cd adlease
flutter run --dart-define=ADLEASE_USE_FIREBASE_EMULATORS=true
```

For Android emulator, the host is `10.0.2.2`. For desktop/iOS simulator it is `127.0.0.1`. A physical Android device requires a trusted LAN host IP and local firewall configuration. Never enable emulator mode in a release build.

## Step 4 — staging project access and billing boundary

The Firebase Emulator Suite and local TypeScript/Flutter tests do not require upgrading the staging project or deploying anything.

**Deploying Cloud Functions to Firebase requires the Blaze pay-as-you-go plan and a linked Cloud Billing account.** Do not upgrade the project yet. Before any upgrade:
- Confirm the payment method and billing account owner.
- Set budget alerts and Cloud Run/Functions spend controls.
- Review expected deployment and logging costs.
- Obtain the owner's explicit approval.

A budget alert is not a hard spending cap. Until that approval, use emulator tests only; no `firebase deploy` command should be run.

## Step 5 — app integration is a separate controlled change

Firebase SDK dependencies and `FirebaseIdentityService` exist, but `AuthProvider` and the app login/register screens still use the local demo `AuthService` and SharedPreferences. The app is not yet using Firebase Authentication for real users.

After FlutterFire options are generated, the next engineering PR must:
1. Add an explicit debug-only staging bootstrap that uses `DefaultFirebaseOptions.currentPlatform` only when a dedicated staging flag is set.
2. Keep emulator and staging modes mutually exclusive; release builds must fail closed unless an approved production configuration is introduced separately.
3. Wire Firebase email/password registration, email verification, login, password reset and sign-out into a separate Firebase Auth provider.
4. Call the server profile initializer after Firebase account creation and handle partial failures safely.
5. Read server-controlled verification/account state; never trust local booleans.
6. Add widget/integration tests for registration, email verification, login, password reset, logout and profile creation.
7. Keep the local demo mode clearly labelled and never silently fall back from failed Firebase login to local accounts.

Do not make this change by simply switching the current `AuthService` implementation in place; preserve the existing testable demo adapter until end-to-end tests pass.

## Information still needed from the owner

Only these non-secret checks remain:
- Run the FlutterFire CLI commands above on the trusted development computer.
- Confirm it registered Android package `com.adlease.adlease` and generated `adlease/lib/firebase_options.dart`.
- Share the generated file through the repository/approved file workflow; do not paste secrets into chat.
- Confirm Firebase Console still shows project `adlease-staging`, database `(default)`, region `eur3`, and Email/Password enabled.

Do not send passwords, private keys, service-account JSON, M-PESA credentials or signing keystores in chat.

## Separate partner workstream — M-KOPA

M-KOPA remains the intended first supplier/financing target, not a confirmed partner. Do not configure M-KOPA credentials or hard-code commercial terms. Keep the integration provider-neutral until signed agreements define the device catalogue, wholesale price, customer quotation, deposit, repayment schedule, settlement, default/returns, warranty, customer data sharing and reconciliation.
