# Firebase emulator setup (development only)

This repository intentionally has no production Firebase project configuration or credentials.

From `adlease/functions`:

```bash
npm install
npm run test:emulator
```

The script starts the Firestore and Authentication emulators using the non-production project ID `demo-adlease`.

For a Flutter Android emulator, after Firebase is initialized with demo FirebaseOptions, connect SDKs to:
- Auth: `10.0.2.2:9099`
- Firestore: `10.0.2.2:8080`
- Functions: `10.0.2.2:5001`

For desktop/web local development use `127.0.0.1` instead. Do not point a production build at emulator endpoints.

## Current integration boundary

`FirebaseIdentityService` provides Firebase email/password registration, email verification, login, password reset and Google credential exchange. It is not yet wired into the app-wide AuthProvider: main.dart currently starts without Firebase.initializeApp, and production Firebase options / Android google-services configuration have not been supplied. Keep the local demo provider as the app default until a Firebase project is created, configured and emulator-tested.

The Cloud Function creates only a pending user profile. It cannot grant verification, activate a suspended account or issue rewards. Ad sessions and reward claims are disabled. The internal compatibility helper always rejects and cannot write reward claims, wallet balances or ledger entries. There is no production ad provider or SSV verifier.

## Verification and reviewer security gates

- Verification request creation is limited transactionally to three attempts per user in a 24-hour window anchored at the first attempt. A pending request cannot be duplicated.
- Profile name, country and phone values are unverified user assertions only. Phone format is validated as E.164; these fields are not KYC evidence.
- Reviewer decisions require a server-issued reviewer/admin custom claim, a Firebase MFA second-factor claim and a recent authentication time (10 minutes).
- The callable also fails closed unless `ENABLE_VERIFICATION_REVIEW=true` is explicitly set in the Functions environment. Leave this unset in ordinary staging until reviewer governance is approved.
- There is deliberately no client-callable role grant/revoke endpoint. Never assign custom claims from the app, a browser, or an unaudited admin dashboard.
- Before enabling review, Avaru must document named reviewers, least-privilege role scope, two-person approval for grants, secure Admin SDK claim assignment, revocation/session invalidation, MFA enrollment/recovery, periodic access reviews and audit/alert ownership. Test grant, revoke, stale-token, missing-MFA and terminated-reviewer cases in a controlled staging project.
- Do not put real identity documents or production personal data in the emulator or staging project until Kenyan counsel/ODPC have approved the data-flow, retention and transfer controls.
