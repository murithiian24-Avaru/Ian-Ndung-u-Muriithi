import assert from "node:assert/strict";
import { after, before, test } from "node:test";
import { getApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { applyVerifiedPartnerEvent } from "../src/index";

let app: ReturnType<typeof getApp>;
let db: ReturnType<typeof getFirestore>;

before(async () => {
  app = getApp();
  db = getFirestore(app);
  await db.recursiveDelete(db.collection("users"));
  await db.recursiveDelete(db.collection("adSessions"));
  await db.recursiveDelete(db.collection("rewardClaims"));
  await db.recursiveDelete(db.collection("rewardLedger"));
  await db.recursiveDelete(db.collection("wallets"));
  await db.recursiveDelete(db.collection("dailyRewardCounters"));
});
after(async () => { /* Firebase Functions module owns the default app. */ });

async function seed(uid: string, sessionId: string) {
  const day = new Intl.DateTimeFormat("en-CA", { timeZone: "Africa/Nairobi", year: "numeric", month: "2-digit", day: "2-digit" }).format(new Date());
  await db.doc(`users/${uid}`).set({ status: "active", verificationStatus: "approved" });
  await db.doc(`adSessions/${sessionId}`).set({
    uid, dayKey: day, status: "issued",
    createdAt: new Date(), expiresAt: new Date(Date.now() + 300000),
  });
  await db.doc(`dailyRewardCounters/${uid}_${day}`).set({ uid, dayKey: day, issuedCount: 1, creditedCount: 0 });
}

test("duplicate provider callback credits exactly once", async () => {
  await seed("u-duplicate", "s-duplicate");
  const event = { provider: "test-network", providerEventId: "provider-event-duplicate", sessionId: "s-duplicate", uid: "u-duplicate" };
  const first = await applyVerifiedPartnerEvent(event);
  const second = await applyVerifiedPartnerEvent(event);
  assert.equal(first.credited, true);
  assert.equal(second.credited, false);
  assert.equal((await db.doc("wallets/u-duplicate").get()).get("balanceMinor"), 250);
  assert.equal((await db.collection("rewardLedger").where("uid", "==", "u-duplicate").get()).size, 1);
});

test("concurrent callbacks for the same event cannot double-credit", async () => {
  await seed("u-concurrent", "s-concurrent");
  const event = { provider: "test-network", providerEventId: "provider-event-concurrent", sessionId: "s-concurrent", uid: "u-concurrent" };
  const results = await Promise.all([applyVerifiedPartnerEvent(event), applyVerifiedPartnerEvent(event)]);
  assert.equal(results.filter((r) => r.credited).length, 1);
  assert.equal((await db.doc("wallets/u-concurrent").get()).get("balanceMinor"), 250);
});

test("suspended account cannot receive reward", async () => {
  await seed("u-suspended", "s-suspended");
  await db.doc("users/u-suspended").update({ status: "suspended" });
  await assert.rejects(applyVerifiedPartnerEvent({
    provider: "test-network", providerEventId: "provider-event-suspended", sessionId: "s-suspended", uid: "u-suspended",
  }), /not eligible/);
});

test("daily reward limit allows the final permitted reward and rejects the next", async () => {
  await seed("u-limit", "s-limit");
  const day = new Intl.DateTimeFormat("en-CA", { timeZone: "Africa/Nairobi", year: "numeric", month: "2-digit", day: "2-digit" }).format(new Date());
  await db.doc(`dailyRewardCounters/u-limit_${day}`).update({ creditedCount: 2 });
  const finalAllowed = await applyVerifiedPartnerEvent({
    provider: "test-network", providerEventId: "provider-event-third", sessionId: "s-limit", uid: "u-limit",
  });
  assert.equal(finalAllowed.credited, true);
  await db.doc("adSessions/s-limit").set({
    uid: "u-limit", dayKey: day, status: "issued",
    createdAt: new Date(), expiresAt: new Date(Date.now() + 300000),
  });
  await assert.rejects(applyVerifiedPartnerEvent({
    provider: "test-network", providerEventId: "provider-event-fourth", sessionId: "s-limit", uid: "u-limit",
  }), /daily reward limit/i);
});

test("same external event ID from different providers is independently namespaced", async () => {
  await seed("u-provider-a", "s-provider-a");
  await seed("u-provider-b", "s-provider-b");
  const [a, b] = await Promise.all([
    applyVerifiedPartnerEvent({
      provider: "network-a", providerEventId: "shared-external-id",
      sessionId: "s-provider-a", uid: "u-provider-a",
    }),
    applyVerifiedPartnerEvent({
      provider: "network-b", providerEventId: "shared-external-id",
      sessionId: "s-provider-b", uid: "u-provider-b",
    }),
  ]);
  assert.equal(a.credited, true);
  assert.equal(b.credited, true);
  assert.equal((await db.doc("wallets/u-provider-a").get()).get("balanceMinor"), 250);
  assert.equal((await db.doc("wallets/u-provider-b").get()).get("balanceMinor"), 250);
});

test("one session cannot be credited by two different provider events", async () => {
  await seed("u-session-once", "s-session-once");
  const first = await applyVerifiedPartnerEvent({
    provider: "network-a", providerEventId: "event-one",
    sessionId: "s-session-once", uid: "u-session-once",
  });
  assert.equal(first.credited, true);
  await assert.rejects(applyVerifiedPartnerEvent({
    provider: "network-b", providerEventId: "event-two",
    sessionId: "s-session-once", uid: "u-session-once",
  }), /already-used/);
  assert.equal((await db.doc("wallets/u-session-once").get()).get("balanceMinor"), 250);
});

test("concurrent distinct rewards preserve wallet and ledger consistency", async () => {
  const uid = "u-wallet-race";
  const day = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Africa/Nairobi", year: "numeric", month: "2-digit", day: "2-digit",
  }).format(new Date());
  await db.doc(`users/${uid}`).set({ status: "active", verificationStatus: "approved" });
  await db.doc(`dailyRewardCounters/${uid}_${day}`).set({
    uid, dayKey: day, issuedCount: 2, creditedCount: 0,
  });
  for (const sessionId of ["s-wallet-race-a", "s-wallet-race-b"]) {
    await db.doc(`adSessions/${sessionId}`).set({
      uid, dayKey: day, status: "issued",
      createdAt: new Date(), expiresAt: new Date(Date.now() + 300000),
    });
  }
  const results = await Promise.all([
    applyVerifiedPartnerEvent({
      provider: "network-a", providerEventId: "wallet-race-a",
      sessionId: "s-wallet-race-a", uid,
    }),
    applyVerifiedPartnerEvent({
      provider: "network-b", providerEventId: "wallet-race-b",
      sessionId: "s-wallet-race-b", uid,
    }),
  ]);
  assert.equal(results.filter((r) => r.credited).length, 2);
  assert.equal((await db.doc(`wallets/${uid}`).get()).get("balanceMinor"), 500);
  assert.equal((await db.doc(`dailyRewardCounters/${uid}_${day}`).get()).get("creditedCount"), 2);
  assert.equal((await db.collection("rewardLedger").where("uid", "==", uid).get()).size, 2);
});
