// table_number_event.dart
import 'package:bloc/bloc.dart';

import '../../../data/repository/table_repository.dart';

abstract class TableNumberEvent {}

class ValidateTableNumber extends TableNumberEvent {
  final String tableNumber;

  ValidateTableNumber({required this.tableNumber});
}

// table_number_state.dart
abstract class TableNumberState {}

class TableNumberInitial extends TableNumberState {}

class TableNumberLoading extends TableNumberState {}

class TableNumberValid extends TableNumberState {}

class TableNumberInvalid extends TableNumberState {
  final String message;

  TableNumberInvalid({required this.message});
}

class TableNumberError extends TableNumberState {
  final String error;

  TableNumberError({required this.error});
}

// table_number_bloc.dart

class TableNumberBloc extends Bloc<TableNumberEvent, TableNumberState> {
  final TableNumberRepository repository;

  TableNumberBloc({required this.repository}) : super(TableNumberInitial()) {
    on<ValidateTableNumber>(_onValidateTableNumber);
  }

  Future<void> _onValidateTableNumber(
    ValidateTableNumber event,
    Emitter<TableNumberState> emit,
  ) async {
    try {
      emit(TableNumberLoading());

      final result = await repository.validateTableNumber(event.tableNumber);

      if (result['status'] == true) {
        emit(TableNumberValid());
      } else {
        emit(TableNumberInvalid(
            message: result['message'] ?? 'Periksa Nomer Meja Dengan Benar'));
      }
    } catch (e) {
      emit(TableNumberError(error: e.toString()));
    }
  }
}
