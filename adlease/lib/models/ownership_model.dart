class OwnershipModel {
  final String id;
  final String userId;
  final String phoneId;
  final String phoneName;
  final double phonePrice;
  final double amountPaid;
  final DateTime startDate;
  final DateTime? completionDate;
  final bool isCompleted;

  OwnershipModel({
    required this.id,
    required this.userId,
    required this.phoneId,
    required this.phoneName,
    required this.phonePrice,
    required this.amountPaid,
    required this.startDate,
    this.completionDate,
    this.isCompleted = false,
  });

  double get progressPercentage =>
      phonePrice > 0 ? (amountPaid / phonePrice * 100).clamp(0, 100) : 0;

  double get remainingAmount => (phonePrice - amountPaid).clamp(0, phonePrice);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'phoneId': phoneId,
      'phoneName': phoneName,
      'phonePrice': phonePrice,
      'amountPaid': amountPaid,
      'startDate': startDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory OwnershipModel.fromMap(Map<String, dynamic> map) {
    return OwnershipModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      phoneId: map['phoneId'] ?? '',
      phoneName: map['phoneName'] ?? '',
      phonePrice: (map['phonePrice'] ?? 0).toDouble(),
      amountPaid: (map['amountPaid'] ?? 0).toDouble(),
      startDate: DateTime.parse(map['startDate'] ?? DateTime.now().toIso8601String()),
      completionDate: map['completionDate'] != null
          ? DateTime.parse(map['completionDate'])
          : null,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  OwnershipModel copyWith({
    double? amountPaid,
    bool? isCompleted,
    DateTime? completionDate,
  }) {
    return OwnershipModel(
      id: id,
      userId: userId,
      phoneId: phoneId,
      phoneName: phoneName,
      phonePrice: phonePrice,
      amountPaid: amountPaid ?? this.amountPaid,
      startDate: startDate,
      completionDate: completionDate ?? this.completionDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
