# AdLease — Google advertising policy review pack
**Status:** Internal draft for policy clarification; not submitted to Google.  
**Product decision:** Advertising is separate from customer financing. Avaru earns advertising revenue as publisher. Users receive no cash, wallet credit, phone-balance credit, deposit offset, loan repayment credit, or other financial benefit for viewing or interacting with ads.

## 1. Purpose of this review
Request written clarification from Google AdMob policy support on the proposed AdLease advertising experience before enabling Google-served ads. This document is not an assertion of compliance or approval.

## 2. Product and party description
- Publisher / app operator: Avaru Tech Company Limited (Kenya).
- App: AdLease, an Android application intended to connect users to a third-party handset financing offer.
- Financing: A separately contracted financing partner, if approved and onboarded, will make the credit decision, contract directly with the customer, set and disclose the financing terms, own/manage the receivable and receive repayments through approved payment rails.
- Technology: Avaru supplies app, software, user-interface and agreed technical services. The final agency/outsourcing scope is subject to Kenyan legal review and the financing partner's regulatory obligations.
- Advertising: Avaru may display ordinary ads to support its own operating revenue. Ad impressions/clicks do not change a user's eligibility, handset price, deposit, instalment, outstanding balance or repayment obligation.

## 3. Proposed user journey
1. User installs and opens AdLease.
2. User sees clear disclosure that the app may display advertising and that advertising is not a way to earn money or reduce the cost of a phone.
3. Ordinary ad placements may appear in clearly identified ad spaces. They do not block core functionality or misrepresent an ad as a financing offer.
4. The user can continue using core app features without watching, clicking or interacting with an ad.
5. A financing offer, where available, is presented separately with the identity of the actual financier, eligibility criteria, total price, deposit, instalment schedule, fees, default consequences, complaints contact and contract terms.
6. Customer payments are recorded only against the financier's contract and reconciled through the authorised payment integration. Ad events are never posted to the customer ledger.

## 4. Explicit exclusions
AdLease will not:
- pay users for impressions, views, clicks, installs or ad interactions;
- issue KES 2.50 (or any other amount) per ad;
- convert ad views into cash, points redeemable for cash, phone credit, deposits, discounts, instalment reductions or loan repayment credits;
- require an ad view to access a customer's financing, account, support or essential app functions;
- describe ads as a way to pay off or earn ownership of a handset;
- imply that Google verifies, guarantees or endorses the financing product.

## 5. Questions for Google AdMob policy support
Please confirm, with reference to the current AdMob policies:
1. Is the described ordinary, non-rewarded ad placement acceptable where the app separately provides information and account access for a third-party handset-financing arrangement?
2. Are any additional disclosures, ad placement restrictions or app-category declarations required because the app includes a separate financing journey?
3. Would any proposed rewarded-ad feature be treated differently if it offered only a non-transferable, non-monetary benefit usable solely inside AdLease and had no connection to handset ownership, financing, payments or real-world goods? We will not implement such a feature unless reviewed and approved in writing.
4. What exact screenshots, app access instructions, test account details or policy declarations should accompany a review?

## 6. Attachments to prepare before contacting support
- Current app screenshots: home, every ad placement, ad close/skip state, profile, financing information, payment history and support.
- A screen recording of the complete journey, including normal use with no ad interaction.
- A one-page data-flow diagram showing ad SDK events separated from customer/financier ledgers.
- Current privacy notice, terms, ads disclosure and financing-partner disclosure (drafts clearly marked if not final).
- App package name, version, target SDK, AdMob app/ad-unit identifiers only after they exist; do not include secret keys.
- Test credentials through Google's approved secure process only; never include passwords or private credentials in this document or GitHub.

## 7. Draft support message
Subject: AdMob policy clarification — ordinary ads in a separate handset-financing app

Hello Google AdMob Policy Support,

We are preparing AdLease, an Android app published by Avaru Tech Company Limited in Kenya. We would like policy clarification before enabling Google-served ads.

Our product decision is to keep advertising entirely separate from customer financing. Avaru may earn publisher revenue from ordinary ad placements. Users will not receive cash, wallet balances, phone credits, discounts, deposits, instalment reductions or repayment credits for ad views, impressions, clicks or interactions. Ad interaction will not be required to access core app features or a financing offer.

Any handset financing will be separately offered and contracted by an appropriately authorised third-party financier. The financier will make credit decisions, set and disclose terms, manage the receivable and receive repayments. Ad events will not be posted to the customer's financing ledger.

Please advise whether this ordinary, non-rewarded advertising model is acceptable under current AdMob policies in an app that separately presents a third-party handset-financing journey, and whether additional declarations, disclosures, placement restrictions or review materials are required.

We can provide screenshots, a test build and a data-flow diagram through your approved process.

Thank you,
Avaru Tech Company Limited

## 8. Internal release gate
Do not enable production AdMob until:
- Google policy support has reviewed the accurate current app flow and any material risk has been resolved;
- the app store listing, privacy disclosures and ad placements accurately describe the product;
- SDK consent, privacy and data-sharing obligations have been reviewed for the applicable jurisdictions;
- ad SDK events are technically isolated from financing, payment and customer ledger services;
- QA confirms ads are non-blocking and never affect customer eligibility, price or repayment.

## 9. Official references
- AdMob policies for ad units that offer rewards: https://support.google.com/admob/answer/7313578
- Overview of rewarded ad units: https://support.google.com/admob/answer/7372450
- AdMob policy change log: https://support.google.com/admob/answer/9391084
- Google Play financial features declaration: https://support.google.com/googleplay/android-developer/answer/13849271

**Important:** This is a policy clarification request, not a formal certification process. Google's response may depend on the actual app, screenshots, SDK configuration, disclosures and final user journey.
