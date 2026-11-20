import { HttpsError } from "firebase-functions/v2/https";

const VERIFICATION_WINDOW_MS = 24 * 60 * 60 * 1000;
const MAX_VERIFICATION_REQUESTS = 3;

export type CustomerAccountStatus = "pending" | "active";

export function assertVerifiedEmail(user: {
  disabled: boolean;
  emailVerified: boolean;
}): void {
  if (user.disabled) {
    throw new HttpsError("permission-denied", "This account is disabled.");
  }
  if (!user.emailVerified) {
    throw new HttpsError("unauthenticated", "Verify your email address before continuing.");
  }
}

export function assertCustomerAccountStatus(status: unknown): asserts status is CustomerAccountStatus {
  if (status === "suspended" || status === "closed") {
    throw new HttpsError("permission-denied", "This account cannot use customer services.");
  }
  if (status !== "pending" && status !== "active") {
    throw new HttpsError("failed-precondition", "Customer account status is invalid.");
  }
}

export function assertVerificationState(status: unknown): void {
  if (!["not_started", "pending", "approved", "rejected"].includes(String(status))) {
    throw new HttpsError("failed-precondition", "Verification state is invalid.");
  }
}

export function nextVerificationRequestWindow(
  windowStart: Date | undefined,
  previousCount: number,
  nowMs: number,
): { windowStartedAt: Date; requestCount: number } {
  const inWindow =
    windowStart !== undefined && nowMs - windowStart.getTime() < VERIFICATION_WINDOW_MS;
  const count = inWindow ? previousCount : 0;
  if (!Number.isInteger(count) || count < 0) {
    throw new HttpsError("failed-precondition", "Verification request counter is invalid.");
  }
  if (count >= MAX_VERIFICATION_REQUESTS) {
    throw new HttpsError(
      "resource-exhausted",
      "Too many verification requests. Try again after the 24-hour limit resets.",
    );
  }
  return {
    windowStartedAt: inWindow ? windowStart : new Date(nowMs),
    requestCount: count + 1,
  };
}

export function assertFreshMfaReviewer(
  token: Record<string, unknown>,
  nowMs = Date.now(),
): void {
  const firebaseClaims = token.firebase as Record<string, unknown> | undefined;
  if (
    typeof firebaseClaims?.sign_in_second_factor !== "string" ||
    !firebaseClaims.sign_in_second_factor
  ) {
    throw new HttpsError(
      "permission-denied",
      "Multi-factor authentication is required for verification reviewers.",
    );
  }

  const authTime = Number(token.auth_time ?? 0);
  const nowSeconds = Math.floor(nowMs / 1000);
  if (
    !authTime ||
    authTime > nowSeconds + 60 ||
    nowMs - authTime * 1000 > 10 * 60 * 1000
  ) {
    throw new HttpsError(
      "unauthenticated",
      "A recent sign-in is required for verification decisions.",
    );
  }
}
