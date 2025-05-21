import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/edit_password_repository.dart';

class EditPasswordBloc extends Bloc<EditPasswordEvent, EditPasswordState> {
  final EditPasswordRepository repository;

  EditPasswordBloc({required this.repository}) : super(EditPasswordInitial()) {
    on<SubmitEditPassword>((event, emit) async {
      emit(EditPasswordLoading());

      try {
        await repository.updatePassword(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
          confirmPassword: event.confirmPassword,
        );
        emit(const EditPasswordSuccess('Password berhasil diperbarui'));
      } catch (e) {
        emit(EditPasswordError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}

abstract class EditPasswordEvent extends Equatable {
  const EditPasswordEvent();
}

class SubmitEditPassword extends EditPasswordEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const SubmitEditPassword({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword, confirmPassword];
}

abstract class EditPasswordState extends Equatable {
  const EditPasswordState();

  @override
  List<Object> get props => [];
}

class EditPasswordInitial extends EditPasswordState {}

class EditPasswordLoading extends EditPasswordState {}

class EditPasswordSuccess extends EditPasswordState {
  final String message;

  const EditPasswordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class EditPasswordError extends EditPasswordState {
  final String message;

  const EditPasswordError(this.message);

  @override
  List<Object> get props => [message];
}
