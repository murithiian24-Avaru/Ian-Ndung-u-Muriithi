import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adlease/screens/profile/edit_profile_screen.dart';

import 'helpers/test_harness.dart';

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

  testWidgets('profile save failure restores button and shows error', (
    tester,
  ) async {
    final providers = await seedDemoData(withPhone: false);
    // Simulate the local account record disappearing between opening the
    // profile editor and saving, causing AuthService.updateUser to fail.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('adlease_users', '[]');

    setPhone(tester, PhoneSize.small, 1.0);
    await tester.pumpWidget(
      buildTestApp(providers, home: const EditProfileScreen()),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Save Changes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Profile could not be saved. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
  });
}
