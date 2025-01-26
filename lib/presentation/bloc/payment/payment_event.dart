import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentMethodSelected extends PaymentEvent {
  final String paymentMethod;

  PaymentMethodSelected(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}
