class Seller {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String image;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  Seller({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      image: json['image'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
