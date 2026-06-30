import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:adlease/models/user_model.dart';
import 'package:adlease/services/storage_service.dart';

class AuthService {
  final StorageService _storage = StorageService();
  static const _usersKey = 'adlease_users';
  static const _currentUserKey = 'adlease_current_user';

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = List.generate(8, (i) => chars[(random + i * 7) % chars.length]).join();
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
      referralCode: _generateReferralCode(),
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
    final passwordHash = _hashPassword(password);

    final matching = users.where(
      (u) => u['email'] == email && u['passwordHash'] == passwordHash,
    ).toList();

    if (matching.isEmpty) {
      throw Exception('Invalid email or password');
    }

    final userData = matching.first;
    userData['lastLoginAt'] = DateTime.now().toIso8601String();
    await _saveUsers(users);

    final user = UserModel.fromMap(userData);
    await _storage.saveString(_currentUserKey, jsonEncode(user.toMap()));
    return user;
  }

  Future<UserModel?> signInWithGoogle() async {
    final uid = const Uuid().v4();
    final user = UserModel(
      uid: uid,
      email: 'demo@gmail.com',
      fullName: 'Demo User',
      phoneNumber: '+254700000000',
      country: 'Kenya',
      referralCode: _generateReferralCode(),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isVerified: true,
    );

    final users = await _getUsers();
    final existing = users.where((u) => u['email'] == user.email).toList();
    if (existing.isEmpty) {
      final userData = user.toMap();
      userData['passwordHash'] = '';
      users.add(userData);
      await _saveUsers(users);
    }
    await _storage.saveString(_currentUserKey, jsonEncode(user.toMap()));
    return user;
  }

  Future<void> resetPassword(String email) async {
    final users = await _getUsers();
    final matching = users.where((u) => u['email'] == email).toList();
    if (matching.isEmpty) {
      throw Exception('No account found with this email');
    }
    debugPrint('Password reset link sent to $email');
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
    if (index != -1) {
      final passwordHash = users[index]['passwordHash'];
      users[index] = user.toMap();
      users[index]['passwordHash'] = passwordHash;
      await _saveUsers(users);
    }
    await _storage.saveString(_currentUserKey, jsonEncode(user.toMap()));
  }

  Future<void> verifyAccount(String uid) async {
    final users = await _getUsers();
    final index = users.indexWhere((u) => u['uid'] == uid);
    if (index != -1) {
      users[index]['isVerified'] = true;
      await _saveUsers(users);
    }
  }
}
