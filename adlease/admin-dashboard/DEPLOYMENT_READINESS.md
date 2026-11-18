# AdLease Admin Dashboard — deployment readiness

Status: **not approved for public deployment**.

The current dashboard is a visual prototype. It contains hard-coded sample users, balances, activity, revenue charts and withdrawal rows. It does not authenticate administrators, authorize roles, read from the AdLease backend, or write audited decisions. The demo banner is not an access-control boundary.

## Why Vercel deployment is blocked

Do not create a public Vercel deployment until all of the following are implemented and reviewed:

- Firebase Authentication sign-in for staff accounts; no public self-registration.
- Server-verified admin/reviewer custom claims, with least-privilege roles (read-only analyst, verification reviewer, support, finance operator, super-admin).
- Server-side authorization on every privileged operation. Hiding buttons or checking roles only in React is not authorization.
- Backend-backed data only; remove hard-coded sample identities, balances, transactions and financial metrics from production builds.
- Verification decisions and every privileged mutation recorded in append-only server audit events with actor, target, action, reason, timestamp and request/correlation ID.
- MFA for privileged users, session expiry/revocation, rate limits and alerting.
- Firestore rules deny client writes to verification decisions, rewards, wallet, ledger, payments, financing and audit collections.
- Automated tests for unauthenticated access, role escalation, cross-user access, suspended admins, replayed requests and audit completeness.
- Privacy review, data minimization, retention rules and incident-response ownership.

## Vercel staging preparation (after the gates above)

- Vercel project root directory: `adlease/admin-dashboard`.
- Framework preset: Vite.
- Install command: `npm ci`.
- Build command: `npm run build`.
- Output directory: `dist`.
- Use a separate Vercel Preview/staging project and staging Firebase project. Never put service-account JSON, Admin SDK credentials, Daraja secrets, private keys or signing material in Vite variables: all `VITE_*` values are browser-visible.
- Add SPA fallback routing only if client-side routes are introduced.
- Configure HTTPS and security headers; restrict preview access at the hosting/identity layer, not with a client-side password gate.
- Keep production deployment disabled until a named owner approves the security review.

## Current CI

The repository CI runs `npm ci` and `npm run build` for this dashboard. A successful Vite build proves only that the static bundle compiles; it does not prove authentication, data integrity, privacy or operational readiness.

## Launch decision

The dashboard may be shown as a clearly labelled, synthetic-data design demo in a private investor presentation. It must not be represented as a functioning admin console or used to manage real users, verification, rewards, withdrawals, payments or financing.
