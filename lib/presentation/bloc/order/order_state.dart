part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderSuccess extends OrderState {
  final Map<String, dynamic> response;

  OrderSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class OrderFailure extends OrderState {
  final String error;

  OrderFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class CountdownState extends OrderState {
  final String formattedTime;
  final int remainingSeconds;

  CountdownState({required this.formattedTime, required this.remainingSeconds});

  @override
  List<Object> get props => [formattedTime, remainingSeconds];
}

class OrdersLoaded extends OrderState {
  final List<Order> orders;

  OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}
