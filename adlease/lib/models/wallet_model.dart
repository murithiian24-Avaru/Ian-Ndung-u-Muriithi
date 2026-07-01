class WalletModel {
  final String userId;
  final double balance;
  final double totalEarnings;
  final double totalWithdrawn;
  final DateTime lastUpdated;

  WalletModel({
    required this.userId,
    required this.balance,
    required this.totalEarnings,
    required this.totalWithdrawn,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'balance': balance,
      'totalEarnings': totalEarnings,
      'totalWithdrawn': totalWithdrawn,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      userId: map['userId'] ?? '',
      balance: (map['balance'] ?? 0).toDouble(),
      totalEarnings: (map['totalEarnings'] ?? 0).toDouble(),
      totalWithdrawn: (map['totalWithdrawn'] ?? 0).toDouble(),
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  WalletModel copyWith({
    double? balance,
    double? totalEarnings,
    double? totalWithdrawn,
    DateTime? lastUpdated,
  }) {
    return WalletModel(
      userId: userId,
      balance: balance ?? this.balance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class WithdrawalRequest {
  final String id;
  final String userId;
  final double amount;
  final String paymentMethod;
  final String paymentDetails;
  final String status;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? adminNote;

  WithdrawalRequest({
    required this.id,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDetails,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.adminNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentDetails': paymentDetails,
      'status': status,
      'requestedAt': requestedAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'adminNote': adminNote,
    };
  }

  factory WithdrawalRequest.fromMap(Map<String, dynamic> map) {
    return WithdrawalRequest(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      paymentDetails: map['paymentDetails'] ?? '',
      status: map['status'] ?? 'pending',
      requestedAt: DateTime.parse(map['requestedAt'] ?? DateTime.now().toIso8601String()),
      processedAt: map['processedAt'] != null
          ? DateTime.parse(map['processedAt'])
          : null,
      adminNote: map['adminNote'],
    );
  }
}
