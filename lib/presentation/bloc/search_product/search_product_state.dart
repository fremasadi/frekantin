import 'package:equatable/equatable.dart';

import '../../../data/models/product.dart';

abstract class SearchProductState extends Equatable {
  const SearchProductState();

  @override
  List<Object> get props => [];
}

class SearchProductInitial extends SearchProductState {}

class SearchProductLoading extends SearchProductState {}

class SearchProductLoaded extends SearchProductState {
  final List<Product> products;

  const SearchProductLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class SearchProductError extends SearchProductState {
  final String message;

  const SearchProductError(this.message);

  @override
  List<Object> get props => [message];
}
