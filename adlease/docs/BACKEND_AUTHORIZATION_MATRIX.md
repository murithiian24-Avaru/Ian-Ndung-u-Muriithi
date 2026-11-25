# AdLease Backend Authorization Matrix

Status: implementation baseline only. Emulator execution and callable integration tests are still required. Verification review is disabled unless `ENABLE_VERIFICATION_REVIEW=true`; do not set that variable in any environment as part of this work.

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
| Any client write | rewardClaims, rewardLedger, wallets, dailyRewardCounters | Deny |
| Any client read/write | payments, financingApplications, unknown collections | Deny |
| Collection query | all users / all verification cases | Deny unless query can prove the owner constraint |
| Collection-group / unknown path | all collections | Deny by catch-all |

## Callable authorization matrix

| Actor / condition | initializeUserProfile | requestVerification | reviewVerification |
|---|---|---|---|
| Anonymous | Deny | Deny | Deny |
| Email unverified | Deny | Deny | Deny |
| Disabled Firebase user | Deny | Deny | Deny |
| Valid verified customer | Allow valid initialization | Allow within account/state/rate limits | Deny without reviewer role |
| Suspended/closed customer | Deny | Deny | Applicant cannot be reviewed |
| Reviewer role absent | N/A | N/A | Deny |
| Reviewer role removed, stale token still has claim | N/A | N/A | Deny |
| Live reviewer role and matching refreshed token | N/A | N/A | Continue only with fresh MFA, verified email, non-self review and pending case |
| Missing MFA / stale auth_time | N/A | N/A | Deny |
| Applicant is reviewer | N/A | N/A | Deny |
| ENABLE_VERIFICATION_REVIEW unset or false | N/A | N/A | Deny |

## Financial and advertising invariants

- Ad session creation rejects.
- Reward claim callable rejects.
- Partner reward event adapter rejects.
- Firestore clients cannot create or modify wallets, reward claims, reward ledger, daily reward counters, payment records or financing applications.
- No payment, financing, wallet-credit, payout, withdrawal or live advertising endpoint is introduced by this branch.
- Keep rewards and withdrawals disabled in Flutter; do not carry PR #32 wholesale.

## Required tests before any reviewer activation

1. Execute the full Firestore rules matrix on the Firestore emulator.
2. Execute callable tests against Auth, Firestore and Functions emulators, including a role revoked after token issuance.
3. Verify token claim refresh behavior and MFA enforcement.
4. Verify all financial and advertising endpoints reject requests and produce no writes.
5. Verify unknown paths, query/list and collection-group access fail closed.
6. Keep `ENABLE_VERIFICATION_REVIEW` unset until all tests and reviewer governance are approved.

## Current limitation

The current Node test suite contains unit tests and Firestore rules tests. It does not yet include end-to-end callable invocations against the Functions emulator. Starting the Functions emulator in CI is not by itself proof that callable authorization has been tested. Do not enable reviewer operations until callable integration tests are added and pass.
