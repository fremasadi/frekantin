import 'package:e_kantin/data/models/seller.dart';

import 'category.dart';

class Product {
  final int id;
  final int sellerId;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final String image;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Seller? seller; // Ubah menjadi nullable
  final Category category;

  Product({
    required this.id,
    required this.sellerId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
    this.seller, // Tidak wajib
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      sellerId: json['seller_id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price']),
      image: json['image'],
      stock: json['stock'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      seller: json['seller'] != null
          ? Seller.fromJson(json['seller'])
          : null, // Periksa null
      category: Category.fromJson(json['category']),
    );
  }
}
