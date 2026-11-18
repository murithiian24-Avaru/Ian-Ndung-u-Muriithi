import 'package:adlease/models/wallet_model.dart';
import 'package:adlease/models/transaction_model.dart';

/// Customer cash balances and transactions are not active in this product
/// model. Legacy local reward data is deliberately ignored, not migrated.
class WalletService {
  Future<WalletModel> getWallet(String userId) async => WalletModel(
    userId: userId,
    balance: 0,
    totalEarnings: 0,
    totalWithdrawn: 0,
    lastUpdated: DateTime.now(),
  );

  Future<WalletModel> addEarning(String userId, double amount, String description) async {
    throw StateError('Customer earnings and ad rewards are disabled.');
  }

  Future<WithdrawalRequest> requestWithdrawal({
    required String userId,
    required double amount,
    required String paymentMethod,
    required String paymentDetails,
  }) async {
    throw StateError('Customer withdrawals are disabled.');
  }

  Future<List<TransactionModel>> getTransactions(String userId) async => const [];

  Future<List<WithdrawalRequest>> getUserWithdrawals(String userId) async => const [];
}
