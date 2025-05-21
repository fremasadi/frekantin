class Category {
  final int id;
  final String name;
  final String? imageUrl; // Dapat null
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    this.imageUrl, // Dapat null
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      // Return default Category jika json kosong
      return Category(
        id: 0,
        name: 'Unknown',
      );
    }

    return Category(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      // Fallback ke 'Unknown' jika null
      imageUrl: json['image'],
      // Biarkan null jika null
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
