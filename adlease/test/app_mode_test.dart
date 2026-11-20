import 'package:adlease/config/app_mode.dart';
import 'package:adlease/services/auth_feature_flags.dart';
import 'package:adlease/widgets/demo_mode_banner.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveAppMode', () {
    test('unset value keeps demo (current default behaviour)', () {
      expect(resolveAppMode(raw: '', isReleaseBuild: false), AppMode.demo);
    });

    test('explicit demo', () {
      expect(resolveAppMode(raw: 'demo', isReleaseBuild: false), AppMode.demo);
    });

    test('emulator allowed outside release builds', () {
      expect(
        resolveAppMode(raw: 'firebase_emulator', isReleaseBuild: false),
        AppMode.firebaseEmulator,
      );
    });

    test('release builds reject demo, emulator and unset modes', () {
      for (final raw in ['demo', 'firebase_emulator', '']) {
        expect(
          () => resolveAppMode(raw: raw, isReleaseBuild: true),
          throwsA(isA<AppModeException>()),
          reason: 'release + "$raw"',
        );
      }
    });

    test('release builds reject unknown values too', () {
      expect(
        () => resolveAppMode(raw: 'production', isReleaseBuild: true),
        throwsA(isA<AppModeException>()),
      );
    });

    test('unknown values are rejected, never defaulted', () {
      for (final bad in ['production', 'staging', 'auto', 'DEMO', 'firebase']) {
        expect(
          () => resolveAppMode(raw: bad, isReleaseBuild: false),
          throwsA(isA<AppModeException>()),
          reason: bad,
        );
      }
    });

    test('only demo shows the DEMO marker', () {
      expect(AppMode.demo.showsDemoMarker, isTrue);
      expect(AppMode.firebaseEmulator.showsDemoMarker, isFalse);
    });
  });

  group('DemoModeBanner', () {
    Widget host(AppMode mode) => Directionality(
          textDirection: TextDirection.ltr,
          child: DemoModeBanner(mode: mode, child: const SizedBox()),
        );

    testWidgets('shows a banner in demo mode', (tester) async {
      await tester.pumpWidget(host(AppMode.demo));
      expect(find.byType(Banner), findsOneWidget);
    });

    testWidgets('no banner in emulator mode', (tester) async {
      await tester.pumpWidget(host(AppMode.firebaseEmulator));
      expect(find.byType(Banner), findsNothing);
    });
  });

  group('Google sign-in policy', () {
    test('flag is off (fails if someone enables it without review)', () {
      expect(kGoogleSignInEnabled, isFalse);
    });

    test('guard rejects attempts', () {
      expect(
        ensureGoogleSignInAllowed,
        throwsA(isA<FeatureDisabledException>()),
      );
    });
  });
}
