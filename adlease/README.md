# AdLease - Watch. Earn. Own.

An innovative ad-powered phone ownership platform where users reduce or complete payment for smartphones by watching compulsory advertisements.

> **Status: demo prototype.** There is no backend: every account, ad view and
> reward is stored only on the phone. Ads, rewards and money are simulated, and
> nothing is suitable for real users yet. See [Features](#features) for what
> works today, and [`docs/architecture/`](docs/architecture/README.md) for the
> proposed (not yet built) production design.

## Architecture

```
adlease/
├── lib/                          # Flutter mobile app
│   ├── config/                   # Theme, routes configuration
│   ├── l10n/                     # Internationalization (EN/SW)
│   ├── models/                   # Data models
│   ├── providers/                # State management (Provider)
│   ├── screens/                  # All app screens
│   │   ├── auth/                 # Login, Register, Forgot Password
│   │   ├── home/                 # Dashboard, Navigation
│   │   ├── ads/                  # Watch Ads, Ad Player
│   │   ├── wallet/               # Wallet, Withdrawal
│   │   ├── ownership/            # Phone Selection, Progress
│   │   ├── profile/              # Profile, Edit Profile
│   │   ├── referral/             # Referral Program
│   │   ├── settings/             # App Settings
│   │   └── splash/               # Splash Screen
│   ├── services/                 # Business logic services
│   ├── utils/                    # Utilities
│   └── widgets/                  # Reusable widgets
├── admin-dashboard/              # React admin panel
│   └── src/
│       ├── components/           # Sidebar, StatCard
│       └── pages/                # Dashboard, Users, Ads, etc.
├── test/                         # Unit tests
└── assets/                       # Images, fonts
```

## Tech Stack

### Mobile App
- **Framework**: Flutter 3.47.8 (Dart 3.13), as pinned in `pubspec.yaml` and used in CI
- **State Management**: Provider
- **Language**: Dart
- **i18n**: English + Kiswahili
- **Theme**: Light + Dark mode with blue gradient branding

### Backend (proposed, not built)
No backend exists yet: the app stores everything on the phone. The proposed
design is in [`docs/architecture/`](docs/architecture/README.md).
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Functions
- Firebase Storage

### Admin Dashboard
- React 18 + Vite
- Tailwind CSS
- Recharts (analytics)
- Lucide React (icons)

## Features

Each feature is labelled with its real status today:

- **Working**: works as described, but only on this phone (no backend).
- **Simulated / demo-only**: looks real but uses generated or sample data.
- **Disabled / unavailable**: shown but switched off, or not offered.
- **Planned, not implemented**: proposed in
  [`docs/architecture/`](docs/architecture/README.md); no code exists.

Nothing below is production-ready.

### User App

| Feature | Status | What it actually does today |
|---|---|---|
| Email and password sign-up and login | Working (on this phone only) | Accounts are stored on the phone with an unsalted SHA-256 password hash (`lib/services/auth_service.dart`). No server, no email verification, not secure enough for real users |
| Google Sign-In | Disabled / unavailable | Shows "not available yet" (`signInWithGoogle()` only throws). The `google_sign_in` package is declared but never used |
| Password reset | Disabled / unavailable | Shows "not available yet" (`resetPassword()` only throws) |
| Home dashboard (ownership progress, ad stats) | Working, with simulated data | Shows the phone's own demo records. The cash balance shows "Not available" |
| Watch ads (60-second ads, 3 per day) | Simulated / demo-only | Five generated "Sample Ad" entries and a 60-second countdown; no ad network and no real ads. The daily limit uses the phone's clock and can be bypassed |
| Anti-cheat verification | Planned, not implemented | The app stores a "verification hash" computed on the phone with a fixed string; it provides **no** protection. Server-side verification is only proposed ([`reward-rules.md`](docs/architecture/reward-rules.md)) |
| Rewards towards a phone | Simulated / demo-only | Each simulated ad adds KSh 2.50 (a demo value) to phone-ownership progress, stored on the phone. No real value |
| Phone ownership tracking | Working, with simulated data | Choose a phone and see progress; stored on the phone only |
| Wallet and transaction history | Simulated / demo-only | Shows simulated phone-progress entries; there is no cash balance |
| Withdrawals | Disabled / unavailable | Hidden (`AppFeatures.withdrawalsEnabled = false`). No payment integration exists |
| Referral codes | Working (on this phone only) | Each account gets a code, and a code can be entered at sign-up |
| Referral bonus | Disabled / unavailable | The Referral screen says "You both earn a … bonus (demo)!", but no referral is ever recorded and no bonus is ever credited |
| Settings: dark/light mode, language (English, Kiswahili) | Working | Saved on the phone and restored at start-up |
| Settings: notifications, change password, biometric login, two-factor authentication | Disabled / unavailable | Shown and marked "Not available yet" (see [Not available yet](#not-available-yet)) |
| Edit profile | Working (on this phone only) | Saves to the phone |
| Real accounts, server-side rewards, real ads, payouts | Planned, not implemented | Proposed only; each step needs approval ([open decisions](docs/architecture/open-decisions.md)) |

### Admin Dashboard

The dashboard is a front-end prototype. **It shows hard-coded sample data, is
not connected to the app or any backend, has no sign-in, and is not
deployed.** A banner in the dashboard says "Demo data only".

| Feature | Status | What it actually does today |
|---|---|---|
| User list | Simulated / demo-only | Sample users with search |
| Verify and suspend users | Simulated / demo-only | Buttons are shown but do nothing |
| Advertiser management | Simulated / demo-only | Sample advertisers; the add form saves nothing |
| Ad upload and management | Simulated / demo-only | The upload form saves nothing |
| Withdrawal approvals | Disabled / unavailable | The page is hidden (`WITHDRAWALS_ENABLED = false` in `src/features.js`); its buttons would do nothing |
| Analytics (revenue, users, ad views) | Simulated / demo-only | Charts of sample numbers. Revenue is labelled "(demo)"; there is no real revenue |
| Fraud detection and monitoring | Simulated / demo-only | A page of sample alerts; no fraud detection runs anywhere |
| Admin sign-in, roles, audit log | Planned, not implemented | Proposed in [`operations.md`](docs/architecture/operations.md). The dashboard must not be deployed publicly before these exist |

## Setup

### Prerequisites
- Flutter SDK 3.47.8 or later (Dart 3.13), as required by `pubspec.yaml`
- Android SDK; the debug APK built in CI targets API 36 with a minimum of API 24
- Node.js (CI uses Node.js 22)

### Mobile App
```bash
cd adlease
flutter pub get
flutter run
```

### Build APK
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

> **Release builds are debug-signed.** `android/app/build.gradle` signs the
> `release` build type with the debug key (`signingConfig =
> signingConfigs.debug`). A `flutter build apk --release` output is therefore
> **not suitable for the Google Play Store or any production release**.
> Proper release signing (an upload key and Play App Signing) is future work
> that needs approval; the signing configuration has not been changed.

### Admin Dashboard
```bash
cd admin-dashboard
npm install
npm run dev     # Development
npm run build   # Production
```

### Firebase (proposed future work, requires approval)

> **Do not create or configure a Firebase project yet.** The app does not use
> Firebase today, and no Firebase project is configured for it in this
> repository. Creating Firebase or Google
> Cloud projects, adding configuration files, enabling billing (the
> pay-as-you-go Blaze plan is needed for server code), and deploying anything
> are **proposed future work that requires the project owner's explicit
> approval** before anyone starts. See
> [`docs/architecture/open-decisions.md`](docs/architecture/open-decisions.md).

Once approved, the work follows the architecture documents in
[`docs/architecture/`](docs/architecture/README.md). Two rules apply regardless:

- Do **not** deploy the draft rules in `DATABASE_SCHEMA.md`: they are unsafe.
  See [`docs/architecture/firestore-rules-review.md`](docs/architecture/firestore-rules-review.md).
- Do not commit service-account keys or other secrets
  ([`docs/architecture/operations.md`](docs/architecture/operations.md)).

## Testing
```bash
flutter test        # Run unit tests
flutter analyze     # Static analysis
```

Layout tests (`test/layout_test.dart`) render screens at 320x568, 360x640
and 393x873 with system font sizes from 100% to 200%, using the app's real
fonts (Poppins from `test/fonts/poppins`, SIL Open Font License; Roboto and
Material Icons from the Flutter SDK). Any overflow fails the test and names
the widget. To write screenshots for review:

```bash
ADLEASE_SCREENSHOT_DIR=build/screenshots flutter test test/screenshots_test.dart
```

## Brand

AdLease is the product brand. Avaru Tech Company Limited is its parent
company, credited as "Powered by Avaru" (`lib/widgets/powered_by_avaru.dart`)
on the splash screen, at the end of Settings, in the About dialog and on the
Profile screen.

- `assets/brand/avaru-logo-official.png` is a byte-for-byte copy of the
  official Avaru logo master (avaru-website repository,
  `public/brand/avaru-logo-official.png`, SHA-256
  `9031557c5f24f9a9b58d49cff211357a28143b589d70ca2b2b619d7d0a31ab47`).
  `test/brand_test.dart` fails if the file changes. Never redraw, crop,
  recolour or replace it. It is about 1 MB; a smaller, approved export of the
  same artwork can replace it later.

## Not available yet

These are visible in the app but marked "Not available yet" and disabled,
because what they need does not exist:

- Notifications (push, ad reminders, reward alerts): no notification service.
- Change password, biometric login, two-factor authentication: need a real
  authentication backend.
- Terms of Service and Privacy Policy: no AdLease documents published yet.
- Withdrawals: hidden (`AppFeatures.withdrawalsEnabled = false`).

Dark mode and language are saved on the device and restored at start-up.
Edit Profile saves to the device (local prototype storage).
