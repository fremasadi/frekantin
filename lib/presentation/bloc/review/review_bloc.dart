import 'package:bloc/bloc.dart';
import '../../../data/models/review.dart';
import '../../../data/repository/review_repository.dart';

part 'review_event.dart';

part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository repository;
  final int productId;

  ReviewBloc({
    required this.repository,
    required this.productId,
  }) : super(ReviewInitial()) {
    on<FetchAverageRating>((event, emit) async {
      emit(ReviewLoading());
      try {
        final averageRating = await repository.fetchAverageRating(productId);
        emit(ReviewLoaded(averageRating.averageRating));
      } catch (e) {
        emit(ReviewError(e.toString()));
      }
    });

    on<SubmitReview>((event, emit) async {
      emit(ReviewLoading());
      try {
        final review = Review(
          orderId: event.orderId,
          productId: event.productId,
          rating: event.rating,
          comment: event.comment,
          image: event.image,
        );

        await repository.submitReview(review);
        emit(ReviewSubmitSuccess());

        // Setelah submit berhasil, fetch average rating terbaru
        final averageRating = await repository.fetchAverageRating(productId);
        emit(ReviewLoaded(averageRating.averageRating));
      } catch (e) {
        emit(ReviewError(e.toString()));
      }
    });
    on<CheckReviewStatus>((event, emit) async {
      emit(ReviewCheckLoading()); // Tampilkan loading
      try {
        // Panggil repository untuk memeriksa status review
        final data = await repository.checkReview(
          event.orderItemId,
          event.productId,
        );

        // Kirim state ReviewChecked dengan data yang diterima
        emit(ReviewChecked(
          isReviewed: data['status'] ?? false,
          rating: data['rating'],
          comment: data['comment'],
          orderItemId: event.orderItemId,
          productId: event.productId,
        ));
      } catch (e) {
        // Jika terjadi error, kirim state ReviewCheckError
        emit(ReviewCheckError(e.toString()));
      }
    });
  }
}
