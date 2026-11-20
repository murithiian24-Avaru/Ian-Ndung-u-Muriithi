import { getAuth, UserRecord } from "firebase-admin/auth";
import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import {
  assertCustomerAccountStatus,
  assertFreshMfaReviewer,
  assertVerificationState,
  assertVerifiedEmail,
  nextVerificationRequestWindow,
} from "./security";

initializeApp();
const db = getFirestore();

type CallableAuth = { uid: string; token: Record<string, unknown> };

function requireAuth(request: { auth?: CallableAuth | null }): CallableAuth {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign-in required.");
  return request.auth;
}

async function requireVerifiedFirebaseUser(uid: string): Promise<UserRecord> {
  let user: UserRecord;
  try {
    user = await getAuth().getUser(uid);
  } catch (error) {
    if (
      typeof error === "object" &&
      error !== null &&
      "code" in error &&
      error.code === "auth/user-not-found"
    ) {
      throw new HttpsError("unauthenticated", "A valid Firebase account is required.");
    }
    throw error;
  }
  assertVerifiedEmail(user);
  return user;
}

function profileProjection(uid: string, data: FirebaseFirestore.DocumentData) {
  return {
    uid,
    status: data.status,
    verificationStatus: data.verificationStatus,
    profileDetailsVerified: data.profileDetailsVerified === true,
    fullName: data.fullName,
    phoneNumber: data.phoneNumber,
    country: data.country,
  };
}

export const initializeUserProfile = onCall(async (request) => {
  const auth = requireAuth(request);
  const firebaseUser = await requireVerifiedFirebaseUser(auth.uid);
  const userRef = db.collection("users").doc(auth.uid);
  const profile = await db.runTransaction(async (tx) => {
    const existing = await tx.get(userRef);
    if (existing.exists) {
      const data = existing.data()!;
      assertCustomerAccountStatus(data.status);
      assertVerificationState(data.verificationStatus);
      return profileProjection(auth.uid, data);
    }

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
    const data = {
      uid: auth.uid,
      email: (firebaseUser.email ?? "").slice(0, 254),
      fullName, phoneNumber, country,
      profileDetailsVerified: false,
      status: "pending",
      verificationStatus: "not_started",
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      schemaVersion: 1,
    };
    tx.create(userRef, data);
    return profileProjection(auth.uid, data);
  });
  return { initialized: true, profile };
});

export const requestVerification = onCall(async (request) => {
  const auth = requireAuth(request);
  await requireVerifiedFirebaseUser(auth.uid);
  const caseRef = db.collection("verificationCases").doc();
  const now = Date.now();
  await db.runTransaction(async (tx) => {
    const userRef = db.collection("users").doc(auth.uid);
    const user = await tx.get(userRef);
    if (!user.exists) throw new HttpsError("failed-precondition", "User profile is not initialized.");
    const data = user.data()!;
    assertCustomerAccountStatus(data.status);
    assertVerificationState(data.verificationStatus);
    if (data.verificationStatus === "approved") {
      throw new HttpsError("already-exists", "Account is already verified.");
    }
    if (data.verificationStatus === "pending") {
      throw new HttpsError("already-exists", "A verification request is already pending.");
    }
    if (
      typeof data.fullName !== "string" ||
      typeof data.phoneNumber !== "string" ||
      typeof data.country !== "string"
    ) {
      throw new HttpsError("failed-precondition", "Complete your profile before requesting verification.");
    }

    const windowStart = data.verificationRequestWindowStartedAt?.toDate?.() as Date | undefined;
    const previousCount = Number(data.verificationRequestCount ?? 0);
    const limit = nextVerificationRequestWindow(windowStart, previousCount, now);

    tx.create(caseRef, {
      uid: auth.uid,
      status: "pending",
      profileSnapshot: {
        fullName: data.fullName,
        phoneNumber: data.phoneNumber,
        country: data.country,
      },
      createdAt: FieldValue.serverTimestamp(),
      schemaVersion: 1,
    });
    tx.set(userRef, {
      verificationStatus: "pending",
      verificationRequestWindowStartedAt: limit.windowStartedAt,
      verificationRequestCount: limit.requestCount,
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
  });
  return { caseId: caseRef.id, status: "pending" };
});

export const reviewVerification = onCall(async (request) => {
  if (process.env.ENABLE_VERIFICATION_REVIEW !== "true") {
    throw new HttpsError("failed-precondition", "Verification review operations are disabled until reviewer governance is approved.");
  }
  const auth = requireAuth(request);
  if (auth.token.verificationReviewer !== true && auth.token.admin !== true) {
    throw new HttpsError("permission-denied", "Verification reviewer role required.");
  }
  assertFreshMfaReviewer(auth.token);
  const reviewer = await getAuth().getUser(auth.uid);
  if (reviewer.disabled) {
    throw new HttpsError("permission-denied", "Disabled reviewer accounts cannot make verification decisions.");
  }

  const caseId = typeof request.data?.caseId === "string" ? request.data.caseId.trim() : "";
  const decision = request.data?.decision;
  const reason = typeof request.data?.reason === "string" ? request.data.reason.slice(0, 500) : "";
  if (!caseId || !["approved", "rejected"].includes(decision)) {
    throw new HttpsError("invalid-argument", "A valid case and decision are required.");
  }

  const caseRef = db.collection("verificationCases").doc(caseId);
  const initialCase = await caseRef.get();
  if (!initialCase.exists || initialCase.get("status") !== "pending") {
    throw new HttpsError("failed-precondition", "Verification case is not pending.");
  }
  const applicantUid = initialCase.get("uid");
  if (typeof applicantUid !== "string" || !applicantUid) {
    throw new HttpsError("failed-precondition", "Verification case has no valid applicant.");
  }
  if (applicantUid === auth.uid) {
    throw new HttpsError("permission-denied", "Reviewers cannot review their own verification cases.");
  }
  await requireVerifiedFirebaseUser(applicantUid);

  const decisionRef = db.collection("verificationDecisions").doc();
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(caseRef);
    if (!snap.exists || snap.get("status") !== "pending" || snap.get("uid") !== applicantUid) {
      throw new HttpsError("failed-precondition", "Verification case is no longer pending.");
    }
    const userRef = db.collection("users").doc(applicantUid);
    const user = await tx.get(userRef);
    if (!user.exists) throw new HttpsError("not-found", "User profile not found.");
    const data = user.data()!;
    assertCustomerAccountStatus(data.status);
    assertVerificationState(data.verificationStatus);
    if (data.verificationStatus !== "pending") {
      throw new HttpsError("failed-precondition", "Applicant verification is not pending.");
    }

    const auditRef = db.collection("adminAudit").doc();
    tx.create(decisionRef, {
      caseId, uid: applicantUid, decision, reason, reviewerUid: auth.uid,
      createdAt: FieldValue.serverTimestamp(), schemaVersion: 1,
    });
    tx.update(caseRef, {
      status: decision,
      reviewedAt: FieldValue.serverTimestamp(),
      reviewerUid: auth.uid,
    });
    tx.set(userRef, {
      verificationStatus: decision,
      profileDetailsVerified: decision === "approved",
      status: decision === "approved" && data.status === "pending" ? "active" : data.status,
      verifiedAt: decision === "approved" ? FieldValue.serverTimestamp() : null,
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    tx.create(auditRef, {
      actorUid: auth.uid, action: "verification_review", targetUid: applicantUid,
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
