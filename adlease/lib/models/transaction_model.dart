enum TransactionType { adReward, referralBonus, withdrawal, bonus }

enum TransactionStatus { pending, completed, rejected }

class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final TransactionStatus status;
  final String description;
  final DateTime createdAt;
  final String? referenceId;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.status,
    required this.description,
    required this.createdAt,
    this.referenceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'amount': amount,
      'status': status.name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'referenceId': referenceId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.adReward,
      ),
      amount: (map['amount'] ?? 0).toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TransactionStatus.pending,
      ),
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      referenceId: map['referenceId'],
    );
  }
}
