import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'trainer_login.dart'; 
import 'view_clients_screen.dart';

class TrainerDashboard extends StatelessWidget {
  const TrainerDashboard({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    // If you're using FirebaseAuth (optional)
    await FirebaseAuth.instance.signOut();

    // Navigate back to login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TrainerLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset('assets/images/logo.png', height: 60),
                const Spacer(),
                MenuButton(
                  text: 'Available Package',
                  onPressed: () {
                    // Navigate to Available Packages screen
                  },
                ),
                const SizedBox(height: 20),
                MenuButton(
                  text: 'View Clients',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewClientsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                MenuButton(
                  text: 'Diet Plan',
                  onPressed: () {
                    // Navigate to Diet Plan screen
                  },
                ),
                const SizedBox(height: 20),
                MenuButton(
                  text: 'Water Intake',
                  onPressed: () {
                    // Navigate to Water Intake screen
                  },
                ),
                const SizedBox(height: 20),
                MenuButton(text: 'Log out', onPressed: () => _logout(context)),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MenuButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
