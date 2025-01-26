import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentMethodUpdated extends PaymentState {
  final String paymentMethod;

  PaymentMethodUpdated(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}
