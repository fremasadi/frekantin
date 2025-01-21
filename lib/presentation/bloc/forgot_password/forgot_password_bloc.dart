import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PhoneEvent {}

class PhoneNumberChanged extends PhoneEvent {
  final String phoneNumber;

  PhoneNumberChanged(this.phoneNumber);
}

class PhoneState {
  final String phoneNumber;

  PhoneState(this.phoneNumber);
}

class ForgotpasswordBloc extends Bloc<PhoneEvent, PhoneState> {
  ForgotpasswordBloc() : super(PhoneState('')) {
    on<PhoneNumberChanged>((event, emit) {
      String input = event.phoneNumber;

      if (input.startsWith('0')) {
        input = input.substring(1);
      }

      emit(PhoneState(input));
    });
  }
}
