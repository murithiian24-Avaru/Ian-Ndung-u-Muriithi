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
    tx.create(userRef, {
      uid: auth.uid,
      email: String(auth.token.email ?? ""),
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
  await db.runTransaction(async (tx) => {
    const userRef = db.collection("users").doc(auth.uid);
    const user = await tx.get(userRef);
    if (!user.exists) throw new HttpsError("failed-precondition", "User profile is not initialized.");
    const status = user.get("verificationStatus");
    if (status === "approved") throw new HttpsError("already-exists", "Account is already verified.");
    if (status === "pending") throw new HttpsError("already-exists", "A verification request is already pending.");
    tx.create(caseRef, {
      uid: auth.uid, status: "pending", createdAt: FieldValue.serverTimestamp(),
      schemaVersion: 1,
    });
    tx.set(userRef, { verificationStatus: "pending", updatedAt: FieldValue.serverTimestamp() }, { merge: true });
  });
  return { caseId: caseRef.id, status: "pending" };
});

export const reviewVerification = onCall(async (request) => {
  const auth = requireAuth(request);
  if (auth.token.verificationReviewer !== true && auth.token.admin !== true) {
    throw new HttpsError("permission-denied", "Verification reviewer role required.");
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
    if (user.get("status") === "suspended" || user.get("status") === "closed") {
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
  providerEventId: string; sessionId: string; uid: string;
}) {
  if (!input.providerEventId || !input.sessionId || !input.uid) {
    throw new Error("Invalid verified partner event.");
  }
  const eventId = safeId(input.providerEventId);
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
    tx.create(claimRef, { uid: input.uid, sessionId: input.sessionId, providerEventIdHash: eventId, createdAt: FieldValue.serverTimestamp() });
    tx.create(ledgerRef, {
      uid: input.uid, type: "ad_reward", amountMinor: REWARD_MINOR, currency: "KES",
      sourceId: input.sessionId, idempotencyKey: eventId, createdAt: FieldValue.serverTimestamp(),
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
