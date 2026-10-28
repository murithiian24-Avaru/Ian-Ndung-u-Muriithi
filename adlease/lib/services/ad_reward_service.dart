import 'package:adlease/models/ownership_model.dart';
import 'package:adlease/services/ad_service.dart';
import 'package:adlease/services/ownership_service.dart';

enum AdRewardOutcome {
  /// The simulated reward was added to the user's phone-ownership progress.
  credited,

  /// The user has not chosen a phone, so there is nothing to credit.
  noActivePhone,

  /// The view was refused, for example because today's limit was reached.
  rejected,
}

class AdRewardResult {
  final AdRewardOutcome outcome;
  final OwnershipModel? ownership;

  const AdRewardResult(this.outcome, [this.ownership]);
}

/// Applies the reward for a completed (simulated) ad.
///
/// The reward goes to ONE place only: the user's phone-ownership progress.
/// It is never added to a cash wallet, so it cannot be counted twice or look
/// like withdrawable money. Ads and rewards are simulated: there is no ad
/// network, no payment and no real money.
class AdRewardService {
  final AdService _ads;
  final OwnershipService _ownership;

  AdRewardService({AdService? ads, OwnershipService? ownership})
      : _ads = ads ?? AdService(),
        _ownership = ownership ?? OwnershipService();

  Future<AdRewardResult> claim({
    required String userId,
    required String adId,
    required String deviceId,
  }) async {
    final current = await _ownership.getUserOwnership(userId);
    if (current == null) {
      return const AdRewardResult(AdRewardOutcome.noActivePhone);
    }

    try {
      await _ads.recordAdView(
        userId: userId,
        adId: adId,
        completedFully: true,
        deviceId: deviceId,
      );
    } on StateError {
      return const AdRewardResult(AdRewardOutcome.rejected);
    }

    final updated = await _ownership.addPayment(userId, AdService.rewardPerAd);
    return AdRewardResult(AdRewardOutcome.credited, updated);
  }
}
