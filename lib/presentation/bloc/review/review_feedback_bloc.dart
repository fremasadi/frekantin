import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/review.dart';
import '../../../data/repository/review_feedback_repository.dart';

// Event
abstract class ReviewFeedbackEvent extends Equatable {
  const ReviewFeedbackEvent();

  @override
  List<Object?> get props => [];
}

class FetchReviewFeedback extends ReviewFeedbackEvent {
  final int productId;

  const FetchReviewFeedback(this.productId);

  @override
  List<Object?> get props => [productId];
}

// State
abstract class ReviewFeedbackState extends Equatable {
  const ReviewFeedbackState();

  @override
  List<Object?> get props => [];
}

class ReviewFeedbackInitial extends ReviewFeedbackState {}

class ReviewFeedbackLoading extends ReviewFeedbackState {}

class ReviewFeedbackLoaded extends ReviewFeedbackState {
  final ReviewFeedbackResponse reviewFeedbackResponse;

  const ReviewFeedbackLoaded(this.reviewFeedbackResponse);

  @override
  List<Object?> get props => [reviewFeedbackResponse];
}

class ReviewFeedbackError extends ReviewFeedbackState {
  final String message;

  const ReviewFeedbackError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ReviewFeedbackBloc
    extends Bloc<ReviewFeedbackEvent, ReviewFeedbackState> {
  final ReviewFeedbackRepository repository;

  ReviewFeedbackBloc({required this.repository})
      : super(ReviewFeedbackInitial()) {
    on<FetchReviewFeedback>(_onFetchReviewFeedback);
  }

  Future<void> _onFetchReviewFeedback(
    FetchReviewFeedback event,
    Emitter<ReviewFeedbackState> emit,
  ) async {
    emit(ReviewFeedbackLoading());

    try {
      final result = await repository.fetchReviewFeedback(event.productId);

      if (result != null && result.status) {
        emit(ReviewFeedbackLoaded(result));
      } else {
        emit(const ReviewFeedbackError('Failed to fetch review feedback'));
      }
    } catch (e) {
      emit(ReviewFeedbackError(e.toString()));
    }
  }
}
