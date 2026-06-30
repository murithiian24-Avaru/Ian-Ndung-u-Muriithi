import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:adlease/models/ad_model.dart';
import 'package:adlease/services/storage_service.dart';

class AdService {
  final StorageService _storage = StorageService();
  static const _adsKey = 'adlease_ads';
  static const _viewRecordsKey = 'adlease_ad_views';
  static const int maxAdsPerDay = 3;
  static const double rewardPerAd = 2.50;

  Future<List<AdModel>> getAvailableAds() async {
    final data = await _storage.getString(_adsKey);
    if (data != null) {
      final list = List<Map<String, dynamic>>.from(jsonDecode(data));
      return list.map((e) => AdModel.fromMap(e)).toList();
    }

    final sampleAds = _generateSampleAds();
    await _storage.saveString(
      _adsKey,
      jsonEncode(sampleAds.map((e) => e.toMap()).toList()),
    );
    return sampleAds;
  }

  List<AdModel> _generateSampleAds() {
    return [
      AdModel(
        id: const Uuid().v4(),
        title: 'Safaricom M-Pesa Go',
        advertiserName: 'Safaricom',
        videoUrl: 'https://example.com/ads/safaricom.mp4',
        thumbnailUrl: '',
        durationSeconds: 60,
        rewardAmount: rewardPerAd,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
      AdModel(
        id: const Uuid().v4(),
        title: 'Samsung Galaxy S24 Launch',
        advertiserName: 'Samsung',
        videoUrl: 'https://example.com/ads/samsung.mp4',
        thumbnailUrl: '',
        durationSeconds: 60,
        rewardAmount: rewardPerAd,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
      AdModel(
        id: const Uuid().v4(),
        title: 'Equity Bank Digital Account',
        advertiserName: 'Equity Bank',
        videoUrl: 'https://example.com/ads/equity.mp4',
        thumbnailUrl: '',
        durationSeconds: 60,
        rewardAmount: rewardPerAd,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
      AdModel(
        id: const Uuid().v4(),
        title: 'Tecno Camon 20 Pro',
        advertiserName: 'Tecno Mobile',
        videoUrl: 'https://example.com/ads/tecno.mp4',
        thumbnailUrl: '',
        durationSeconds: 60,
        rewardAmount: rewardPerAd,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
      AdModel(
        id: const Uuid().v4(),
        title: 'KCB M-Shwari Savings',
        advertiserName: 'KCB Bank',
        videoUrl: 'https://example.com/ads/kcb.mp4',
        thumbnailUrl: '',
        durationSeconds: 60,
        rewardAmount: rewardPerAd,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
    ];
  }

  Future<int> getAdsWatchedToday(String userId) async {
    final records = await _getViewRecords();
    final today = DateTime.now();
    return records
        .where((r) =>
            r.userId == userId &&
            r.viewedAt.year == today.year &&
            r.viewedAt.month == today.month &&
            r.viewedAt.day == today.day)
        .length;
  }

  Future<int> getRemainingAdsToday(String userId) async {
    final watched = await getAdsWatchedToday(userId);
    return (maxAdsPerDay - watched).clamp(0, maxAdsPerDay);
  }

  Future<bool> canWatchAd(String userId) async {
    final remaining = await getRemainingAdsToday(userId);
    return remaining > 0;
  }

  String _generateVerificationHash(String userId, String adId, DateTime timestamp) {
    final data = '$userId:$adId:${timestamp.toIso8601String()}:adlease_secret';
    return sha256.convert(utf8.encode(data)).toString();
  }

  Future<AdViewRecord> recordAdView({
    required String userId,
    required String adId,
    required bool completedFully,
    required String deviceId,
  }) async {
    final now = DateTime.now();
    final record = AdViewRecord(
      id: const Uuid().v4(),
      userId: userId,
      adId: adId,
      viewedAt: now,
      completedFully: completedFully,
      rewardEarned: completedFully ? rewardPerAd : 0,
      deviceId: deviceId,
      verificationHash: _generateVerificationHash(userId, adId, now),
    );

    final records = await _getViewRecords();
    records.add(record);
    await _storage.saveString(
      _viewRecordsKey,
      jsonEncode(records.map((r) => r.toMap()).toList()),
    );

    return record;
  }

  Future<List<AdViewRecord>> _getViewRecords() async {
    final data = await _storage.getString(_viewRecordsKey);
    if (data == null) return [];
    final list = List<Map<String, dynamic>>.from(jsonDecode(data));
    return list.map((e) => AdViewRecord.fromMap(e)).toList();
  }

  Future<List<AdViewRecord>> getUserViewHistory(String userId) async {
    final records = await _getViewRecords();
    return records.where((r) => r.userId == userId).toList()
      ..sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
  }

  Future<DateTime?> getNextRewardTime(String userId) async {
    final records = await _getViewRecords();
    final today = DateTime.now();
    final todayRecords = records
        .where((r) =>
            r.userId == userId &&
            r.viewedAt.year == today.year &&
            r.viewedAt.month == today.month &&
            r.viewedAt.day == today.day)
        .toList()
      ..sort((a, b) => b.viewedAt.compareTo(a.viewedAt));

    if (todayRecords.isEmpty) return null;
    return todayRecords.first.viewedAt.add(const Duration(hours: 4));
  }
}
