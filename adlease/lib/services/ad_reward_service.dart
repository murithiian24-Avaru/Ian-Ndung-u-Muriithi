/// Ad rewards are disabled by product policy. This compatibility service
/// deliberately refuses all claims so stale callers cannot issue value.
class AdRewardService {
  Future<Never> claim({
    required String userId,
    required String adId,
    required String deviceId,
  }) async {
    throw StateError(
      'Ad rewards are disabled. Advertising activity cannot create customer value.',
    );
  }
}
