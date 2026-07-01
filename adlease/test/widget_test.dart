import 'package:flutter_test/flutter_test.dart';
import 'package:adlease/models/user_model.dart';
import 'package:adlease/models/ownership_model.dart';
import 'package:adlease/models/wallet_model.dart';
import 'package:adlease/models/transaction_model.dart';
import 'package:adlease/models/phone_model.dart';
import 'package:adlease/models/ad_model.dart';

void main() {
  group('UserModel', () {
    test('should create user from map', () {
      final map = {
        'uid': 'test-uid',
        'email': 'test@example.com',
        'fullName': 'Test User',
        'phoneNumber': '+254700000000',
        'country': 'Kenya',
        'referralCode': 'ADL-TEST1234',
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
      };
      final user = UserModel.fromMap(map);
      expect(user.uid, 'test-uid');
      expect(user.email, 'test@example.com');
      expect(user.fullName, 'Test User');
      expect(user.country, 'Kenya');
    });

    test('should serialize to map', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '+254700000000',
        country: 'Kenya',
        referralCode: 'ADL-TEST1234',
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 1, 1),
      );
      final map = user.toMap();
      expect(map['uid'], 'test-uid');
      expect(map['email'], 'test@example.com');
    });

    test('should copy with updated fields', () {
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '+254700000000',
        country: 'Kenya',
        referralCode: 'ADL-TEST1234',
        createdAt: DateTime(2024, 1, 1),
        lastLoginAt: DateTime(2024, 1, 1),
      );
      final updated = user.copyWith(fullName: 'Updated Name');
      expect(updated.fullName, 'Updated Name');
      expect(updated.email, 'test@example.com');
    });
  });

  group('OwnershipModel', () {
    test('should calculate progress percentage', () {
      final ownership = OwnershipModel(
        id: 'test-id',
        userId: 'user-id',
        phoneId: 'phone-id',
        phoneName: 'Samsung Galaxy A54',
        phonePrice: 300,
        amountPaid: 120,
        startDate: DateTime(2024, 1, 1),
      );
      expect(ownership.progressPercentage, 40);
      expect(ownership.remainingAmount, 180);
    });

    test('should cap progress at 100%', () {
      final ownership = OwnershipModel(
        id: 'test-id',
        userId: 'user-id',
        phoneId: 'phone-id',
        phoneName: 'Test Phone',
        phonePrice: 300,
        amountPaid: 350,
        startDate: DateTime(2024, 1, 1),
      );
      expect(ownership.progressPercentage, 100);
    });
  });

  group('WalletModel', () {
    test('should create wallet with correct balance', () {
      final wallet = WalletModel(
        userId: 'user-id',
        balance: 25.50,
        totalEarnings: 50.00,
        totalWithdrawn: 24.50,
        lastUpdated: DateTime.now(),
      );
      expect(wallet.balance, 25.50);
      expect(wallet.totalEarnings, 50.00);
    });

    test('should copy with new balance', () {
      final wallet = WalletModel(
        userId: 'user-id',
        balance: 25.50,
        totalEarnings: 50.00,
        totalWithdrawn: 24.50,
        lastUpdated: DateTime.now(),
      );
      final updated = wallet.copyWith(balance: 30.00);
      expect(updated.balance, 30.00);
      expect(updated.totalEarnings, 50.00);
    });
  });

  group('TransactionModel', () {
    test('should create transaction from map', () {
      final map = {
        'id': 'tx-id',
        'userId': 'user-id',
        'type': 'adReward',
        'amount': 2.50,
        'status': 'completed',
        'description': 'Ad reward',
        'createdAt': DateTime.now().toIso8601String(),
      };
      final tx = TransactionModel.fromMap(map);
      expect(tx.type, TransactionType.adReward);
      expect(tx.status, TransactionStatus.completed);
      expect(tx.amount, 2.50);
    });
  });

  group('PhoneModel', () {
    test('should return full name', () {
      final phone = PhoneModel(
        id: '1',
        brand: 'Samsung',
        model: 'Galaxy A54',
        imageUrl: '',
        price: 300,
        description: 'Test phone',
        specs: {'Display': '6.4" AMOLED'},
      );
      expect(phone.fullName, 'Samsung Galaxy A54');
    });
  });

  group('AdModel', () {
    test('should create ad from map', () {
      final map = {
        'id': 'ad-1',
        'title': 'Test Ad',
        'advertiserName': 'Test Corp',
        'videoUrl': 'https://example.com/video.mp4',
        'thumbnailUrl': '',
        'durationSeconds': 60,
        'rewardAmount': 2.50,
        'createdAt': DateTime.now().toIso8601String(),
        'expiresAt': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      };
      final ad = AdModel.fromMap(map);
      expect(ad.title, 'Test Ad');
      expect(ad.rewardAmount, 2.50);
      expect(ad.durationSeconds, 60);
    });
  });
}
