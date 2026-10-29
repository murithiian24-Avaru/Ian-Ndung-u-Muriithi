// Shared helpers for widget tests: realistic fonts, seeded demo data, a test
// app that mirrors main.dart, phone sizes, and layout-error collection.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adlease/config/routes.dart';
import 'package:adlease/config/theme.dart';
import 'package:adlease/l10n/app_localizations.dart';
import 'package:adlease/providers/ad_provider.dart';
import 'package:adlease/providers/auth_provider.dart';
import 'package:adlease/providers/locale_provider.dart';
import 'package:adlease/providers/ownership_provider.dart';
import 'package:adlease/providers/theme_provider.dart';
import 'package:adlease/providers/wallet_provider.dart';
import 'package:adlease/services/ad_reward_service.dart';
import 'package:adlease/services/auth_service.dart';
import 'package:adlease/services/ownership_service.dart';

/// Phone sizes in logical pixels (what Flutter lays out against).
class PhoneSize {
  final String name;
  final Size size;
  final double dpr;
  const PhoneSize(this.name, this.size, this.dpr);

  /// Small Android phone (for example 720x1280 at 2.25x is similar).
  static const small = PhoneSize('small 320x568', Size(320, 568), 2);

  /// Common budget Android size.
  static const medium = PhoneSize('medium 360x640', Size(360, 640), 3);

  /// Redmi Note class: 1080x2400 at 2.75x.
  static const redmi = PhoneSize('redmi 393x873', Size(392.7, 872.7), 2.75);

  static const all = [small, medium, redmi];
}

/// System font sizes to check (100% to 200%, Android's largest setting).
const textScales = [1.0, 1.3, 1.6, 2.0];

bool _fontsLoaded = false;
String fontsStatus = 'not loaded';

/// Loads the app's real fonts so text is measured as on a phone. Without
/// this, tests use the "Ahem" test font, whose letters are much wider than
/// Poppins and whose line height differs, which gives misleading layouts.
///
/// - Poppins (the app's font, via google_fonts): test/fonts/poppins, SIL OFL.
///   google_fonts names families like "Poppins_600" with "Poppins" as the
///   fallback, so registering "Poppins" covers every weight it asks for.
/// - Roboto and Material Icons: from the Flutter SDK's material_fonts.
Future<void> loadRealFonts() async {
  if (_fontsLoaded) return;
  final poppins = FontLoader('Poppins');
  for (final w in ['Light', 'Regular', 'Medium', 'SemiBold', 'Bold']) {
    poppins.addFont(_read('test/fonts/poppins/Poppins-$w.ttf'));
  }
  await poppins.load();
  final loaded = <String>['Poppins (5 weights)'];

  final dir = _materialFontsDir();
  if (dir != null) {
    final roboto = FontLoader('Roboto');
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => RegExp(r'Roboto-[A-Za-z]+\.ttf$').hasMatch(f.path));
    for (final f in files) {
      roboto.addFont(_read(f.path));
    }
    await roboto.load();
    final icons = File('${dir.path}/MaterialIcons-Regular.otf');
    if (icons.existsSync()) {
      await (FontLoader('MaterialIcons')..addFont(_read(icons.path))).load();
      loaded.add('MaterialIcons');
    }
    loaded.add('Roboto (${files.length} files)');
  }
  fontsStatus = 'loaded: ${loaded.join(', ')}';
  debugPrint('Test fonts $fontsStatus');
  _fontsLoaded = true;
}

Future<ByteData> _read(String path) async =>
    ByteData.sublistView(File(path).readAsBytesSync());

Directory? _materialFontsDir() {
  final roots = <String>[
    if (Platform.environment['FLUTTER_ROOT'] case final r?) r,
    // flutter_tester lives in <root>/bin/cache/artifacts/engine/<platform>/.
    File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path,
  ];
  for (final root in roots) {
    final d = Directory('$root/bin/cache/artifacts/material_fonts');
    if (d.existsSync()) return d;
  }
  return null;
}

/// Providers with demo data already loaded, as the app has after login.
class TestProviders {
  final auth = AuthProvider();
  final theme = ThemeProvider();
  final locale = LocaleProvider();
  final ads = AdProvider();
  final wallet = WalletProvider();
  final ownership = OwnershipProvider();
}

/// Seeds a signed-in demo user (with a long name, to stress the header).
/// With [withPhone], a phone is chosen and [adsWatched] simulated ads are
/// claimed, which adds progress to the phone.
Future<TestProviders> seedDemoData({
  bool withPhone = true,
  int adsWatched = 2,
  String fullName = 'Wanjiku Muthoni-Kamau',
}) async {
  SharedPreferences.setMockInitialValues({});
  final user = await AuthService().signUp(
    email: 'demo@example.com',
    password: 'Password123!',
    fullName: fullName,
    phoneNumber: '+254700000000',
    country: 'Kenya',
  );
  if (withPhone) {
    final phones = await OwnershipService().getAvailablePhones();
    await OwnershipService().selectPhone(userId: user.uid, phone: phones.first);
    for (var i = 0; i < adsWatched; i++) {
      await AdRewardService().claim(
        userId: user.uid,
        adId: 'ad$i',
        deviceId: '',
      );
    }
  }
  final p = TestProviders();
  await p.auth.checkAuthState();
  await p.ownership.loadOwnership(user.uid);
  await p.ads.loadAds(user.uid);
  await p.wallet.loadWallet(user.uid);
  return p;
}

/// The app shell from main.dart (themes, localization) around [home].
Widget buildTestApp(
  TestProviders p, {
  required Widget home,
  ThemeMode themeMode = ThemeMode.light,
  Locale locale = const Locale('en'),
  Key? boundaryKey,
}) {
  final routes = Map.of(AppRoutes.routes)..remove(AppRoutes.splash);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: p.auth),
      ChangeNotifierProvider.value(value: p.theme),
      ChangeNotifierProvider.value(value: p.locale),
      ChangeNotifierProvider.value(value: p.ads),
      ChangeNotifierProvider.value(value: p.wallet),
      ChangeNotifierProvider.value(value: p.ownership),
    ],
    child: RepaintBoundary(
      key: boundaryKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AdLeaseTheme.lightTheme(),
        darkTheme: AdLeaseTheme.darkTheme(),
        themeMode: themeMode,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
        routes: routes,
      ),
    ),
  );
}

/// Sets the test window to a phone size and system font scale.
void setPhone(WidgetTester tester, PhoneSize phone, double textScale) {
  tester.view.physicalSize = phone.size * phone.dpr;
  tester.view.devicePixelRatio = phone.dpr;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// Runs [body] and returns every layout error reported meanwhile (for
/// example "A RenderFlex overflowed by 20 pixels on the bottom"), with the
/// widget location Flutter gives. Other errors are passed on unchanged.
Future<List<String>> collectLayoutErrors(Future<void> Function() body) async {
  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.library == 'rendering library' ||
        details.exceptionAsString().contains('overflowed')) {
      final text = details.toString();
      final where = RegExp(r'lib/[\w/]+\.dart:\d+:\d+')
          .allMatches(text)
          .map((m) => m.group(0))
          .toSet()
          .take(2)
          .join(', ');
      errors.add(
        '${details.exceptionAsString().split('\n').first}'
        '${where.isEmpty ? '' : ' at $where'}',
      );
    } else {
      previous?.call(details);
    }
  };
  try {
    await body();
  } finally {
    FlutterError.onError = previous;
  }
  return errors;
}

/// Lays out [home] at the given phone size and font scale, then scrolls
/// every scrollable to its end so the whole screen is laid out.
Future<List<String>> layoutErrorsFor(
  WidgetTester tester,
  TestProviders p,
  Widget home,
  PhoneSize phone,
  double textScale, {
  ThemeMode themeMode = ThemeMode.light,
  Duration settle = const Duration(milliseconds: 500),
}) async {
  setPhone(tester, phone, textScale);
  return collectLayoutErrors(() async {
    await tester.pumpWidget(buildTestApp(p, home: home, themeMode: themeMode));
    await tester.pump(settle);
    await scrollAllToEnd(tester);
  });
}

/// Scrolls each vertical scrollable on screen to its end, in steps, so
/// lazily built content is laid out too.
Future<void> scrollAllToEnd(WidgetTester tester) async {
  final scrollables = find.byType(Scrollable);
  for (var i = 0; i < scrollables.evaluate().length; i++) {
    final state = tester.state<ScrollableState>(scrollables.at(i));
    final position = state.position;
    if (position.axis != Axis.vertical) continue;
    for (var step = 0; step < 20 && position.pixels < position.maxScrollExtent; step++) {
      position.jumpTo(
        (position.pixels + position.viewportDimension * 0.8)
            .clamp(0, position.maxScrollExtent),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }
}
