import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isUpdating = false;

  Future<void> _updatePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;

    if (newPassword != _confirmPasswordController.text) {
      _showSnackbar('New passwords do not match');
      return;
    }

    try {
      setState(() => _isUpdating = true);

      final credential = EmailAuthProvider.credential(email: email!, password: oldPassword);
      await user!.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      _showSnackbar('Password updated successfully');
    } on FirebaseAuthException catch (e) {
      _showSnackbar('Error: ${e.message}');
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _submitMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final name = user?.displayName ?? 'User';
    final email = user?.email;
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      _showSnackbar('Message cannot be empty');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('user_feedback').doc(uid).set({
        'name': name,
        'email': email,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      _showSnackbar('Message sent successfully');
    } catch (e) {
      _showSnackbar('Failed to send message');
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Update Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Old Password"),
              ),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "New Password"),
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirm New Password"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isUpdating ? null : _updatePassword,
                child: _isUpdating
                    ? const CircularProgressIndicator()
                    : const Text("Update Password"),
              ),
              const Divider(height: 30, thickness: 1),
              const Text("Leave a Message for Trainer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Your Message",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitMessage,
                child: const Text("Send Message"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
