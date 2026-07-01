import 'package:flutter/foundation.dart';
import 'package:adlease/models/wallet_model.dart';
import 'package:adlease/models/transaction_model.dart';
import 'package:adlease/services/wallet_service.dart';

class WalletProvider extends ChangeNotifier {
  final WalletService _walletService = WalletService();
  WalletModel? _wallet;
  List<TransactionModel> _transactions = [];
  List<WithdrawalRequest> _withdrawals = [];
  bool _isLoading = false;
  String? _error;

  WalletModel? get wallet => _wallet;
  List<TransactionModel> get transactions => _transactions;
  List<WithdrawalRequest> get withdrawals => _withdrawals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get balance => _wallet?.balance ?? 0;

  Future<void> loadWallet(String userId) async {
    _isLoading = true;
    notifyListeners();

    _wallet = await _walletService.getWallet(userId);
    _transactions = await _walletService.getTransactions(userId);
    _withdrawals = await _walletService.getUserWithdrawals(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEarning(String userId, double amount, String description) async {
    _wallet = await _walletService.addEarning(userId, amount, description);
    _transactions = await _walletService.getTransactions(userId);
    notifyListeners();
  }

  Future<bool> requestWithdrawal({
    required String userId,
    required double amount,
    required String paymentMethod,
    required String paymentDetails,
  }) async {
    _error = null;
    try {
      await _walletService.requestWithdrawal(
        userId: userId,
        amount: amount,
        paymentMethod: paymentMethod,
        paymentDetails: paymentDetails,
      );
      await loadWallet(userId);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
