import 'package:bloc/bloc.dart';
import 'package:e_kantin/presentation/bloc/search_product/search_product_event.dart';
import 'package:e_kantin/presentation/bloc/search_product/search_product_state.dart';

import '../../../data/repository/product_repository.dart';

class SearchProductBloc extends Bloc<SearchProductEvent, SearchProductState> {
  final ProductRepository productRepository;

  SearchProductBloc({required this.productRepository})
      : super(SearchProductInitial()) {
    on<SearchProductByKeyword>((event, emit) async {
      emit(SearchProductLoading());
      try {
        final products = await productRepository.searchProducts(event.keyword);
        emit(SearchProductLoaded(products));
      } catch (e) {
        emit(SearchProductError("Failed to search products: ${e.toString()}"));
      }
    });
    on<ClearSearchResults>((event, emit) {
      print("ClearSearchResults event diproses");

      emit(SearchProductInitial());
    });
  }
}
