import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class ProfileModel extends ChangeNotifier {
  String displayName = "User";
  String userEmail = "user@example.com";
  String? userPhotoUrl;

  bool isLoading = false;
  bool isLoggingOut = false;
  String? errorMessage;

  ProfileModel() {
    initState();
  }

  void initState() {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = FirebaseService.currentUser;
      if (user != null) {
        displayName = FirebaseService.getUserDisplayName();
        userEmail = FirebaseService.getUserEmail();
        userPhotoUrl = FirebaseService.getUserPhotoURL();
      }
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load profile: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    isLoggingOut = true;
    errorMessage = null;
    notifyListeners();

    try {
      await FirebaseService.signOut();
      isLoggingOut = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Logout failed: $e';
      isLoggingOut = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    await _loadUserProfile();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}