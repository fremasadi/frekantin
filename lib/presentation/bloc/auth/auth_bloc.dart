import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../data/repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await authRepository.login(event.email, event.password);
        emit(AuthSuccess(token!));
      } catch (e) {
        emit(AuthFailure('Login failed. Please try again.'));
      }
    });
    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final success = await authRepository.logout();
        if (success) {
          emit(LogoutSuccess());
        } else {
          emit(LogoutFailure());
        }
      } catch (e) {
        emit(LogoutFailure());
      }
    });
    on<SendOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.sendOtp(event.email);
        emit(OtpSent());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<VerifyOtpEvent>((event, emit) async {
      try {
        await authRepository.verifyOtp(event.email, event.otp);
        emit(OtpVerified());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<ResetPasswordEvent>((event, emit) async {
      try {
        await authRepository.resetPassword(event.email, event.newPassword);
        emit(PasswordReset());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
