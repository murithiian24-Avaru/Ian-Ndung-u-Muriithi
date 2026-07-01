class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String country;
  final String profilePictureUrl;
  final String referralCode;
  final String? referredBy;
  final String deviceModel;
  final String deviceId;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isVerified;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.country,
    this.profilePictureUrl = '',
    required this.referralCode,
    this.referredBy,
    this.deviceModel = '',
    this.deviceId = '',
    required this.createdAt,
    required this.lastLoginAt,
    this.isVerified = false,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'country': country,
      'profilePictureUrl': profilePictureUrl,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'deviceModel': deviceModel,
      'deviceId': deviceId,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'isVerified': isVerified,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      country: map['country'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
      referralCode: map['referralCode'] ?? '',
      referredBy: map['referredBy'],
      deviceModel: map['deviceModel'] ?? '',
      deviceId: map['deviceId'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: DateTime.parse(map['lastLoginAt'] ?? DateTime.now().toIso8601String()),
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? country,
    String? profilePictureUrl,
    String? referralCode,
    String? referredBy,
    String? deviceModel,
    String? deviceId,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isVerified,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
    );
  }
}
