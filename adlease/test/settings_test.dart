// Every visible setting either works and persists, or is clearly marked
// "Not available yet" and cannot be used.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adlease/providers/locale_provider.dart';
import 'package:adlease/providers/theme_provider.dart';
import 'package:adlease/screens/settings/settings_screen.dart';

import 'helpers/test_harness.dart';

Future<void> _openSettings(WidgetTester tester, TestProviders p) async {
  setPhone(tester, PhoneSize.redmi, 1.0);
  await tester.pumpWidget(buildTestApp(p, home: const SettingsScreen()));
  await tester.pump(const Duration(milliseconds: 300));
}

Finder _tile(String title) => find.ancestor(
  of: find.text(title),
  matching: find.byWidgetPredicate((w) => w is ListTile || w is SwitchListTile),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadRealFonts);
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'AdLease',
      packageName: 'com.adlease.adlease',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );
  });

  testWidgets('dark mode switch changes the theme and is saved', (
    tester,
  ) async {
    final p = await seedDemoData();
    await _openSettings(tester, p);
    expect(p.theme.isDarkMode, isFalse);

    await tester.tap(find.text('Dark Mode'));
    await tester.pump();
    expect(p.theme.isDarkMode, isTrue);
    expect(find.text('Dark theme enabled'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('adlease_dark_mode'), isTrue);

    // A fresh start (as the splash screen does) restores the saved choice.
    final restarted = ThemeProvider();
    await restarted.loadTheme();
    expect(restarted.themeMode, ThemeMode.dark);
  });

  testWidgets('language choice changes the locale and is saved', (
    tester,
  ) async {
    final p = await seedDemoData();
    await _openSettings(tester, p);

    await tester.tap(find.text('Kiswahili'));
    await tester.pump();
    expect(p.locale.locale.languageCode, 'sw');

    final restarted = LocaleProvider();
    await restarted.loadLocale();
    expect(restarted.locale.languageCode, 'sw');
  });

  testWidgets('notification switches are off, disabled and explained', (
    tester,
  ) async {
    final p = await seedDemoData();
    await _openSettings(tester, p);
    await tester.scrollUntilVisible(find.text('Reward Alerts'), 200);

    expect(
      find.text('AdLease does not send notifications yet.'),
      findsOneWidget,
    );
    for (final title in [
      'Push Notifications',
      'Ad Reminders',
      'Reward Alerts',
    ]) {
      final tile = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, title),
      );
      expect(tile.value, isFalse, reason: '$title must not look switched on');
      expect(tile.onChanged, isNull, reason: '$title must be disabled');
    }
  });

  testWidgets('unbuilt security and legal items are disabled and labelled', (
    tester,
  ) async {
    final p = await seedDemoData();
    await _openSettings(tester, p);
    for (final title in [
      'Change Password',
      'Biometric Login',
      'Two-Factor Authentication',
      'Terms of Service',
      'Privacy Policy',
    ]) {
      await tester.scrollUntilVisible(find.text(title), 200);
      final tile = tester.widget<ListTile>(_tile(title).first);
      expect(tile.enabled, isFalse, reason: '$title must be disabled');
      expect(
        find.descendant(
          of: _tile(title).first,
          matching: find.text('Not available yet'),
        ),
        findsOneWidget,
        reason: title,
      );
    }
  });

  testWidgets('About shows the installed version and the attribution', (
    tester,
  ) async {
    final p = await seedDemoData();
    await _openSettings(tester, p);
    await tester.scrollUntilVisible(find.text('About AdLease'), 200);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Version 1.2.3 (45)'), findsOneWidget);

    await tester.tap(find.text('About AdLease'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('1.2.3 (45)'), findsOneWidget);
    expect(find.text('© Avaru Tech Company Limited'), findsOneWidget);
    expect(
      find.textContaining('ads and rewards are simulated'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Powered by Avaru'), findsWidgets);
    // Flutter's own licence page is reachable from the dialog.
    expect(find.text('View licenses'), findsOneWidget);
  });

  testWidgets('settings end with the Powered by Avaru attribution', (
    tester,
  ) async {
    final p = await seedDemoData();
    await _openSettings(tester, p);
    await tester.scrollUntilVisible(
      find.bySemanticsLabel('Powered by Avaru'),
      200,
    );
    expect(find.bySemanticsLabel('Powered by Avaru'), findsOneWidget);
  });
}
