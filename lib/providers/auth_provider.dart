import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoading;

  AuthState({this.isLoading = false});

  AuthState copyWith({bool? isLoading}) {
    return AuthState(isLoading: isLoading ?? this.isLoading);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthNotifier() : super(AuthState());

  Future<String?> signIn(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true);

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      state = state.copyWith(isLoading: false);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false);
      return _getErrorMessage(e);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'An unexpected error occurred: $e';
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true);

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(isLoading: false);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false);
      return _getErrorMessage(e);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 'An unexpected error occurred: $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      default:
        return 'Authentication failed: ${e.message ?? e.code}';
    }
  }
}

// Auth provider - only tracks loading state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Simple auth check using Firebase directly
final isAuthenticatedProvider = Provider<bool>((ref) {
  // This will only rebuild when manually invalidated
  return FirebaseAuth.instance.currentUser != null;
});
