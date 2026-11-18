# AdLease technology-provider structure and GitHub implementation plan
**Decision recorded:** Avaru role = technology/platform provider (subject to Kenyan counsel's classification); advertising model = separate Avaru publisher revenue, no customer ad rewards.  
**Repository:** murithiian24-Avaru/Ian-Ndung-u-Muriithi  
**Status:** Planning and controlled implementation only. No PR merges, deployment, live ads, live payments, credit origination or pilot authorised.

## 1. Target operating model
### Avaru Tech Company Limited
- Builds and operates the AdLease software platform and customer-facing technology.
- Provides contracted technical support, application hosting, workflow orchestration and agreed reporting.
- Does not underwrite, approve, price, originate, fund, own or collect the financing receivable unless separately authorised and legally approved.
- Does not promise that advertising pays for a customer's handset.
- Receives advertising publisher revenue independently from customer financing and repayments.

### Financing partner
- Must be appropriately authorised for the activity and jurisdiction, as confirmed by counsel.
- Is named to the customer before application/contract.
- Owns the credit decision, affordability/eligibility assessment, pricing, fees, repayment schedule, credit agreement, receivable, collections and complaints relating to credit.
- Is responsible for required regulatory reporting, disclosures and customer-protection obligations, while retaining control of functions that law reserves to it.
- Contracts directly with the customer unless counsel confirms another lawful structure.

### Supplier / handset provider
- Supplies and warrants the handset under a written supply agreement.
- Confirms stock, device condition, IMEI/serial capture, delivery, returns, warranty and title-transfer mechanics.
- Does not become a financier by assumption; legal role must be assessed from the actual arrangement.

### Avaru must not assume
Calling Avaru a “technology provider” does not itself create a regulatory exemption. Actual conduct, agency, outsourcing, customer communications, control over credit decisions, handling of funds and data access determine the legal analysis. The lender's reserved functions and oversight obligations must not be delegated away by contract.

## 2. Contract and governance pack for counsel
Prepare and review:
1. Avaru–financier technology services / outsourcing agreement: scope, service levels, security, audit/access rights, subcontractors, incident notice, business continuity, data processing, exit/portability, regulator access where required, liability and change control.
2. Financier–customer credit agreement and pre-contract disclosure: financier identity, total handset cash price, financed amount, deposit, interest/fees, APR or legally required cost disclosure, instalments, due dates, late/default treatment, early settlement, cancellation/returns, repossession/device restriction rules, complaints and support.
3. Supplier–financier supply agreement: price, inventory, delivery, warranties, returns, title, risk, defective devices, reconciliation and settlement.
4. Avaru–supplier integration/services terms where needed.
5. Data processing and data-sharing agreements, controller/processor allocation, retention, security, cross-border transfer, breach support and data-subject requests.
6. Advertising/vendor terms and privacy disclosures for any ad SDK.
7. Customer-facing terms that clearly separate platform services, advertising and financing.

## 3. System boundaries and ledgers
Keep separate bounded domains:
- Advertising domain: SDK initialization, consent state, ad request/impression/click telemetry, publisher revenue reporting. No user monetary balance.
- Identity/profile domain: authentication, account status and minimum necessary profile attributes.
- Financing application domain: application reference and status; financier remains source of truth for underwriting and contract.
- Financing account domain: read-only/synchronised view of financier-issued contract, schedule, balance and payment status. No ad event can mutate this domain.
- Payments domain: server-side payment initiation/callback validation, provider-scoped idempotency, reconciliation and financier settlement.
- Audit domain: append-only business audit events, privileged action records and trace IDs.

The existing wallet/reward ledger must not be repurposed to hold ad-derived value. Any remaining demo wallet must be clearly labelled synthetic/test-only and inaccessible to production flows until its legal purpose is decided.

## 4. GitHub implementation phases
### Phase 0 — freeze unsafe behaviour and record decisions
- Disable ad reward issuance in all builds, not merely hide the button.
- Remove or clearly label KES-per-ad claims and any copy suggesting ads pay for a phone.
- Keep test reward functions emulator-only and reject client-originated reward claims.
- Add regression tests proving ad events cannot mutate wallet, financing balance, deposit or repayments.
- Add architecture decision record (ADR) and feature flags defaulting production ads/rewards/payments/credit to OFF.

### Phase 1 — inspect and harden existing backend foundation (PR #24)
- Re-run full CI and emulator tests against the latest head SHA.
- Verify provider-scoped event IDs, duplicate callback rejection, concurrent claim safety, session replay prevention, daily limits and ledger atomicity.
- Ensure no reward route is callable from a client or any unverified provider callback.
- Confirm production Firebase configuration is absent and emulator-only tests use synthetic data.
- Review Firestore rules and Admin SDK privileged paths; test least privilege.
- No production rollout from this phase.

### Phase 2 — establish financing-partner boundary
- Define partner-neutral interfaces: FinancingPartnerAdapter, FinancingApplication, FinancingAgreementSnapshot, RepaymentSchedule, PaymentInstruction, SettlementRecord and PartnerWebhookEvent.
- Partner owns underwriting and authoritative contract data; AdLease stores partner reference IDs and minimum necessary display snapshots.
- Sign and verify webhook events server-side, with provider-specific secrets held only in server secret storage.
- Enforce idempotency, replay protection, event ordering, reconciliation and audit trails.
- Do not hard-code M-KOPA APIs or imply an agreement exists. Use a mock partner adapter until a signed partner agreement and technical specification exist.

### Phase 3 — payments and reconciliation (sandbox only)
- Use Safaricom Daraja sandbox only after approved test credentials are configured securely.
- Keep payment initiation and callback validation server-side.
- Use a separate payment transaction ledger; reconcile payment provider reference, customer contract, financier settlement and reversals.
- Do not treat an app callback or client success screen as proof of payment.
- Live credentials and production activation remain blocked pending legal, partner, security and Safaricom onboarding approvals.

### Phase 4 — advertising isolation
- Start with ordinary non-rewarded ads only, after policy and privacy review.
- Ad SDK adapter emits advertising telemetry only; it has no dependency on wallet, loan, financing or payments modules.
- No per-user reward callback, balance credit or financial side effect.
- Add automated tests that fail if ad events call wallet/payment/financing mutation functions.
- Keep production ad flag OFF until Google review and privacy checks are complete.

### Phase 5 — identity, privacy and admin
- Decide identity assurance and KYC responsibility with the financier; do not independently collect IDs by default.
- Document Avaru and partner controller/processor roles for each data flow.
- Assess ODPC registration, DPIA, lawful bases, data minimisation, retention, data-subject rights and cross-border transfer safeguards.
- Admin dashboard requires server-side authentication, role-based authorization, MFA for privileged roles, least privilege, audit logs and no sample-data fallback in production.
- No public Vercel deployment until those controls and security testing pass.

### Phase 6 — release and pilot gates
- Complete legal classification and written counsel opinion; obtain any required CBK/other approvals.
- Execute financier and supplier contracts.
- Complete ODPC and vendor privacy requirements.
- Complete security review, threat model, penetration test, incident response and support readiness.
- Complete sandbox end-to-end tests and financial reconciliation.
- Complete Play Console financial-features declaration, Data safety, privacy policy, ads declaration, store listing and signing.
- Obtain explicit owner approval for each production activation, deployment and pilot.

## 5. Required engineering invariants
1. Ad impressions, clicks and completions never create or alter a customer financial balance.
2. Financing terms and repayment obligations come only from the contracted financier's authoritative system.
3. No client can approve identity verification, approve credit, issue rewards or mark a payment successful.
4. Every external callback is authenticated, provider-scoped, idempotent and replay-protected.
5. Financial mutations are transactional, auditable and reconcilable.
6. Admin privileges are enforced server-side; hiding UI controls is not authorization.
7. Production flags default OFF and cannot be enabled by a client.
8. Test/demo balances and identities are visibly synthetic and never mixed with production data.
9. No real customer personal data in the current Firebase staging project until cross-border/data protection review is complete; use synthetic test data only.
10. No public admin deployment while authentication and authorization are incomplete.

## 6. Current PR landscape (18 Nov 2026)
- #23 security hardening — open draft; review and CI still required.
- #24 Firebase emulator backend foundation — open draft; verify latest CI and all recent concurrency/idempotency tests.
- #25 admin/Vercel deployment readiness — open draft; dashboard remains prototype, no deployment.
- #26 Play Store signing readiness — open draft; local keystore and AAB not created/uploaded.
- #27 advertising/credit/data compliance — open draft; this plan and policy pack extend its documentation.
All PRs remain unmerged. Keep main protected. Do not merge or deploy without explicit owner approval.

## 7. Immediate next technical work
1. Update PR #27 documentation with the approved business decisions and this policy pack.
2. Create one tracked GitHub issue for Phase 0 and Phase 1 acceptance criteria; keep it unassigned unless the owner chooses an assignee.
3. Run/review CI on #23–#27 and report exact status per latest head SHA.
4. Inspect PR #24 code paths for any ad-to-wallet or client-triggered reward route and close gaps on a separate reviewed branch.
5. Implement the feature-off and no-ad-financial-side-effect tests before any ad SDK work.
6. Only after the legal/business model and contracts are validated, implement the partner-neutral financing adapter.

## 8. Decisions still requiring evidence
- Written Kenyan legal opinion on whether Avaru's exact role is purely technical or constitutes agency, outsourcing, arranging, payment handling or another regulated activity.
- Confirmation of financier authorisation and allocation of reserved functions.
- Whether any CBK approval, notification or registration applies to Avaru's outsourced technology role.
- Financier and handset supplier identity and signed agreements.
- ODPC controller/processor mapping, registration and DPIA outcome.
- Google AdMob policy response for the actual ordinary-ad implementation.
- Firebase region/cross-border transfer assessment before any real personal data is used.

## 9. References
- Google AdMob rewarded-ad policy: https://support.google.com/admob/answer/7313578
- Kenya Law legislation index (Legal Notice 191 of 2026 listing): https://kenyalaw.org/legislation/
- CBK Act: https://www.centralbank.go.ke/wp-content/uploads/2026/03/Central-Bank-of-Kenya-Act.pdf
- CBK legislation and guidelines: https://www.centralbank.go.ke/policy-procedures/legislation-and-guidelines/
- ODPC compliance: https://www.odpc.go.ke/data-protection-compliance/
- Google Play financial features declaration: https://support.google.com/googleplay/android-developer/answer/13849271

**This plan is an engineering/business operating proposal, not legal advice, a CBK determination, a Google approval or permission to launch.**
