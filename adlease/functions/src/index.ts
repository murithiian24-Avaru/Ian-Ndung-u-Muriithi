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

// Advertising/reward endpoints are intentionally disabled. Do not add a
// client-callable reward route. A future ordinary-ad integration must have no
// access to financing, wallet, payment or customer-ledger mutation paths.
export const startAdSession = onCall(async () => {
  throw new HttpsError("failed-precondition", "Ad serving is disabled pending policy and privacy review.");
});

// Compatibility seam for legacy tests and future provider adapters. No
// partner event can currently create customer value.
export async function applyVerifiedPartnerEvent(_input: {
  provider: string; providerEventId: string; sessionId: string; uid: string;
}): Promise<never> {
  throw new Error("Ad rewards are disabled; no provider event can create customer value.");
}

export const claimReward = onCall(async () => {
  throw new HttpsError("failed-precondition", "Ad rewards are permanently disabled in this product model.");
});
