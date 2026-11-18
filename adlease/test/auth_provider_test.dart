import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adlease/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AuthProvider reloads protected status after profile update', () async {
    final auth = AuthProvider();
    expect(
      await auth.signUp(
        email: 'provider-status@example.com',
        password: 'Password123!',
        fullName: 'Provider Test',
        phoneNumber: '+254700000000',
        country: 'Kenya',
      ),
      isTrue,
    );

    final initial = auth.user!;
    await auth.updateUser(
      initial.copyWith(
        fullName: 'Updated Provider Test',
        isVerified: true,
        isActive: false,
      ),
    );

    expect(auth.user?.fullName, 'Updated Provider Test');
    expect(auth.user?.isVerified, isFalse);
    expect(auth.user?.isActive, isTrue);
  });
}
