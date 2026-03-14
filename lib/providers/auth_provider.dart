import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isUserLoggedIn => _user != null;

  AuthProvider() {
    _initializeUser();
  }

  void _initializeUser() {
    _user = FirebaseService.currentUser;
    notifyListeners();
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    required String phoneNumber,
    required String misNumber,
    required String hostelName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty || displayName.isEmpty || 
          phoneNumber.isEmpty || misNumber.isEmpty || hostelName.isEmpty) {
        _errorMessage = 'All fields are required.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'Password must be at least 6 characters.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      UserCredential? credential = await FirebaseService.signUp(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: phoneNumber,
        misNumber: misNumber,
        hostelName: hostelName,
      );

      _user = credential?.user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Email and password are required.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      UserCredential? credential = await FirebaseService.signIn(
        email: email,
        password: password,
      );

      _user = credential?.user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseService.signOut();
      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty) {
        _errorMessage = 'Email is required.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await FirebaseService.resetPassword(email: email);
      _isLoading = false;
      _errorMessage = 'Password reset email sent. Check your inbox.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}