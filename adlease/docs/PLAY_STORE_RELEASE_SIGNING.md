# AdLease Play Store release signing

The Android release build must never use the debug certificate. The Gradle release variant now uses a dedicated `release` signing configuration and expects a private keystore configuration at `android/key.properties`.

## Create the upload keystore (Windows PowerShell or Command Prompt)

Run from the `adlease` directory. Keep the keystore and passwords in a secure backup outside the repository.

```powershell
keytool -genkeypair -v -keystore android\adlease-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias adlease-upload
```

Use a strong unique password and store it in a password manager. Do not upload the keystore or passwords to GitHub, chat, email, or Vercel.

Create `android/key.properties` locally (this file is git-ignored):

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=adlease-upload
storeFile=adlease-upload.jks
```

The keystore path is resolved relative to `android/app` by Gradle in the common Flutter template. If your local Gradle environment resolves it differently, use the absolute local path; never commit that path if it reveals sensitive filesystem details.

## Validate locally

```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

Expected artifact: `build\app\outputs\bundle\release\app-release.aab`.

Before Play Console upload:
- Create the app entry under the Avaru-owned Play Console account.
- Enable Play App Signing and securely preserve the upload key backup.
- Confirm application ID `com.adlease.adlease`; changing it later creates a different Play Store app identity.
- Set an intentional version name/code in `pubspec.yaml` and verify the generated AAB.
- Complete store listing, privacy policy URL, Data safety, content rating, target audience, ads declaration and app access instructions truthfully.
- Test on physical devices and complete required internal/closed testing.
- Do not publish until backend, ads policy, payments/credit model, privacy and legal reviews are complete.

This repository change does not create a keystore, sign an artifact, upload to Play Console, or publish the app. The owner must generate and safeguard the private key locally.
