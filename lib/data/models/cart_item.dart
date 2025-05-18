import 'package:e_kantin/data/models/seller.dart';

class CartItem {
  final int id;
  final int cartId;
  final int productId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CartProduct? product;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      cartId: json['cart_id'] is String
          ? int.parse(json['cart_id'])
          : json['cart_id'],
      productId: json['product_id'] is String
          ? int.parse(json['product_id'])
          : json['product_id'],
      quantity: json['quantity'] is String
          ? int.parse(json['quantity'])
          : json['quantity'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      product: json['product'] != null
          ? CartProduct.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'product': product?.toJson(),
    };
  }
}

class CartProduct {
  final int id;
  final int sellerId;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final String image;
  final int stock;
  final int isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SellerInfo? sellerInfo;
  final Seller? seller;

  CartProduct({
    required this.id,
    required this.sellerId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.stock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.sellerInfo,
    this.seller,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      sellerId: json['seller_id'] is String
          ? int.parse(json['seller_id'])
          : json['seller_id'],
      categoryId: json['category_id'] is String
          ? int.parse(json['category_id'])
          : json['category_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      image: json['image'],
      stock: json['stock'] is String ? int.parse(json['stock']) : json['stock'],
      isActive: json['is_active'] is String
          ? int.parse(json['is_active'])
          : json['is_active'] ?? 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      sellerInfo: json['seller_info'] != null
          ? SellerInfo.fromJson(json['seller_info'])
          : null,
      seller: json['seller'] != null ? Seller.fromJson(json['seller']) : null,
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
      'seller_info': sellerInfo?.toJson(),
      'seller': seller?.toJson(),
    };
  }
}
