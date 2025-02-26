part of 'review_bloc.dart';

abstract class ReviewEvent {}

class FetchAverageRating extends ReviewEvent {
  final int productId;

  FetchAverageRating(this.productId);
}

class SubmitReview extends ReviewEvent {
  final int orderId;
  final int productId;
  final int rating;
  final String comment;
  final String? image;

  SubmitReview({
    required this.orderId,
    required this.productId,
    required this.rating,
    required this.comment,
    this.image,
  });
}

class CheckReviewStatus extends ReviewEvent {
  final int orderItemId;
  final int productId;

  CheckReviewStatus({
    required this.orderItemId,
    required this.productId,
  });
}
