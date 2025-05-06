import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_login.dart'; // adjust this import to your actual path

class AdminForgotPasswordScreen extends StatefulWidget {
  const AdminForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _AdminForgotPasswordScreenState createState() => _AdminForgotPasswordScreenState();
}

class _AdminForgotPasswordScreenState extends State<AdminForgotPasswordScreen> {
  final TextEditingController _phoneController            = TextEditingController();
  final TextEditingController _newPasswordController      = TextEditingController();
  final TextEditingController _confirmPasswordController  = TextEditingController();

  bool _phoneVerified = false;
  String? _adminDocId;

  Future<void> _verifyPhoneNumber() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phone)
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number not found.')),
        );
      } else {
        setState(() {
          _phoneVerified = true;
          _adminDocId    = snap.docs.first.id;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying phone: $e')),
      );
    }
  }

  Future<void> _resetPassword() async {
    final newPwd     = _newPasswordController.text.trim();
    final confirmPwd = _confirmPasswordController.text.trim();

    if (newPwd != confirmPwd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }
    if (_adminDocId == null) return;

    // Prompt for master key
    final masterInput = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctl = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Master Password'),
          content: TextField(
            controller: ctl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Master Password'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, ctl.text),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (masterInput != 'master123') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect master password.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_adminDocId)
          .update({'password': newPwd});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminLogin()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Registered Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (!_phoneVerified)
              ElevatedButton(
                onPressed: _verifyPhoneNumber,
                child: const Text('Verify Phone Number'),
              )
            else ...[
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetPassword,
                child: const Text('Reset & Go to Login'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
