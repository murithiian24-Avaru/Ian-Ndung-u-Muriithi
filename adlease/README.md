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

### Backend (Firebase-ready)
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
6. Deploy security rules from `DATABASE_SCHEMA.md`

## Testing
```bash
flutter test        # Run unit tests
flutter analyze     # Static analysis
```
