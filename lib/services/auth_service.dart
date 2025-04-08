import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if email already exists in Firebase Authentication and Firestore
  Future<bool> checkIfEmailExists(String email) async {
    try {
      // Check Firebase Authentication
      var methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        // Email exists in Firebase Authentication
        return true;
      }

      // Check Firestore
      var snapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
      if (snapshot.docs.isNotEmpty) {
        // Email exists in Firestore
        return true;
      }

      return false;
    } catch (e) {
      print("Error checking if email exists: $e");
      return false;
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      // Check if email is already in use
      bool emailExists = await checkIfEmailExists(email);
      if (emailExists) {
        print('Error: The email address is already in use.');
        return null;  // Email is already in use
      }

      // Check if this is the first user for assigning role
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
