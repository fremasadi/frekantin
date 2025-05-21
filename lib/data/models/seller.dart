class Seller {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? image; // Dapat null
  final String? fcmToken;
  final String role;
  final int isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Seller({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.image, // Dapat null
    this.fcmToken,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'] ?? '',
      // Fallback ke empty string jika null
      email: json['email'] ?? '',
      // Fallback ke empty string jika null
      phone: json['phone'] ?? '',
      // Fallback ke empty string jika null
      image: json['image'],
      // Biarkan null jika null
      fcmToken: json['fcm_token'],
      // Biarkan null jika null
      role: json['role'] ?? 'user',
      // Fallback ke 'user' jika null
      isActive: json['is_active'] is String
          ? int.parse(json['is_active'])
          : json['is_active'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'fcm_token': fcmToken,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Model untuk seller_info yang lebih ringkas
class SellerInfo {
  final int id;
  final String name;
  final bool isActive;

  SellerInfo({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] ?? 0,
      name: json['name'] ?? '', // Fallback ke empty string jika null
      isActive: json['is_active'] is String
          ? json['is_active'] == '1' || json['is_active'] == 'true'
          : json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive,
    };
  }
}
