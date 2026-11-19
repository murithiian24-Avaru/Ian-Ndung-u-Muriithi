# AdLease implementation and release gate tracker
Approved decisions: Avaru is intended as technology/platform provider (subject to Kenyan counsel's classification); advertising revenue is separate company revenue and never customer value.
Scope: feat/adlease-separate-financing-mock-provider. No merge, deployment, production activation or pilot is authorised.

## Phase 0 — disable rewards and remove claims
- [x] App feature flags default advertising, ad rewards, live financing and live payments OFF.
- [x] Replace Ads and Watch Ad screens with non-reward informational states.
- [x] Legacy reward service refuses all claims.
- [x] Local ad-view recording refuses events; legacy stored reward values are ignored.
- [x] Server ad-session and reward callables reject; internal event helper performs no writes.
- [x] Local wallet credits/withdrawals and local ownership payment/selection reject.
- [x] Home, wallet, financing and English/Swahili copy no longer says watch ads to earn or pay for a phone.
- [x] Regression tests updated for disabled paths.
- [ ] Verify all user-facing strings and routes with complete Flutter test/build on CI.

## Phase 1 — PR #24 backend security
- [x] Review auth requirements, server-owned profile and verification state.
- [x] Review Firestore rules for client write denial to privileged collections.
- [x] Review provider-scoped idempotency and same-session replay protection in prior implementation.
- [x] Review transaction boundaries and concurrent wallet/counter updates in prior tests.
- [x] Record missing provider SSV, custom-claim lifecycle, Admin SDK and reconciliation limitations.
- [x] Remove customer reward ledger write path from this implementation branch.
- [ ] Run updated emulator tests on this branch.
- [ ] Review backend functions and rules after disabled-path change.
- [ ] Add tests for concurrent verification review and malformed input.
- [ ] Review profile field validation, email verification and status transitions end-to-end.

## Phase 2 — partner-neutral financing interface
- [x] Add provider-neutral quote, application, offer and contract snapshot models.
- [x] Add FinancingProvider interface.
- [x] Add MockFinancingProvider that returns no quotes and cannot issue real offers/contracts.
- [x] Add mock provider boundary tests.
- [x] Add a partner-neutral payment gateway contract and a no-money mock that rejects payment creation and customer payment requests.
- [ ] Add adapter contract tests and repository/service injection.
- [ ] Replace legacy sample handset catalogue with partner-sourced quote display only.
- [ ] Add customer consent/version evidence and partner reference persistence.
- [ ] No M-KOPA-specific API or commercial terms until a signed agreement exists.
- [ ] Obtain Kenyan legal opinion confirming Avaru's exact technology-provider role.

## Phase 3 — ordinary, non-rewarded advertising
- [x] Keep advertising feature flag OFF.
- [x] Keep reward and customer-financial mutation paths disabled.
- [ ] Submit accurate app flow/screenshots/data-flow to Google AdMob policy support.
- [ ] Complete ODPC/privacy and SDK consent assessment.
- [ ] Implement only ordinary non-rewarded placements after written review and owner approval.
- [ ] Test ad SDK events cannot call wallet, financing, payments or customer ledger services.
- [ ] Verify ads are labelled, non-blocking and not required for essential features.

## Phase 4 — admin security, payment sandbox and release testing
### Admin
- [x] Fail-closed dashboard entry point: all sample-data pages are unreachable until security controls exist.
- [ ] Authentication with MFA for privileged accounts.
- [ ] Server-side role-based authorization; no client-only role checks.
- [ ] Audited role grant/revocation and least-privilege roles.
- [ ] Reviewer queue and sensitive data minimisation.
- [ ] Append-only audit events, alerting, retention and export controls.
- [ ] No sample data fallback or unauthenticated public dashboard.
- [ ] Security testing before any Vercel deployment.

### Payments
- [x] Add provider-neutral payment interface and disabled mock; it cannot create intents or mark payments successful.
- [ ] Daraja sandbox application and test credentials configured locally/secret manager only.
- [ ] Server-side payment intent and callback validation.
- [ ] Provider-scoped idempotency, replay protection, amount/currency/reference validation.
- [ ] Tests for duplicate, delayed, concurrent, failed, reversed and refunded callbacks.
- [ ] Financier settlement and customer-contract reconciliation.
- [ ] No live credentials or real money until legal, partner, security and Safaricom approvals.

### Release
- [ ] Android signing keystore generated and backed up securely by owner.
- [ ] Release signing config validated without committing private key material.
- [ ] Target API and Play Console requirements rechecked at submission.
- [ ] Privacy policy, Data safety, ads declaration and financial-features declaration reviewed.
- [ ] Full Flutter tests, analysis, formatting, Android release build and small-screen UI tests pass.
- [ ] Firebase rules/emulator tests and security review pass.
- [ ] Admin build and authenticated integration tests pass.
- [ ] Play internal testing track only after explicit owner approval.
- [ ] Production deployment and Play submission require separate explicit approval.

## Non-negotiable restrictions
- No real customer data in US-region Firebase staging before cross-border transfer review.
- No production ad SDK, ad rewards, credit origination, customer payment collection or live supplier API.
- No secrets in GitHub, app code, Vercel client environment or chat.
- Keep package ID com.adlease.adlease unchanged unless separately approved.
- Keep main protected; all work remains reviewable on a separate branch.
