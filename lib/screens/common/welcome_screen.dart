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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Circular Logo
              Image.asset(
                'assets/images/logo.png',
                height: 80,
              ),
              const SizedBox(height: 20),
              // App Name
              const Text(
                'ZenFit',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              // Log In Button
              _buildButton(context, 'Log In', const UserLogin()),
              const SizedBox(height: 15),
              // Sign Up Button
              _buildButton(context, 'Sign Up', const UserSignup()),
              const SizedBox(height: 30),
              // Role Buttons (Admin, Trainer)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSmallButton(context, 'Admin', const AdminLogin()),
                  const SizedBox(width: 10),
                  _buildSmallButton(context, 'Trainer', const TrainerLogin()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Large Button (Log In / Sign Up)
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
          backgroundColor: Colors.green.shade300,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  // Small Button (Admin / Trainer)
  Widget _buildSmallButton(BuildContext context, String text, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 80, 162, 82),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
