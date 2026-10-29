# Threat model

> Status: **proposed**. Risks are listed for the target architecture, with
> the current demo's exposure noted where it differs.

## Assets

1. Reward value: credits towards a phone, which have real value once AdLease
   is live.
2. Users' personal data (see [data-inventory.md](data-inventory.md)).
3. Admin access.
4. Ad revenue and the AdMob account standing (policy violations can close the
   account).
5. Server credentials and the release signing key.

## Principal risks and mitigations

| # | Risk | Current demo | Required mitigation |
|---|---|---|---|
| T1 | User edits stored rewards, balances or view records | Possible: all in plain SharedPreferences | Server-only writes; security rules deny client writes to protected collections; ledger is append-only ([reward-rules.md](reward-rules.md)) |
| T2 | App claims an ad was watched when it was not | Possible: the app decides completion | Credit only after a verified AdMob SSV callback; ignore the app's completion claim |
| T3 | Replayed or duplicated reward (same callback twice, retried request) | No protection | Ledger entry ID = ad network transaction ID; single-use view sessions; idempotent crediting |
| T4 | Daily limit bypassed by changing the phone's clock or reinstalling | Possible | Limits counted on the server clock, per user and per device |
| T5 | Many accounts on one device, or bots and emulators | No protection | App Check (Play Integrity); accounts-per-device limit; fraud review in the dashboard |
| T6 | Modified or repackaged app | Release builds use the debug key | Release signing with Play App Signing; App Check; server never trusts client values |
| T7 | User marks their own account verified, active or referred | Draft rules allow it | Users may update only an allow-list of profile fields ([firestore-rules-review.md](firestore-rules-review.md)) |
| T8 | Account takeover | Local unsalted SHA-256 hashes; no lockout | Firebase Authentication (no passwords stored by AdLease); sign-in rate limits; recovery through verified contact method |
| T9 | Unauthorised admin access or admin misuse | Dashboard has no sign-in (not deployed) | Admin role set only by server code; two-factor sign-in; least-privilege roles; every action audit-logged ([operations.md](operations.md)) |
| T10 | Personal data leaked from the device or backups | Plain JSON; Android backup not disabled | Store no personal data or tokens beyond what Firebase manages; disable Android backup of app data (separate PR) |
| T11 | Personal data leaked from the database | Not applicable yet | Owner-only read rules; no list queries across users; admin reads only through audited functions |
| T12 | Secrets leaked (service-account keys, signing key) | No secrets exist yet | Secret Manager; no keys in the repository or app; no long-lived service-account keys ([operations.md](operations.md)) |
| T13 | Test data mixed with real users | Not applicable yet | Separate development and production projects; test ad units only in development |
| T14 | Data loss or corruption | Uninstalling erases everything | Scheduled backups or point-in-time recovery, with tested restores |
| T15 | Runaway costs from abuse or a bug | Not applicable yet | Budget alerts, quotas and rate limits on functions; alerts do not cap spending, so they must be watched |
| T16 | Ad-network policy violation (rewards with monetary value) | Not applicable yet | Policy confirmation before integrating real ads (**decision needed**) |
| T17 | Data-protection breach not reported on time | No process | Breach-response process: report to the ODPC within 72 hours and inform affected users |
| T18 | Supply-chain risk from unused dependencies | Ten declared packages are unused | Remove unused packages (separate PR); keep the lockfile committed |

## Assumptions

- Rooted phones and modified apps exist among users. The design does not rely
  on the phone being honest.
- App Check reduces abuse but can be bypassed; server-side limits and fraud
  review are still required.
- AdMob SSV callbacks can be delayed or retried. Crediting must be idempotent,
  and the app must show "pending" until the server credits.
