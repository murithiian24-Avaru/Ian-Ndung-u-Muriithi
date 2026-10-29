// Local hardening checks: Android backup of app data is switched off, and no
// screen promises a referral reward that the app cannot pay.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adlease/screens/referral/referral_screen.dart';
import 'package:adlease/screens/wallet/wallet_screen.dart';

import 'helpers/test_harness.dart';

const _manifestPath = 'android/app/src/main/AndroidManifest.xml';
const _rulesPath = 'android/app/src/main/res/xml/data_extraction_rules.xml';

const _domains = [
  'root',
  'file',
  'database',
  'sharedpref',
  'external',
  'device_root',
  'device_file',
  'device_database',
  'device_sharedpref',
];

/// All text on screen, including text that is scrolled out of view.
List<String> _visibleText(WidgetTester tester) {
  return find
      .byType(Text, skipOffstage: false)
      .evaluate()
      .map((e) {
        final t = e.widget as Text;
        return t.data ?? t.textSpan?.toPlainText() ?? '';
      })
      .where((s) => s.isNotEmpty)
      .toList();
}

/// Wording that would promise a referral reward.
final _promises = [
  RegExp(r'KSh', caseSensitive: false),
  RegExp(r'\bearn', caseSensitive: false),
  RegExp(r'you both', caseSensitive: false),
  RegExp(r'no limit', caseSensitive: false),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Android backup', () {
    test('the application turns off backup and points to the rules', () {
      final manifest = File(_manifestPath).readAsStringSync();
      final tag = RegExp(r'<application\b[^>]*>').firstMatch(manifest);
      final app = tag!.group(0)!;
      expect(app, contains('android:allowBackup="false"'));
      expect(
        app,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      );
    });

    test('every transfer type excludes every storage domain', () {
      // Ignore XML comments, which may mention the element names.
      final rules = File(_rulesPath)
          .readAsStringSync()
          .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
      expect(rules, isNot(contains('<include')));
      for (final section in [
        'cloud-backup',
        'device-transfer',
        'cross-platform-transfer',
      ]) {
        final body = RegExp(
          '<$section\\b[^>]*>(.*?)</$section>',
          dotAll: true,
        ).firstMatch(rules);
        expect(body, isNotNull, reason: '$section section missing');
        for (final domain in _domains) {
          expect(
            body!.group(1),
            contains('<exclude domain="$domain" path="." />'),
            reason: '$section does not exclude $domain',
          );
        }
      }
    });
  });

  group('referral wording', () {
    setUpAll(loadRealFonts);

    for (final locale in const [Locale('en'), Locale('sw')]) {
      testWidgets('Referral screen promises no reward ($locale)', (
        tester,
      ) async {
        final p = await seedDemoData();
        setPhone(tester, PhoneSize.redmi, 1.0);
        await tester.pumpWidget(
          buildTestApp(p, home: const ReferralScreen(), locale: locale),
        );
        await tester.pump(const Duration(milliseconds: 300));

        final text = _visibleText(tester);
        for (final pattern in _promises) {
          final hits = text.where(pattern.hasMatch).toList();
          expect(hits, isEmpty, reason: 'promise-like text: $hits');
        }
        final notice = locale.languageCode == 'sw'
            ? 'Zawadi za rufaa bado hazipatikani'
            : 'Referral rewards are not available yet';
        expect(
          text.where((s) => s.contains(notice)),
          isNotEmpty,
          reason: 'the "not available yet" notice is missing',
        );
        // Referral codes still work: the user's code is shown.
        expect(find.text('Your Referral Code'), findsOneWidget);
      });
    }

    testWidgets('Wallet invites friends without promising earnings', (
      tester,
    ) async {
      final p = await seedDemoData();
      setPhone(tester, PhoneSize.redmi, 1.0);
      await tester.pumpWidget(buildTestApp(p, home: const WalletScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Refer & Earn'), findsNothing);
      expect(find.text('Refer a Friend'), findsOneWidget);
    });
  });
}
