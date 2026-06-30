import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:adlease/models/ownership_model.dart';
import 'package:adlease/models/phone_model.dart';
import 'package:adlease/services/storage_service.dart';

class OwnershipService {
  final StorageService _storage = StorageService();
  static const _ownershipsKey = 'adlease_ownerships';
  static const _phonesKey = 'adlease_phones';

  Future<List<PhoneModel>> getAvailablePhones() async {
    final data = await _storage.getString(_phonesKey);
    if (data != null) {
      final list = List<Map<String, dynamic>>.from(jsonDecode(data));
      return list.map((e) => PhoneModel.fromMap(e)).toList();
    }

    final phones = _generateSamplePhones();
    await _storage.saveString(
      _phonesKey,
      jsonEncode(phones.map((e) => e.toMap()).toList()),
    );
    return phones;
  }

  List<PhoneModel> _generateSamplePhones() {
    return [
      PhoneModel(
        id: '1',
        brand: 'Samsung',
        model: 'Galaxy A54',
        imageUrl: '',
        price: 300,
        description: 'Premium mid-range smartphone with stunning display',
        specs: {
          'Display': '6.4" Super AMOLED',
          'Camera': '50MP Triple',
          'Battery': '5000mAh',
          'Storage': '128GB',
          'RAM': '8GB',
        },
      ),
      PhoneModel(
        id: '2',
        brand: 'Tecno',
        model: 'Camon 20 Pro',
        imageUrl: '',
        price: 200,
        description: 'Capture every moment with pro-grade camera',
        specs: {
          'Display': '6.67" AMOLED',
          'Camera': '64MP',
          'Battery': '5000mAh',
          'Storage': '256GB',
          'RAM': '8GB',
        },
      ),
      PhoneModel(
        id: '3',
        brand: 'Xiaomi',
        model: 'Redmi Note 13',
        imageUrl: '',
        price: 180,
        description: 'Power-packed performance at an affordable price',
        specs: {
          'Display': '6.67" AMOLED 120Hz',
          'Camera': '108MP',
          'Battery': '5000mAh',
          'Storage': '128GB',
          'RAM': '6GB',
        },
      ),
      PhoneModel(
        id: '4',
        brand: 'Infinix',
        model: 'Note 30 Pro',
        imageUrl: '',
        price: 220,
        description: 'Wireless charging meets premium design',
        specs: {
          'Display': '6.78" AMOLED',
          'Camera': '108MP',
          'Battery': '5000mAh',
          'Storage': '256GB',
          'RAM': '8GB',
        },
      ),
      PhoneModel(
        id: '5',
        brand: 'Samsung',
        model: 'Galaxy S24',
        imageUrl: '',
        price: 800,
        description: 'Flagship AI-powered smartphone experience',
        specs: {
          'Display': '6.2" Dynamic AMOLED 2X',
          'Camera': '50MP Triple AI',
          'Battery': '4000mAh',
          'Storage': '256GB',
          'RAM': '8GB',
        },
      ),
      PhoneModel(
        id: '6',
        brand: 'iPhone',
        model: '15',
        imageUrl: '',
        price: 999,
        description: 'Dynamic Island. Innovative safety features.',
        specs: {
          'Display': '6.1" Super Retina XDR',
          'Camera': '48MP Dual',
          'Battery': 'All-day battery',
          'Storage': '128GB',
          'Chip': 'A16 Bionic',
        },
      ),
    ];
  }

  Future<OwnershipModel?> getUserOwnership(String userId) async {
    final data = await _storage.getString(_ownershipsKey);
    if (data == null) return null;
    final list = List<Map<String, dynamic>>.from(jsonDecode(data));
    final match = list.where((o) => o['userId'] == userId && o['isCompleted'] == false).toList();
    if (match.isEmpty) return null;
    return OwnershipModel.fromMap(match.first);
  }

  Future<OwnershipModel> selectPhone({
    required String userId,
    required PhoneModel phone,
  }) async {
    final ownership = OwnershipModel(
      id: const Uuid().v4(),
      userId: userId,
      phoneId: phone.id,
      phoneName: phone.fullName,
      phonePrice: phone.price,
      amountPaid: 0,
      startDate: DateTime.now(),
    );

    final data = await _storage.getString(_ownershipsKey);
    final list = data != null
        ? List<Map<String, dynamic>>.from(jsonDecode(data))
        : <Map<String, dynamic>>[];
    list.add(ownership.toMap());
    await _storage.saveString(_ownershipsKey, jsonEncode(list));

    return ownership;
  }

  Future<OwnershipModel> addPayment(String userId, double amount) async {
    final data = await _storage.getString(_ownershipsKey);
    if (data == null) throw Exception('No active ownership found');

    final list = List<Map<String, dynamic>>.from(jsonDecode(data));
    final index = list.indexWhere(
      (o) => o['userId'] == userId && o['isCompleted'] == false,
    );

    if (index == -1) throw Exception('No active ownership found');

    var ownership = OwnershipModel.fromMap(list[index]);
    final newAmount = ownership.amountPaid + amount;
    final isCompleted = newAmount >= ownership.phonePrice;

    ownership = ownership.copyWith(
      amountPaid: newAmount.clamp(0, ownership.phonePrice),
      isCompleted: isCompleted,
      completionDate: isCompleted ? DateTime.now() : null,
    );

    list[index] = ownership.toMap();
    await _storage.saveString(_ownershipsKey, jsonEncode(list));

    return ownership;
  }

  Future<List<OwnershipModel>> getUserOwnerships(String userId) async {
    final data = await _storage.getString(_ownershipsKey);
    if (data == null) return [];
    final list = List<Map<String, dynamic>>.from(jsonDecode(data));
    return list
        .map((e) => OwnershipModel.fromMap(e))
        .where((o) => o.userId == userId)
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }
}
