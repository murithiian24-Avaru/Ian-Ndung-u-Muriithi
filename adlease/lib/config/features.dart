/// Runtime-safe defaults for product capabilities that are not approved for launch.
class AppFeatures {
  AppFeatures._();

  /// No user reward may be issued for an ad view or interaction.
  static const bool adRewardsEnabled = false;

  /// Ads remain disabled until Google policy and privacy review is complete.
  static const bool advertisingEnabled = false;

  /// Financing remains a mock/read-only product journey until a licensed
  /// partner and legal approvals are verified.
  static const bool liveFinancingEnabled = false;

  /// Payments remain sandbox-only until all release gates pass.
  static const bool livePaymentsEnabled = false;

  /// Withdrawals are disabled until an approved payout system exists.
  static const bool withdrawalsEnabled = false;
}
