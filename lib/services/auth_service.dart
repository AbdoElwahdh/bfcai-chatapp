import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<String?> signUp(String email, String password, String username) async {
    try {
      // Create user account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      if (credential.user != null) {
        final user = UserModel(
          id: credential.user!.uid,
          email: email,
          username: username,
          createdAt: Timestamp.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toMap());
      }

      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        return 'Email is already registered';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email format';
      } else {
        return e.message ?? 'Sign up failed';
      }
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  // Sign in with email and password
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email format';
      } else {
        return e.message ?? 'Sign in failed';
      }
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Find user by email
  Future<UserModel?> findUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
