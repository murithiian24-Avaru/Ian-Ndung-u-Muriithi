# Server-authoritative reward rules

> Status: **proposed**. These rules apply once real ads exist. Until then the
> app keeps its clearly labelled simulation. Values marked **decision needed**
> (amounts, limits, retention) are not set by this document.

## Scope

These rules cover rewarded ads and the credit they add towards a phone. They
do not cover payouts or withdrawals, which stay switched off and out of scope.
Avaru house ads (promotional videos), if added later, MUST NOT create view
records, ledger entries, rewards or revenue records.

## Core rules

**R1. Server only.** Only Cloud Functions may create view sessions, view
records, ledger entries and changes to ownership progress. Security rules
deny every client write to these collections.

**R2. Verified completion only.** A reward is credited only after the server
has verified an AdMob server-side verification (SSV) callback for that view.
The app's own "ad finished" event never credits anything.

**R3. Server values only.** The reward amount, daily limits and all
timestamps come from server configuration and the server clock. The server
ignores any amount, time, count or "completed" flag sent by the app. The SSV
callback's `reward_amount` is checked against the server's configured value
for that ad unit and is not itself trusted as the amount to credit.

**R4. Exactly once.** Each reward is credited at most once, however many
times a request or callback arrives (see [Idempotency](#idempotency)).

**R5. Append-only ledger.** Ledger entries are never edited or deleted.
Corrections are new entries of type `adjustment` that reference the original,
made only through an audited admin function.

**R6. Progress cannot exceed the price.** Credit towards a phone stops at the
phone's price. Any excess is not credited.

**R7. Fail closed.** If any check fails or cannot be completed (signature,
session, limits, configuration missing), nothing is credited and the reason
is recorded. The app shows the view as "not credited" or "pending", never as
credited.

## The view flow

1. **Start.** The app calls `startAdView`. The server checks the caller is
   signed in, the App Check token is valid, the account is active, and the
   daily limits are not reached. It then creates a view session:
   `viewSessions/{sessionId}` with `userId`, `deviceKey`, `adUnit`,
   `createdAt` (server time), `expiresAt` (server time + a short window,
   **decision needed**) and `status: open`. It returns `sessionId`.
2. **Show.** The app loads the rewarded ad with SSV options: `userId` set to
   the Firebase user ID and `customData` set to the `sessionId`. This must be
   set before the ad is shown.
3. **Callback.** AdMob calls the SSV endpoint. The endpoint MUST:
   1. Verify the `signature` with the public key named by `key_id`, from
      Google's published verifier keys
      (`https://gstatic.com/admob/reward/verifier-keys.json`, cached and
      refreshed). The signature uses ECDSA with SHA-256. Unsigned or invalid
      callbacks are rejected.
   2. Check `ad_unit` is one of AdLease's configured rewarded ad units for
      this environment.
   3. Look up the session from `custom_data`. It must exist, be `open`, not be
      expired, and belong to the same user as `user_id`.
   4. Re-check the daily limits (they may have changed since the session
      started).
   5. In **one Firestore transaction**: create
      `ledger/{transaction_id}` (fails if it already exists), create the view
      record, mark the session `credited`, and update ownership progress.
4. **Respond.** Return HTTP 200 for every callback that was processed,
   including duplicates and rejected ones, so AdMob does not keep retrying.
   AdMob retries up to five times if the endpoint is unreachable or responds
   unexpectedly.
5. **Read.** The app reads the user's own progress and ledger; it never
   computes the balance itself.

## Replay prevention

| Threat | Rule |
|---|---|
| The same SSV callback delivered again (retry or replay) | `ledger/{transaction_id}` is created only if absent; a second delivery finds it and credits nothing |
| One session used for several rewards | A session moves from `open` to `credited` once, inside the same transaction |
| An old session reused later | Sessions expire after a short window; expired sessions are rejected |
| A session used by another user | The session's `userId` must equal the callback's `user_id` |
| Forged callback | Signature verification against Google's published keys; unknown `key_id` is rejected |
| A callback from another app or environment | `ad_unit` must be one of this environment's configured units |

## Daily limits

- **Server clock only.** All times use the server timestamp. The phone's clock
  is never used.
- **Day boundary.** A "day" is a calendar day in East Africa Time
  (`Africa/Nairobi`, UTC+3), so limits reset at local midnight for Kenyan
  users (**decision needed**: confirm, or use a rolling 24 hours).
- **Per user.** At most N credited views per user per day (**decision
  needed**; the demo uses 3).
- **Per device.** At most M credited views per device per day, and at most K
  accounts per device (**decision needed**), using an app-scoped device key
  and App Check.
- **Checked twice.** At session start (to avoid showing an ad that cannot be
  rewarded) and again at crediting (the authoritative check, inside the
  transaction).
- **Counters.** Daily counters live in server-only documents, for example
  `limits/{userId}_{yyyy-mm-dd}`, updated in the crediting transaction.

## Idempotency

- **SSV endpoint.** Keyed by `transaction_id`. Processing the same
  `transaction_id` again has no further effect and returns success.
- **App-callable functions** (`startAdView` and later others) accept a
  client-generated request ID. The server stores the result under that ID for
  a short period and returns the same result for a repeated request instead
  of repeating the action.
- **Admin adjustments** require a request ID and write a single ledger entry
  and audit-log entry per ID.

## Records

| Collection (proposed) | Written by | Readable by | Purpose |
|---|---|---|---|
| `viewSessions/{sessionId}` | Server only | Server only | Single-use sessions linking an ad view to a user |
| `ledger/{transaction_id}` and adjustment IDs | Server only | Owner (own entries) | Append-only record of every credit |
| `adViews/{id}` | Server only | Owner (own records) | View history and rejection reasons |
| `limits/{userId}_{day}` | Server only | Server only | Daily counters |
| `config/rewards` | Admin function only | Server only | Reward amount, limits, ad units per environment |

## Monitoring and reconciliation

- Rejected callbacks are counted by reason (bad signature, expired session,
  limit reached, duplicate). A sudden rise is an alert.
- A scheduled job compares ownership progress with the sum of ledger entries
  and flags any difference for review.
- Credited views are reconciled with AdMob's reporting. A credited view is
  **not** evidence of revenue; AdLease MUST NOT assume every completed view
  earns money.

## Notes on the current demo

`lib/services/ad_service.dart` computes a "verification hash" on the phone
with a fixed string compiled into the app. It provides no security and MUST
NOT be carried into the real system. The draft `adViews.verificationHash`
field in `DATABASE_SCHEMA.md` is replaced by the verified SSV
`transaction_id`.
