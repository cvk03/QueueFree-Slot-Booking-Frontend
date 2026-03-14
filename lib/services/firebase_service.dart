import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  static Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user display name
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();

      // Create user document in Firestore with safe data
      await _firestore.collection('users').doc(userCredential.user?.uid).set(
        {
          'uid': userCredential.user?.uid,
          'email': email,
          'displayName': displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'photoURL': '',
          'hostel': '',
          'rollNumber': '',
        },
        SetOptions(merge: true),
      ).catchError((e) {
        print('Firestore error: $e');
        // Don't fail signup if Firestore fails
        return null;
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'The password provided is too weak. Use at least 6 characters.';
      } else if (e.code == 'email-already-in-use') {
        throw 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        throw 'The email address is invalid.';
      } else {
        throw e.message ?? 'An error occurred during sign up.';
      }
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Reload user to get latest data
      await userCredential.user?.reload();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        throw 'The email address is invalid.';
      } else if (e.code == 'user-disabled') {
        throw 'This user account has been disabled.';
      } else {
        throw e.message ?? 'An error occurred during sign in.';
      }
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out: $e';
    }
  }

  // Check if user is logged in
  static bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get user stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Reset password
  static Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw 'Failed to send reset email: $e';
    }
  }

  // Get user data from Firestore - FIXED
  static Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
      await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      } else {
        // Return empty map if user document doesn't exist
        return {
          'uid': uid,
          'email': '',
          'displayName': '',
          'photoURL': '',
        };
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // Return empty map on error instead of throwing
      return {
        'uid': uid,
        'email': '',
        'displayName': '',
        'photoURL': '',
      };
    }
  }

  // Get user name
  static String getUserDisplayName() {
    return _auth.currentUser?.displayName ?? 'User';
  }

  // Get user email
  static String getUserEmail() {
    return _auth.currentUser?.email ?? 'user@example.com';
  }

  // Get user photo URL
  static String? getUserPhotoURL() {
    return _auth.currentUser?.photoURL;
  }

  // Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (displayName != null) {
        await _auth.currentUser?.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }
      await _auth.currentUser?.reload();
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }
}