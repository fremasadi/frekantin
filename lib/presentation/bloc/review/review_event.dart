part of 'review_bloc.dart';

abstract class ReviewEvent {}

class FetchAverageRating extends ReviewEvent {
  final int productId;

  FetchAverageRating(this.productId);
}
