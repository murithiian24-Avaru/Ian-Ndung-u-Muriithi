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
storeFile=../adlease-upload.jks
```

The `storeFile` path is resolved relative to the Android app Gradle project (`android/app`), hence `../adlease-upload.jks` points to the keystore in `android/`.

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

## Verify the owner's artifact and test it on a physical Android device

After building with the owner's private upload key:

```powershell
keytool -printcert -jarfile build\app\outputs\bundle\release\app-release.aab
Get-FileHash build\app\outputs\bundle\release\app-release.aab -Algorithm SHA256
```

Record the SHA-256 upload-certificate fingerprint and AAB checksum in the private release record. Never send the keystore or passwords to the engineering team.

For the closest-to-production physical-device test, use Google Play **Internal testing**:
1. Create the AdLease app entry under the Avaru-owned Play Console account and enable Play App Signing.
2. Complete the required store listing and App content declarations, including the Financial features declaration and Data safety form for the actual app functionality.
3. Upload the owner's signed AAB to the Internal testing track only; do not start a production rollout.
4. Add the owner's Google account as an internal tester, open the opt-in link on the physical Android device and install from Google Play.
5. Verify the installed app's package ID is `com.adlease.adlease`, version/build number, launch, login/demo-state behaviour, settings, navigation, small-screen layout, network loss/recovery, background/resume and uninstall/reinstall.
6. Capture test results and any crashes/ANRs. Fix defects, increment the version code and repeat with a newly signed AAB.
7. Keep production rollout disabled until the owner separately approves all legal, privacy, backend and partner gates.

The CI signing test uses a disposable self-signed key only to prove Gradle can build and verify a signed AAB. It is not the owner's upload key and its AAB must never be uploaded to Play Console or used as the final device-test artifact.
