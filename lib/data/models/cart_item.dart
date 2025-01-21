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
      id: json['id'],
      cartId: json['cart_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      product: json['product'] != null
          ? CartProduct.fromJson(json['product'])
          : null,
    );
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
  final DateTime createdAt;
  final DateTime updatedAt;

  CartProduct({
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
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'],
      sellerId: json['seller_id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      image: json['image'],
      stock: json['stock'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
