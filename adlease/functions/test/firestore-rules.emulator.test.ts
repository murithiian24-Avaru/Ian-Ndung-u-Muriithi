import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { after, before, test } from "node:test";
import { initializeTestEnvironment, RulesTestEnvironment, assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import { doc, getDoc, setDoc, updateDoc } from "firebase/firestore";

let env: RulesTestEnvironment;

before(async () => {
  const rules = readFileSync(resolve(__dirname, "../../../firestore.rules"), "utf8");
  env = await initializeTestEnvironment({
    projectId: "demo-adlease",
    firestore: { rules, host: "127.0.0.1", port: 8080 },
  });
});
after(async () => { await env.cleanup(); });

test("users can edit profile allowlist but cannot alter server-owned account state", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "users/u1"), {
      uid: "u1", fullName: "Before", status: "pending",
      verificationStatus: "not_started", createdAt: new Date(),
    });
  });
  const db = env.authenticatedContext("u1").firestore();
  await assertSucceeds(updateDoc(doc(db, "users/u1"), { fullName: "After" }));
  await assertFails(updateDoc(doc(db, "users/u1"), { status: "active" }));
  await assertFails(updateDoc(doc(db, "users/u1"), { verificationStatus: "approved" }));
  await assertFails(updateDoc(doc(db, "users/u1"), { isAdmin: true }));
});

test("clients cannot create reward ledger or wallet entries", async () => {
  const db = env.authenticatedContext("u1").firestore();
  await assertFails(setDoc(doc(db, "rewardLedger/fake"), {
    uid: "u1", amountMinor: 250, currency: "KES",
  }));
  await assertFails(setDoc(doc(db, "wallets/u1"), { balanceMinor: 999999 }));
});

test("unauthenticated users cannot read user or verification data", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "users/private-user"), {
      uid: "private-user", fullName: "Private", status: "pending",
    });
    await setDoc(doc(context.firestore(), "verificationCases/private-case"), {
      uid: "private-user", status: "pending",
    });
  });
  const db = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, "users/private-user")));
  await assertFails(getDoc(doc(db, "verificationCases/private-case")));
});

test("users cannot read another user's profile or verification case", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "users/owner"), {
      uid: "owner", fullName: "Owner", status: "pending",
    });
    await setDoc(doc(context.firestore(), "verificationCases/owner-case"), {
      uid: "owner", status: "pending",
    });
  });
  const db = env.authenticatedContext("other-user").firestore();
  await assertFails(getDoc(doc(db, "users/owner")));
  await assertFails(getDoc(doc(db, "verificationCases/owner-case")));
});

test("clients cannot write verification decisions, cases or admin audit records", async () => {
  const db = env.authenticatedContext("u1").firestore();
  await assertFails(setDoc(doc(db, "verificationCases/fake"), {
    uid: "u1", status: "approved",
  }));
  await assertFails(setDoc(doc(db, "verificationDecisions/fake"), {
    uid: "u1", decision: "approved",
  }));
  await assertFails(setDoc(doc(db, "adminAudit/fake"), {
    actorUid: "u1", action: "grant_admin",
  }));
});
