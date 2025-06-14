import 'package:e_kantin/data/models/seller.dart';
import 'category.dart';

class Product {
  final int id;
  final int sellerId;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final String? image;
  final int stock;
  final int isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Seller? seller;
  final Category category;
  final double averageRating; // Tambahan di sini

  Product({
    required this.id,
    required this.sellerId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.stock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.seller,
    required this.category,
    this.averageRating = 0.0, // Default 0.0 jika tidak ada
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      sellerId: json['seller_id'] is String
          ? int.parse(json['seller_id'])
          : json['seller_id'],
      categoryId: json['category_id'] is String
          ? int.parse(json['category_id'])
          : json['category_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.parse((json['price'] ?? '0').toString()),
      image: json['image'],
      stock: json['stock'] is String
          ? int.parse(json['stock'])
          : (json['stock'] ?? 0),
      isActive: json['is_active'] is String
          ? int.parse(json['is_active'])
          : json['is_active'] ?? 1,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      seller: json['seller'] != null ? Seller.fromJson(json['seller']) : null,
      category: Category.fromJson(json['category'] ?? {}),
      averageRating: json['average_rating'] != null
          ? double.tryParse(json['average_rating'].toString()) ?? 0.0
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price.toString(),
      'image': image,
      'stock': stock,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'average_rating': averageRating, // Tambahan
    };
  }
}
