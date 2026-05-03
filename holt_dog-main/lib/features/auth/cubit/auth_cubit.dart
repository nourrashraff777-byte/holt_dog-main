import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  // Login
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await _authService.login(email, password);
    if (result != null) {
      emit(Authenticated(result.user!.uid));
    } else {
      emit(const AuthError('Login failed. Please check your credentials.'));
    }
  }

  // Signup
  Future<void> signup(
      {required String name,
      required String phone,
      required String email,
      required String password,
      required String role}) async {
    emit(AuthLoading());
    final result = await _authService.signUp(
      name: name,
      phone: phone,
      email: email,
      password: password,
      role: role,
    );
    if (result != null) {
      emit(Authenticated(result.user!.uid));
    } else {
      emit(const AuthError('Signup failed. Email may be already in use.'));
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    emit(Unauthenticated());
  }

  // Send Reset Password Email
  Future<void> sendResetEmail(String email) async {
    emit(AuthLoading());
    try {
      await _authService.sendPasswordResetEmail(email);
      emit(AuthInitial()); // Reset to initial state or success state
    } catch (e) {
      emit(AuthError('Failed to send reset email: ${e.toString()}'));
    }
  }
}
