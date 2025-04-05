import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      print('Checking if user is the first user...');
      QuerySnapshot users = await _firestore.collection('users').get();
      String role = users.docs.isEmpty ? 'admin' : 'user';

      print('Creating user with email: $email');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('User creation failed: user is null.');
      }

      print('Saving user data to Firestore...');
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'role': role,
      });

      print('Signup successful!');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('Error: The email address is already in use by another account.');
      } else {
        print('FirebaseAuthException: ${e.code} - ${e.message ?? 'No message available'}');
      }
      return null;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('Signing in with email: $email');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Sign-in successful!');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('Error: No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Error: Wrong password provided for that user.');
      } else {
        print('FirebaseAuthException: ${e.code} - ${e.message ?? 'No message available'}');
      }
      return null;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Signing out...');
      await _auth.signOut();
      print('Sign-out successful!');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}