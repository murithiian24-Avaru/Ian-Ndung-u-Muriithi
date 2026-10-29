// The Avaru logo used by the app must be the official master, unchanged.
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adlease/screens/splash/splash_screen.dart';
import 'package:adlease/widgets/powered_by_avaru.dart';

import 'helpers/test_harness.dart';

/// SHA-256 of the official Avaru logo master
/// (avaru-website repository: public/brand/avaru-logo-official.png).
const officialLogoSha256 =
    '9031557c5f24f9a9b58d49cff211357a28143b589d70ca2b2b619d7d0a31ab47';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the bundled Avaru logo is the official master, byte for byte', () {
    final bytes = File(PoweredByAvaru.logoAsset).readAsBytesSync();
    expect(sha256.convert(bytes).toString(), officialLogoSha256);
  });

  test('no other Avaru logo files are bundled', () {
    final files = Directory('assets/brand').listSync().whereType<File>();
    expect(
      files.map((f) => f.uri.pathSegments.last),
      ['avaru-logo-official.png'],
    );
  });

  testWidgets('splash shows AdLease first and Powered by Avaru below', (
    tester,
  ) async {
    await loadRealFonts();
    final p = await seedDemoData();
    setPhone(tester, PhoneSize.small, 1.6);
    final errors = await collectLayoutErrors(() async {
      await tester.pumpWidget(buildTestApp(p, home: const SplashScreen()));
      await tester.pump(const Duration(milliseconds: 1800));

      expect(find.text('AdLease'), findsOneWidget);
      final attribution = find.bySemanticsLabel('Powered by Avaru');
      expect(attribution, findsOneWidget);
      final image = tester.widget<Image>(
        find.descendant(of: find.byType(PoweredByAvaru), matching: find.byType(Image)),
      );
      expect(
        (image.image as ResizeImage).imageProvider,
        isA<AssetImage>().having((a) => a.assetName, 'asset', PoweredByAvaru.logoAsset),
      );
      // The product name sits above the attribution.
      expect(
        tester.getCenter(find.text('AdLease')).dy,
        lessThan(tester.getCenter(attribution).dy),
      );

      // Let the splash finish (it moves on to the welcome screen).
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 1));
    });
    expect(errors, isEmpty, reason: errors.join('\n'));
  });
}
