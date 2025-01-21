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
