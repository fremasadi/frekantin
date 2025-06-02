import 'package:bloc/bloc.dart';

import '../../../data/repository/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc(this.cartRepository) : super(CartInitial()) {
    on<LoadCart>((event, emit) async {
      emit(CartLoading());
      try {
        final items = await cartRepository.getCartItems();

        if (items.isEmpty) {
          emit(CartLoaded(items, ''));
        } else {
          final totalPrice = await cartRepository.getTotalPrice();
          emit(CartLoaded(items, totalPrice));
        }
      } catch (e) {
        emit(const CartError('Failed to load cart items'));
      }
    });

    on<AddCartItem>((event, emit) async {
      emit(CartLoading());
      try {
        await cartRepository.addItemToCart(event.productId, event.quantity);
        emit(const CartActionSuccess('Makanan berhasil ditambah ke keranjang'));
        add(LoadCart());
      } catch (e) {
        emit(CartError('Failed to add item to cart: $e'));
      }
    });

    on<UpdateCartItem>((event, emit) async {
      emit(CartLoading());
      try {
        await cartRepository.updateCartItem(event.itemId, event.quantity);
        emit(const CartActionSuccess('Cart item updated successfully'));
        add(LoadCart()); // Refresh cart after updating
      } catch (e) {
        emit(CartError(
            'Failed to update cart item: $e')); // Include error details
      }
    });

    on<RemoveCartItem>((event, emit) async {
      emit(CartLoading());
      try {
        await cartRepository.removeCartItem(event.itemId);
        emit(const CartActionSuccess('Cart item removed successfully'));
        add(LoadCart()); // Refresh cart after removing
      } catch (e) {
        emit(const CartError('Failed to remove cart item'));
      }
    });
    on<UpdateCartItemNotes>((event, emit) async {
      emit(CartLoading());
      try {
        await cartRepository.updateCartItemNotes(event.itemId, event.notes);
        emit(const CartActionSuccess('Catatan berhasil diperbarui'));
        add(LoadCart()); // Refresh cart after updating notes
      } catch (e) {
        emit(CartError('Failed to update cart item notes: $e'));
      }
    });
  }
}
