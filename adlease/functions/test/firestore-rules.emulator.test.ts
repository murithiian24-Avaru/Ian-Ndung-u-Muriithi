import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { after, before, test } from "node:test";
import { initializeTestEnvironment, RulesTestEnvironment, assertFails, assertSucceeds } from "@firebase/rules-unit-testing";
import { collection, collectionGroup, deleteDoc, doc, getDoc, getDocs, query, setDoc, updateDoc, where } from "firebase/firestore";

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
      uid: "u1", fullName: "Before", phoneNumber: "+254712345678", country: "Kenya",
      status: "pending", verificationStatus: "not_started", createdAt: new Date(),
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
      uid: "private-user", fullName: "Private", phoneNumber: "+254712345678", country: "Kenya", status: "pending",
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
      uid: "owner", fullName: "Owner", phoneNumber: "+254712345678", country: "Kenya", status: "pending",
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

test("users cannot store malformed or oversized profile details", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "users/profile-validation"), {
      uid: "profile-validation", fullName: "Valid Name",
      phoneNumber: "+254712345678", country: "Kenya", status: "pending",
    });
  });
  const db = env.authenticatedContext("profile-validation").firestore();
  await assertFails(updateDoc(doc(db, "users/profile-validation"), {
    phoneNumber: "0712345678",
  }));
  await assertFails(updateDoc(doc(db, "users/profile-validation"), {
    fullName: "x".repeat(101),
  }));
  await assertFails(updateDoc(doc(db, "users/profile-validation"), {
    country: "K",
  }));
});


test("pending verification locks identity fields but still permits locale changes", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "users/pending-profile"), {
      uid: "pending-profile", fullName: "Applicant", phoneNumber: "+254712345678",
      country: "Kenya", locale: "en", status: "pending",
      verificationStatus: "pending", profileDetailsVerified: false,
    });
  });
  const db = env.authenticatedContext("pending-profile").firestore();
  await assertFails(updateDoc(doc(db, "users/pending-profile"), { fullName: "Changed Name" }));
  await assertFails(updateDoc(doc(db, "users/pending-profile"), { phoneNumber: "+254700000000" }));
  await assertFails(updateDoc(doc(db, "users/pending-profile"), { country: "Uganda" }));
  await assertSucceeds(updateDoc(doc(db, "users/pending-profile"), { locale: "sw" }));
});

test("unknown collections and unexpected server-owned writes fail closed", async () => {
  const db = env.authenticatedContext("u1").firestore();
  await assertFails(setDoc(doc(db, "unexpectedCollection/record"), { value: true }));
  await assertFails(setDoc(doc(db, "payments/fake"), { uid: "u1", amountMinor: 100 }));
  await assertFails(setDoc(doc(db, "financingApplications/fake"), { uid: "u1", amountMinor: 100 }));
  await assertFails(setDoc(doc(db, "wallets/u1"), { balanceMinor: 100 }));
});

test("users cannot create or delete their own profile", async () => {
  const db = env.authenticatedContext("new-user").firestore();
  await assertFails(setDoc(doc(db, "users/new-user"), { uid: "new-user", fullName: "New User" }));
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "users/existing-user"), {
      uid: "existing-user", fullName: "Existing User", phoneNumber: "+254712345678",
      country: "Kenya", status: "pending", verificationStatus: "not_started",
    });
  });
  const ownerDb = env.authenticatedContext("existing-user").firestore();
  const { deleteDoc } = await import("firebase/firestore");
  await assertFails(deleteDoc(doc(ownerDb, "users/existing-user")));
});

test("users cannot list all user profiles or all verification cases", async () => {
  const db = env.authenticatedContext("u1").firestore();
  const { collection, getDocs } = await import("firebase/firestore");
  await assertFails(getDocs(collection(db, "users")));
  await assertFails(getDocs(collection(db, "verificationCases")));
});

test("collection-group queries cannot enumerate verification or wallet records", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "users/u1/verificationCases/c1"), { uid: "u1", status: "pending" });
    await setDoc(doc(db, "users/u2/verificationCases/c2"), { uid: "u2", status: "pending" });
  });
  const db = env.authenticatedContext("u1").firestore();
  await assertFails(getDocs(query(collectionGroup(db, "verificationCases"))));
  await assertFails(getDocs(query(collectionGroup(db, "wallets"))));
});

test("clients cannot read or mutate any disabled financial or operational records", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    const protectedDocs = [
      "wallets/u1", "rewardClaims/r1", "rewardLedger/l1", "dailyRewardCounters/u1",
      "payments/p1", "financingApplications/f1", "withdrawalRequests/w1",
      "adSessions/a1", "partnerEvents/e1", "adminAudit/a1",
    ];
    for (const path of protectedDocs) {
      await setDoc(doc(db, path), { uid: "u1", status: "pending", amountMinor: 100 });
    }
  });
  const db = env.authenticatedContext("u1").firestore();
  const protectedDocs = [
    "wallets/u1", "rewardClaims/r1", "rewardLedger/l1", "dailyRewardCounters/u1",
    "payments/p1", "financingApplications/f1", "withdrawalRequests/w1",
    "adSessions/a1", "partnerEvents/e1", "adminAudit/a1",
  ];
  for (const path of protectedDocs) {
    await assertFails(getDoc(doc(db, path)));
    await assertFails(updateDoc(doc(db, path), { amountMinor: 999999 }));
    await assertFails(deleteDoc(doc(db, path)));
  }
});

test("profile query must be constrained to the authenticated uid", async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "users/u1"), {
      uid: "u1", fullName: "User One", phoneNumber: "+254712345678", country: "Kenya",
      status: "pending", verificationStatus: "not_started",
    });
  });
  const db = env.authenticatedContext("u1").firestore();
  await assertSucceeds(getDocs(query(collection(db, "users"), where("uid", "==", "u1"))));
  await assertFails(getDocs(collection(db, "users")));
});
