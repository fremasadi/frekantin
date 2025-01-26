part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchOrdersEvent extends OrderEvent {}

class CreateOrderEvent extends OrderEvent {
  final OrderRequest orderRequest;

  CreateOrderEvent(this.orderRequest);

  @override
  List<Object?> get props => [orderRequest];
}

class StartCountdownEvent extends OrderEvent {}

class FetchOrderEvent extends OrderEvent {
  FetchOrderEvent();

  @override
  List<Object?> get props => [];
}
