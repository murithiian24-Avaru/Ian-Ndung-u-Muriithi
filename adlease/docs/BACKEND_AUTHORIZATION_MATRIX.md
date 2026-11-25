# AdLease Backend Authorization Matrix

Status: implementation and test coverage added; execution remains blocked until a Functions lockfile is committed and emulator tests run. `ENABLE_VERIFICATION_REVIEW=true` is set only by the disposable emulator test script. Never set it in production or a deployed environment.

## Firestore rules matrix

| Actor / operation | Target | Expected |
|---|---|---|
| Anonymous get | users/{uid}, verificationCases/{id} | Deny |
| Signed-in owner get | users/{own uid} | Allow |
| Signed-in non-owner get | users/{other uid} | Deny |
| Signed-in owner update | allowlisted profile fields | Allow only when field validation passes |
| Any client create/delete | users | Deny |
| Any client update | status, verificationStatus, profileDetailsVerified, uid, email, admin claims | Deny |
| Any client write | verificationCases, verificationDecisions, adminAudit | Deny |
| Any client read/write | wallets, rewardClaims, rewardLedger, dailyRewardCounters | Deny |
| Any client read/write | payments, financingApplications, withdrawalRequests, adSessions, partnerEvents, unknown collections | Deny |
| Collection query | all users / all verification cases | Deny unless query proves the owner document ID |
| Collection-group query | verificationCases, wallets and unknown groups | Deny |

## Callable authorization matrix

| Actor / condition | initializeUserProfile | requestVerification | reviewVerification |
|---|---|---|---|
| Anonymous | Deny | Deny | Deny |
| Email unverified | Deny | Deny | Deny |
| Disabled Firebase user | Deny | Deny | Deny |
| Valid verified customer | Allow valid initialization | Allow within account/state/rate limits | Deny without reviewer role |
| Suspended/closed customer | Deny | Deny | Applicant cannot be reviewed |
| Reviewer role absent | N/A | N/A | Deny |
| Reviewer role removed, stale token still has claim | N/A | N/A | Deny using live Auth record |
| Live reviewer role and matching token | N/A | N/A | Continue only with fresh MFA, verified email, non-self review and pending case |
| Missing MFA / stale auth_time | N/A | N/A | Deny |
| Applicant is reviewer | N/A | N/A | Deny |
| Reviewer gate unset or false | N/A | N/A | Deny |

## Financial and advertising invariants

- Ad session creation rejects.
- Reward claim callable rejects.
- Partner reward event adapter rejects.
- Firestore clients cannot read or mutate wallets, reward claims, reward ledger, daily reward counters, payment records, financing applications, withdrawal requests or ad session records.
- No payment, financing, wallet-credit, payout, withdrawal or live advertising endpoint is introduced by this branch.
- Keep rewards and withdrawals disabled in Flutter; do not carry PR #32 wholesale.

## Test coverage added (execution pending)

- TypeScript unit tests cover MFA freshness, verified email, account state, request limits and live-role/token claim agreement.
- Firestore emulator tests cover owner reads/updates, cross-user access, create/delete, protected financial documents, unknown collections, collection listing and collection-group queries.
- Callable emulator tests invoke the actual Functions emulator for anonymous requests, verified/unverified/disabled accounts, profile initialization, verification request idempotency, stale reviewer tokens, missing MFA and disabled ad/reward endpoints.
- The emulator-only test command sets `ENABLE_VERIFICATION_REVIEW=true` for the disposable local emulator process only. This is not a production setting.

## Remaining release gates

1. Generate and commit a valid `adlease/functions/package-lock.json` using the selected Node 22/npm 10 toolchain.
2. Run `npm ci`, TypeScript compilation, unit tests, Firestore rules emulator tests and callable emulator tests in CI.
3. Verify that all tests pass, including the stale-token test with the revoked claim actually present in the old ID token.
4. Keep `ENABLE_VERIFICATION_REVIEW` unset in every non-emulator environment until reviewer governance is approved.
5. Complete independent review of reviewer-role provisioning, MFA enrollment and operational audit procedures.

## Current execution limitation

The implementation environment has no DNS/network access to `registry.npmjs.org`, and the Functions package has no lockfile. Dependency installation therefore failed with `EAI_AGAIN`; TypeScript compilation and emulator suites have not been run. CI deliberately fails its lockfile preflight instead of substituting `npm install` or silently resolving floating versions.

The admin dashboard now renders only an unavailable shell in production builds, and a bundle assertion checks that demo dashboard content is absent. No dashboard deployment or hosting-level access control has been tested. No production deployment was performed.
