import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;

  AuthSuccess(this.token);

  @override
  List<Object?> get props => [token];
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class LogoutSuccess extends AuthState {}

class LogoutFailure extends AuthState {}

class OtpSent extends AuthState {}

class OtpVerified extends AuthState {}

class PasswordReset extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object> get props => [message];
}
