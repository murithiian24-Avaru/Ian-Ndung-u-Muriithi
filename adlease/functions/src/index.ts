import { createHash } from "node:crypto";
import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

initializeApp();
const db = getFirestore();
const DAILY_LIMIT = 3;
const REWARD_MINOR = 250; // KES 2.50, expressed in cents; pilot value requires approval.
const SESSION_TTL_MS = 5 * 60 * 1000;

function requireAuth(request: { auth?: { uid: string; token: Record<string, unknown> } | null }) {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign-in required.");
  return request.auth;
}

function nairobiDay(date: Date): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Africa/Nairobi", year: "numeric", month: "2-digit", day: "2-digit",
  }).formatToParts(date);
  const values = Object.fromEntries(parts.map((p) => [p.type, p.value]));
  return `${values.year}-${values.month}-${values.day}`;
}

function safeId(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

export const initializeUserProfile = onCall(async (request) => {
  const auth = requireAuth(request);
  const userRef = db.collection("users").doc(auth.uid);
  await db.runTransaction(async (tx) => {
    const existing = await tx.get(userRef);
    if (existing.exists) return;
    const rawName = request.data?.fullName;
    const rawPhone = request.data?.phoneNumber;
    const rawCountry = request.data?.country;
    if (typeof rawName !== "string" || typeof rawPhone !== "string" || typeof rawCountry !== "string") {
      throw new HttpsError("invalid-argument", "Name, phone number and country must be text.");
    }
    const fullName = rawName.trim();
    const phoneNumber = rawPhone.trim();
    const country = rawCountry.trim();
    if (fullName.length < 2 || fullName.length > 100
        || !/^\\+[1-9]\\d{7,14}$/.test(phoneNumber)
        || country.length < 2 || country.length > 60) {
      throw new HttpsError("invalid-argument", "Provide a valid name, E.164 phone number and country.");
    }
    tx.create(userRef, {
      uid: auth.uid,
      email: String(auth.token.email ?? "").slice(0, 254),
      fullName, phoneNumber, country,
      profileDetailsVerified: false,
      status: "pending",
      verificationStatus: "not_started",
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      schemaVersion: 1,
    });
  });
  return { initialized: true };
});

export const requestVerification = onCall(async (request) => {
  const auth = requireAuth(request);
  const caseRef = db.collection("verificationCases").doc();
  const now = Date.now();
  const windowMs = 24 * 60 * 60 * 1000;
  const maxRequestsPerWindow = 3;
  await db.runTransaction(async (tx) => {
    const userRef = db.collection("users").doc(auth.uid);
    const user = await tx.get(userRef);
    if (!user.exists) throw new HttpsError("failed-precondition", "User profile is not initialized.");
    const status = user.get("verificationStatus");
    if (status === "approved") throw new HttpsError("already-exists", "Account is already verified.");
    if (status === "pending") throw new HttpsError("already-exists", "A verification request is already pending.");

    const windowStart = user.get("verificationRequestWindowStartedAt")?.toDate?.() as Date | undefined;
    const previousCount = Number(user.get("verificationRequestCount") ?? 0);
    const inWindow = windowStart !== undefined && now - windowStart.getTime() < windowMs;
    const requestCount = inWindow ? previousCount : 0;
    if (requestCount >= maxRequestsPerWindow) {
      throw new HttpsError("resource-exhausted", "Too many verification requests. Try again after the 24-hour limit resets.");
    }

    tx.create(caseRef, {
      uid: auth.uid, status: "pending", createdAt: FieldValue.serverTimestamp(),
      schemaVersion: 1,
    });
    tx.set(userRef, {
      verificationStatus: "pending",
      verificationRequestWindowStartedAt: inWindow ? windowStart : new Date(now),
      verificationRequestCount: requestCount + 1,
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
  });
  return { caseId: caseRef.id, status: "pending" };
});

export const reviewVerification = onCall(async (request) => {
  const auth = requireAuth(request);
  if (auth.token.verificationReviewer !== true && auth.token.admin !== true) {
    throw new HttpsError("permission-denied", "Verification reviewer role required.");
  }
  const firebaseClaims = auth.token.firebase as Record<string, unknown> | undefined;
  if (typeof firebaseClaims?.sign_in_second_factor !== "string" || !firebaseClaims.sign_in_second_factor) {
    throw new HttpsError("permission-denied", "Multi-factor authentication is required for verification reviewers.");
  }
  const authTime = Number(auth.token.auth_time ?? 0);
  if (!authTime || Date.now() - authTime * 1000 > 10 * 60 * 1000) {
    throw new HttpsError("unauthenticated", "A recent sign-in is required for verification decisions.");
  }
  const caseId = String(request.data?.caseId ?? "");
  const decision = request.data?.decision;
  const reason = String(request.data?.reason ?? "").slice(0, 500);
  if (!caseId || !["approved", "rejected"].includes(decision)) {
    throw new HttpsError("invalid-argument", "A valid case and decision are required.");
  }
  const caseRef = db.collection("verificationCases").doc(caseId);
  const decisionRef = db.collection("verificationDecisions").doc();
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(caseRef);
    if (!snap.exists || snap.get("status") !== "pending") {
      throw new HttpsError("failed-precondition", "Verification case is not pending.");
    }
    const userRef = db.collection("users").doc(snap.get("uid"));
    const user = await tx.get(userRef);
    if (!user.exists) throw new HttpsError("not-found", "User profile not found.");
    if (decision === "approved" && (user.get("status") === "suspended" || user.get("status") === "closed")) {
      throw new HttpsError("failed-precondition", "Suspended or closed accounts cannot be approved.");
    }
    const auditRef = db.collection("adminAudit").doc();
    tx.create(decisionRef, {
      caseId, uid: snap.get("uid"), decision, reason, reviewerUid: auth.uid,
      createdAt: FieldValue.serverTimestamp(), schemaVersion: 1,
    });
    tx.update(caseRef, { status: decision, reviewedAt: FieldValue.serverTimestamp() });
    tx.set(userRef, {
      verificationStatus: decision,
      status: decision === "approved" && user.get("status") === "pending" ? "active" : user.get("status"),
      verifiedAt: decision === "approved" ? FieldValue.serverTimestamp() : null,
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    tx.create(auditRef, {
      actorUid: auth.uid, action: "verification_review", targetUid: snap.get("uid"),
      caseId, decision, reason, createdAt: FieldValue.serverTimestamp(),
    });
  });
  return { status: decision };
});

export const startAdSession = onCall(async (request) => {
  const auth = requireAuth(request);
  if (auth.token.email_verified !== true) {
    throw new HttpsError("failed-precondition", "Verify your email before starting an ad.");
  }
  const userRef = db.collection("users").doc(auth.uid);
  const sessionRef = db.collection("adSessions").doc();
  const now = new Date();
  const dayKey = nairobiDay(now);
  const counterRef = db.collection("dailyRewardCounters").doc(`${auth.uid}_${dayKey}`);
  await db.runTransaction(async (tx) => {
    const [user, counter] = await Promise.all([tx.get(userRef), tx.get(counterRef)]);
    if (!user.exists || user.get("status") !== "active" || user.get("verificationStatus") !== "approved") {
      throw new HttpsError("permission-denied", "Account is not eligible for rewards.");
    }
    const issued = Number(counter.get("issuedCount") ?? 0);
    if (issued >= DAILY_LIMIT) throw new HttpsError("resource-exhausted", "Daily ad limit reached.");
    tx.set(counterRef, { uid: auth.uid, dayKey, issuedCount: issued + 1, creditedCount: Number(counter.get("creditedCount") ?? 0), updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    tx.create(sessionRef, {
      uid: auth.uid, dayKey, status: "issued", createdAt: FieldValue.serverTimestamp(),
      expiresAt: new Date(now.getTime() + SESSION_TTL_MS), schemaVersion: 1,
    });
  });
  return { sessionId: sessionRef.id, expiresAt: new Date(now.getTime() + SESSION_TTL_MS).toISOString() };
});

// This function is called only after a provider-specific adapter has verified
// the partner's signed SSV/webhook. Never expose it as a client callable.
export async function applyVerifiedPartnerEvent(input: {
  provider: string; providerEventId: string; sessionId: string; uid: string;
}) {
  const provider = input.provider.trim().toLowerCase();
  if (!/^[a-z0-9][a-z0-9_-]{1,39}$/.test(provider)
      || !input.providerEventId || !input.sessionId || !input.uid) {
    throw new Error("Invalid verified partner event.");
  }
  // Provider-scoped idempotency prevents unrelated ad networks from colliding
  // when they happen to issue the same external event identifier.
  const eventId = safeId(`${provider}:${input.providerEventId}`);
  const claimRef = db.collection("rewardClaims").doc(eventId);
  const sessionRef = db.collection("adSessions").doc(input.sessionId);
  const userRef = db.collection("users").doc(input.uid);
  const ledgerRef = db.collection("rewardLedger").doc(eventId);
  const walletRef = db.collection("wallets").doc(input.uid);
  const now = new Date();
  const dayKey = nairobiDay(now);
  const counterRef = db.collection("dailyRewardCounters").doc(`${input.uid}_${dayKey}`);

  return db.runTransaction(async (tx) => {
    const [claim, session, user, counter, wallet] = await Promise.all([
      tx.get(claimRef), tx.get(sessionRef), tx.get(userRef), tx.get(counterRef), tx.get(walletRef),
    ]);
    if (claim.exists) return { credited: false, reason: "duplicate" as const };
    if (!session.exists || session.get("uid") !== input.uid || session.get("status") !== "issued") {
      throw new Error("Invalid or already-used ad session.");
    }
    const expiry = session.get("expiresAt")?.toDate?.() as Date | undefined;
    if (!expiry || expiry.getTime() < now.getTime() || session.get("dayKey") !== dayKey) {
      throw new Error("Ad session expired or outside its Nairobi day.");
    }
    if (!user.exists || user.get("status") !== "active" || user.get("verificationStatus") !== "approved") {
      throw new Error("Account is not eligible.");
    }
    const credited = Number(counter.get("creditedCount") ?? 0);
    if (credited >= DAILY_LIMIT) throw new Error("Daily reward limit reached.");
    const previousBalance = Number(wallet.get("balanceMinor") ?? 0);
    tx.create(claimRef, { uid: input.uid, sessionId: input.sessionId, provider, providerEventIdHash: eventId, createdAt: FieldValue.serverTimestamp() });
    tx.create(ledgerRef, {
      uid: input.uid, type: "ad_reward", amountMinor: REWARD_MINOR, currency: "KES",
      provider, sourceId: input.sessionId, idempotencyKey: eventId, createdAt: FieldValue.serverTimestamp(),
      schemaVersion: 1,
    });
    tx.set(walletRef, { balanceMinor: previousBalance + REWARD_MINOR, currency: "KES", updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    tx.set(counterRef, { uid: input.uid, dayKey, creditedCount: credited + 1, issuedCount: Number(counter.get("issuedCount") ?? 0), updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    tx.update(sessionRef, { status: "credited", creditedAt: FieldValue.serverTimestamp() });
    return { credited: true, reason: "accepted" as const };
  });
}

// Client callbacks are not evidence of an ad view. A partner adapter must call
// applyVerifiedPartnerEvent only after cryptographic SSV verification.
export const claimReward = onCall(async () => {
  throw new HttpsError("failed-precondition", "Rewards can only be credited after verified partner server-side verification.");
});
