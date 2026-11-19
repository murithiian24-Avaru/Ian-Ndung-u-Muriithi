# AdLease — Device access, built with technology

AdLease is a technology platform being developed to connect customers with handset options and, when available, financing from an appropriately authorised partner. Avaru Tech Company Limited is intended to provide the software platform. Advertising revenue, if enabled later, belongs to Avaru and never creates customer value.

> **Status: controlled development demo.** A Firebase Auth/Firestore emulator backend foundation exists in the backend development stream, but Firebase is not wired as the app-wide production identity provider and no production backend is deployed. Advertising, all ad rewards, customer wallet credits, financing, and payments are disabled. Do not use real customer data or money.

## Approved product decisions (18 November 2026)

1. Avaru is intended to act as a technology/platform provider. Kenyan counsel must confirm the actual legal classification and outsourcing/agency obligations.
2. Advertising is separate Avaru publisher revenue. No user receives cash, wallet credit, phone credit, discount, deposit offset or repayment credit for viewing or interacting with an ad.
3. A properly authorised financing partner must make credit decisions, set and disclose terms, contract with customers, own/manage receivables and control collections.
4. No M-KOPA or other supplier/financier partnership is confirmed unless a signed agreement exists.

## Current capability status

| Area | Current status |
|---|---|
| Flutter mobile app | Development demo; local authentication remains in the app; not production-ready |
| Firebase | Emulator-first Auth/Firestore/Functions foundation; app-wide auth integration and production deployment are incomplete |
| Advertising | Disabled. No ad SDK, ad viewing, tracking or rewards are active |
| Customer rewards | Removed from the product model. No cash, wallet, phone, discount or repayment credits for ads |
| Financing | No lender connected. No credit application, offer, contract or repayment schedule is active |
| Financing interface | Partner-neutral models/interface and a mock provider exist for development only; mock returns no quotes and cannot issue a real offer or contract |
| Wallet / withdrawals | Customer credits and withdrawals reject; no customer cash wallet is active |
| Payments | No live M-PESA or other payment collection; sandbox work remains gated |
| Admin dashboard | Prototype only; no sign-in or production backend; do not deploy publicly |
| Play Store | Not submitted. Signing, declarations, security and release checks remain outstanding |

## Repository layout

- lib/ — Flutter application, models, screens, providers and services
- functions/ — Firebase Cloud Functions development foundation
- admin-dashboard/ — React/Vite admin prototype
- test/ — Flutter tests
- docs/ — compliance, architecture, backend review and release gates

## Backend and Firebase

The Firebase emulator configuration and backend functions are for development/testing. Firebase Authentication is not yet the app-wide production identity provider. Do not deploy Cloud Functions or Firestore rules from this development branch to production.

The staging Firestore database uses the US region (nam5). Use synthetic test data only until Kenyan cross-border transfer, ODPC and privacy obligations have been reviewed and approved.

See:
- docs/FIREBASE_EMULATOR.md
- docs/FIREBASE_PROJECT_SETUP.md
- docs/PR24_BACKEND_SECURITY_REVIEW.md
- docs/TECHNOLOGY_PROVIDER_ARCHITECTURE_AND_IMPLEMENTATION_PLAN.md
- docs/IMPLEMENTATION_AND_RELEASE_GATES.md

## Advertising policy boundary

AdLease's approved initial advertising model is ordinary, non-rewarded advertising only, after Google policy and privacy review. Advertising interaction must not affect a customer's financing eligibility, handset price, deposit, instalments, balance or repayments.

The old rewarded-ad architecture document is superseded and retained only as a historical security-design record. Do not implement its reward flows.

Policy review pack: docs/GOOGLE_ADMOB_POLICY_REVIEW_PACK.md

## Financing boundary

The app may display financing information only when supplied by a verified partner integration. Avaru must not invent quotes, approve credit, set credit terms, hold repayments or represent demo data as a customer contract. The mock provider is not a lender and cannot issue real offers/contracts.

## Admin dashboard

The dashboard is a front-end prototype with no authentication and no production backend. It must not be deployed publicly or used to process real customer information. Before deployment it requires MFA, server-side role authorization, least privilege, audit logging, secure data access and security testing.

## Development commands

From the adlease directory:

```bash
flutter pub get
flutter test
flutter analyze
flutter build apk --debug
```

For backend emulator tests, from adlease/functions:

```bash
npm install
npm run test:emulator
```

For the admin prototype, from adlease/admin-dashboard:

```bash
npm install
npm run build
```

## Security and release rules

- Keep main protected. Work through reviewable pull requests.
- Never commit service-account keys, signing keystores, OAuth secrets, Daraja credentials or provider webhook secrets.
- Keep package ID com.adlease.adlease unchanged unless separately approved.
- Do not use real customer data in the current staging project.
- Do not enable production ads, financing, payments or admin access until legal, Google, ODPC, partner, security and release gates are satisfied.
- No merge, deployment, Play Store submission or pilot without explicit owner approval.

See docs/IMPLEMENTATION_AND_RELEASE_GATES.md for the full phase tracker.
