# PR #24 backend security review — AdLease
Reviewed 18 November 2026. Engineering review only; not a penetration test, legal opinion or production approval.

## Executive finding
PR #24 provides a useful emulator-first foundation: critical Firestore writes are denied to clients, verification decisions are server-controlled, and the previous reward implementation used transactions and provider-scoped idempotency. It was not production-ready. The provider's signed server-side verification (SSV) adapter did not exist, so the internal reward helper was not proof that an ad event was authentic. The previous implementation also created a KES 2.50 wallet credit per verified event, which conflicts with the approved decision that ads must never create customer value.

The current implementation branch disables all ad session and reward issuance paths. It removes the reward transaction from the Flutter flow, disables local wallet credits/withdrawals and local ownership payment/selection, and replaces product copy with demo-only states.

## Positive controls in PR #24
- Authentication is required for user profile and verification callables.
- New user profiles are created server-side with pending status; clients cannot create/delete user profiles.
- Verification decisions use a callable requiring reviewer/admin custom claims.
- Verification case state, user verification state and admin audit record are written in a Firestore transaction.
- Firestore client writes to verification decisions, ad sessions, reward claims, reward ledger, wallet, daily counters and admin audit are denied.
- Prior reward callback idempotency was namespaced by provider plus provider event ID.
- Prior transaction checked session ownership/status/expiry, account status and daily credited count; it atomically wrote claim, ledger, wallet projection, counter and session state.
- Emulator tests covered duplicate event delivery, concurrent same-event delivery, cross-provider ID collisions, replay of one session with a different event, suspended accounts and concurrent distinct wallet updates.

## Risks and limitations
1. No real SSV verification adapter. PR #24 explicitly stated signed provider SSV verification was not implemented. The current branch disables the internal helper and all callable reward/session endpoints.
2. The former reward ledger was not a balanced accounting ledger. It stored a positive reward event and wallet projection, not a complete double-entry liability ledger. Do not reuse it for financing/payment accounting.
3. Daily quota reservations could consume capacity without a completed view because the old session-start path incremented issued count before completion. Do not carry reward quotas into ordinary advertising.
4. Firestore rules do not constrain Admin SDK writes. Every privileged function, service identity and future admin API requires least privilege, audit and tests.
5. Custom-claim administration is not delivered by PR #24. Reviewer checks rely on verificationReviewer or admin claims. A controlled, audited grant/revoke process, MFA and periodic review are still required.
6. Admin workflow is incomplete: no complete authenticated admin application, role lifecycle, reviewer queue, support workflow or production audit review.
7. Partner event verification and reconciliation are absent: no signature validation, webhook secret rotation, raw-event retention policy, reconciliation process or real provider integration.
8. Production identity integration is incomplete. Firebase identity adapter is not wired as the app-wide auth provider; production Firebase configuration is absent.
9. No live financial integration exists. No Daraja sandbox integration, financier contract API or supplier settlement reconciliation is implemented.
10. Staging Firestore uses the Europe multi-region `eur3` location. Use synthetic data until counsel completes the cross-border transfer and ODPC assessment.

## Current branch changes
- App feature flags default ad rewards, advertising, live financing and live payments OFF.
- Ads and watch-ad screens are informational only; no simulated timer, completion or claim action.
- Legacy ad reward service always throws; local ad-view recording always throws; legacy stored reward amounts are ignored.
- Server startAdSession, claimReward and internal event helper reject without writes.
- Wallet earning/withdrawal and local ownership payment/selection services reject.
- Home, wallet, ownership and ad copy no longer promises ad-derived money or phone progress.
- Admin dashboard entry point is fail-closed; sample-data pages are unreachable until authentication/MFA/roles/audit are implemented.
- Partner-neutral payment interface and disabled mock gateway are present; no payment intent can be created.
- Flutter and emulator regression tests assert disabled behaviour and mock financing boundary.

## Acceptance gates
- [ ] Flutter tests, static analysis, formatting and Android debug build pass on this branch.
- [ ] Firebase emulator build and rules tests pass.
- [ ] No reward/session path can create a customer financial mutation.
- [ ] No ordinary ad SDK until Google policy and privacy review.
- [ ] Partner APIs only after signed agreement and technical specification.
- [ ] Admin roles, MFA, audit and server-side authorization independently reviewed.
- [ ] Payment sandbox tests include duplicate, delayed, reversed, mismatched and concurrent callbacks plus reconciliation.
- [ ] Separate security review/penetration test complete before production.

Decision: keep PR #24 unmerged until this branch's regression CI is green and the backend is reviewed. Do not deploy Firebase Functions or connect production credentials.
