import 'dart:convert';

import 'package:adlease/models/wallet_model.dart';
import 'package:adlease/models/transaction_model.dart';
import 'package:adlease/services/storage_service.dart';

class WalletService {
  final StorageService _storage = StorageService();
  static const _walletsKey = 'adlease_wallets';
  static const _transactionsKey = 'adlease_transactions';
  static const _withdrawalsKey = 'adlease_withdrawals';

  Future<WalletModel> getWallet(String userId) async {
    final wallets = await _getWallets();
    final match = wallets.where((w) => w['userId'] == userId).toList();
    if (match.isNotEmpty) {
      return WalletModel.fromMap(match.first);
    }

    final wallet = WalletModel(
      userId: userId,
      balance: 0,
      totalEarnings: 0,
      totalWithdrawn: 0,
      lastUpdated: DateTime.now(),
    );
    wallets.add(wallet.toMap());
    await _saveWallets(wallets);
    return wallet;
  }

  /// Customer credits are not part of the approved product model.
  Future<WalletModel> addEarning(
    String userId,
    double amount,
    String description,
  ) async {
    throw StateError('Customer earnings and ad rewards are disabled.');
  }

  /// Withdrawals remain unavailable; no customer cash wallet is active.
  Future<WithdrawalRequest> requestWithdrawal({
    required String userId,
    required double amount,
    required String paymentMethod,
    required String paymentDetails,
  }) async {
    throw StateError('Customer withdrawals are disabled.');
  }

  Future<List<TransactionModel>> getTransactions(String userId) async {
    final data = await _storage.getString(_transactionsKey);
    if (data == null) return [];
    final list = List<Map<String, dynamic>>.from(jsonDecode(data));
    return list
        .map((e) => TransactionModel.fromMap(e))
        .where((t) => t.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _addTransaction(TransactionModel transaction) async {
    final data = await _storage.getString(_transactionsKey);
    final list = data != null
        ? List<Map<String, dynamic>>.from(jsonDecode(data))
        : <Map<String, dynamic>>[];
    list.add(transaction.toMap());
    await _storage.saveString(_transactionsKey, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> _getWallets() async {
    final data = await _storage.getString(_walletsKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  Future<void> _saveWallets(List<Map<String, dynamic>> wallets) async {
    await _storage.saveString(_walletsKey, jsonEncode(wallets));
  }

  Future<List<Map<String, dynamic>>> _getWithdrawals() async {
    final data = await _storage.getString(_withdrawalsKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  Future<List<WithdrawalRequest>> getUserWithdrawals(String userId) async {
    final withdrawals = await _getWithdrawals();
    return withdrawals
        .map((e) => WithdrawalRequest.fromMap(e))
        .where((w) => w.userId == userId)
        .toList()
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }
}
