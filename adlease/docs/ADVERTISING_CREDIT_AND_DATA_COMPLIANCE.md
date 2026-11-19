# AdLease advertising, credit and data-protection launch gates

**Approved product decisions (18 Nov 2026):**
- Avaru role: technology/platform provider, subject to written Kenyan legal classification.
- Advertising model: separate publisher revenue for Avaru; no ad-derived customer reward, wallet credit, phone balance, deposit offset or repayment credit.
- No merge, deployment, live ads, live payments, credit origination or pilot is authorised by these decisions.

This document is an engineering/product risk register, not legal advice or regulatory approval.

## 1. Google-served advertising: separate, non-rewarded model
AdLease's initial advertising design is ordinary non-rewarded advertising. Avaru earns publisher revenue; the user receives no financial or other reward for viewing, clicking or interacting with ads. Ad events must not mutate customer wallet, handset price, deposit, instalment, financing balance or repayment status.

Google's rewarded-ad policy states:
- Direct monetary items (including cash, cryptocurrency and gift cards) cannot be offered as rewards.
- Indirect/non-monetary rewards are limited to qualifying non-transferable benefits redeemable only within the publisher's platform, website or app.
- Discounts/vouchers for physical items must not exceed 25% of the item's total value.
- Required actions and rewards must be clearly disclosed; standard rewarded ads require affirmative opt-in; skipping must not disrupt normal app use.
- The publisher is responsible for rewards and must not imply Google endorses them.

Official policy: https://support.google.com/admob/answer/7313578

Engineering requirements:
- Do not implement KES-per-ad, phone credit, loan repayment credit or any ad-linked customer financial benefit.
- Do not add rewarded ads to the first release. Any future rewarded feature requires a separate product decision and written policy review of the exact flow.
- Do not treat changing the label to points as a compliance solution.
- Ad SDK integration must be isolated from financing, wallet and payment domains.
- Keep production ads disabled until policy, privacy and QA gates pass.

## 2. Kenya credit / pay-as-you-go model: counsel classification required
Kenya Law lists the Central Bank of Kenya (Non-Deposit Taking Credit Providers) Regulations, 2026 as Legal Notice No. 191 of 2026. The CBK Act's definition of non-deposit-taking credit business includes asset financing and certain pay-as-you-go arrangements. Public legal commentary describes the 2026 framework as covering asset financing, BNPL and PAYG models. The exact current legal status, operative text, transitional provisions and any subsequent parliamentary/CBK directions must be checked by Kenyan counsel against the Gazette before launch.

**Material status update (18 November 2026):** On 12 November 2026, the National Assembly Delegated Legislation Committee directed CBK to suspend rollout and redraft contested provisions. This committee direction is not itself an annulment. A 16 November 2026 legal update reports that the Regulations remain in force unless and until Parliament annuls them or CBK amends/revokes them, and that the 29 March 2027 transition deadline had not been moved as at that update. Do not rely on a general statement that implementation is paused as permission to conduct credit business without any required authorisation. Kenyan counsel must verify the Gazette, parliamentary proceedings, CBK notices and any written forbearance immediately before launch. Reference: https://bowmanslaw.com/insights/kenya-paused-rollout-of-the-non-deposit-taking-credit-provider-regulations-what-lenders-need-to-know-now/

Official legislation listing: https://kenyalaw.org/legislation/
CBK Act: https://www.centralbank.go.ke/wp-content/uploads/2026/03/Central-Bank-of-Kenya-Act.pdf
CBK regulatory context: https://www.centralbank.go.ke/policy-procedures/legislation-and-guidelines/

Target operating model:
- A properly authorised financing partner contracts directly with the customer, performs underwriting/affordability assessment, sets and discloses credit terms, owns/manages the receivable, and controls collections and credit complaints.
- Avaru supplies contracted software/platform services only, without taking credit risk, setting credit terms, approving credit, holding repayments or owning the receivable, unless separately authorised and legally approved.
- Supplier supplies handset and manages agreed warranty, inventory, returns and title obligations.
- Advertising revenue is entirely separate from the financing contract and repayment ledger.

Important: describing Avaru as a technology provider does not itself establish an exemption. Actual conduct, agency, outsourcing, control over reserved functions, payment handling, customer communications and data access determine legal treatment.

Before a pilot:
- Obtain written Kenyan legal opinion mapping every party's activities and whether Avaru is a technology provider, agent, outsourced service provider, credit arranger, payment intermediary or otherwise regulated.
- Verify financier authorisation and any CBK approval/notification/registration requirements for outsourced technology.
- Confirm current Gazette text, commencement, transition and any subsequent parliamentary or CBK directions.
- Execute technology/outsourcing, financier-customer and supplier agreements covering regulatory access, reserved functions, audit, security, complaints, service continuity, title, pricing, repayment, default, returns, warranties, settlement and refunds.
- Do not describe M-KOPA as a partner or rely on its facilities until a signed agreement exists.

## 3. Data protection / ODPC

**Applicable official materials reviewed (18 Nov 2026):**
- Data Protection Act, 2019, including sections 18, 25, 28–32, 39–43 and 48–50.
- Data Protection (Registration of Data Controllers and Data Processors) Regulations, 2021, Legal Notice No. 265.
- ODPC Guidance Notes for Cross-border Data Transfers (2026).

### Registration decision
Avaru must map controller/processor roles per processing activity, not simply assign one label to the whole company. Regulation 4 requires controllers/processors to register subject to the Regulation 13 exemption. Regulation 13(2) gives a general exemption for entities below KES 5 million annual turnover/revenue and with fewer than 10 employees, but Regulation 13(4) removes that exemption for processing purposes in the Third Schedule. The Third Schedule includes provision of financial services. Therefore, if counsel determines that an Avaru processing activity is provision of financial services, the small-entity exemption does not apply to that activity. Obtain a written registration determination for Avaru as controller and/or processor before any real-user pilot; do not assume the company is exempt because it is small.

### US Firebase / cloud transfer gate
The user's existing staging Firestore database is configured in `eur3` (Europe multiregion), not a Kenya region. This is still a cross-border transfer for Kenyan data subjects and requires the section 48/49 and ODPC safeguards described below. ODPC's 2026 cross-border guidance states that personal data processed in cloud environments with servers outside Kenya constitutes a cross-border transfer. It expects a lawful basis and a valid transfer route under the Act, provider due diligence, a DPA, review of subprocessors, documented rights handling, retention/deletion controls and evidence of safeguards before transfer. Section 48 transfer routes must be assessed; consent is not a universal substitute for the other statutory requirements. Sensitive personal data transferred outside Kenya additionally requires data-subject consent and confirmation of appropriate safeguards under section 49.

Before moving any Kenyan personal data to this US Firebase environment:
- Identify the exporting and receiving entities, data categories, purpose, legal basis, destination, subprocessors and onward transfers.
- Select and document the applicable section 48 transfer basis and legal instrument/safeguards; confirm whether ODPC notification or prior engagement is required for the specific arrangement.
- Execute and retain the Firebase/Google DPA and applicable ODPC standard clauses or another legally sufficient instrument; record audit rights, breach notification, data-subject rights, onward-transfer restrictions and deletion/return obligations.
- Complete the DPIA before processing where the operation is likely to create high risk. If the DPIA indicates residual high risk, obtain the required ODPC consultation before processing. ODPC guidance also calls for DPIAs for high-risk cross-border cloud deployments.
- Maintain the transfer register required by the ODPC guidance: date/time, recipient, justification and description of data transferred.
- Verify encryption in transit/at rest, MFA, least privilege, retained access/change logs, backup and recovery, retention automation and provider/subprocessor changes.
- Use synthetic data only until the above is documented and approved. Do not upload real national IDs, phone lists, financial records or identity documents to the US staging project.

### Other required privacy controls
- Complete a data inventory, purpose/legal-basis map, retention schedule and data-subject rights process.
- Execute data processing and sharing agreements with each financier, supplier, Firebase/Google, ad network and other vendor as applicable.
- Assess DPIA requirements for profiling, credit-related/identity data, monitoring and large-scale processing.
- Publish accurate privacy notices and terms before collection; implement access controls, encryption, retention/deletion and breach response.
- Avoid collecting national ID documents until necessity, lawful basis, access, cross-border route and retention are approved.

Official sources:
- ODPC 2026 Cross-border Data Transfer Guidance: https://odpc.go.ke/wp-content/uploads/2026/09/ODPC-%E2%80%93-Guidance-Notes-for-Cross-border-Data-Transfers.pdf
- Data Protection Act, 2019: https://new.kenyalaw.org/akn/ke/act/2019/24/eng%402022-12-31/source
- Registration Regulations, 2021: https://www.odpc.go.ke/wp-content/uploads/2024/03/THE-DATA-PROTECTION-REGISTRATION-OF-DATA-CONTROLLERS-AND-DATA-PROCESSORS-REGULATIONS-2021.pdf
- ODPC registration portal: https://dataportal.odpc.go.ke/account/Register

## 4. Payments (M-PESA)
Use Safaricom Daraja sandbox only after an approved test use case and secure test credentials are configured. Payment initiation and callback verification must be server-side, provider-scoped, idempotent and reconciled. Never put secrets in Flutter, Vercel browser variables, source control or chat.

Official portal: https://developer.safaricom.co.ke/

## 5. Play Store
Google Play financial-features declaration includes loan facilitation, mobile payments/digital wallets, rewards/incentives and BNPL categories where applicable. Complete the declaration accurately for the actual shipped functionality; do not declare the app as having no financial features if the app exposes financing or payment features.

Financial features declaration: https://support.google.com/googleplay/android-developer/answer/13849271

For new apps and updates submitted from 31 August 2026, Google Play requires target Android 16 / API 36 or higher. Verify the actual build/toolchain and Play Console requirements at submission.

## 6. Go / no-go criteria
No production ads, live financing, payment collection or Kenyan pilot until:
1. Google policy and privacy review for the actual advertising flow is complete.
2. Kenyan counsel provides written role classification and confirms required CBK/other approvals.
3. Financier authorisation and signed supplier/financier contracts are verified.
4. ODPC compliance, cross-border safeguards and vendor agreements are complete.
5. Backend, admin roles, audit, incident response and security tests pass.
6. Sandbox payment, settlement, refund and reconciliation tests pass.
7. Play Console declarations, privacy policy, Data safety and release signing are accurate and reviewed.
8. Owner explicitly approves each production activation, deployment and pilot.

Until then, use synthetic users, emulator-only tests and a clearly labelled demo. No real customer data or money.
