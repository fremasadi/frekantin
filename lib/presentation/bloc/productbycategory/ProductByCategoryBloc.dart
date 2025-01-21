import 'package:bloc/bloc.dart';
import 'package:e_kantin/data/models/product.dart';
import 'package:e_kantin/data/repository/product_repository.dart';

abstract class ProductByCategoryState {}

class ProductByCategoryInitial extends ProductByCategoryState {}

class ProductByCategoryLoading extends ProductByCategoryState {}

class ProductByCategoryLoaded extends ProductByCategoryState {
  final List<Product> products;

  ProductByCategoryLoaded(this.products);
}

class ProductByCategoryError extends ProductByCategoryState {
  final String message;

  ProductByCategoryError(this.message);
}

class ProductByCategoryBloc extends Cubit<ProductByCategoryState> {
  final ProductRepository repository;

  ProductByCategoryBloc({required this.repository})
      : super(ProductByCategoryInitial());

  Future<void> fetchProductsByCategory(String categoryId) async {
    try {
      emit(ProductByCategoryLoading());
      final products = await repository.getProductByCategory(categoryId);
      emit(ProductByCategoryLoaded(products));
    } catch (e) {
      emit(ProductByCategoryError(e.toString()));
    }
  }
}
