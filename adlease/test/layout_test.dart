// Layout checks at real phone sizes and system font scales, with the app's
// real fonts. A failure lists each overflow and the widget that caused it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:adlease/screens/ads/ads_screen.dart';
import 'package:adlease/screens/ads/watch_ad_screen.dart';
import 'package:adlease/screens/auth/forgot_password_screen.dart';
import 'package:adlease/screens/auth/login_screen.dart';
import 'package:adlease/screens/auth/register_screen.dart';
import 'package:adlease/screens/auth/welcome_screen.dart';
import 'package:adlease/screens/home/home_screen.dart';
import 'package:adlease/screens/home/main_navigation.dart';
import 'package:adlease/screens/ownership/ownership_screen.dart';
import 'package:adlease/screens/ownership/select_phone_screen.dart';
import 'package:adlease/screens/profile/edit_profile_screen.dart';
import 'package:adlease/screens/profile/profile_screen.dart';
import 'package:adlease/screens/referral/referral_screen.dart';
import 'package:adlease/screens/settings/settings_screen.dart';
import 'package:adlease/screens/wallet/wallet_screen.dart';

import 'helpers/test_harness.dart';

/// Screens changed in this work: must have no overflow at any size or scale.
final _required = <String, Widget Function()>{
  'Home (dashboard)': () => const HomeScreen(),
  'Main navigation (bottom bar)': () => const MainNavigation(),
  'Settings': () => const SettingsScreen(),
  'Profile': () => const ProfileScreen(),
};

/// Other screens: surveyed and reported, not yet required to pass.
final _surveyed = <String, Widget Function()>{
  'Watch (ads list)': () => const AdsScreen(),
  'Watch Ad': () => const WatchAdScreen(),
  'Wallet': () => const WalletScreen(),
  'Phone (ownership)': () => const OwnershipScreen(),
  'Select Phone': () => const SelectPhoneScreen(),
  'Referral': () => const ReferralScreen(),
  'Edit Profile': () => const EditProfileScreen(),
  'Welcome': () => const WelcomeScreen(),
  'Login': () => const LoginScreen(),
  'Register': () => const RegisterScreen(),
  'Forgot Password': () => const ForgotPasswordScreen(),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadRealFonts);
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'AdLease',
      packageName: 'com.adlease.adlease',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  for (final entry in _required.entries) {
    for (final phone in PhoneSize.all) {
      for (final scale in textScales) {
        testWidgets('${entry.key} fits: ${phone.name}, font x$scale', (
          tester,
        ) async {
          final p = await seedDemoData();
          final errors = await layoutErrorsFor(
            tester,
            p,
            entry.value(),
            phone,
            scale,
          );
          expect(errors, isEmpty, reason: errors.join('\n'));
        });
      }
    }
  }

  testWidgets('Home fits with no phone selected (small phone, font x2.0)', (
    tester,
  ) async {
    final p = await seedDemoData(withPhone: false);
    final errors = await layoutErrorsFor(
      tester,
      p,
      const HomeScreen(),
      PhoneSize.small,
      2.0,
    );
    expect(errors, isEmpty, reason: errors.join('\n'));
  });

  testWidgets('Home fits in dark mode (Redmi size, font x1.3)', (tester) async {
    final p = await seedDemoData();
    final errors = await layoutErrorsFor(
      tester,
      p,
      const HomeScreen(),
      PhoneSize.redmi,
      1.3,
      themeMode: ThemeMode.dark,
    );
    expect(errors, isEmpty, reason: errors.join('\n'));
  });

  testWidgets('dashboard shows all four statistic cards and quick actions', (
    tester,
  ) async {
    final p = await seedDemoData();
    setPhone(tester, PhoneSize.redmi, 1.0);
    await tester.pumpWidget(buildTestApp(p, home: const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    for (final title in [
      'Ads Watched Today',
      'Ads Remaining',
      'Total Views',
      'Applied to phone',
      'Ownership Progress',
      'Quick Actions',
      'Watch Ad',
      'Refer',
    ]) {
      await tester.scrollUntilVisible(find.text(title), 200);
      expect(find.text(title), findsOneWidget, reason: title);
    }
  });

  // Not a pass/fail check: reports overflows on screens outside this change
  // so they can be planned. See README "Known layout issues".
  testWidgets('survey: other screens', (tester) async {
    final report = <String>[];
    for (final entry in _surveyed.entries) {
      for (final phone in [PhoneSize.small, PhoneSize.redmi]) {
        for (final scale in [1.0, 1.3, 2.0]) {
          final p = await seedDemoData();
          final errors = await layoutErrorsFor(
            tester,
            p,
            entry.value(),
            phone,
            scale,
            allErrors: true,
          );
          await tester.pumpWidget(const SizedBox());
          if (errors.isNotEmpty) {
            report.add(
              '${entry.key} | ${phone.name} | x$scale | ${errors.toSet().join(' ; ')}',
            );
          }
        }
      }
    }
    // ignore: avoid_print
    print(
      'LAYOUT SURVEY (fonts $fontsStatus): '
      '${report.isEmpty ? 'no overflow found' : '\n${report.join('\n')}'}',
    );
  });
}
