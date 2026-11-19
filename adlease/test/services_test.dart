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

  group('WalletService disables customer money movement', () {
    test('does not allow local earnings or reward credits', () async {
      expect(
        () => WalletService().addEarning('u1', 10, 'test'),
        throwsA(isA<StateError>()),
      );
    });
    test('does not allow withdrawals', () async {
      expect(
        () => WalletService().requestWithdrawal(
          userId: 'u1',
          amount: 1,
          paymentMethod: 'M-Pesa',
          paymentDetails: '0700000000',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('WalletService ignores legacy customer value', () {
    test(
      'legacy stored wallet balances and reward transactions are not exposed',
      () async {
        SharedPreferences.setMockInitialValues({
          'adlease_wallets': '[{"userId":"u1","balance":99,"totalEarnings":99,"totalWithdrawn":0,"lastUpdated":"2026-01-01T00:00:00.000"}]',
          'adlease_transactions': '[{"id":"legacy","userId":"u1","type":"adReward","amount":2.5,"status":"completed","description":"legacy reward","createdAt":"2026-01-01T00:00:00.000"}]',
        });
        final wallet = WalletService();
        expect((await wallet.getWallet('u1')).balance, 0);
        expect(await wallet.getTransactions('u1'), isEmpty);
      },
    );
  });

  group('AdService disables ad tracking and rewards', () {
    test('completed ad views are rejected', () async {
      expect(
        () => AdService().recordAdView(
          userId: 'u1',
          adId: 'ad1',
          completedFully: true,
          deviceId: '',
        ),
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
