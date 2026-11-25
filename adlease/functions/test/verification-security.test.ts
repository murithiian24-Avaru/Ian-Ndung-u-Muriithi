import assert from "node:assert/strict";
import { test } from "node:test";
import {
  assertCustomerAccountStatus,
  assertFreshMfaReviewer,
  assertLiveReviewerAuthorization,
  assertVerificationState,
  assertVerifiedEmail,
  nextVerificationRequestWindow,
} from "../src/security";

test("verification request limit allows three attempts then rejects the fourth", () => {
  const now = 1_800_000_000_000;
  const first = nextVerificationRequestWindow(undefined, 0, now);
  const second = nextVerificationRequestWindow(first.windowStartedAt, first.requestCount, now + 1);
  const third = nextVerificationRequestWindow(second.windowStartedAt, second.requestCount, now + 2);

  assert.equal(first.requestCount, 1);
  assert.equal(second.requestCount, 2);
  assert.equal(third.requestCount, 3);
  assert.throws(
    () => nextVerificationRequestWindow(third.windowStartedAt, third.requestCount, now + 3),
    (error: unknown) =>
      error instanceof Error &&
      "code" in error &&
      error.code === "resource-exhausted",
  );
});

test("verification request limit resets after its 24-hour window", () => {
  const now = 1_800_000_000_000;
  const first = nextVerificationRequestWindow(undefined, 0, now);
  const second = nextVerificationRequestWindow(
    first.windowStartedAt,
    2,
    now + 24 * 60 * 60 * 1000,
  );
  assert.equal(second.requestCount, 1);
  assert.equal(second.windowStartedAt.getTime(), now + 24 * 60 * 60 * 1000);
});

test("invalid verification request counters fail closed", () => {
  assert.throws(
    () => nextVerificationRequestWindow(new Date(1_800_000_000_000), -1, 1_800_000_000_001),
    (error: unknown) =>
      error instanceof Error &&
      "code" in error &&
      error.code === "failed-precondition",
  );
});

test("reviewer session accepts a recent Firebase MFA sign-in", () => {
  const now = 1_800_000_000_000;
  assert.doesNotThrow(() =>
    assertFreshMfaReviewer(
      {
        firebase: { sign_in_second_factor: "phone" },
        auth_time: Math.floor(now / 1000),
      },
      now,
    ),
  );
});

test("reviewer session rejects missing MFA", () => {
  const now = 1_800_000_000_000;
  assert.throws(
    () => assertFreshMfaReviewer({ firebase: {}, auth_time: Math.floor(now / 1000) }, now),
    (error: unknown) =>
      error instanceof Error &&
      "code" in error &&
      error.code === "permission-denied",
  );
});

test("reviewer session rejects stale and future authentication times", () => {
  const now = 1_800_000_000_000;
  const mfa = { firebase: { sign_in_second_factor: "phone" } };
  assert.throws(
    () =>
      assertFreshMfaReviewer(
        { ...mfa, auth_time: Math.floor((now - 11 * 60 * 1000) / 1000) },
        now,
      ),
    (error: unknown) =>
      error instanceof Error &&
      "code" in error &&
      error.code === "unauthenticated",
  );
  assert.throws(
    () =>
      assertFreshMfaReviewer(
        { ...mfa, auth_time: Math.floor((now + 2 * 60 * 1000) / 1000) },
        now,
      ),
    (error: unknown) =>
      error instanceof Error &&
      "code" in error &&
      error.code === "unauthenticated",
  );
});

test("customer access requires a non-disabled Firebase account with verified email", () => {
  assert.doesNotThrow(() => assertVerifiedEmail({ disabled: false, emailVerified: true }));
  assert.throws(
    () => assertVerifiedEmail({ disabled: true, emailVerified: true }),
    (error: unknown) => error instanceof Error && "code" in error && error.code === "permission-denied",
  );
  assert.throws(
    () => assertVerifiedEmail({ disabled: false, emailVerified: false }),
    (error: unknown) => error instanceof Error && "code" in error && error.code === "unauthenticated",
  );
});

test("customer account and verification states fail closed", () => {
  assert.doesNotThrow(() => assertCustomerAccountStatus("pending"));
  assert.doesNotThrow(() => assertCustomerAccountStatus("active"));
  assert.throws(() => assertCustomerAccountStatus("suspended"));
  assert.throws(() => assertCustomerAccountStatus("closed"));
  assert.throws(() => assertCustomerAccountStatus("unexpected"));
  for (const state of ["not_started", "pending", "approved", "rejected"]) {
    assert.doesNotThrow(() => assertVerificationState(state));
  }
  assert.throws(() => assertVerificationState("unknown"));
});


test("reviewer authorization requires a current live role and matching token claims", () => {
  assert.doesNotThrow(() => assertLiveReviewerAuthorization({ verificationReviewer: true }, { verificationReviewer: true }));
  assert.doesNotThrow(() => assertLiveReviewerAuthorization({ admin: true }, { admin: true }));
  const revokedOrStaleCases: Array<[Record<string, unknown>, Record<string, unknown>]> = [
    [{}, { verificationReviewer: true }],
    [{ verificationReviewer: true }, {}],
    [{}, { admin: true }],
    [{ admin: true }, { verificationReviewer: true }],
  ];
  for (const [live, token] of revokedOrStaleCases) {
    assert.throws(
      () => assertLiveReviewerAuthorization(live, token),
      (error: unknown) => error instanceof Error && "code" in error && error.code === "permission-denied",
    );
  }
});

test("revoked reviewer role is denied even when an old token still carries reviewer claim", () => {
  assert.throws(
    () => assertLiveReviewerAuthorization({}, { verificationReviewer: true }),
    (error: unknown) => error instanceof Error && "code" in error && error.code === "permission-denied",
  );
});
