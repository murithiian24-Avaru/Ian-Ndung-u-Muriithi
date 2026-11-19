# AdLease — Google Play release checklist

**Status: NOT READY FOR SUBMISSION.** This checklist is a release control, not evidence of approval. The current app is a development demo: Firebase production authentication, live financing, payments and advertising are not active.

## A. Product and legal go/no-go

- [ ] Kenyan counsel has reviewed Avaru's exact role and the financing arrangement against the current Gazette and CBK requirements.
- [ ] Any financing partner is authorised for the relevant activity and a signed supplier/financier agreement exists.
- [ ] Financier identity, cash price, deposit, total payable, fees, instalments, default/returns, complaints and contract terms are disclosed accurately.
- [ ] ODPC registration assessment, controller/processor mapping, DPIA decision, lawful bases, retention, data-subject rights and cross-border transfer safeguards are documented.
- [ ] Google advertising policy clarification and privacy review are complete before any production ad SDK is enabled.
- [ ] No ad impression, view, click or completion creates cash, wallet credit, phone credit, discount, deposit offset or repayment credit.
- [ ] No M-KOPA, Safaricom or Google partnership/approval is claimed without written evidence.

## B. Android application identity and build

- [ ] Confirm application ID remains `com.adlease.adlease`; changing it creates a different Play app identity.
- [ ] Confirm `versionCode` is strictly greater than the last uploaded release and `versionName` is intentional.
- [ ] Confirm `minSdk`, target SDK and compile SDK from the final generated artifact. The current project target is API 36; verify current Play requirements at submission.
- [ ] Run `flutter analyze`, the full Flutter test suite, Dart format check and Android release build on the exact release commit.
- [ ] Run physical-device QA across supported Android versions, screen sizes, font scales, network conditions, app upgrade and reinstall.
- [ ] Verify app launch, login/account recovery, logout, settings, accessibility, offline/error states and all navigation paths.
- [ ] Verify no placeholder catalogue, fake balances, fake payment state, sample advertiser or unimplemented control is presented as live functionality.

## C. Signing and artifact integrity

- [ ] Generate a unique upload keystore locally using the release signing guide.
- [ ] Store the keystore and strong passwords in a password manager and secure offline backup.
- [ ] Keep `android/key.properties`, `.jks` and `.keystore` files out of Git, chat, email, Vercel and build logs.
- [ ] Verify the release task fails closed if the key properties or keystore are missing.
- [ ] Build the release Android App Bundle: `flutter build appbundle --release`.
- [ ] Verify the output is `build/app/outputs/bundle/release/app-release.aab`.
- [ ] Verify the AAB is signed with the intended upload certificate, not the Android debug certificate; record the SHA-256 certificate fingerprint securely.
- [ ] Enable Play App Signing in Play Console and preserve the upload-key backup.
- [ ] Keep the exact source commit, build logs, AAB checksum and signing certificate fingerprint in the release record.

## D. Firebase, backend and operations

- [ ] Replace emulator-only Firebase bootstrap with reviewed staging/production configuration; emulator endpoints are never present in release builds.
- [ ] Complete end-to-end authentication, email verification, password reset and account lifecycle tests.
- [ ] Firestore rules and Cloud Functions have passed emulator security tests and independent review.
- [ ] Reviewer/admin MFA, server-side role authorization, audited role grant/revoke, session revocation and alerting are implemented before operational admin access.
- [ ] Payment sandbox, callback authentication, provider-scoped idempotency, reversals/refunds and reconciliation are tested before payment features are declared live.
- [ ] No production credentials, service-account keys, Daraja secrets or private signing material are embedded in the app or browser bundle.
- [ ] Incident response, support ownership, backups, monitoring, retention and account deletion procedures are ready.

## E. Play Console declarations and store listing

- [ ] Create the app under the Avaru-owned Play Console account.
- [ ] Complete the store listing: app name, short/full descriptions, icon, feature graphic, screenshots and support contact.
- [ ] Publish an accurate public privacy policy URL and ensure the in-app privacy link works.
- [ ] Complete the Data safety form based on actual SDK and backend data flows, including third-party sharing and retention.
- [ ] Complete the Financial features declaration accurately for any financing, loan facilitation, BNPL, mobile payment, wallet or reward functionality actually exposed.
- [ ] Complete the Ads declaration accurately for the shipped app; do not claim no ads if ads are present.
- [ ] Complete content rating, target audience/children declarations and app access instructions.
- [ ] Provide reviewer credentials and instructions through Play Console's approved secure process if access is restricted.
- [ ] Ensure store copy does not promise ad-funded phone ownership, guaranteed credit, guaranteed approval or unverified partner relationships.

## F. Testing and staged rollout

- [ ] Upload first to Internal testing and install from the Play testing track.
- [ ] Test upgrade from the previous version, fresh install, account recovery and uninstall/reinstall.
- [ ] Resolve all crashes, ANRs, policy warnings, accessibility issues and critical defects.
- [ ] Complete any required closed-testing period and tester criteria shown in the Play Console for this developer account.
- [ ] Review pre-launch report, device compatibility and Android vitals.
- [ ] Obtain written owner approval for production rollout.
- [ ] Start with a controlled staged rollout and monitor crashes, ANRs, support tickets, security alerts and privacy requests.
- [ ] Have a tested rollback/stop-release procedure.

## G. Release record

Record before submission:

- Release version / version code:
- Git commit SHA:
- AAB SHA-256:
- Upload certificate SHA-256:
- Play testing track:
- Privacy policy URL:
- Data safety reviewed by / date:
- Financial features declaration reviewed by / date:
- Ads declaration reviewed by / date:
- Legal and partner approvals reference:
- Owner production approval reference:

**No-go rule:** If any mandatory item above is incomplete, do not submit or roll out the app. A successful debug build or green CI run alone does not make AdLease Play Store-ready.
