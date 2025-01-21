// product_state.dart
import 'package:bloc/bloc.dart';
import 'package:e_kantin/data/models/product.dart';
import 'package:e_kantin/data/repository/product_repository.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;

  ProductLoaded(this.products);
}

class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}

class ProductCategoryLoading extends ProductState {}

class ProductCategoryLoaded extends ProductState {
  final List<Product> products;

  ProductCategoryLoaded(this.products);
}

class ProductCategoryError extends ProductState {
  final String message;

  ProductCategoryError(this.message);
}

// product_bloc.dart
class ProductBloc extends Cubit<ProductState> {
  final ProductRepository repository;

  ProductBloc({required this.repository}) : super(ProductInitial());

  Future<void> fetchProducts() async {
    try {
      emit(ProductLoading());
      final products = await repository.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
