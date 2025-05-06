import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminUpdatePasswordScreen extends StatefulWidget {
  const AdminUpdatePasswordScreen({super.key});

  @override
  _AdminUpdatePasswordScreenState createState() => _AdminUpdatePasswordScreenState();
}

class _AdminUpdatePasswordScreenState extends State<AdminUpdatePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _statusMessage = "";
  bool _isLoading = false;

  Future<void> _updateAdminPassword() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "";
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final currentPassword = _currentPasswordController.text.trim();
      final newPassword = _newPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (newPassword != confirmPassword) {
        setState(() {
          _statusMessage = "New passwords do not match.";
          _isLoading = false;
        });
        return;
      }

      if (user == null) {
        setState(() {
          _statusMessage = "No admin user logged in.";
          _isLoading = false;
        });
        return;
      }

      final uid = user.uid;
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        setState(() {
          _statusMessage = "Admin data not found in Firestore.";
          _isLoading = false;
        });
        return;
      }

      final storedPassword = docSnapshot['password'];

      if (storedPassword != currentPassword) {
        setState(() {
          _statusMessage = "Current password is incorrect.";
          _isLoading = false;
        });
        return;
      }

      // Re-authenticate the admin
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      // Update Firestore password field
      await docRef.update({'password': newPassword});

      setState(() {
        _statusMessage = "Password updated successfully!";
        _isLoading = false;
      });

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      setState(() {
        _statusMessage = "Error: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Update Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm New Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateAdminPassword,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Update Password'),
            ),
            if (_statusMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(_statusMessage, style: TextStyle(color: _statusMessage.contains("success") ? Colors.green : Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}
