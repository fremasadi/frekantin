import 'package:e_kantin/data/models/cart_item.dart';
import 'package:equatable/equatable.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final String totalPrice;

  const CartLoaded(this.items, this.totalPrice);

  @override
  List<Object> get props => [items];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object> get props => [message];
}

class CartActionSuccess extends CartState {
  final String message;

  const CartActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}
