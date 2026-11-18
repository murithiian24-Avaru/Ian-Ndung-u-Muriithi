// Regression tests for the Phase 2 product decisions:
// A. withdrawals hidden, B. generic sample ads, C. KSh amounts,
// D. a simulated ad reward goes to phone-ownership progress only.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adlease/config/features.dart';
import 'package:adlease/screens/wallet/wallet_screen.dart';
import 'package:adlease/config/routes.dart';
import 'package:adlease/l10n/app_localizations.dart';
import 'package:adlease/providers/auth_provider.dart';
import 'package:adlease/providers/ownership_provider.dart';
import 'package:adlease/providers/wallet_provider.dart';
import 'package:adlease/services/ad_reward_service.dart';
import 'package:adlease/services/ad_service.dart';
import 'package:adlease/utils/currency.dart';

const _realBrands = [
  'safaricom',
  'samsung',
  'equity',
  'kcb',
  'tecno',
  'm-pesa',
  'm-shwari',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('C. Kenyan shilling formatting', () {
    test('formats with KSh and two decimals by default', () {
      expect(formatKsh(2.5), 'KSh 2.50');
      expect(formatKsh(0), 'KSh 0.00');
    });

    test('groups thousands and supports whole shillings', () {
      expect(formatKsh(1250.5), 'KSh 1,250.50');
      expect(formatKsh(300, decimals: 0), 'KSh 300');
    });

    test('never uses a dollar sign', () {
      expect(formatKsh(999.99), isNot(contains(r'$')));
    });
  });

  group('B. sample ads are generic', () {
    test(
      'every sample ad is labelled "Sample Ad" with a generic advertiser',
      () async {
        final ads = await AdService().getAvailableAds();
        expect(ads, isNotEmpty);
        for (final ad in ads) {
          expect(ad.title, startsWith('Sample Ad'));
          expect(ad.advertiserName, 'Sample Advertiser');
        }
      },
    );

    test('no sample ad mentions a real company', () async {
      final ads = await AdService().getAvailableAds();
      for (final ad in ads) {
        final text = '${ad.title} ${ad.advertiserName} ${ad.videoUrl}'
            .toLowerCase();
        for (final brand in _realBrands) {
          expect(text, isNot(contains(brand)), reason: 'found "$brand"');
        }
      }
    });

    test(
      'old branded samples stored by earlier versions are not shown',
      () async {
        SharedPreferences.setMockInitialValues({
          'adlease_ads':
              '[{"id":"x","title":"Safaricom M-Pesa Go","advertiserName":"Safaricom",'
              '"videoUrl":"","thumbnailUrl":"","durationSeconds":60,"rewardAmount":2.5,'
              '"createdAt":"2026-01-01T00:00:00.000","expiresAt":"2026-12-01T00:00:00.000"}]',
        });
        final ads = await AdService().getAvailableAds();
        expect(ads.map((a) => a.title), everyElement(startsWith('Sample Ad')));
      },
    );
  });

  group('A. withdrawals are hidden', () {
    test('the feature switch is off and the route is not registered', () {
      expect(AppFeatures.withdrawalsEnabled, isFalse);
      expect(AppRoutes.routes.containsKey(AppRoutes.withdrawal), isFalse);
    });

    testWidgets('the Wallet tab has no Withdraw button and says why', (
      tester,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => WalletProvider()),
            ChangeNotifierProvider(create: (_) => OwnershipProvider()),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const WalletScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Withdraw'), findsNothing);
      expect(find.text('Withdrawals are not available yet.'), findsOneWidget);
      expect(find.textContaining(r'$'), findsNothing);
    });
  });

  group('D. advertising rewards are disabled', () {
    test('all advertising and reward feature flags default off', () {
      expect(AppFeatures.adRewardsEnabled, isFalse);
      expect(AppFeatures.advertisingEnabled, isFalse);
      expect(AppFeatures.liveFinancingEnabled, isFalse);
      expect(AppFeatures.livePaymentsEnabled, isFalse);
    });

    test('legacy reward service refuses every claim', () async {
      await expectLater(
        AdRewardService().claim(userId: 'u1', adId: 'ad1', deviceId: ''),
        throwsA(isA<StateError>()),
      );
    });

    test('legacy ad records cannot record completed views', () async {
      await expectLater(
        AdService().recordAdView(userId: 'u1', adId: 'ad1', completedFully: true, deviceId: ''),
        throwsA(isA<StateError>()),
      );
    });
  });

}
