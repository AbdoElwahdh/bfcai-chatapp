import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up with Search Optimization
  Future<String?> signUpWithEmail(
    String email,
    String password,
    String username,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).set({
          'username': username,
          'username_lowercase': username.toLowerCase(), // Critical for search
          'email': email,
          'uid': uid,
          'createdAt': Timestamp.now(),
        });
      }

      return null; // success
    } on FirebaseAuthException catch (e) {
      return "Error: ${e.message}";
    } catch (e) {
      return "Unexpected error: ${e.toString()}";
    }
  }

  // Sign In
  Future<String?> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return "Error: ${e.message}";
    } catch (e) {
      return "Unexpected error: ${e.toString()}";
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
