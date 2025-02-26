class AverageRating {
  final double averageRating;

  AverageRating({required this.averageRating});

  factory AverageRating.fromJson(Map<String, dynamic> json) {
    final rating = json['averageRating'];
    if (rating == null) return AverageRating(averageRating: 0.0);
    return AverageRating(averageRating: (rating as num).toDouble());
  }
}

class Review {
  final int orderId;
  final int productId;
  final int rating;
  final String comment;
  final String? image;

  Review({
    required this.orderId,
    required this.productId,
    required this.rating,
    required this.comment,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'rating': rating,
      'comment': comment,
      'image': image,
    };
  }
}
