import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if email already exists in Firebase Auth or Firestore
  Future<bool> checkIfEmailExists(String email) async {
    try {
      var methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) return true;

      var snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking email: $e");
      return false;
    }
  }

  /// Sign up a user with role (admin, trainer, user)
  Future<Map<String, dynamic>?> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String? requestedRole,
  }) async {
    try {
      // Email already in use?
      if (await checkIfEmailExists(email)) {
        print('Email already in use.');
        return null;
      }

      // Determine role
      String role;
      final existingUsers = await _firestore.collection('users').get();

      if (requestedRole == 'admin') {
        final adminCheck = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'admin')
            .get();

        if (adminCheck.docs.isNotEmpty) {
          throw Exception('An admin already exists.');
        }
        role = 'admin';
      } else if (requestedRole != null) {
        role = requestedRole;
      } else {
        role = existingUsers.docs.isEmpty ? 'admin' : 'user';
      }

      print('Creating $role account for $email');

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('User creation failed.');

      // Save user data in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'role': role,
      });

      return {
        'uid': user.uid,
        'email': email,
        'role': role,
        'name': name,
      };
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Signup error: $e');
      return null;
    }
  }

  /// Sign in with email and password, return user profile
  Future<Map<String, dynamic>?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('Signing in: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception("User UID is null.");

      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) throw Exception("User profile not found in Firestore.");

      final data = userDoc.data()!;
      print("Signed in as ${data['role']}");

      return {
        'uid': uid,
        'email': email,
        'role': data['role'],
        'name': data['name'],
      };
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Sign-in error: $e');
      return null;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('Signed out successfully.');
    } catch (e) {
      print('Sign-out error: $e');
    }
  }
}
