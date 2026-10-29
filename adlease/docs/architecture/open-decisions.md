# Open decisions

> These cannot be settled by engineering alone. None of them is decided by
> this documentation. Items marked **approval** need the owner's explicit
> approval before any work that depends on them starts.

## Product

| # | Decision | Why it matters |
|---|---|---|
| P1 | Sign-in method: phone number (SMS), email, Google, or a combination | Decides which personal data is collected; SMS verification has a per-message cost |
| P2 | Whether to start fresh rather than migrate on-device demo accounts | All current on-device data is demo data; migration would carry unsafe password hashes |
| P3 | Reward amount per verified view, daily limit per user, per-device limits, accounts per device | Needed by [reward-rules.md](reward-rules.md); the demo uses KSh 2.50 and 3 per day, which were never decided as product values |
| P4 | Day boundary for limits: calendar day in East Africa Time, or rolling 24 hours | Affects fairness and support questions |
| P5 | View-session expiry window | Too short loses legitimate rewards; too long widens replay windows |
| P6 | Referral programme: whether it exists, and its reward | The app currently mentions a bonus that nothing pays; the draft schema states $5.00 |
| P7 | Which profile fields users may edit (v1 proposal: full name only) | Sets the `users` update allow-list |
| P8 | Whether AdLease is limited to Kenya | Decides whether `country` is collected |
| P9 | Who the admins are, and their roles | Admin access and reviews ([operations.md](operations.md)) |
| P10 | Final Android package name (`com.adlease.adlease` or `com.avaru.adlease`) | Must be fixed before Firebase apps and Play Console are set up; changing it later is costly |

## Advertising policy (**approval**)

| # | Decision | Why it matters |
|---|---|---|
| A1 | Written confirmation that credit towards a phone is an allowed reward under Google AdMob's rewarded-ad policies | Google's policies restrict rewards with monetary value. If this is not allowed, the reward model must change before real ads |
| A2 | AdMob account ownership and ad unit setup | Needed before any real ad integration |
| A3 | Consent for personalised ads, where required | Affects the consent flow and privacy notice |
| A4 | Publishing `app-ads.txt` on the Avaru website | Required for AdMob to serve ads to the app |

## Cost (**approval**)

| # | Decision | Why it matters |
|---|---|---|
| C1 | Creating Firebase/Google Cloud projects (development and production) | No project exists |
| C2 | A billing account and the pay-as-you-go (Blaze) plan | Cloud Functions, which all server-side reward logic needs, are not available on the no-cost Spark plan |
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
| L8 | Terms of use | Must describe rewards accurately, including that a credited view is not money |

## Uncertainties flagged in this documentation

- **Firestore location**: `africa-south1` (Johannesburg) is listed by Google
  for Firestore in Datastore mode; availability for Native mode is
  unverified.
- **Ad policy**: whether phone credit is an allowed reward is unverified (A1).
- **Legal**: all lawful bases, retention periods and registration questions
  are unverified until reviewed by a qualified adviser.
- **Provider limits and prices** were not fixed in this documentation and
  must be checked at decision time.

## Already out of scope until separately approved

Payouts and withdrawals, payment integration (for example M-Pesa), partner
integrations (for example M-KOPA) and the Avaru promotional videos.
