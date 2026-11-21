// Tests for demo-only and financial feature guards.
// Run with: flutter test
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adlease/services/ad_reward_service.dart';
import 'package:adlease/services/ad_service.dart';
import 'package:adlease/services/auth_service.dart';
import 'package:adlease/services/wallet_service.dart';
import 'package:adlease/services/ownership_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Disabled financial features', () {
    test(
      'wallet rejects local reward credits while rewards are disabled',
      () async {
        final wallet = WalletService();

        await expectLater(
          wallet.addEarning('u1', 10, 'test earning'),
          throwsA(isA<StateError>()),
        );
      },
    );

    test('withdrawal request is rejected before balance or payment details are stored', () async {
      final wallet = WalletService();

      await expectLater(
        wallet.requestWithdrawal(
          userId: 'u1',
          amount: 10,
          paymentMethod: 'M-Pesa',
          paymentDetails: '0700000000',
        ),
        throwsA(isA<StateError>()),
      );

      expect((await wallet.getUserWithdrawals('u1')), isEmpty);
      expect((await wallet.getTransactions('u1')), isEmpty);
      expect((await wallet.getWallet('u1')).balance, 0);
    });

    test('direct phone progress credits are rejected', () async {
      await expectLater(
        OwnershipService().addPayment('u1', 10),
        throwsA(isA<StateError>()),
      );
    });

    test(
      'ad reward claims are rejected before touching ownership or ad history',
      () async {
        final result = await AdRewardService().claim(
          userId: 'u1',
          adId: 'sample-ad',
          deviceId: 'demo-device',
        );

        expect(result.outcome, AdRewardOutcome.rejected);
        expect(result.ownership, isNull);
        expect(await AdService().getAdsWatchedToday('u1'), 0);
      },
    );
  });

  group('AdService.recordAdView daily limit (demo playback only)', () {
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

  group('AuthService placeholders', () {
    test('Google sign-in does not log into a demo account', () async {
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
