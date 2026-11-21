/// Product switches for features that are deliberately turned off.
class AppFeatures {
  AppFeatures._();

  /// Ad rewards remain disabled until the business model, legal review,
  /// server-side ledger and partner terms are approved and implemented.
  static const bool rewardsEnabled = false;

  /// Withdrawals remain disabled until a secure, approved server-side payout
  /// system exists. The UI route and service operation both enforce this.
  static const bool withdrawalsEnabled = false;
}
