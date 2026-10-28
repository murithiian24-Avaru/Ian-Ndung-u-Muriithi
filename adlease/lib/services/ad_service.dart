import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:adlease/models/ad_model.dart';
import 'package:adlease/services/storage_service.dart';

class AdService {
  final StorageService _storage = StorageService();
  // 'adlease_ads' held the earlier samples that used real company names. They
  // are no longer read (and not deleted); generic samples use this key.
  static const _adsKey = 'adlease_ads_v2';
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

  /// Generic, clearly labelled sample ads for the demo. They must not use real
  /// company names, products or logos: no advertiser has agreed to appear.
  List<AdModel> _generateSampleAds() {
    return List.generate(5, (i) {
      final n = i + 1;
      return AdModel(
        id: const Uuid().v4(),
        title: 'Sample Ad $n',
        advertiserName: 'Sample Advertiser',
        videoUrl: 'https://example.com/sample-ads/sample-ad-$n.mp4',
        thumbnailUrl: '',
        durationSeconds: 60,
        rewardAmount: rewardPerAd,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
    });
  }

  Future<int> getAdsWatchedToday(String userId) async {
    final records = await _getViewRecords();
    final today = DateTime.now();
    return records
        .where(
          (r) =>
              r.userId == userId &&
              r.viewedAt.year == today.year &&
              r.viewedAt.month == today.month &&
              r.viewedAt.day == today.day,
        )
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

  String _generateVerificationHash(
    String userId,
    String adId,
    DateTime timestamp,
  ) {
    final data = '$userId:$adId:${timestamp.toIso8601String()}:adlease_secret';
    return sha256.convert(utf8.encode(data)).toString();
  }

  Future<AdViewRecord> recordAdView({
    required String userId,
    required String adId,
    required bool completedFully,
    required String deviceId,
  }) async {
    // Enforce the daily limit at the point the reward is recorded, not only
    // before an ad starts, so a second claim cannot exceed maxAdsPerDay.
    // (Still based on the device clock; a server must enforce this for real.)
    if (completedFully && !await canWatchAd(userId)) {
      throw StateError('Daily ad limit reached');
    }

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
    final todayRecords =
        records
            .where(
              (r) =>
                  r.userId == userId &&
                  r.viewedAt.year == today.year &&
                  r.viewedAt.month == today.month &&
                  r.viewedAt.day == today.day,
            )
            .toList()
          ..sort((a, b) => b.viewedAt.compareTo(a.viewedAt));

    if (todayRecords.isEmpty) return null;
    return todayRecords.first.viewedAt.add(const Duration(hours: 4));
  }
}
