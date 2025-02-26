part of 'review_bloc.dart';

abstract class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final double rating;

  ReviewLoaded(this.rating);
}

class ReviewError extends ReviewState {
  final String message;

  ReviewError(this.message);
}

class ReviewSubmitSuccess extends ReviewState {}

class ReviewCheckLoading extends ReviewState {}

class ReviewCheckError extends ReviewState {
  final String message;

  ReviewCheckError(this.message);
}

class ReviewChecked extends ReviewState {
  final bool isReviewed;
  final int? rating;
  final String? comment;
  final int orderItemId;
  final int productId;

  ReviewChecked({
    required this.isReviewed,
    this.rating,
    this.comment,
    required this.orderItemId,
    required this.productId,
  });
}
