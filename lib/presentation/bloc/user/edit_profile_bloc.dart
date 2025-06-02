import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/edit_profile_repository.dart';

// Events
abstract class EditProfileEvent {}

class SubmitEditProfile extends EditProfileEvent {
  final String username;
  final String email;
  final File? imageFile;
  final String? phone;

  SubmitEditProfile({
    required this.username,
    required this.email,
    this.imageFile,
    this.phone,
  });
}

// States
abstract class EditProfileState {}

class EditProfileInitial extends EditProfileState {}

class EditProfileLoading extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {
  final String message;

  EditProfileSuccess({required this.message});
}

class EditProfileError extends EditProfileState {
  final String message;

  EditProfileError({required this.message});
}

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final EditProfileRepository repository;

  EditProfileBloc({required this.repository}) : super(EditProfileInitial()) {
    on<SubmitEditProfile>((event, emit) async {
      emit(EditProfileLoading());
      try {
        final response = await repository.updateProfile(
          username: event.username,
          email: event.email,
          imageFile: event.imageFile,
          phone: event.phone,
        );
        emit(EditProfileSuccess(
            message: response['message'] ?? 'Profil berhasil diperbarui'));
      } catch (e) {
        emit(EditProfileError(message: e.toString()));
      }
    });
  }
}
