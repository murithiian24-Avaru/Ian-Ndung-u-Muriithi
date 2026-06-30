class AdModel {
  final String id;
  final String title;
  final String advertiserName;
  final String videoUrl;
  final String thumbnailUrl;
  final int durationSeconds;
  final double rewardAmount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int totalViews;

  AdModel({
    required this.id,
    required this.title,
    required this.advertiserName,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.durationSeconds = 60,
    required this.rewardAmount,
    this.isActive = true,
    required this.createdAt,
    required this.expiresAt,
    this.totalViews = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'advertiserName': advertiserName,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'durationSeconds': durationSeconds,
      'rewardAmount': rewardAmount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'totalViews': totalViews,
    };
  }

  factory AdModel.fromMap(Map<String, dynamic> map) {
    return AdModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      advertiserName: map['advertiserName'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      durationSeconds: map['durationSeconds'] ?? 60,
      rewardAmount: (map['rewardAmount'] ?? 0).toDouble(),
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: DateTime.parse(map['expiresAt'] ?? DateTime.now().toIso8601String()),
      totalViews: map['totalViews'] ?? 0,
    );
  }
}

class AdViewRecord {
  final String id;
  final String userId;
  final String adId;
  final DateTime viewedAt;
  final bool completedFully;
  final double rewardEarned;
  final String deviceId;
  final String verificationHash;

  AdViewRecord({
    required this.id,
    required this.userId,
    required this.adId,
    required this.viewedAt,
    required this.completedFully,
    required this.rewardEarned,
    required this.deviceId,
    required this.verificationHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'adId': adId,
      'viewedAt': viewedAt.toIso8601String(),
      'completedFully': completedFully,
      'rewardEarned': rewardEarned,
      'deviceId': deviceId,
      'verificationHash': verificationHash,
    };
  }

  factory AdViewRecord.fromMap(Map<String, dynamic> map) {
    return AdViewRecord(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      adId: map['adId'] ?? '',
      viewedAt: DateTime.parse(map['viewedAt'] ?? DateTime.now().toIso8601String()),
      completedFully: map['completedFully'] ?? false,
      rewardEarned: (map['rewardEarned'] ?? 0).toDouble(),
      deviceId: map['deviceId'] ?? '',
      verificationHash: map['verificationHash'] ?? '',
    );
  }
}
