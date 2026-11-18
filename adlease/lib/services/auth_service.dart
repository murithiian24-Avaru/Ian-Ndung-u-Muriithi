import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:adlease/models/user_model.dart';
import 'package:adlease/services/storage_service.dart';

class AuthService {
  final StorageService _storage = StorageService();
  static const _usersKey = 'adlease_users';
  static const _currentUserKey = 'adlease_current_user';

  // Local demo credential protection only. Live authentication must be delegated
  // to a vetted backend identity provider; never use this as a server substitute.
  static const _pbkdf2Iterations = 120000;
  static const _saltLength = 16;
  static const _hashLength = 32;

  String _toHex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  List<int> _fromHex(String value) {
    if (value.length.isOdd || !RegExp(r'^[0-9a-fA-F]*$').hasMatch(value)) {
      throw const FormatException('Invalid hex encoding');
    }
    return List<int>.generate(
      value.length ~/ 2,
      (i) => int.parse(value.substring(i * 2, i * 2 + 2), radix: 16),
    );
  }

  List<int> _pbkdf2(String password, List<int> salt, int iterations) {
    final hmac = Hmac(sha256, utf8.encode(password));
    final blockInput = Uint8List(salt.length + 4)
      ..setRange(0, salt.length, salt);
    blockInput[salt.length] = 0;
    blockInput[salt.length + 1] = 0;
    blockInput[salt.length + 2] = 0;
    blockInput[salt.length + 3] = 1;
    var u = hmac.convert(blockInput).bytes;
    final t = List<int>.from(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < t.length; j++) {
        t[j] ^= u[j];
      }
    }
    return t.take(_hashLength).toList();
  }

  String _hashPassword(String password) {
    final salt = List<int>.generate(
      _saltLength,
      (_) => math.Random.secure().nextInt(256),
    );
    final hash = _pbkdf2(password, salt, _pbkdf2Iterations);
    return 'pbkdf2_sha256' +
        r'$' +
        _pbkdf2Iterations.toString() +
        r'$' +
        _toHex(salt) +
        r'$' +
        _toHex(hash);
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }

  bool _verifyPassword(String password, String stored) {
    if (stored.startsWith(r'pbkdf2_sha256$')) {
      final parts = stored.split(r'$');
      if (parts.length != 4 || parts[0] != 'pbkdf2_sha256') return false;
      final iterations = int.tryParse(parts[1]);
      if (iterations == null || iterations < 100000 || iterations > 1000000) {
        return false;
      }
      try {
        final salt = _fromHex(parts[2]);
        final expected = _fromHex(parts[3]);
        if (salt.length != _saltLength || expected.length != _hashLength) {
          return false;
        }
        return _constantTimeEquals(
          _pbkdf2(password, salt, iterations),
          expected,
        );
      } on FormatException {
        return false;
      }
    }
    final legacy = sha256.convert(utf8.encode(password)).toString();
    return _constantTimeEquals(utf8.encode(legacy), utf8.encode(stored));
  }

  bool _isLegacyHash(String stored) => !stored.startsWith(r'pbkdf2_sha256$');

  String _generateReferralCode(List<Map<String, dynamic>> users) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = math.Random.secure();
    final existingCodes = users.map((u) => u['referralCode']).toSet();
    String code;
    do {
      code = List.generate(
        8,
        (_) => chars[random.nextInt(chars.length)],
      ).join();
    } while (existingCodes.contains('ADL-$code'));
    return 'ADL-$code';
  }

  Future<List<Map<String, dynamic>>> _getUsers() async {
    final data = await _storage.getString(_usersKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    await _storage.saveString(_usersKey, jsonEncode(users));
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String country,
    String? referralCode,
  }) async {
    final users = await _getUsers();

    final existing = users.where((u) => u['email'] == email).toList();
    if (existing.isNotEmpty) {
      throw Exception('An account with this email already exists');
    }

    final uid = const Uuid().v4();
    final user = UserModel(
      uid: uid,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      country: country,
      referralCode: _generateReferralCode(users),
      referredBy: referralCode,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isVerified: false,
      isActive: true,
    );

    final userData = user.toMap();
    userData['passwordHash'] = _hashPassword(password);
    users.add(userData);
    await _saveUsers(users);
    await _storage.saveString(_currentUserKey, jsonEncode(user.toMap()));

    return user;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final users = await _getUsers();
    final matchingIndex = users.indexWhere((u) {
      final stored = u['passwordHash'];
      return u['email'] == email &&
          stored is String &&
          _verifyPassword(password, stored);
    });

    if (matchingIndex == -1) {
      throw Exception('Invalid email or password');
    }

    final userData = users[matchingIndex];
    final storedHash = userData['passwordHash'] as String;
    if (_isLegacyHash(storedHash)) {
      userData['passwordHash'] = _hashPassword(password);
    }
    userData['lastLoginAt'] = DateTime.now().toIso8601String();
    await _saveUsers(users);

    final user = UserModel.fromMap(userData);
    await _storage.saveString(_currentUserKey, jsonEncode(user.toMap()));
    return user;
  }

  // Google sign-in previously logged every user into a hard-coded
  // "Demo User" account. It stays unavailable until real Firebase
  // Authentication with Google is configured.
  Future<UserModel?> signInWithGoogle() async {
    throw Exception(
      'Google sign-in is not available yet. Please use email and password.',
    );
  }

  // There is no email backend yet, so no reset link can be sent. Say so
  // instead of pretending a link was sent.
  Future<void> resetPassword(String email) async {
    throw Exception(
      'Password reset by email is not available yet. Please contact support.',
    );
  }

  Future<UserModel?> getCurrentUser() async {
    final data = await _storage.getString(_currentUserKey);
    if (data == null) return null;
    return UserModel.fromMap(jsonDecode(data));
  }

  Future<void> signOut() async {
    await _storage.remove(_currentUserKey);
  }

  Future<void> updateUser(UserModel user) async {
    final users = await _getUsers();
    final index = users.indexWhere((u) => u['uid'] == user.uid);
    if (index == -1) {
      throw StateError('Cannot update an account that does not exist locally');
    }

    final existing = users[index];
    final updatedUser = user.copyWith(
      isVerified: existing['isVerified'] == true,
      isActive: existing['isActive'] != false,
      referralCode: existing['referralCode'] as String? ?? user.referralCode,
      referredBy: existing['referredBy'] as String?,
      deviceModel: existing['deviceModel'] as String? ?? user.deviceModel,
      deviceId: existing['deviceId'] as String? ?? user.deviceId,
      createdAt:
          DateTime.tryParse(existing['createdAt'] as String? ?? '') ??
          user.createdAt,
    );

    final userData = updatedUser.toMap();
    userData['passwordHash'] = existing['passwordHash'];
    users[index] = userData;
    await _saveUsers(users);
    await _storage.saveString(_currentUserKey, jsonEncode(updatedUser.toMap()));
  }

  // Local demo cannot grant verification. Only a trusted backend workflow may
  // change verification state after checking authoritative evidence.
  @Deprecated('Client-side verification is disabled; use the secure backend.')
  Future<void> verifyAccount(String uid) async {
    throw UnsupportedError(
      'Verification is unavailable in the demo and requires the secure backend.',
    );
  }
}
