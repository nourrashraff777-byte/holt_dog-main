import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  // Login
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final credential = await _authService.login(email, password);
    if (credential == null || credential.user == null) {
      emit(const AuthError('Login failed. Please check your credentials.'));
      return;
    }
    final uid = credential.user!.uid;
    final userModel = await _authService.fetchUserData(uid);
    if (userModel == null) {
      emit(const AuthError('Failed to load user data. Please try again.'));
      return;
    }
    emit(Authenticated(userModel));
  }

  // Signup
  Future<void> signup({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    emit(AuthLoading());
    final credential = await _authService.signUp(
      name: name,
      phone: phone,
      email: email,
      password: password,
      role: role,
    );
    if (credential == null || credential.user == null) {
      emit(const AuthError('Signup failed. Email may be already in use.'));
      return;
    }
    final uid = credential.user!.uid;
    final userModel = await _authService.fetchUserData(uid);
    if (userModel == null) {
      emit(const AuthError('Failed to load user data. Please try again.'));
      return;
    }
    emit(Authenticated(userModel));
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    emit(Unauthenticated());
  }

  // Update Profile
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    final currentState = state;
    if (currentState is! Authenticated) return;

    emit(AuthLoading());
    final uid = currentState.user.id;
    
    final success = await _authService.updateUserProfile(
      uid: uid,
      name: name,
      phone: phone,
    );

    if (success) {
      // Fetch the updated user data
      final updatedUserModel = await _authService.fetchUserData(uid);
      if (updatedUserModel != null) {
        emit(Authenticated(updatedUserModel));
      } else {
        emit(const AuthError('Failed to refresh user data after update.'));
        emit(currentState); // Revert to previous state
      }
    } else {
      emit(const AuthError('Failed to update profile. Please try again.'));
      emit(currentState); // Revert to previous state
    }
  }

  // Send Reset Password Email
  Future<void> sendResetEmail(String email) async {
    emit(AuthLoading());
    try {
      await _authService.sendPasswordResetEmail(email);
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError('Failed to send reset email: ${e.toString()}'));
    }
  }
}
