# Review of the draft Firestore rules in `DATABASE_SCHEMA.md`

> Status: **the draft rules in `DATABASE_SCHEMA.md` are unsafe and MUST NOT
> be deployed.** They have never been deployed (no Firebase project or rules
> file exists in the repository). This document identifies the problems and
> specifies the required correction. The corrected rules below are a
> specification for roadmap step 5; they are **not tested**, and must be
> implemented with Firebase Emulator tests before use.

## Problems found

| # | Severity | Draft rule or text | Problem |
|---|---|---|---|
| F1 | **Critical** | `match /users/{userId}`: `allow write: if request.auth != null && request.auth.uid == userId;` | `write` covers create, update and delete, with no limit on fields. A signed-in user can set their own `isVerified: true` and `isActive: true`, choose any `referralCode` (including one copied from someone else), set or change `referredBy` (self-referral), change `deviceId` to evade per-device limits, and delete their own user document |
| F2 | **Critical** | `README.md`, Firebase Setup step 6: "Deploy security rules from `DATABASE_SCHEMA.md`" | Instructs readers to deploy the unsafe rules |
| F3 | High | `adViews` field `verificationHash`, described as "SHA-256 anti-cheat hash" | The hash is computed on the phone with a fixed string compiled into the app, so it proves nothing. Describing it as anti-cheat is misleading |
| F4 | Medium | `wallets` and `transactions` readable by their owner | These are cash-wallet records for withdrawals, which are switched off. Rewards go to phone-ownership progress only. Clients need no access while withdrawals are out of scope |
| F5 | Medium | `adViews`, `withdrawals`, `referrals` have no rules | Firestore denies access by default, so these are not open. But the intent is undocumented, and the reward design needs owner-read access to view history |
| F6 | Low | `ads` readable by any signed-in user | Harmless, but with a real ad network AdLease does not host ad content, so this collection is probably unnecessary |
| F7 | Low | `referrals.rewardAmount` "Referral reward ($5.00)" and `referrals.referredUserName` | States a reward in US dollars that no one has decided or pays, and copies one user's name into another user's records |

## Required correction for `users` (F1)

1. **Create**: only server code creates `users/{uid}`, when the account is
   first created. Server code (the Firebase Admin SDK) is not subject to
   security rules, so clients get `allow create: if false`.
2. **Update**: the owner may change only an allow-list of profile fields. For
   v1 that is `fullName` (**decision needed** if more fields are wanted). Every
   other field, including `isVerified`, `isActive`, `referralCode`,
   `referredBy`, `deviceId`, `deviceModel`, `createdAt` and `lastLoginAt`, is
   server-only.
3. **Delete**: clients cannot delete. Account deletion is a request handled
   by server code, which removes or anonymises data according to the
   retention schedule.
4. **Read**: owner only.
5. **Validation**: allowed fields are type- and length-checked.

## Proposed rules (specification only, untested)

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function signedIn() {
      return request.auth != null;
    }
    function isOwner(userId) {
      return signedIn() && request.auth.uid == userId;
    }
    function ownsDoc() {
      return signedIn() && resource.data.userId == request.auth.uid;
    }

    match /users/{userId} {
      allow read: if isOwner(userId);
      // Created and deleted only by server code.
      allow create, delete: if false;
      // Owner may change only these fields.
      allow update: if isOwner(userId)
        && request.resource.data.diff(resource.data).affectedKeys()
             .hasOnly(['fullName'])
        && request.resource.data.fullName is string
        && request.resource.data.fullName.size() > 0
        && request.resource.data.fullName.size() <= 100;
    }

    // Read-only to the owner; written only by server code.
    match /ownerships/{id} {
      allow read: if ownsDoc();
      allow write: if false;
    }
    match /ledger/{id} {
      allow read: if ownsDoc();
      allow write: if false;
    }
    match /adViews/{id} {
      allow read: if ownsDoc();
      allow write: if false;
    }

    // Catalogue of phones: readable when signed in; admin changes go
    // through server code.
    match /phones/{id} {
      allow read: if signedIn();
      allow write: if false;
    }

    // No client access at all (default deny, stated for clarity):
    // viewSessions, limits, config, auditLog, referrals, wallets,
    // transactions, withdrawals and anything not listed above.
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Notes:

- Owner-read rules on `ownerships`, `ledger` and `adViews` only allow queries
  that filter on `userId == request.auth.uid`; the app must query that way.
- Rules alone are not enough: server code must also validate everything it
  writes (see [reward-rules.md](reward-rules.md)).
- App Check enforcement is configured on the services, not in these rules.

## Tests required before these rules are used (roadmap step 5)

Emulator tests that prove, at minimum:

- A user cannot create their own `users` document.
- A user cannot set or change `isVerified`, `isActive`, `referralCode`,
  `referredBy`, `deviceId` or any other server-only field.
- A user cannot delete their `users` document.
- A user can update `fullName` within the length limit, and nothing else.
- A user cannot read another user's documents in any collection.
- No client can write to `ownerships`, `ledger`, `adViews`, `viewSessions`,
  `limits`, `config`, `auditLog`, `referrals`, `wallets`, `transactions` or
  `withdrawals`.

## Changes made in this pull request

Documentation only. The draft rules text in `DATABASE_SCHEMA.md` is left as it
was, for the record, with a warning placed above it that it is unsafe and must
not be deployed, pointing here. The README's instruction to deploy those
rules (F2) is replaced with a pointer to this document.
