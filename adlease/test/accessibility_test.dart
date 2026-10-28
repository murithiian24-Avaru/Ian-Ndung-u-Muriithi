// Screen-reader labels for icon-only buttons, in English and Kiswahili.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adlease/l10n/app_localizations.dart';
import 'package:adlease/widgets/custom_text_field.dart';

Widget _app(Locale locale) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: CustomTextField(
          controller: TextEditingController(),
          label: 'Password',
          isPassword: true,
        ),
      ),
    );

void main() {
  testWidgets('password toggle is labelled in English and changes on tap',
      (tester) async {
    await tester.pumpWidget(_app(const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Show password'), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets('password toggle is labelled in Kiswahili', (tester) async {
    await tester.pumpWidget(_app(const Locale('sw')));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Onyesha nywila'), findsOneWidget);
  });
}
