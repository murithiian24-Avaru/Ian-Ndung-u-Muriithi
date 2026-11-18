# AdLease payment and supplier integration architecture

Status: design only. This document does not represent a Safaricom/M-PESA or M-KOPA partnership, approval, API credential, commercial agreement, or production integration.

## Design boundaries

- Keep payments, ad rewards, and device-financing obligations as separate domains and ledgers.
- The mobile app never holds Daraja consumer secrets, passkeys, access tokens, webhook signing secrets, or supplier credentials.
- All money amounts are integer minor units with an explicit ISO currency (KES); never use floating-point arithmetic for money.
- Every externally initiated operation has a stable internal ID and idempotency key. A repeated callback must not create a second financial posting.
- Only authenticated server-side adapters may change payment or financing state. Client requests can initiate an operation but cannot mark it paid, settled, approved, or fulfilled.
- Use sandbox/test credentials and synthetic users until security, provider approval, legal review and reconciliation are complete.

## M-PESA / Safaricom Daraja boundary

Implement a provider-neutral `PaymentGateway` interface, with a future `DarajaPaymentGateway` adapter behind it. The app calls AdLease backend endpoints/callables; the backend calls Daraja. Do not call Daraja directly from Flutter.

Suggested operations:
- `createPaymentIntent(customerId, amountMinor, currency, purpose, reference)`
- `requestCustomerPayment(paymentIntentId, msisdn)` (for a supported customer-initiated/STK flow)
- `getPaymentStatus(paymentIntentId)`
- `acceptProviderCallback(rawRequest)` (server-only callback endpoint)
- `reconcilePayments(window)` (restricted operator job)

Payment state machine:
`created -> pending -> succeeded | failed | expired`; a previously succeeded payment may later receive a separately recorded `reversed` or `refunded` event. Never overwrite the original event or delete a ledger posting.

For every callback:
1. Validate the provider-specific callback structure and expected transaction fields.
2. Resolve the internal payment intent using a server-generated reference.
3. Verify amount, currency, account/reference, expected payee/business context and customer details against the intent.
4. Persist the raw provider event securely with restricted access and a retention policy; redact unnecessary personal data from logs.
5. Deduplicate by provider + provider transaction/event identifier, then transactionally update payment state and append a balanced ledger posting.
6. Acknowledge only after durable processing. Handle retries safely.
7. Reconcile pending/unknown outcomes using the provider's supported status-query/reporting mechanisms; a timeout is not proof of failure.

Do not store or request the customer's M-PESA PIN. Never treat an app screenshot, client callback, SMS text, or client-supplied receipt as authoritative payment proof. Use the official Daraja documentation and Safaricom-approved sandbox/production onboarding for endpoint details, callback requirements and credentials.

## Supplier / financier boundary

M-KOPA is the intended first target only; no partnership or terms are confirmed. Build against a neutral `DeviceFinancingProvider` contract so another supplier/financier can be substituted without changing wallet or payment logic.

Suggested capabilities:
- `getCatalogue()` and `getQuote(customer, deviceSku)`
- `submitApplication(quoteId, customerConsent, requiredKycReference)`
- `getApplicationStatus(applicationId)`
- `acceptOffer(offerId, explicitCustomerAcceptance)`
- `getContract(contractId)` and `getRepaymentSchedule(contractId)`
- `recordSettlement(settlementReference, amountMinor, currency)`
- `receiveProviderEvent(event)` and `reconcileProviderAccounts(window)`

Persist provider-neutral records with provider name, provider reference, quote/version, device SKU, quoted cash price, deposit, financed principal, fees/interest if any, repayment frequency, total payable, schedule, start/end dates, currency, status, consent evidence, and timestamps. Do not invent or hard-code these commercial values before signed terms are available.

Keep distinct:
- Customer payments received through M-PESA.
- Supplier/financier settlement payable.
- Customer financing receivable / repayment obligation.
- Ad-funded rewards and reward liability.
- Device fulfilment and ownership/transfer status.

A payment receipt does not by itself mean a financing instalment is allocated, a supplier is settled, or a device is owned. Allocation must follow a verified contract and schedule. Any lender's fixed repayment entitlement, default handling, refunds, repossession/returns, and customer-data sharing must be defined in the signed agreement and reviewed by Kenyan counsel.

## Suggested backend modules and collections

- `paymentIntents`: server-created intent, amount/currency/purpose, customer, state and expiry.
- `providerEvents`: provider-scoped event ID, payload digest, received/processed timestamps and processing outcome; strict access and retention.
- `paymentsLedger`: append-only debit/credit postings with balanced transaction groups and idempotency keys.
- `supplierQuotes`, `financingApplications`, `financingContracts`, `repaymentScheduleItems`.
- `supplierSettlements` and `reconciliationRuns`.
- `consentRecords`: versioned consent purpose, notice version, timestamp and withdrawal state.

Firestore client rules should deny all writes to these collections. Use Cloud Functions/Admin SDK only, with least-privilege service identities, auditable operator actions, and tests for replay, concurrency, amount mismatch, wrong customer, duplicate receipt, reversal, partial settlement and reconciliation drift.

## Required decisions before implementation

1. Confirm whether AdLease collects customer repayments, routes funds to a supplier, or acts only as a technology/orchestration layer.
2. Obtain Safaricom Daraja sandbox access and the exact supported product/transaction flow. Keep credentials in a secret manager, not GitHub or chat.
3. Obtain written supplier/financier commercial and technical terms before implementing partner-specific endpoints.
4. Define the reward funding source and ensure the ad provider's policies explicitly allow the proposed user benefit. Do not assume ad views can directly generate cash-equivalent rewards.
5. Complete Kenyan legal, consumer-credit, data-protection, tax, and accounting review before real-money pilot.

## Official developer reference

- Safaricom Daraja portal: https://developer.safaricom.co.ke/
- Daraja API catalogue: https://developer.safaricom.co.ke/apis

This is a technical boundary and implementation plan, not legal, accounting, financial, or provider-policy approval.
