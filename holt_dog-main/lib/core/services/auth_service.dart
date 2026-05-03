import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Stream of the current authenticated user (null when logged out).
  Stream<User?> get user => _auth.authStateChanges();

  /// Sign up with email + password. [role] can be stored later with the user profile.
  Future<UserCredential?> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Store user details in Firestore
      final user = userCredential.user;
      if (user != null) {
        await _auth.currentUser!.updateDisplayName(name);
        
        // Store additional user data in Firestore
        await _saveUserDetails(user.uid, name, phone, email, role);
      }
      return userCredential;
    } catch (e) {
      debugPrint('SignUp Error: $e');
      return null;
    }
  }

  Future<void> _saveUserDetails(
    String uid,
    String name,
    String phone,
    String email,
    String role,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
    debugPrint('User details saved: uid=$uid, name=$name, role=$role');
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
