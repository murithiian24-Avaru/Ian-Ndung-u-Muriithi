# AdLease architecture and security requirements

> **Status: PROPOSED. None of this exists yet.**
> AdLease today has no backend, database, API or server code. All data is
> stored only on the user's phone (see [Current state](#current-state)). These
> documents describe the proposed target and the rules it must follow. They
> are not permission to create cloud projects, enable billing or incur costs;
> each of those needs a separate approval (see
> [open-decisions.md](open-decisions.md)).

This is roadmap step 1 of the AdLease Infrastructure Audit (29 October 2026).
Later steps implement it in small, separately reviewed pull requests.

## Documents

| Document | Contents |
|---|---|
| [architecture.md](architecture.md) | Proposed components and the main data flows |
| [data-inventory.md](data-inventory.md) | Personal data AdLease expects to collect, why, and minimisation rules |
| [threat-model.md](threat-model.md) | Principal security risks and their mitigations |
| [reward-rules.md](reward-rules.md) | Server-authoritative rules for ad views and rewards |
| [operations.md](operations.md) | Admin authorisation, access logging, backups, secrets, environments |
| [firestore-rules-review.md](firestore-rules-review.md) | Review of the draft rules in `DATABASE_SCHEMA.md`, and the required corrections |
| [open-decisions.md](open-decisions.md) | Product, ad-policy, cost and data-protection decisions still open |

## Proposed architecture in one paragraph

One Firebase project per environment (development and production). Users sign
in with **Firebase Authentication**. Data lives in **Cloud Firestore**. Only
**Cloud Functions** (server code) may create ad-view records, credit rewards,
enforce limits or perform admin actions. **App Check** adds a layer of abuse
prevention by helping to reject requests that do not appear to come from the
genuine app on a genuine device. It is not a guarantee: it can be bypassed,
so server-side checks, limits and fraud review are still required (see
[threat-model.md](threat-model.md)). The **admin dashboard** is a separate web app
with its own sign-in, an admin role that only server code can grant, and an
audit log of every admin action.

## Current state

Verified in the repository at `main` commit `ccbb6c5`:

- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` and
  `google_sign_in` are declared in `pubspec.yaml` but never imported, and
  `Firebase.initializeApp` is never called. There are no Firebase
  configuration files.
- All data is plain JSON in SharedPreferences
  (`lib/services/storage_service.dart`), including accounts with unsalted
  SHA-256 password hashes (`lib/services/auth_service.dart`).
- Ads and rewards are simulated: the reward amount and daily limit are
  constants in `lib/services/ad_service.dart`, applied on the phone using the
  phone's clock.
- The admin dashboard (`admin-dashboard/`) shows hard-coded sample data and
  has no sign-in.
- `DATABASE_SCHEMA.md` contains draft Firestore rules that were never deployed
  and are **unsafe as written** (see
  [firestore-rules-review.md](firestore-rules-review.md)).

## Conventions

- **MUST** / **MUST NOT**: required before AdLease handles real users, real
  ads or anything of value.
- **SHOULD**: expected, unless a documented decision says otherwise.
- **Decision needed**: cannot be settled by engineering alone; listed in
  [open-decisions.md](open-decisions.md).
- **Unverified**: a fact about an outside service that must be confirmed
  before relying on it.
