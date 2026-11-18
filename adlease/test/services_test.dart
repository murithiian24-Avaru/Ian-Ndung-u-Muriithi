// Tests for the audit fixes on branch fix/adlease-audit-safe-fixes.
// Run with: flutter test
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adlease/services/ad_service.dart';
import 'package:adlease/services/auth_service.dart';
import 'package:adlease/services/wallet_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WalletService.requestWithdrawal (finding C5)', () {
    test('deducts the requested amount from the balance', () async {
      final wallet = WalletService();
      await wallet.addEarning('u1', 10, 'test earning');

      await wallet.requestWithdrawal(
        userId: 'u1',
        amount: 6,
        paymentMethod: 'M-Pesa',
        paymentDetails: '0700000000',
      );

      final after = await wallet.getWallet('u1');
      expect(after.balance, 4);
    });

    test('rejects a second withdrawal of the same balance', () async {
      final wallet = WalletService();
      await wallet.addEarning('u1', 10, 'test earning');

      await wallet.requestWithdrawal(
        userId: 'u1',
        amount: 10,
        paymentMethod: 'M-Pesa',
        paymentDetails: '0700000000',
      );

      expect(
        () => wallet.requestWithdrawal(
          userId: 'u1',
          amount: 10,
          paymentMethod: 'M-Pesa',
          paymentDetails: '0700000000',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('rejects zero or negative amounts', () async {
      final wallet = WalletService();
      await wallet.addEarning('u1', 10, 'test earning');
      expect(
        () => wallet.requestWithdrawal(
          userId: 'u1',
          amount: 0,
          paymentMethod: 'M-Pesa',
          paymentDetails: '0700000000',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('AdService.recordAdView daily limit (finding H4)', () {
    test('allows maxAdsPerDay completed views, then refuses more', () async {
      final ads = AdService();
      for (var i = 0; i < AdService.maxAdsPerDay; i++) {
        await ads.recordAdView(
          userId: 'u1',
          adId: 'ad$i',
          completedFully: true,
          deviceId: '',
        );
      }
      expect(await ads.getAdsWatchedToday('u1'), AdService.maxAdsPerDay);
      expect(
        () => ads.recordAdView(
          userId: 'u1',
          adId: 'extra',
          completedFully: true,
          deviceId: '',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('the limit is per user', () async {
      final ads = AdService();
      for (var i = 0; i < AdService.maxAdsPerDay; i++) {
        await ads.recordAdView(
          userId: 'u1',
          adId: 'ad$i',
          completedFully: true,
          deviceId: '',
        );
      }
      expect(await ads.canWatchAd('u2'), isTrue);
    });
  });

  group('AuthService placeholders (findings H1, H2)', () {
    test('Google sign-in no longer logs into a demo account', () async {
      expect(() => AuthService().signInWithGoogle(), throwsA(isA<Exception>()));
    });

    test('password reset does not pretend to send an email', () async {
      expect(
        () => AuthService().resetPassword('someone@example.com'),
        throwsA(isA<Exception>()),
      );
    });
  });
  group('Local password hashing hardening', () {
    test('new accounts use unique salted PBKDF2 hashes', () async {
      final auth = AuthService();
      await auth.signUp(
        email: 'hash-one@example.com',
        password: 'Password123!',
        fullName: 'Hash One',
        phoneNumber: '+254700000001',
        country: 'Kenya',
      );
      await auth.signUp(
        email: 'hash-two@example.com',
        password: 'Password123!',
        fullName: 'Hash Two',
        phoneNumber: '+254700000002',
        country: 'Kenya',
      );

      final prefs = await SharedPreferences.getInstance();
      final users = List<Map<String, dynamic>>.from(
        jsonDecode(prefs.getString('adlease_users')!),
      );
      final hash1 = users.first['passwordHash'] as String;
      final hash2 = users.last['passwordHash'] as String;
      final delimiter = String.fromCharCode(36);
      final prefix = ['pbkdf2_sha256', '120000'].join(delimiter) + delimiter;
      expect(hash1, startsWith(prefix));
      expect(hash2, startsWith(prefix));
      expect(hash1, isNot(hash2));

      final signedIn = await auth.signIn(
        email: 'hash-one@example.com',
        password: 'Password123!',
      );
      expect(signedIn.email, 'hash-one@example.com');
      await expectLater(
        auth.signIn(email: 'hash-one@example.com', password: 'wrong-password'),
        throwsA(isA<Exception>()),
      );
    });

    test('verifies the PBKDF2-HMAC-SHA256 known vector', () async {
      const password = 'Password123!';
      final delimiter = String.fromCharCode(36);
      final encodedHash = [
        'pbkdf2_sha256',
        '120000',
        '00112233445566778899aabbccddeeff',
        'a347c459bf2630291c32e2074384328bfce1c0fc110d4dac12d85f85b8ab88ee',
      ].join(delimiter);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'adlease_users',
        jsonEncode([
          {
            'uid': 'pbkdf2-vector',
            'email': 'vector@example.com',
            'fullName': 'Vector Test',
            'phoneNumber': '+254700000004',
            'country': 'Kenya',
            'profilePictureUrl': '',
            'referralCode': 'ADL-VECTOR01',
            'referredBy': null,
            'deviceModel': '',
            'deviceId': '',
            'createdAt': DateTime.now().toIso8601String(),
            'lastLoginAt': DateTime.now().toIso8601String(),
            'isVerified': false,
            'isActive': true,
            'passwordHash': encodedHash,
          }
        ]),
      );
      final signedIn = await AuthService().signIn(
        email: 'vector@example.com',
        password: password,
      );
      expect(signedIn.uid, 'pbkdf2-vector');
    });

    test('upgrades legacy SHA-256 hash after successful login', () async {
      const password = 'LegacyPass123!';
      final legacyHash = sha256.convert(utf8.encode(password)).toString();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'adlease_users',
        jsonEncode([
          {
            'uid': 'legacy-user',
            'email': 'legacy@example.com',
            'fullName': 'Legacy User',
            'phoneNumber': '+254700000003',
            'country': 'Kenya',
            'profilePictureUrl': '',
            'referralCode': 'ADL-LEGACY01',
            'referredBy': null,
            'deviceModel': '',
            'deviceId': '',
            'createdAt': DateTime.now().toIso8601String(),
            'lastLoginAt': DateTime.now().toIso8601String(),
            'isVerified': false,
            'isActive': true,
            'passwordHash': legacyHash,
          }
        ]),
      );

      final user = await AuthService().signIn(
        email: 'legacy@example.com',
        password: password,
      );
      expect(user.uid, 'legacy-user');

      final migratedUsers = List<Map<String, dynamic>>.from(
        jsonDecode(prefs.getString('adlease_users')!),
      );
      final migratedHash = migratedUsers.single['passwordHash'] as String;
      final delimiter = String.fromCharCode(36);
      expect(
        migratedHash,
        startsWith(['pbkdf2_sha256', '120000'].join(delimiter) + delimiter),
      );
      expect(migratedHash, isNot(legacyHash));
    });
  });

}
