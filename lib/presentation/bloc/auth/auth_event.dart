import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class SendOtpEvent extends AuthEvent {
  final String email;

  SendOtpEvent(this.email);

  @override
  List<Object> get props => [email];
}

class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String otp;

  VerifyOtpEvent(this.email, this.otp);

  @override
  List<Object> get props => [email, otp];
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String newPassword;

  ResetPasswordEvent({required this.email, required this.newPassword});
}
