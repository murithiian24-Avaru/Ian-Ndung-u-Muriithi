import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

initializeApp();
const db = getFirestore();

function requireAuth(request: { auth?: { uid: string; token: Record<string, unknown> } | null }) {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign-in required.");
  return request.auth;
}

export const initializeUserProfile = onCall(async (request) => {
  const auth = requireAuth(request);
  const userRef = db.collection("users").doc(auth.uid);
  await db.runTransaction(async (tx) => {
    const existing = await tx.get(userRef);
    if (existing.exists) return;
    const fullName = String(request.data?.fullName ?? "").trim().slice(0, 100);
    const phoneNumber = String(request.data?.phoneNumber ?? "").trim().slice(0, 24);
    const country = String(request.data?.country ?? "").trim().slice(0, 60);
    if (!fullName || !phoneNumber || !country) {
      throw new HttpsError("invalid-argument", "Name, phone number and country are required.");
    }
    tx.create(userRef, {
      uid: auth.uid,
      email: String(auth.token.email ?? ""),
      fullName, phoneNumber, country,
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

export const claimReward = onCall(async () => {
  throw new HttpsError("failed-precondition", "Ad rewards are permanently disabled in this product model.");
});
