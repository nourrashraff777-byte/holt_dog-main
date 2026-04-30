import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Stream of the current authenticated user (null when logged out).
  Stream<User?> get user => _auth.authStateChanges();

  /// Sign up with email + password. [role] can be stored later with the user profile.
  Future<UserCredential?> signUp(
    String email,
    String password, {
    String role = 'user',
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('SignUp Error: $e');
      return null;
    }
  }

  /// Login with email + password.
  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Login Error: $e');
      return null;
    }
  }

  /// Sign out the current user.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Send a password-reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Password Reset Error: $e');
      rethrow;
    }
  }
}
