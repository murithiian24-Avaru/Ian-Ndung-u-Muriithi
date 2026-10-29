# AdLease - Watch. Earn. Own.

An innovative ad-powered phone ownership platform where users reduce or complete payment for smartphones by watching compulsory advertisements.

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
- **Framework**: Flutter 3.27.4
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

### User App
- Authentication (Email/Password, Google Sign-In)
- Home dashboard with balance, ownership progress, ad stats
- Watch Ads system (60s ads, 3/day max, anti-cheat verification)
- Wallet with transaction history and withdrawal requests
- Phone ownership tracking with progress visualization
- Referral program with unique codes
- Settings (Dark/Light mode, Language, Security)

### Admin Dashboard
- User management (view, verify, suspend)
- Advertiser management
- Ad upload and management
- Withdrawal approval system
- Analytics with charts (revenue, users, ad views)
- Fraud detection and monitoring

## Setup

### Prerequisites
- Flutter SDK 3.27+
- Android SDK 34
- Node.js 18+

### Mobile App
```bash
cd adlease
flutter pub get
flutter run
```

### Build APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Admin Dashboard
```bash
cd admin-dashboard
npm install
npm run dev     # Development
npm run build   # Production
```

### Firebase Setup
1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app with package name `com.adlease.adlease`
3. Download `google-services.json` to `android/app/`
4. Enable Authentication (Email/Password, Google)
5. Create Firestore database
6. Do **not** deploy the draft rules in `DATABASE_SCHEMA.md`: they are unsafe.
   See [`docs/architecture/firestore-rules-review.md`](docs/architecture/firestore-rules-review.md).

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
