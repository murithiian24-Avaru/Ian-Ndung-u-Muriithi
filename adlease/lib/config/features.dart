/// Product switches for features that are deliberately turned off.
class AppFeatures {
  AppFeatures._();

  /// Withdrawals are hidden until a secure, approved payout system exists.
  /// While false, the app shows no withdraw buttons and has no withdrawal
  /// route. The withdrawal screen and any locally stored requests are kept,
  /// unused, so nothing is deleted.
  static const bool withdrawalsEnabled = false;
}
