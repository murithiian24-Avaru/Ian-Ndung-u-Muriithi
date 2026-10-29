// Renders key screens to PNG files for visual review, with the app's real
// fonts. Runs only when ADLEASE_SCREENSHOT_DIR is set, for example:
//   ADLEASE_SCREENSHOT_DIR=build/screenshots flutter test test/screenshots_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:adlease/screens/home/main_navigation.dart';
import 'package:adlease/screens/profile/profile_screen.dart';
import 'package:adlease/screens/settings/settings_screen.dart';
import 'package:adlease/screens/splash/splash_screen.dart';

import 'helpers/test_harness.dart';

final _dir = Platform.environment['ADLEASE_SCREENSHOT_DIR'];

/// Screen width of a Redmi Note class phone, with a tall window so a whole
/// scrolling screen fits in one image. Layout depends on width (and font
/// scale); the extra height only avoids having to scroll.
const _redmiTall = PhoneSize('redmi full page', Size(392.7, 1500), 2);
const _smallTall = PhoneSize('small full page', Size(320, 1500), 2);

/// Advances time in small steps so animations run as on a device (one large
/// pump would jump timers but leave animations at their first frame).
Future<void> _frames(WidgetTester tester, Duration total) async {
  const step = Duration(milliseconds: 50);
  for (var t = Duration.zero; t < total; t += step) {
    await tester.pump(step);
  }
}

Future<void> _capture(WidgetTester tester, Key key, String name) async {
  await _frames(tester, const Duration(milliseconds: 800));
  // Decode images (the Avaru logo) before capturing.
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pump(const Duration(milliseconds: 100));
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_dir/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

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

  final scenarios =
      <(String, PhoneSize, double, ThemeMode, bool, Widget Function())>[
        (
          '01-home-redmi-x1.0',
          _redmiTall,
          1.0,
          ThemeMode.light,
          true,
          () => const MainNavigation(),
        ),
        (
          '02-home-redmi-x1.3',
          _redmiTall,
          1.3,
          ThemeMode.light,
          true,
          () => const MainNavigation(),
        ),
        (
          '03-home-small-x1.0',
          _smallTall,
          1.0,
          ThemeMode.light,
          true,
          () => const MainNavigation(),
        ),
        (
          '04-home-small-x2.0',
          _smallTall,
          2.0,
          ThemeMode.light,
          true,
          () => const MainNavigation(),
        ),
        (
          '05-home-redmi-dark',
          _redmiTall,
          1.0,
          ThemeMode.dark,
          true,
          () => const MainNavigation(),
        ),
        (
          '06-home-no-phone',
          _redmiTall,
          1.0,
          ThemeMode.light,
          false,
          () => const MainNavigation(),
        ),
        (
          '07-settings-redmi-x1.0',
          _redmiTall,
          1.0,
          ThemeMode.light,
          true,
          () => const SettingsScreen(),
        ),
        (
          '08-settings-small-x1.6',
          _smallTall,
          1.6,
          ThemeMode.light,
          true,
          () => const SettingsScreen(),
        ),
        (
          '09-profile-redmi',
          _redmiTall,
          1.0,
          ThemeMode.light,
          true,
          () => const ProfileScreen(),
        ),
      ];

  for (final (name, phone, scale, mode, withPhone, build) in scenarios) {
    testWidgets('screenshot $name', (tester) async {
      final p = await seedDemoData(withPhone: withPhone);
      setPhone(tester, phone, scale);
      final key = GlobalKey();
      await tester.pumpWidget(
        buildTestApp(p, home: build(), themeMode: mode, boundaryKey: key),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await _capture(tester, key, name);
    }, skip: _dir == null);
  }

  testWidgets('screenshot 10-about-dialog', (tester) async {
    final p = await seedDemoData();
    setPhone(tester, const PhoneSize('redmi', Size(392.7, 872.7), 2), 1.0);
    final key = GlobalKey();
    await tester.pumpWidget(
      buildTestApp(p, home: const SettingsScreen(), boundaryKey: key),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.scrollUntilVisible(find.text('About AdLease'), 200);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('About AdLease'));
    await tester.pump(const Duration(milliseconds: 600));
    await _capture(tester, key, '10-about-dialog');
  }, skip: _dir == null);

  testWidgets('screenshot 11-splash', (tester) async {
    final p = await seedDemoData();
    setPhone(tester, const PhoneSize('redmi', Size(392.7, 872.7), 2), 1.0);
    final key = GlobalKey();
    await tester.pumpWidget(
      buildTestApp(p, home: const SplashScreen(), boundaryKey: key),
    );
    await _frames(tester, const Duration(milliseconds: 1600));
    await _capture(tester, key, '11-splash');
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 1));
  }, skip: _dir == null);
}
