// Tests for the audit fixes on branch fix/adlease-audit-safe-fixes.
// Run with: flutter test
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
}
