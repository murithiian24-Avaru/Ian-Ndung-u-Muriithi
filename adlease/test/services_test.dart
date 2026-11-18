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

  group('AdService disables ad tracking and rewards', () {
    test('completed ad views are rejected', () async {
      expect(
        () => AdService().recordAdView(userId: 'u1', adId: 'ad1', completedFully: true, deviceId: ''),
        throwsA(isA<StateError>()),
      );
    });
    test('legacy reward amount is zero', () {
      expect(AdService.rewardPerAd, 0);
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
