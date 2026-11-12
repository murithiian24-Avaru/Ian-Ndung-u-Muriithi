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
| T10 | Personal data leaked from the device or backups | Plain JSON; Android backup disabled (`allowBackup="false"` and data extraction rules), not yet verified on a device | Store no personal data or tokens beyond what Firebase manages; keep Android backup of app data disabled |
| T11 | Personal data leaked from the database | Not applicable yet | Owner-only read rules; no list queries across users; admin reads only through audited functions |
| T12 | Secrets leaked (service-account keys, signing key) | No secrets exist yet | Secret Manager; no keys in the repository or app; no long-lived service-account keys ([operations.md](operations.md)) |
| T13 | Test data mixed with real users | Not applicable yet | Separate development and production projects; test ad units only in development |
| T14 | Data loss or corruption | Uninstalling erases everything | Scheduled backups or point-in-time recovery, with tested restores |
| T15 | Runaway costs from abuse or a bug | Not applicable yet | Budget alerts, quotas and rate limits on functions; alerts do not cap spending, so they must be watched |
| T16 | Ad-network policy violation (rewards with monetary value) | Not applicable yet | Policy confirmation before integrating real ads (**decision needed**) |
| T17 | Data-protection breach not reported on time | No process | Breach-response process: report to the ODPC within 72 hours and inform affected users |
| T18 | Supply-chain risk from unused dependencies | 16 of the 25 hosted packages declared in `pubspec.yaml` are never imported (see [Unused packages](#unused-packages)) | Remove unused packages (separate PR); keep the lockfile committed |

## Unused packages

Counted on `main` at commit `45e248a` (29 October 2026).

**Method.** Take every entry under `dependencies:` in `adlease/pubspec.yaml`
(27 entries). Exclude the two that come with the Flutter SDK (`flutter` and
`flutter_localizations`), leaving **25 hosted packages**. A package counts as
unused if no file under `lib/` or `test/` contains `package:<name>/`. Each
package is counted once, under exactly one group below.

**Result: 16 unused.**

| Group | Packages | Count |
|---|---|---|
| Firebase and Google sign-in | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `google_sign_in` | 5 |
| Other Dart packages | `fl_chart`, `shimmer`, `cached_network_image`, `device_info_plus`, `url_launcher`, `share_plus`, `image_picker`, `path_provider`, `connectivity_plus`, `flutter_secure_storage` | 10 |
| Icon font | `cupertino_icons` (an asset-only package that is never imported by design; it is used only through `CupertinoIcons`, which appears nowhere in `lib/`) | 1 |

The other 9 are imported: `provider`, `shared_preferences`, `intl`, `uuid`,
`crypto`, `percent_indicator`, `flutter_animate`, `google_fonts` and
`package_info_plus`.

Several of the unused packages are plugins with native code. Flutter still
registers them in the generated platform plugin registrants and builds their
native code into the app, even though the Dart code never imports them. For
example, the committed `macos/Flutter/GeneratedPluginRegistrant.swift`
registers `cloud_firestore`, `firebase_auth` and `connectivity_plus`. Removing them is a separate change. The Firebase packages may
be reintroduced deliberately when the backend is approved.

## Assumptions

- Rooted phones and modified apps exist among users. The design does not rely
  on the phone being honest.
- App Check reduces abuse but can be bypassed; server-side limits and fraud
  review are still required.
- AdMob SSV callbacks can be delayed or retried. Crediting must be idempotent,
  and the app must show "pending" until the server credits.
