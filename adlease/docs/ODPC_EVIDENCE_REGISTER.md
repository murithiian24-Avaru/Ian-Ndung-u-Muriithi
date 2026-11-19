# AdLease — ODPC evidence register and counsel hand-off

**Status: DRAFT / NOT AN ODPC FILING / NOT LEGAL APPROVAL**  
**Prepared:** 18 November 2026  
**Project:** Avaru Tech Company Limited — AdLease staging  
**Firebase project:** `adlease-staging` (project number `268757513757`)  
**Firestore database:** `(default)`, Standard edition, `eur3` Europe multi-region  
**Use restriction:** synthetic test data only; no production users, national IDs, credit files or payment records.

This register organises the evidence Avaru and Kenyan counsel need to complete before any real-user pilot. Blank fields are intentional; do not invent a legal basis, approval, registration number or contractual safeguard.

## 1. Processing-role map — to be confirmed by Kenyan counsel

| Activity | Current/planned data | Proposed role to assess | Evidence still required |
|---|---|---|---|
| AdLease account and app support | Firebase UID, email, name, phone, country, locale, account status | Avaru may be controller for its own account/service purposes | Confirm purposes, lawful bases, retention, notice and rights process |
| Identity / verification | Not currently collecting identity documents; future verification case/status only | Avaru and any verification provider roles depend on actual decision and collection model | Define necessity, verification provider, access, retention and sensitive-data handling |
| Device catalogue / financing quote | Planned SKU, quote, application and consent references | Financier likely independent controller for underwriting/credit decisions; Avaru role must be assessed per activity | Signed financier agreement, role allocation, data-sharing schedule and CBK legal opinion |
| Handset supply / fulfilment | Planned device SKU, customer delivery and warranty records | Supplier role depends on contract and operational control | Supplier contract, data-sharing schedule and returns/warranty responsibilities |
| Cloud services | Firebase Authentication, Firestore, Cloud Functions, logs and support access | Google/Firebase processor/subprocessor roles per applicable terms | Executed DPA, service terms, subprocessor list, transfer basis and security evidence |
| Future advertising | Disabled; no ad SDK/reward activity authorised | Avaru/ad network roles depend on SDK, identifiers and measurement | Google policy review, vendor DPA, consent/notice and data minimisation |

**Do not describe Avaru as merely a processor or technology provider without checking the purposes and means Avaru actually determines.** The controller/processor role can differ by processing activity.

## 2. Current data inventory — distinguish active from planned

### Present staging configuration
- Firebase project exists, but Android Firebase app registration and FlutterFire options are not yet confirmed.
- Email/Password provider is enabled in Firebase Authentication.
- The Flutter app's main authentication provider still uses local demo storage; Firebase sign-in is not yet the app's active user journey.
- Firestore is created in `eur3`; use synthetic records only.
- The Cloud Function profile schema contains UID, email, name, phone number, country, unverified-profile flag, account status, verification status and timestamps.
- Ad serving, reward credits, live financing and live payments are disabled.
- No national ID document collection, biometric verification, credit scoring or real payment collection is authorised.

### Future / proposed data (not authorised for collection yet)
- Identity documents, KYC outcomes and verification evidence.
- Financing quotes, affordability/underwriting inputs, application and contract references.
- Device allocation, delivery, warranty and return information.
- M-PESA transaction references, settlement and reconciliation records.
- Advertising identifiers, attribution and measurement events (ordinary ads only if later approved).

For each field, counsel/DPO must record: purpose, lawful basis, data subject, source, recipients, whether sensitive, mandatory/optional status, retention period, storage location, access roles, onward transfers and deletion method.

## 3. ODPC registration assessment

The Data Protection (Registration of Data Controllers and Data Processors) Regulations, 2021 require registration subject to Regulation 13. Regulation 13(2) provides a general small-entity threshold exemption where annual turnover/revenue is below KES 5 million and the entity has fewer than 10 employees. Regulation 13(4) removes that exemption for processing purposes in the Third Schedule; the Third Schedule includes provision of financial services.

**Required counsel determination:** does any AdLease/Avaru processing activity amount to provision of financial services, direct marketing, telecommunications or another Third Schedule purpose? If yes, assess mandatory controller and/or processor registration regardless of the small-entity threshold. Record the ODPC application(s), certificates, registration numbers, renewal dates and the processing activities covered. Do not assume Avaru is exempt.

- Controller registration: [ODPC registration portal](https://dataportal.odpc.go.ke/account/Register)
- Primary regulation: [Data Protection (Registration of Data Controllers and Data Processors) Regulations, 2021](https://www.odpc.go.ke/wp-content/uploads/2024/03/THE-DATA-PROTECTION-REGISTRATION-OF-DATA-CONTROLLERS-AND-DATA-PROCESSORS-REGULATIONS-2021.pdf)

## 4. Cross-border transfer record — Firebase Europe region

ODPC's 2026 Guidance Notes state that personal data processed in cloud environments with servers outside Kenya constitutes a cross-border transfer. Avaru must not treat choosing an EU region or displaying a privacy notice as sufficient by itself.

### Transfer facts to complete
- Exporting Kenyan entity: Avaru Tech Company Limited (confirm legal identity and address).
- Importing/receiving entity: identify the correct Google/Firebase contracting entity from the applicable service terms/DPA.
- Service: Firebase Authentication / Cloud Firestore / Cloud Functions / Google Cloud logging (confirm each service's actual processing location).
- Database location: `eur3` Europe multi-region.
- Data categories transferred: complete from final data inventory; currently synthetic test data only.
- Purpose and lawful basis: counsel/DPO to determine per processing activity.
- Transfer mechanism under Data Protection Act section 48 and General Regulations: counsel/DPO to identify and document.
- Sensitive personal data: do not transfer unless section 49 requirements, including data-subject consent and confirmation of appropriate safeguards, are met.
- Contractual instrument: attach executed Google/Firebase DPA and applicable ODPC standard clauses or another legally sufficient instrument.
- Subprocessors and onward transfers: attach current vendor list and document any onward transfer restrictions.
- Security measures: document encryption in transit/at rest, MFA, least privilege, access/change logging, backup/recovery, retention and secure deletion.
- ODPC engagement/notification: counsel to confirm whether notification, prior engagement or additional approval is required for the actual transfer basis and processing.

### Transfer log template

| Date/time | Recipient entity/service | Destination | Data categories | Purpose / legal basis | Safeguard / DPA reference | Approved by |
|---|---|---|---|---|---|---|
| Not started — synthetic data only | Google/Firebase (contracting entity to confirm) | Europe multi-region (`eur3`) | Synthetic test records only | Emulator/staging validation only | Not approved for real personal data | Pending |

Before any real transfer, complete and retain the ODPC guidance's transfer record fields: date/time, recipient, justification and description of personal data transferred.

## 5. DPIA decision and draft scope

A DPIA is required before processing where an operation is likely to result in high risk to data subjects' rights and freedoms (Data Protection Act section 31). The Act also provides for prior ODPC consultation where the DPIA indicates residual high risk. ODPC's 2026 cross-border guidance specifically calls for DPIAs for high-risk cross-border cloud deployments.

Given the planned combination of identity/verification, financing-related information, device ownership and cross-border cloud processing, Avaru should commission a documented DPIA screening now and complete a full DPIA before any high-risk real-user processing if the statutory threshold is met.

DPIA evidence must include:
1. Systematic description of processing, purposes, data flows, recipients and storage locations.
2. Necessity and proportionality analysis for every data category.
3. Risk assessment for confidentiality, misuse, profiling, exclusion, identity theft, unauthorised access, cross-border access and data-subject rights.
4. Measures to mitigate risks: minimisation, role-based access, encryption, MFA, logging, retention/deletion, breach response, processor controls and user rights.
5. Residual-risk decision and ODPC consultation record if required.
6. Approval/sign-off by the accountable controller and DPO/counsel before processing starts.

**DPIA screening outcome:** Pending.  
**DPIA owner:** Pending appointment.  
**Date completed:** Not started.  
**ODPC consultation:** Not assessed / pending screening.

## 6. Required agreements and operational evidence

- [ ] Google/Firebase DPA and current subprocessor list reviewed and retained.
- [ ] Cross-border transfer legal instrument / ODPC standard clauses completed and signed where relied upon.
- [ ] Financier agreement and data-sharing schedule executed before any quote/application data is shared.
- [ ] Supplier agreement and data-sharing schedule executed before device fulfilment data is shared.
- [ ] Privacy notice identifies purposes, lawful bases, categories, recipients, transfers, retention, rights and contact details.
- [ ] Data-subject access, correction, objection, erasure, portability and complaint handling procedures tested.
- [ ] Retention schedule and deletion workflow approved and technically implemented.
- [ ] Access matrix, MFA, admin audit logging, incident response and breach escalation documented.
- [ ] DPO appointment/requirement assessment completed and contact details published/communicated where required.
- [ ] ODPC registration decision and certificate(s) attached.
- [ ] DPIA screening/full DPIA and any ODPC consultation evidence attached.
- [ ] Vendor security review and cloud configuration evidence attached.

## 7. Legal and regulatory hand-off

### CBK / credit role
The 2026 Non-Deposit Taking Credit Providers Regulations are Legal Notice No. 191 of 2026. On 12 November 2026, the National Assembly Delegated Legislation Committee directed CBK to suspend rollout and redraft contested provisions. This is not an annulment. Counsel must verify the Gazette, parliamentary proceedings, CBK notices, commencement/transitional rules and the current status immediately before launch. Avaru must not originate, approve, arrange, collect or service credit beyond its legally approved role.

### Play Store
Google Play requires an accurate Financial features declaration for apps published on Play, including testing tracks. If the app facilitates personal loans, BNPL, digital wallets, payments or other declared features, complete the applicable disclosures and provide required lender/licensing information. Store metadata must match the shipped functionality.

## 8. Sign-off register

| Review | Reviewer | Evidence/reference | Date | Status |
|---|---|---|---|---|
| Kenyan CBK/credit counsel opinion | Pending | Pending | Pending | <span>Not approved</span> |
| ODPC registration assessment | Pending | Pending | Pending | Not approved |
| DPIA screening / full DPIA | Pending | Pending | Pending | Not approved |
| Cross-border transfer assessment | Pending | Pending | Pending | Not approved |
| Google/Firebase DPA and safeguards | Pending | Pending | Pending | Not approved |
| Financier/supplier data-sharing agreements | Pending | Pending | Pending | Not approved |
| Avaru owner launch approval | Pending | Pending | Pending | Not approved |

**No-go:** Until the mandatory legal, registration, DPIA and transfer items are completed and signed by the responsible people, staging remains synthetic-data-only and no Kenyan customer pilot or production data transfer is authorised.
