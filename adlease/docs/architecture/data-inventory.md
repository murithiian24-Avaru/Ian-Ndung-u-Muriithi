# Personal data inventory

> Status: **proposed**. Lawful bases and retention periods below are
> engineering proposals, **not legal advice**. They must be confirmed by a
> qualified Kenyan data-protection adviser before launch (see
> [open-decisions.md](open-decisions.md)).

AdLease is subject to the Kenya Data Protection Act, 2019. Every category
below needs a documented purpose and lawful basis, a retention period, and a
way for the user to access, correct and delete it.

## Minimisation rules (apply to every category)

1. **MUST** collect only what a listed purpose needs. A field with no purpose
   is not collected.
2. **MUST NOT** collect national ID numbers, exact location, contacts, call
   logs, SMS content, photos or the device's list of installed apps.
3. **MUST NOT** store payment details until payouts are separately approved.
   The draft `withdrawals.paymentDetails` field stays unused.
4. **MUST NOT** copy one user's personal data into another user's records
   (for example the draft `referrals.referredUserName` field).
5. **MUST NOT** write personal data into logs, crash reports or analytics
   events. Use the user ID instead.
6. **SHOULD** use identifiers scoped to AdLease (Firebase user ID, App Check
   attestation) rather than hardware identifiers.
7. **MUST** delete or anonymise data when its retention period ends or the
   user deletes their account, except records the law requires to be kept.

## Categories

| # | Category | Data | Purpose | Proposed lawful basis | Proposed retention | Minimisation notes |
|---|---|---|---|---|---|---|
| 1 | Account identity | Phone number and/or email (depends on sign-in method), Firebase user ID | Sign-in, account recovery, one account per person | Contract | While the account exists | Collect one contact method unless both are needed (**decision needed**) |
| 2 | Profile | Full name | Showing the user's name; support | Contract | While the account exists | Optional. `profilePictureUrl` is not needed for v1 and SHOULD NOT be collected |
| 3 | Location (coarse) | Country | Eligibility, if AdLease is limited to Kenya | Contract | While the account exists | Only if eligibility needs it (**decision needed**). Never GPS location |
| 4 | Device | App Check attestation result, an app-scoped installation ID, device model | Fraud prevention (accounts per device), support | Legitimate interest (fraud prevention) | While the account exists, then up to the fraud-review period | Prefer an app-scoped ID over hardware IDs. Device model only if support needs it |
| 5 | Ad-view records | View session, ad network transaction ID, server timestamps, outcome (credited or rejected and why) | Crediting rewards, enforcing limits, preventing replay, fraud review | Contract; legitimate interest (fraud) | Ledger period (**decision needed**) | No ad content or viewing behaviour beyond what crediting needs |
| 6 | Reward ledger | Entries crediting value towards a phone, with reasons and references | Showing progress; resolving disputes; reconciliation | Contract; possibly legal obligation | Likely years if treated as financial records (**decision needed**, legal advice) | Append-only; amounts only, no free text with personal data |
| 7 | Phone ownership progress | Chosen phone, amount credited, completion | The core product | Contract | While the account exists, plus the ledger period | Nothing beyond the phone and the amounts |
| 8 | Referrals | Which user referred which | Referral programme, fraud review | Contract (if a programme exists) | While either account exists | Store user IDs only, not names |
| 9 | Consent and preferences | Consent records (what was agreed, version, time), language, theme | Proof of consent; app settings | Legal obligation (consent records); contract | Consent records for the period legal advice requires | Theme and language can stay on the phone only |
| 10 | Support and data requests | Messages and requests to access, correct or delete data | Handling requests within legal time limits | Legal obligation | Period legal advice requires | Only what the request needs |
| 11 | Admin audit log | Which admin did what, to which record, when | Accountability, investigating misuse | Legitimate interest; legal obligation | Period legal advice requires | Reference users by ID |
| 12 | Crash and diagnostics | Crash reports, app version, device model, OS version | Fixing crashes | Legitimate interest, or consent (**decision needed**) | Provider default or shorter | No personal data in custom log messages |
| 13 | Advertising data processed by AdMob | Advertising ID and other data the ad network collects | Serving ads | Consent where required (**decision needed**) | Set by Google's terms | AdLease does not store it. Disclosed in the privacy notice; consent shown before ads where required |

## Data the current demo collects that the target SHOULD NOT

- `passwordHash`: not a field of the user model. It is added to each stored
  account record by `lib/services/auth_service.dart` (`signUp()`, an unsalted
  SHA-256 of the password) and kept on the phone in SharedPreferences under
  `adlease_users`. Replaced by Firebase Authentication; AdLease never stores
  passwords.
- `profilePictureUrl` (field of the user model in
  `lib/models/user_model.dart`): no purpose in v1.
- `deviceId` (field of the user model in `lib/models/user_model.dart`), as a
  free value from the phone: replaced by an app-scoped ID and App Check.

## Transfers outside Kenya

Every proposed provider stores data outside Kenya (see
[architecture.md](architecture.md)). The Data Protection Act allows this only
with appropriate safeguards and a documented assessment. This is an open
legal decision in [open-decisions.md](open-decisions.md).
