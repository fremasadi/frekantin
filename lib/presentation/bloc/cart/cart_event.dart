import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class LoadCart extends CartEvent {}

class AddCartItem extends CartEvent {
  final int productId;
  final int quantity;

  const AddCartItem(this.productId, this.quantity);

  @override
  List<Object> get props => [productId, quantity];
}

class UpdateCartItem extends CartEvent {
  final int itemId;
  final int quantity;

  const UpdateCartItem(this.itemId, this.quantity);

  @override
  List<Object> get props => [itemId, quantity];
}

class RemoveCartItem extends CartEvent {
  final int itemId;

  const RemoveCartItem(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class LoadCartTotal extends CartEvent {}

class UpdateCartItemNotes extends CartEvent {
  final int itemId;
  final String notes;

  UpdateCartItemNotes(this.itemId, this.notes);
}
