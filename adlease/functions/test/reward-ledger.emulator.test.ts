import assert from "node:assert/strict";
import { test } from "node:test";
import { getFirestore } from "firebase-admin/firestore";
import { applyVerifiedPartnerEvent } from "../src/index";

const db = getFirestore();

test("verified-looking provider events cannot issue a reward", async () => {
  await assert.rejects(applyVerifiedPartnerEvent({
    provider: "test-network", providerEventId: "event-disabled", sessionId: "session-disabled", uid: "user-disabled",
  }), /rewards are disabled/i);
  assert.equal((await db.collection("rewardClaims").get()).size, 0);
  assert.equal((await db.collection("rewardLedger").get()).size, 0);
  assert.equal((await db.collection("wallets").get()).size, 0);
});

test("disabled reward event path does not mutate financing or customer records", async () => {
  await db.doc("financingContracts/contract-disabled-test").set({ outstandingMinor: 125000, status: "mock" });
  await assert.rejects(applyVerifiedPartnerEvent({
    provider: "test-network", providerEventId: "event-finance-disabled", sessionId: "session-finance-disabled", uid: "user-finance-disabled",
  }), /rewards are disabled/i);
  assert.equal((await db.doc("financingContracts/contract-disabled-test").get()).get("outstandingMinor"), 125000);
  await db.doc("financingContracts/contract-disabled-test").delete();
});
