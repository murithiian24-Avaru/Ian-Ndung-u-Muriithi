# Open decisions

> These cannot be settled by engineering alone. None of them is decided by
> this documentation. Items marked **approval** need the owner's explicit
> approval before any work that depends on them starts.

## Product

**Approved product decision (18 Nov 2026):** ad rewards are removed; Avaru advertising revenue is separate from customer financing. Avaru is intended to provide technology services, subject to Kenyan counsel's role classification. Live advertising, financing and payments remain disabled.

| # | Decision | Why it matters |
|---|---|---|
| P1 | Sign-in method: phone number (SMS), email, Google, or a combination | Decides which personal data is collected; SMS verification has a per-message cost |
| P2 | Whether to start fresh rather than migrate on-device demo accounts | All current on-device data is demo data; migration would carry unsafe password hashes |
| P3 | Removed: no user reward for advertising activity | No ad view, click or impression creates cash, phone credit, wallet credit, discount or repayment credit |
| P4 | Ordinary advertising format and placement after Google/privacy review | Must not be required for essential features or affect financing terms |
| P5 | Advertising SDK consent and data flows | Requires ODPC/privacy review before implementation |
| P6 | Referral programme: whether it exists, and its reward | The app currently mentions a bonus that nothing pays; the draft schema states $5.00 |
| P7 | Which profile fields users may edit (v1 proposal: full name only) | Sets the `users` update allow-list |
| P8 | Whether AdLease is limited to Kenya | Decides whether `country` is collected |
| P9 | Who the admins are, and their roles | Admin access and reviews ([operations.md](operations.md)) |
| P10 | Final Android package name (`com.adlease.adlease` or `com.avaru.adlease`) | Must be fixed before Firebase apps and Play Console are set up; changing it later is costly |

## Advertising policy (**approval**)

The approved initial model is ordinary, non-rewarded ads only. No user incentive or customer financial benefit may be linked to ad activity.

| # | Decision | Why it matters |
|---|---|---|
| A1 | Written Google policy clarification for ordinary non-rewarded ad placements in an app that separately presents third-party handset financing | No user rewards are offered; obtain review of the actual app flow before enabling ads |
| A2 | AdMob account ownership and ad unit setup | Needed before any real ad integration |
| A3 | Consent for personalised ads, where required | Affects the consent flow and privacy notice |
| A4 | Publishing `app-ads.txt` on the Avaru website | Required for AdMob to serve ads to the app |

## Cost (**approval**)

| # | Decision | Why it matters |
|---|---|---|
| C1 | Production Firebase/Google Cloud environment | Staging project exists; production environment is not approved or configured |
| C2 | A billing account and the pay-as-you-go (Blaze) plan | Cloud Functions and other server-side services may require a paid billing plan; confirm current pricing and budget before any deployment |
| C3 | Budget alert amounts | Alerts notify; they do not cap spending |
| C4 | Backup retention and point-in-time recovery | Adds storage cost |
| C5 | Optional Data Access audit logs | Adds logging cost |
| C6 | SMS verification volume | Per-message cost if phone sign-in is chosen |

Prices and free quotas change; they must be checked on the providers'
official pricing pages at decision time. This documentation states no prices.

## Kenya Data Protection Act 2019 (**approval**, with legal advice)

| # | Decision | Notes |
|---|---|---|
| L1 | Whether AdLease must register with the Office of the Data Protection Commissioner (ODPC) | Registration depends on size thresholds and on sector; whether lease-to-own, credit-like or direct-marketing activity applies needs legal advice |
| L2 | Lawful basis for each data category, and the privacy notice | [data-inventory.md](data-inventory.md) contains proposals only |
| L3 | Data Protection Impact Assessment | Likely required given financial-style records, device identifiers and fraud profiling |
| L4 | Cross-border transfer safeguards | Every proposed provider stores data outside Kenya |
| L5 | Retention periods, especially for ledger records if treated as financial records | Proposed periods in [data-inventory.md](data-inventory.md) are placeholders |
| L6 | Breach-response process and owner | Breaches must be reported to the ODPC within 72 hours |
| L7 | Process for access, correction and deletion requests | Must meet the legal time limits |
| L8 | Terms of use | Must accurately describe platform services, separate advertising and financing, and the absence of ad-derived customer rewards |

## Uncertainties flagged in this documentation

- **Firestore location**: the current staging database is in the US region (`nam5`). This is a cross-border transfer and requires privacy/legal review before real data is used.
- **Ad policy**: ordinary non-rewarded ad placements in the final financing app require Google policy clarification (A1).
- **Legal**: all lawful bases, retention periods and registration questions
  are unverified until reviewed by a qualified adviser.
- **Provider limits and prices** were not fixed in this documentation and
  must be checked at decision time.

## Already out of scope until separately approved

Payouts and withdrawals, payment integration (for example M-Pesa), partner
integrations (for example M-KOPA) and the Avaru promotional videos.
