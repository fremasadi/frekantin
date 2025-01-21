class Review {
  final int id;
  final int productId;
  final int customerId;
  final double rating;
  final String comment;

  Review({
    required this.id,
    required this.productId,
    required this.customerId,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      productId: json['product_id'],
      customerId: json['customer_id'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
    );
  }
}

class AverageRating {
  final double averageRating;

  AverageRating({required this.averageRating});

  factory AverageRating.fromJson(Map<String, dynamic> json) {
    final rating = json['averageRating'];
    if (rating == null) return AverageRating(averageRating: 0.0);
    return AverageRating(averageRating: (rating as num).toDouble());
  }
}
