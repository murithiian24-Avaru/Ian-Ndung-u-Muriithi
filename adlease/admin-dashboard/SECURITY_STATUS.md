# AdLease admin dashboard security status
**Status:** fail-closed prototype; not an operational admin system.

## Current protection
- The app entry point renders only an unavailable/locked screen.
- The prior sample-data pages are no longer reachable through the app entry point.
- No real customer data, identity documents, financing accounts or payment records are accessible.
- No public deployment is authorised.

## Why it is not yet considered secured for operational use
The dashboard still lacks:
1. Firebase Authentication integration and a verified sign-in flow.
2. Mandatory MFA for privileged users.
3. Server-side custom-claim/role verification on every admin API.
4. An audited process for granting, changing and revoking admin/reviewer roles.
5. Protected backend endpoints for user review, verification, financing support and audit search.
6. Least-privilege service identities and sensitive-field minimisation.
7. Immutable/auditable admin action records, monitoring and alerting.
8. Session expiry, reauthentication for sensitive actions, CSRF/origin protections where applicable, and security testing.

## Required implementation before unlock
- Add Firebase web app configuration through environment-specific non-secret identifiers; never place service-account keys in the browser.
- Authenticate with Firebase Auth; require MFA for admin and reviewer roles.
- Send Firebase ID tokens to callable/HTTP backend endpoints.
- Verify tokens and custom claims server-side; deny by default. UI role checks are display-only.
- Add backend functions for each allowed action, validate inputs and target records, enforce least privilege and write audit events transactionally.
- Provide audited role grant/revoke tooling outside ordinary user-facing admin screens.
- Add emulator tests for unauthenticated users, ordinary users, revoked admins, wrong roles, malformed requests and concurrent reviewer actions.
- Complete independent security review before deployment.

## Release rule
Keep the dashboard locked and do not deploy it to Vercel until all required controls pass and the owner separately approves deployment.
