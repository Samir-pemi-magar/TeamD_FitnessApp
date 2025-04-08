import 'package:flutter/material.dart';
import '../user/user_login.dart';
import '../user/user_signup.dart';
import '../admin/admin_login.dart';
import '../trainer/trainer_login.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 60),
              // Logo and App Title
              Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'zenfit',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              // Login/Signup buttons
              Column(
                children: [
                  _buildButton(context, 'Log In', const UserLogin()),
                  const SizedBox(height: 15),
                  _buildButton(context, 'Sign Up', const UserSignup()),
                ],
              ),
              
              // Admin/Trainer buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSmallButton(context, 'Admin', const AdminLogin()),
                    const SizedBox(width: 20),
                    _buildSmallButton(context, 'Trainer', const TrainerLogin()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Main buttons (Log In / Sign Up)
  Widget _buildButton(BuildContext context, String text, Widget page) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, color: Colors.green.shade700),
        ),
      ),
    );
  }

  // Small buttons (Admin / Trainer)
  Widget _buildSmallButton(BuildContext context, String text, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, color: Colors.green.shade700),
      ),
    );
  }
}
