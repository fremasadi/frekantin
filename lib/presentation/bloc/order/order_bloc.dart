import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/order.dart';
import '../../../data/repository/order_repository.dart';

part 'order_event.dart';

part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc({required this.orderRepository}) : super(OrderInitial()) {
    on<CreateOrderEvent>(_onCreateOrderEvent);
    on<StartCountdownEvent>(_onStartCountdownEvent);
    on<FetchOrdersEvent>(_onFetchOrdersEvent);
  }

  Future<void> _onFetchOrdersEvent(
      FetchOrdersEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());

    try {
      final orders = await orderRepository.fetchOrders();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderFailure('Gagal mengambil daftar pesanan: ${e.toString()}'));
    }
  }

  Stream<int> countdownTimer(int totalSeconds) async* {
    for (int remaining = totalSeconds; remaining > 0; remaining--) {
      yield remaining;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _onCreateOrderEvent(
      CreateOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());

    try {
      final response = await orderRepository.postOrder(event.orderRequest);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        emit(OrderSuccess(responseData));
      } else {
        final errorData = jsonDecode(response.body);
        emit(OrderFailure(errorData['message'] ?? 'Gagal membuat pesanan.'));
      }
    } catch (e) {
      print(OrderFailure(e.toString()));
      emit(OrderFailure(e.toString()));
    }
  }

  Future<void> _onStartCountdownEvent(
      StartCountdownEvent event, Emitter<OrderState> emit) async {
    await emit.forEach(
      countdownTimer(3600), // 1 jam = 3600 detik
      onData: (remainingSeconds) {
        int minutes = remainingSeconds ~/ 60;
        int seconds = remainingSeconds % 60;
        return CountdownState(
          formattedTime: '$minutes:${seconds.toString().padLeft(2, '0')}',
          remainingSeconds: remainingSeconds,
        );
      },
    );
  }
}
