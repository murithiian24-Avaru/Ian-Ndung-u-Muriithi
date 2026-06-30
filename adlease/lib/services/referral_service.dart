import 'dart:convert';
import 'package:adlease/services/storage_service.dart';

class ReferralService {
  final StorageService _storage = StorageService();
  static const _referralsKey = 'adlease_referrals';
  static const double referralReward = 5.0;

  Future<List<Map<String, dynamic>>> getReferrals(String userId) async {
    final data = await _storage.getString(_referralsKey);
    if (data == null) return [];
    final list = List<Map<String, dynamic>>.from(jsonDecode(data));
    return list.where((r) => r['referrerId'] == userId).toList();
  }

  Future<int> getReferralCount(String userId) async {
    final referrals = await getReferrals(userId);
    return referrals.length;
  }

  Future<double> getTotalReferralEarnings(String userId) async {
    final referrals = await getReferrals(userId);
    return referrals.length * referralReward;
  }

  Future<void> recordReferral({
    required String referrerId,
    required String referredUserId,
    required String referredUserName,
  }) async {
    final data = await _storage.getString(_referralsKey);
    final list = data != null
        ? List<Map<String, dynamic>>.from(jsonDecode(data))
        : <Map<String, dynamic>>[];

    list.add({
      'referrerId': referrerId,
      'referredUserId': referredUserId,
      'referredUserName': referredUserName,
      'date': DateTime.now().toIso8601String(),
      'rewardAmount': referralReward,
    });

    await _storage.saveString(_referralsKey, jsonEncode(list));
  }
}
