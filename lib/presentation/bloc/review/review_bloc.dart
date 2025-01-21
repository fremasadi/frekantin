import 'package:bloc/bloc.dart';

import '../../../data/repository/review_repository.dart';

part 'review_event.dart';

part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository repository;
  final int productId; // Tambahkan productId sebagai parameter

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
  }
}
