# Operations: admin access, logging, backups, secrets and environments

> Status: **proposed**. Nothing here is set up. Creating projects, accounts or
> billing needs separate approval.

## Admin authorisation

- **Separate sign-in.** The admin dashboard is its own web app. Admins sign in
  with Firebase Authentication and **MUST** use two-factor authentication.
- **Roles set only by server code.** Admin roles are Firebase Auth custom
  claims, set only by a server-side script or function run by the account
  owner. No user, app or dashboard screen can grant a role.
- **Least privilege.** Proposed roles: `viewer` (read reports), `support`
  (look up a user's records), `admin` (adjustments, configuration, role
  changes). Each function checks the role it needs.
- **No direct database writes.** The dashboard calls admin functions. Security
  rules give the dashboard no direct write access.
- **Server-side checks.** Hiding a button in the dashboard is not
  authorisation; every admin function re-checks the caller's role.
- **Reviews.** The list of admins is reviewed regularly, and access is removed
  when someone leaves (**decision needed**: who the admins are).
- **Not public until ready.** The dashboard MUST NOT be deployed publicly
  until sign-in, roles and audit logging work.

## Access logging

- **Audit log.** Every admin action writes an entry to a server-only
  `auditLog` collection in the same operation: admin user ID, role, action,
  target record IDs, before and after values for changes, reason, request ID
  and server time. Entries are append-only.
- **Platform logs.** Google Cloud's Admin Activity audit logs record
  configuration changes. Data Access audit logs are optional and can add cost
  (**decision needed**).
- **Function logs** record request IDs, outcomes and rejection reasons, never
  personal data, tokens or secrets.
- **Alerts** for unusual activity: failed admin sign-ins, role changes, bursts
  of rejected reward callbacks, rising costs.

## Backup and recovery

- **Backups.** Scheduled Firestore backups and/or point-in-time recovery in
  production, kept in the same region (**decision needed**: retention and
  cost).
- **Targets.** Recovery point objective (how much data may be lost) and
  recovery time objective (how long recovery may take) are **decisions
  needed**.
- **Tested restores.** A restore into a non-production project is tested
  before launch and at regular intervals. An untested backup is not counted
  as a backup.
- **Ledger.** Because the ledger is append-only, a restore can be checked by
  reconciling progress against ledger entries.
- **Account deletion** removes the user's data from live systems; backups age
  out on their retention schedule. The privacy notice must say so.

## Secrets management

- **Nothing secret in the repository or the app.** The Firebase app
  configuration files (`google-services.json`) identify the project and are
  not secrets, but API keys in them SHOULD be restricted to the app's package
  and signing certificate.
- **Server secrets** live in Google Secret Manager, readable only by the
  functions that need them.
- **No long-lived service-account keys.** Functions use their runtime
  identity. Future CI deployments SHOULD use short-lived credentials
  (Workload Identity Federation) rather than a key file.
- **GitHub.** Any CI secret lives only in GitHub encrypted secrets, scoped to
  the workflow that needs it. Today's CI uses no secrets and never deploys.
- **Release signing key.** Kept offline by the owner, with Play App Signing
  holding the app signing key (**decision needed**: custody).
- **If a secret leaks**: revoke and rotate it first, then investigate.

## Environment separation

| | Development (`adlease-dev`, proposed) | Production (`adlease-prod`, proposed) |
|---|---|---|
| Users | Test accounts only | Real users |
| Ads | AdMob test ad units only | Approved production ad units |
| Data | Never copied from production | Real data |
| Access | Developers | Smallest possible set of admins |
| Billing | Budget alert; low limits | Budget alerts; monitored |

- **Local tests** use the Firebase Emulator Suite, so CI needs no cloud
  project or credentials.
- **Separate builds.** App builds for each environment use different Firebase
  configuration and are clearly labelled; a development build cannot reach
  production.
- **Production changes** go through a reviewed pull request; no manual edits
  to production data except through audited admin functions.
