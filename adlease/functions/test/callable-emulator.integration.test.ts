import assert from "node:assert/strict";
import { after, before, test } from "node:test";
import { initializeApp, deleteApp } from "firebase-admin/app";
import { getAuth as getAdminAuth } from "firebase-admin/auth";
import { initializeApp as initializeClientApp } from "firebase/app";
import { getAuth, signInWithCustomToken, signOut } from "firebase/auth";
import { getFunctions, connectFunctionsEmulator, httpsCallable } from "firebase/functions";

const projectId = "demo-adlease";
const adminApp = initializeApp({ projectId }, "adlease-callable-test-admin");
const adminAuth = getAdminAuth(adminApp);
const clientApp = initializeClientApp({ projectId, apiKey: "fake-api-key", authDomain: "localhost" }, "adlease-callable-test-client");
const clientAuth = getAuth(clientApp);
const functions = getFunctions(clientApp, "us-central1");
connectFunctionsEmulator(functions, "127.0.0.1", 5001);

before(async () => {
  process.env.FIREBASE_AUTH_EMULATOR_HOST ??= "127.0.0.1:9099";
  process.env.FIRESTORE_EMULATOR_HOST ??= "127.0.0.1:8080";
});
after(async () => {
  await signOut(clientAuth).catch(() => undefined);
  await deleteApp(clientApp);
  await deleteApp(adminApp);
});

async function signedInUser(options: { emailVerified?: boolean; claims?: Record<string, unknown> } = {}) {
  const email = `test-${Date.now()}-${Math.random().toString(16).slice(2)}@example.test`;
  const user = await adminAuth.createUser({ email, emailVerified: options.emailVerified ?? true });
  if (options.claims) await adminAuth.setCustomUserClaims(user.uid, options.claims);
  const token = await adminAuth.createCustomToken(user.uid);
  await signInWithCustomToken(clientAuth, token);
  return { uid: user.uid, user };
}

async function call<T>(name: string, data: unknown = {}) {
  return httpsCallable<unknown, T>(functions, name)(data);
}

test("unauthenticated profile and verification callables reject", async () => {
  await signOut(clientAuth).catch(() => undefined);
  await assert.rejects(call("initializeUserProfile", {
    fullName: "Test User", phoneNumber: "+254712345678", country: "Kenya",
  }), (error: unknown) => typeof error === "object" && error !== null && "code" in error && error.code === "functions/unauthenticated");
  await assert.rejects(call("requestVerification"), (error: unknown) => typeof error === "object" && error !== null && "code" in error && error.code === "functions/unauthenticated");
});

test("verified customer can initialize profile once and request verification", async () => {
  const { uid } = await signedInUser();
  const initialized = await call<{ initialized: boolean; profile: { uid: string } }>("initializeUserProfile", {
    fullName: "Integration User", phoneNumber: "+254712345678", country: "Kenya",
  });
  assert.equal(initialized.data.initialized, true);
  assert.equal(initialized.data.profile.uid, uid);
  const repeated = await call<{ initialized: boolean }>("initializeUserProfile", {
    fullName: "Ignored Replacement", phoneNumber: "+254700000000", country: "Uganda",
  });
  assert.equal(repeated.data.initialized, true);
  const requested = await call<{ caseId: string; status: string }>("requestVerification");
  assert.equal(requested.data.status, "pending");
  assert.ok(requested.data.caseId);
  await assert.rejects(call("requestVerification"), (error: unknown) =>
    typeof error === "object" && error !== null && "code" in error && error.code === "functions/already-exists");
});

test("unverified email is rejected by profile initialization", async () => {
  await signedOut();
  await signedInUser({ emailVerified: false });
  await assert.rejects(call("initializeUserProfile", {
    fullName: "Unverified User", phoneNumber: "+254712345678", country: "Kenya",
  }), (error: unknown) => typeof error === "object" && error !== null && "code" in error && error.code === "functions/unauthenticated");
});

test("review callable rejects a revoked reviewer role even with stale token claims", async () => {
  await signedOut();
  const { uid } = await signedInUser({ claims: { verificationReviewer: true } });
  await adminAuth.setCustomUserClaims(uid, {});
  await assert.rejects(call("reviewVerification", { caseId: "not-a-case", decision: "approved" }),
    (error: unknown) => typeof error === "object" && error !== null && "code" in error && error.code === "functions/permission-denied");
});

test("review callable rejects reviewer token without MFA", async () => {
  await signedOut();
  await signedInUser({ claims: { verificationReviewer: true } });
  await assert.rejects(call("reviewVerification", { caseId: "not-a-case", decision: "approved" }),
    (error: unknown) => typeof error === "object" && error !== null && "code" in error && error.code === "functions/permission-denied");
});

test("advertising and reward callables reject without customer-value side effects", async () => {
  await signedOut();
  await assert.rejects(call("startAdSession"), (error: unknown) =>
    typeof error === "object" && error !== null && "code" in error && error.code === "functions/failed-precondition");
  await assert.rejects(call("claimReward"), (error: unknown) =>
    typeof error === "object" && error !== null && "code" in error && error.code === "functions/failed-precondition");
});

async function signedOut() {
  await signOut(clientAuth).catch(() => undefined);
}
