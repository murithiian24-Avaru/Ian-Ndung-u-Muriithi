import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adlease/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('referral codes are cryptographically generated and unique', () async {
    final auth = AuthService();
    final codes = <String>{};
    for (var i = 0; i < 20; i++) {
      final user = await auth.signUp(
        email: 'secure-ref-$i@example.com',
        password: 'Password123!',
        fullName: 'Referral $i',
        phoneNumber: '+254700000000',
        country: 'Kenya',
      );
      expect(user.referralCode, matches(RegExp(r'^ADL-[A-Z0-9]{8}$')));
      codes.add(user.referralCode);
    }
    expect(codes, hasLength(20));
  });

  test('client verification cannot grant verified status', () async {
    final auth = AuthService();
    final created = await auth.signUp(
      email: 'verification@example.com',
      password: 'Password123!',
      fullName: 'Verification User',
      phoneNumber: '+254700000000',
      country: 'Kenya',
    );

    await expectLater(
      auth.verifyAccount(created.uid),
      throwsA(isA<UnsupportedError>()),
    );
    expect((await auth.getCurrentUser())?.isVerified, isFalse);
  });

  test('profile update cannot change protected account fields', () async {
    final auth = AuthService();
    final created = await auth.signUp(
      email: 'protected@example.com',
      password: 'Password123!',
      fullName: 'Protected User',
      phoneNumber: '+254700000000',
      country: 'Kenya',
    );

    await auth.updateUser(
      created.copyWith(
        fullName: 'Updated Name',
        isVerified: true,
        isActive: false,
        referralCode: 'ADL-MANIPULATED',
      ),
    );

    final current = await auth.getCurrentUser();
    expect(current?.fullName, 'Updated Name');
    expect(current?.isVerified, isFalse);
    expect(current?.isActive, isTrue);
    expect(current?.referralCode, created.referralCode);

    final prefs = await SharedPreferences.getInstance();
    final users = List<Map<String, dynamic>>.from(
      jsonDecode(prefs.getString('adlease_users')!),
    );
    expect(users.single['isVerified'], isFalse);
    expect(users.single['referralCode'], created.referralCode);
  });

  test('unknown user cannot overwrite current account state', () async {
    final auth = AuthService();
    final created = await auth.signUp(
      email: 'known@example.com',
      password: 'Password123!',
      fullName: 'Known User',
      phoneNumber: '+254700000000',
      country: 'Kenya',
    );

    await expectLater(
      auth.updateUser(created.copyWith(uid: 'unknown-user')),
      throwsA(isA<StateError>()),
    );
    expect((await auth.getCurrentUser())?.uid, created.uid);
  });
}
