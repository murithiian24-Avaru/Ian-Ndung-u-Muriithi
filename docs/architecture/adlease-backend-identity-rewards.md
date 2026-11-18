# AdLease Backend Architecture — Identity, Verification and Reward Ledger

**Status:** Proposed design / not deployed  
**Scope:** First secure pilot; 1,000-user target is a planning target, not current usage  
**Decision principle:** The Android client is untrusted. Identity, verification, eligibility, daily limits, rewards, phone ownership progress, admin authority and payment state are controlled by the backend.

## 1. Recommended first backend

Use Firebase for the first pilot, subject to a security review and configuration review:

- Firebase Authentication: email/password with verified-email requirement; Google sign-in only after real provider configuration. Never create a demo identity fallback.
- Cloud Functions (2nd gen) with TypeScript: callable/HTTP endpoints for privileged workflows; service account least privilege.
- Firestore: transactional state, immutable ledger and audit records.
- App Check: enable and enforce after staged rollout; treat as abuse signal, not proof of user identity.
- Firebase Storage: partner-approved ad creatives and product images; no user evidence stored without a defined purpose/retention policy.
- Cloud Monitoring/Logging: alerts on abuse, errors, payout/repayment reconciliation and admin actions.
- Secrets: Secret Manager; never commit provider secrets or private keys.

Do not use client-side writes to authoritative collections. Firebase rules must deny writes to all server-owned state; Cloud Functions use service privileges and validate every request.

## 2. Identity and account state

### Authentication
- Firebase Auth UID is the canonical user ID; never trust a client-supplied UID to identify the caller.
- Email/password: require verified email before sensitive actions; enforce password reset through provider-managed flow.
- Google: real OAuth provider and verified ID token only; unavailable until setup and test complete.
- Normalize email for display/duplicate checks but let Auth provider own identity uniqueness.
- Sign-out clears client session data; sensitive operations require fresh auth when appropriate.

### Account status
Store server-managed status in `users/{uid}`:
- `status`: `pending`, `active`, `suspended`, `closed`
- `emailVerifiedAt`, `createdAt`, `updatedAt`
- `verificationStatus`: `not_started`, `pending`, `approved`, `rejected`
- `verificationMethod`, `verificationReviewedAt`, reviewer ID and reason (restricted)
- `riskFlags` (restricted; never expose details that help bypass checks)

Clients may update only an allowlisted profile subset (name, locale, optional user-editable contact fields subject to validation). Clients cannot set status, verification, referrals, device identifiers, reward balance, eligibility, phone ownership, repayment, admin roles, timestamps, or risk flags.

### Verification workflow
1. Authenticated user requests verification; backend creates a verification case with server ID and status pending.
2. Collect only evidence required for the chosen method and disclose retention/processing. Avoid storing raw ID documents unless legally and operationally necessary; prefer a vetted verification provider.
3. Reviewer/provider callback uses authenticated server-to-server channel, signature verification and replay protection.
4. Function validates case state and reviewer/provider authority, writes an immutable decision record and updates status in a transaction.
5. Repeated callback/request is idempotent. Users cannot approve themselves. Admin changes require elevated claims and audit event.

Do not use a local hash or device flag as evidence of verification.

## 3. Data model (Firestore)

| Collection | Purpose | Write authority |
|---|---|---|
| `users/{uid}` | Profile and server-controlled account state | Functions; profile allowlist via rules if needed |
| `verificationCases/{caseId}` | Verification requests and workflow state | Functions only |
| `verificationDecisions/{decisionId}` | Append-only decisions and evidence reference | Functions only |
| `adSessions/{sessionId}` | Server-issued ad session, provider/creative, start/expiry, state | Functions only |
| `rewardLedger/{entryId}` | Append-only signed/validated earning, reversal, adjustment | Functions only |
| `rewardClaims/{claimId}` | Idempotency key, status, ad-session reference and provider event ID | Functions only |
| `wallets/{uid}` | Derived balance/cache and sequence/version | Functions only; rebuildable |
| `ownershipPlans/{planId}` | Phone SKU, customer quote, supplier, terms, deposit/repayment schedule | Functions only |
| `ownershipLedger/{entryId}` | Append-only allocation, repayment, reversal, settlement | Functions only |
| `paymentEvents/{eventId}` | Provider payment callbacks and reconciliation metadata | Functions only |
| `adminAudit/{eventId}` | Actor, action, target, reason, before/after summary, timestamp | Functions only |
| `riskEvents/{eventId}` | Rate limits, duplicate events, suspicious activity | Functions only |

Use server timestamps, stable IDs, explicit schema/version fields, currency (KES), integer minor units for money (e.g. cents), and never floating-point money. The balance document is a projection of ledger entries, not the source of truth.

## 4. Reward flow — server-authoritative and idempotent

1. Client requests `startAdSession`. Function verifies auth, active/verified eligibility (as required by pilot rules), daily limit, risk checks and policy-approved ad partner. Creates random session ID, server time, expiry and state `issued`.
2. Client launches approved ad placement with provider-supported reward mechanism. The client completion callback is only UX and cannot credit funds.
3. Partner server-side verification (SSV/webhook) arrives. Function authenticates signature, checks timestamp/nonce, provider event ID, session, user, placement, completion, expiry and reward rule.
4. In a Firestore transaction, claim provider event/session exactly once; check daily limit again using server time; write immutable ledger entry; update balance projection and session/claim state. Transaction retries must not double-credit.
5. Repeated event/callback returns prior outcome. Invalid, late, duplicate, or unverified events do not credit. Reversal is a new ledger entry linked to original; never delete/edit ledger rows.
6. Nightly/periodic reconciliation compares provider events, ledger, wallet projections and limit counts; alerts on mismatch.

**Idempotency:** Unique provider event ID plus session ID; enforce uniqueness with deterministic document IDs and transaction. A unique client request key is useful for request retries but is not proof of ad completion.

**Daily cap:** Determine day boundary in `Africa/Nairobi` on server. Count accepted reward entries (or maintain transactionally protected day counters). Client clock never decides eligibility.

## 5. Ledger invariants

- Each entry has immutable ID, UID, event type, amount in integer minor units, currency, source ID, idempotency key, server timestamp, policy/rule version, and metadata.
- Only trusted functions can append; no client create/update/delete.
- Earn, reversal, manual correction, ownership allocation, payment, repayment and settlement are distinct types.
- Corrections append reversal/correction entries referencing originals. Never overwrite history.
- Wallet balance equals sum of valid ledger entries (projection must be rebuildable and periodically reconciled).
- Enforce non-negative available balance and no double-spend in transactions.
- A reward claim and its ledger entry must be transactionally linked.
- Admin adjustment requires reason, authorized role, dual approval above a configurable threshold, and audit event.

## 6. Admin and least privilege

Use custom claims/roles: `support_readonly`, `verification_reviewer`, `finance_operator`, `risk_analyst`, `admin`. Separate privileges; no role granted by client or profile. Require MFA for privileged accounts and recent-auth for sensitive actions. Admin actions must be logged with actor, reason, target and change. Avoid broad admin dashboard access to secrets or ID evidence. Test rules with emulator and deny-by-default.

## 7. Payments and phone ownership

- No M-PESA or supplier integration until terms, pricing, financing/credit, ownership transfer, default, refunds and customer support are documented and reviewed.
- Payment callback verification must use provider signatures, event IDs, reconciliation and idempotent processing. A client success screen is never proof of payment.
- Ownership plan is bound to an approved customer quote and SKU; price/terms cannot be edited by client after acceptance.
- Repayment and ownership progress are server-calculated from payment/reward allocation ledger; legal ownership transfer occurs only at the defined contract milestone and is documented.
- Do not describe AdLease as credit/lending until legal and partner structure has been reviewed for Kenya.

## 8. Abuse controls and monitoring

- Rate-limit signup, verification requests, ad sessions, reward claims, password/reset and payment initiation.
- Device signals and App Check help detect abuse but must not be sole identity/verification authority; plan for false positives and appeal.
- Monitor duplicate event IDs, impossible session timing, repeated account/device patterns, unusually high claim rates, failed verification, ledger/balance mismatch, webhook failures, admin changes, provider outages.
- Alerts: reward mismatch, suspected replay, limit bypass, elevated auth failures, provider callback failure, unapproved admin activity, payment reconciliation discrepancy.
- Keep operational runbook: incident owner, freeze rewards/payouts, preserve logs, notify affected users/partners, investigate and append corrections.

## 9. Policy and compliance gate

Advertising partner and reward mechanic are **not approved**. Do not implement or activate rewarded ads until written partner/policy confirmation that the AdLease incentive (progress toward physical phone ownership) is allowed and the exact reward structure meets policy. This may require a non-AdMob partner or a different mechanic. Counsel/privacy review must cover Kenya consumer protection, data protection, financing/credit characterization, KYC/verification, terms, consent, retention, deletion, support, complaints, age eligibility, and supplier contracts.

## 10. Implementation sequence

1. Firebase project/security baseline, separate dev/staging/prod, billing alerts and secrets.
2. Auth integration (email verification/reset, real Google provider) and account state migration.
3. Verification case API + reviewer/admin roles + rules tests.
4. Reward-session API, provider SSV adapter and idempotent ledger in emulator; provider remains disabled until policy gate.
5. Wallet projection, reconciliation and fraud/risk monitoring.
6. Phone catalogue/quotes/ownership plan and supplier terms.
7. Payment integration sandbox, signed callbacks and reconciliation.
8. Security review, privacy/terms, operational runbooks, closed pilot gates.
9. Pilot with explicit cohort, limits, incident response and analytics; expand only after measured outcomes.

## 11. Pilot launch gates (must all pass)

- [ ] No client writes to authoritative state; Firestore rules tested deny-by-default.
- [ ] Auth flows work and no demo/fallback identity remains.
- [ ] Verification decisions only via protected server/provider workflow.
- [ ] Rewards require validated server callback; idempotency/replay tests pass.
- [ ] Daily cap tested across time zones, day rollover and concurrency.
- [ ] Ledger and wallet projection reconcile; no negative/double-spend.
- [ ] Admin MFA, role separation, audit logs and incident controls.
- [ ] Partner/ad reward policy confirmed in writing.
- [ ] Supplier/payment terms and ownership milestone documented.
- [ ] Privacy notice, terms, consent, retention, support and complaint handling reviewed.
- [ ] Monitoring, alerts, backups and rollback/freeze tested.
- [ ] Closed-pilot test plan and success/failure criteria approved.
