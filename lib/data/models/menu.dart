class Menu {
  final String id;
  final String category;
  final String description;
  final String imageUrl;
  final String name;
  final double price;
  final List<dynamic> reviews;
  final String userId;
  String? userName;

  Menu({
    required this.id,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.reviews,
    required this.userId,
    this.userName,
  });

  factory Menu.fromFirestore(Map<String, dynamic> data, String id) {
    return Menu(
      id: id,
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      name: data['name'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      reviews: data['reviews'] ?? [],
      userId: data['userId'] ?? '',
      userName: null,
    );
  }
}
