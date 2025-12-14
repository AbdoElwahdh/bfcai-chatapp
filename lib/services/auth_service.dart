// Simple auth wrapper: sign up, sign in, sign out, current user.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up a new user and store extra data in Firestore
  Future<String?> signUpWithEmail(
      String email, String password, String username) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).set({
          'username': username,
          'email': email,
          'uid': uid,
          'createdAt': Timestamp.now(),
        });
      }

      return null; // success
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e.code);
    } catch (_) {
      return "Unknown error. Please try again.";
    }
  }

  // Sign in existing user
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e.code);
    } catch (_) {
      return "Unknown error. Please try again.";
    }
  }

  // Sign out user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Current user getter
  User? get currentUser => _auth.currentUser;

  // Error message handler (internal)
  String _handleAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return "Email already in use. Try logging in.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'user-not-found':
        return "No user found with this email.";
      case 'network-request-failed':
        return "Network error. Check your internet connection.";
      default:
        return "Something went wrong. Please try again.";
    }
  }
}
