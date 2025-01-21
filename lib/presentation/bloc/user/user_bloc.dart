import 'package:e_kantin/data/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repository/user_repository.dart';

abstract class UserEvent {}

class FetchUserEvent extends UserEvent {}

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;

  UserLoaded(this.user);
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc(this.userRepository) : super(UserInitial()) {
    on<FetchUserEvent>((event, emit) async {
      emit(UserLoading());
      try {
        final user = await userRepository.fetchUser();
        emit(UserLoaded(user));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });
  }
}
