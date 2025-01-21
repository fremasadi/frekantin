import 'package:bloc/bloc.dart';
import '../../../data/repository/category_repository.dart';
import 'category_state.dart';
import 'categoty_event.dart';

// BLoC
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc(this.categoryRepository) : super(CategoryInitial()) {
    on<FetchCategories>((event, emit) async {
      emit(CategoryLoading());
      try {
        final categories = await categoryRepository.fetchCategories();
        // Debug log
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
        // Debug log
      }
    });

  }
}