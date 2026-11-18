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

The Cloud Function creates only a pending user profile. It cannot grant verification, activate a suspended account or issue rewards. The reward helper is internal and must only be called after a provider-specific signed SSV adapter has been implemented and reviewed.
