import 'package:flutter/foundation.dart';
import 'package:adlease/models/ad_model.dart';
import 'package:adlease/services/ad_service.dart';

class AdProvider extends ChangeNotifier {
  final AdService _adService = AdService();
  List<AdModel> _availableAds = [];
  List<AdViewRecord> _viewHistory = [];
  int _adsWatchedToday = 0;
  int _adsRemainingToday = 3;
  DateTime? _nextRewardTime;
  bool _isLoading = false;

  List<AdModel> get availableAds => _availableAds;
  List<AdViewRecord> get viewHistory => _viewHistory;
  int get adsWatchedToday => _adsWatchedToday;
  int get adsRemainingToday => _adsRemainingToday;
  DateTime? get nextRewardTime => _nextRewardTime;
  bool get isLoading => _isLoading;
  bool get canWatchAd => _adsRemainingToday > 0;

  Future<void> loadAds(String userId) async {
    _isLoading = true;
    notifyListeners();

    _availableAds = await _adService.getAvailableAds();
    _adsWatchedToday = await _adService.getAdsWatchedToday(userId);
    _adsRemainingToday = await _adService.getRemainingAdsToday(userId);
    _viewHistory = await _adService.getUserViewHistory(userId);
    _nextRewardTime = await _adService.getNextRewardTime(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<AdViewRecord?> recordAdView({
    required String userId,
    required String adId,
    required bool completedFully,
    required String deviceId,
  }) async {
    try {
      final record = await _adService.recordAdView(
        userId: userId,
        adId: adId,
        completedFully: completedFully,
        deviceId: deviceId,
      );

      _adsWatchedToday = await _adService.getAdsWatchedToday(userId);
      _adsRemainingToday = await _adService.getRemainingAdsToday(userId);
      _viewHistory = await _adService.getUserViewHistory(userId);
      _nextRewardTime = await _adService.getNextRewardTime(userId);

      notifyListeners();
      return record;
    } catch (e) {
      debugPrint('Error recording ad view: $e');
      return null;
    }
  }
}
