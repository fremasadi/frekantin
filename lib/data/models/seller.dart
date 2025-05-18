class Seller {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String image;
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
    required this.image,
    this.fcmToken,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      image: json['image'],
      fcmToken: json['fcm_token'],
      role: json['role'],
      isActive: json['is_active'] is String
          ? int.parse(json['is_active'])
          : json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'],
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
