import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'), // Set your actual background path
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top logo
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png', // Ensure it's a clean, circular logo
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Welcome text
              const Text(
                "Welcome To Zenfit",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const Spacer(),

              // Menu Buttons
              _buildMenuButton(context, "Available Package", '/admin_packages'),
              const SizedBox(height: 20),
              _buildMenuButton(context, "User Login Stats", '/admin_user_stats'),
              const SizedBox(height: 20),
              _buildMenuButton(context, "Add Trainer", '/admin_add_trainer'),
              const SizedBox(height: 20),
              _buildMenuButton(context, "Log out", '', isLogout: true),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, String route,
      {bool isLogout = false}) {
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          if (isLogout) {
            _logout(context);
          } else {
            Navigator.pushNamed(context, route);
          }
        },
        child: Text(label),
      ),
    );
  }
}
