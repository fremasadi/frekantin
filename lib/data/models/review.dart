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

class ReviewFeedbackResponse {
  final bool status;
  final List<ReviewFeedback> data;

  ReviewFeedbackResponse({
    required this.status,
    required this.data,
  });

  factory ReviewFeedbackResponse.fromJson(Map<String, dynamic> json) {
    return ReviewFeedbackResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => ReviewFeedback.fromJson(item))
          .toList(),
    );
  }
}

class ReviewFeedback {
  int id;
  String orderItemId;
  String productId;
  String customerId;
  String rating;
  String comment;
  String? image;
  String reviewDate;
  DateTime createdAt;
  DateTime updatedAt;
  Customer customer;

  ReviewFeedback({
    required this.id,
    required this.orderItemId,
    required this.productId,
    required this.customerId,
    required this.rating,
    required this.comment,
    this.image,
    required this.reviewDate,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
  });

  factory ReviewFeedback.fromJson(Map<String, dynamic> json) {
    return ReviewFeedback(
      id: json['id'] ?? 0,
      orderItemId: json['order_item_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '0',
      comment: json['comment']?.toString() ?? '',
      image: json['image']?.toString(),
      reviewDate: json['review_date']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      customer: Customer.fromJson(json['customer'] ?? {}),
    );
  }
}

class Customer {
  int id;
  String name;
  String email;
  String phone;
  String? image;
  String fcmToken;
  String role;
  DateTime createdAt;
  DateTime updatedAt;
  String isActive;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.image,
    required this.fcmToken,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      image: json['image']?.toString(),
      fcmToken: json['fcm_token']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      isActive: json['is_active']?.toString() ?? '0',
    );
  }
}
