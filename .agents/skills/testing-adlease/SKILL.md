---
name: testing-adlease
description: Test the AdLease Flutter mobile app and React admin dashboard. Use when verifying UI, builds, or feature changes.
---

# Testing AdLease

## Prerequisites

- Flutter SDK (3.27.4+) at `/home/ubuntu/flutter/bin/flutter`
- Android SDK at `/home/ubuntu/android-sdk`
- Node.js for admin dashboard

## Devin Secrets Needed

None required for demo/local testing. Firebase credentials would be needed for production testing.

## Quick Verification Commands

```bash
export PATH="/home/ubuntu/flutter/bin:$PATH"
cd adlease

# Static analysis (should report 0 issues)
flutter analyze

# Unit tests (10 tests covering model serialization and calculations)
flutter test

# Build APK
flutter build apk --release

# Build web version
flutter build web --release
```

## Admin Dashboard

```bash
cd adlease/admin-dashboard
npm install
npx vite --port 3000 --host 0.0.0.0
# Opens at http://localhost:3000
# 7 pages: Dashboard, Users, Advertisers, Ads, Withdrawals, Analytics, Fraud
```

## Flutter Web Testing

The Flutter web build is the easiest way to visually test the app without an Android emulator:

```bash
cd adlease
flutter build web --release
cd build/web && python3 -m http.server 8080
# Opens at http://localhost:8080
```

## Android Emulator Testing

**Important:** The Android emulator requires significant resources. On VMs with less than 4GB free RAM and 2 CPU cores, the emulator will likely crash during APK installation. Recommendations:

- Ensure at least 4GB free RAM before starting the emulator
- Kill all unnecessary processes first
- Use `--no-window` mode if GUI isn't needed for the test
- Do NOT run `flutter build` and the emulator simultaneously - build first, then start emulator
- The emulator needs KVM permissions: `sudo gpasswd -a $USER kvm && sudo chmod 666 /dev/kvm`

```bash
export ANDROID_HOME=/home/ubuntu/android-sdk
export PATH="/home/ubuntu/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# Install emulator + system image (if not already)
sdkmanager "emulator" "system-images;android-34;default;x86_64"

# Create AVD
echo "no" | avdmanager create avd -n adlease_test -k "system-images;android-34;default;x86_64" --force

# Fix KVM permissions
sudo chmod 666 /dev/kvm

# Start emulator (build APK FIRST, before starting emulator)
emulator -avd adlease_test -no-audio -gpu swiftshader_indirect -no-snapshot-save &

# Wait for boot
adb wait-for-device
for i in $(seq 1 90); do
  status=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
  [ "$status" = "1" ] && break
  sleep 2
done

# Install pre-built APK
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Launch app
adb shell am start -n com.adlease.adlease/.MainActivity
```

## App Architecture (for understanding test paths)

- **Navigation:** Splash (3s) -> Welcome -> Register -> Main Navigation (5 tabs: Home, Watch, Wallet, Phone, Profile)
- **State:** 6 ChangeNotifier providers (Auth, Theme, Locale, Ad, Wallet, Ownership)
- **Data:** SharedPreferences with JSON serialization (demo mode, no Firebase required)
- **Ad system:** Max 3 ads/day, 60-second countdown timer, $2.50/ad reward
- **Phones:** 6 sample phones ($180-$999), ownership tracked via percentage

## Key Test Flows

1. **Registration:** Welcome -> Get Started -> Fill form (name, email, phone, country, password) -> Create Account -> Main Navigation
2. **Watch Ad:** Watch tab -> Watch Now -> Play button -> 60s timer -> Claim Reward -> Balance updates
3. **Phone Selection:** Phone tab -> Browse Phones -> Select phone -> Confirm -> Ownership progress starts
4. **Settings:** Profile tab -> Settings -> Toggle dark mode / Switch to Kiswahili

## Known Quirks

- The `flutter build web` command might take 5-10 minutes on resource-constrained VMs
- The X display server (`Xvfb :0`) might need to be restarted if it crashes due to OOM: `Xvfb :0 -screen 0 1920x1080x24 &`
- Chrome needs to be started manually after X recovery: use the real binary at `/opt/.devin/chrome/chrome/linux-137.0.7118.2/chrome-linux64/chrome` (not the wrapper at `~/.local/bin/google-chrome`)
- The wrapper script at `~/.local/bin/google-chrome` uses CDP on port 29229; if Chrome isn't running, it will fail
