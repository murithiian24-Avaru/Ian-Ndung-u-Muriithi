import 'package:flutter/foundation.dart';
import 'package:adlease/models/ownership_model.dart';
import 'package:adlease/models/phone_model.dart';
import 'package:adlease/services/ownership_service.dart';

class OwnershipProvider extends ChangeNotifier {
  final OwnershipService _ownershipService = OwnershipService();
  OwnershipModel? _currentOwnership;
  List<PhoneModel> _availablePhones = [];
  List<OwnershipModel> _allOwnerships = [];
  bool _isLoading = false;

  OwnershipModel? get currentOwnership => _currentOwnership;
  List<PhoneModel> get availablePhones => _availablePhones;
  List<OwnershipModel> get allOwnerships => _allOwnerships;
  bool get isLoading => _isLoading;
  bool get hasActiveOwnership => _currentOwnership != null;

  double get progressPercentage => _currentOwnership?.progressPercentage ?? 0;
  double get remainingAmount => _currentOwnership?.remainingAmount ?? 0;

  Future<void> loadOwnership(String userId) async {
    _isLoading = true;
    notifyListeners();

    _currentOwnership = await _ownershipService.getUserOwnership(userId);
    _availablePhones = await _ownershipService.getAvailablePhones();
    _allOwnerships = await _ownershipService.getUserOwnerships(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> selectPhone(String userId, PhoneModel phone) async {
    try {
      _currentOwnership = await _ownershipService.selectPhone(
        userId: userId,
        phone: phone,
      );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error selecting phone: $e');
      return false;
    }
  }

  Future<OwnershipModel?> addPayment(String userId, double amount) async {
    try {
      _currentOwnership = await _ownershipService.addPayment(userId, amount);
      notifyListeners();
      return _currentOwnership;
    } catch (e) {
      debugPrint('Error adding payment: $e');
      return null;
    }
  }
}
