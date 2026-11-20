/// Application-level authentication stages. Email verification, profile
/// initialization and identity (KYC) verification are separate things:
/// this enum covers only the first two. `customerShell` does NOT mean the
/// customer is identity-verified, credit-approved or fully active.
enum AuthStage {
  signedOut,
  verificationPending,
  checkingProfile,
  profileCompletion,
  customerShell,
  blocked,
}

enum ProfileLookup { notChecked, missing, present }

/// Server account statuses the app may show a customer shell for. Anything
/// else (suspended, closed, or unknown) fails closed to `blocked`.
const Set<String> kCustomerShellStatuses = {'pending', 'active'};

AuthStage resolveAuthStage({
  required bool signedIn,
  required bool emailVerified,
  required ProfileLookup profile,
  String? accountStatus,
}) {
  if (!signedIn) return AuthStage.signedOut;
  if (!emailVerified) return AuthStage.verificationPending;
  if (profile == ProfileLookup.notChecked) return AuthStage.checkingProfile;
  if (profile == ProfileLookup.missing) return AuthStage.profileCompletion;
  return kCustomerShellStatuses.contains(accountStatus)
      ? AuthStage.customerShell
      : AuthStage.blocked;
}
