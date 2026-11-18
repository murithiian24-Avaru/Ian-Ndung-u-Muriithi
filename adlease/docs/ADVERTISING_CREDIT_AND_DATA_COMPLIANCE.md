# AdLease advertising, credit and data-protection launch gates

This document is an engineering/product risk register, not legal advice or a regulatory approval. It records the minimum evidence required before real rewards, financing, or a Kenyan pilot.

## 1. Google-served rewarded ads: current concept is not approved

The current demo concept has been described as users watching ads to accrue value toward ownership of a physical phone. Do not connect Google AdMob rewarded ads to a cash-like balance or promise that viewing ads earns money.

Google's rewarded-ad policy states:
- Direct monetary items (including cash, cryptocurrency and gift cards) cannot be offered as rewards.
- Indirect/non-monetary rewards must be redeemable only within the publisher's platform, non-transferable, and not directly convertible into cash or transferable items.
- Discounts/vouchers for physical items must not exceed 25% of the item's total value.
- The reward and required action must be clearly disclosed before the ad; users must affirmatively opt in for standard rewarded ads; skipping must not disrupt normal app use.
- The publisher is responsible for delivering rewards and must not imply Google endorses them.

Official policy: https://support.google.com/admob/answer/7313578

Engineering decision:
- Keep ad serving disabled and all reward issuance in emulator/test-only mode until an ad network has reviewed the exact proposed user journey and reward mechanics in writing.
- Do not treat a phone ownership balance, cash-out, transferable credit, deposit offset or repayment credit as automatically compliant.
- If the model changes to a non-transferable in-app-only benefit, obtain policy review for the exact implementation before enabling ads.
- A physical phone discount remains subject to the 25% cap under the cited Google policy; do not assume that a different label changes the economic substance.
- Never pay for clicks, incentivize ad interaction, or obstruct skipping.

## 2. Kenya credit / pay-as-you-go model: CBK legal review required

Kenya Law lists the Central Bank of Kenya (Non-Deposit Taking Credit Providers) Regulations, 2026 as Legal Notice No. 191 of 2026. Public legal commentary reports the 2026 regulations broaden the regulated perimeter to include asset financing, buy-now-pay-later and pay-as-you-go credit arrangements, among other non-deposit-taking credit business. The precise application to AdLease depends on the actual contracts, who provides credit, who owns the handset, who sets price/fees, who collects repayments, and whether Avaru itself carries credit risk or merely provides software/agency services.

Official legislation listing: https://kenyalaw.org/legislation/
CBK regulatory context: https://www.centralbank.go.ke/policy-procedures/legislation-and-guidelines/

Before a pilot:
- Obtain a written Kenyan legal opinion mapping each party's role (Avaru, financier/supplier, payment provider, ad network and customer).
- Confirm with counsel/CBK whether Avaru is a credit provider, credit agent, technology provider, asset financier, payment intermediary or another regulated participant.
- Confirm licensing/registration, disclosures, pricing/fees, affordability/creditworthiness, complaints, collections, credit reporting, recordkeeping and customer-protection duties.
- Execute supplier/financier contracts covering handset title, risk, deposits, repayment schedule, defaults, repossession/returns, warranties, settlement, refunds, data sharing and reconciliation.
- Do not describe M-KOPA as a partner or rely on its credit facilities until a signed agreement exists.

## 3. Data protection / ODPC

Avaru must map whether it acts as data controller, processor, or both for each processing activity. ODPC guidance says entities should assess registration obligations; exemptions are narrow and depend on the applicable criteria. The ODPC compliance page describes controller/processor roles and electronic registration.

Official ODPC compliance guidance: https://www.odpc.go.ke/data-protection-compliance/
Registration guidance: https://www.odpc.go.ke/wp-content/uploads/2024/02/ODPC-Guidance-Note-on-Registration-of-Data-Controllers-and-Data-Processors.pdf

Before collecting real identity, device, phone, financial or ad-attribution data:
- Complete a data inventory, purpose/legal-basis map, retention schedule and data-subject rights process.
- Assess ODPC controller/processor registration requirements for Avaru and relevant vendors.
- Execute processor/data-sharing agreements with Firebase/Google, ad networks, financiers and other vendors as applicable.
- Assess whether a DPIA is required, especially for profiling, financial/identity data, monitoring or large-scale processing.
- Publish accurate privacy notice and terms, obtain valid consent where required, and implement access controls, encryption, deletion/retention and breach response.
- Avoid collecting national ID or sensitive documents until the verification purpose, necessity, access controls and retention are approved.

## 4. Payments (M-PESA)

Use Safaricom Daraja sandbox only until the company has an approved use case and live business credentials. Safaricom's developer portal requires a Daraja account and sandbox app for test credentials; live activation requires business onboarding and a live Paybill/Till or other approved business setup.

Official portal: https://developer.safaricom.co.ke/
Getting started: https://developer.safaricom.co.ke/apis/GettingStarted

Never place consumer secrets, passkeys, security credentials or private keys in the Flutter app, Vercel browser variables, source control or chat. All payment initiation and callback verification must be server-side, idempotent and reconciled.

## 5. Play Store

For new Android apps and updates submitted from 31 August 2026, Google Play requires target Android 16 / API 36 or higher. This repository's release-readiness branch sets targetSdk 36; CI must validate the actual resolved SDK/toolchain before an AAB is accepted.

Official policy: https://support.google.com/googleplay/android-developer/answer/11926878

A Play Store submission also needs accurate Data safety, privacy policy, app access, ads declaration, content rating, target audience, store listing and signing. Do not claim real money, ad rewards, repayments, supplier availability or user protections that are not actually live and approved.

## 6. Go / no-go criteria

No real-user pilot or production reward/repayment launch until all are evidenced:
1. Written ad-network approval for the exact reward mechanism, or a redesigned policy-compliant non-AdMob model.
2. Kenyan legal opinion and any required CBK/other regulatory approvals.
3. ODPC compliance and vendor contracts.
4. Signed supplier/financier agreement and tested repayment/settlement/reconciliation process.
5. Security-reviewed backend, role-based admin, incident response and support process.
6. End-to-end sandbox tests and audited production readiness.
7. Approved Play Console declarations and production signing.

Until then, use synthetic test users, emulator-only rewards and a clearly labelled investor demo. No real money or customer data.
