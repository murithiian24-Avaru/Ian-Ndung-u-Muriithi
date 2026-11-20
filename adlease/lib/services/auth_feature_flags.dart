/// Google sign-in stays disabled until provider configuration, a security
/// review and complete onboarding tests exist. Do not flip this flag in a
/// feature PR; test/app_mode_test.dart fails if it changes.
const bool kGoogleSignInEnabled = false;

class FeatureDisabledException implements Exception {
  const FeatureDisabledException(this.feature);

  final String feature;

  @override
  String toString() => 'FeatureDisabledException: $feature is disabled.';
}

/// Call first inside any Google sign-in entry point.
void ensureGoogleSignInAllowed() {
  if (!kGoogleSignInEnabled) {
    throw const FeatureDisabledException('google_sign_in');
  }
}
