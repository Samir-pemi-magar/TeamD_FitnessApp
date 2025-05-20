import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp/screens/admin/admin_package.dart';
import 'package:fitnessapp/screens/common/welcome_screen.dart';
import 'package:fitnessapp/screens/trainer/PackageScreen.dart';
import 'package:flutter/material.dart';

import 'package:fitnessapp/screens/trainer/TrainerExerciseAdd.dart';
import 'package:fitnessapp/screens/trainer/WaterIntakeView.dart';
import 'trainer_login.dart';
import 'view_clients_screen.dart';

class TrainerDashboard extends StatefulWidget {
  const TrainerDashboard({Key? key}) : super(key: key);

  @override
  _TrainerDashboardState createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  String? emailAddress;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Confirm Logout"),
            content: Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Cancel
                child: Text("No"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close dialog
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => TrainerLogin()),
                    (route) => false,
                  );
                },
                child: Text("Yes"),
              ),
            ],
          ),
    );
  }

  void _fetchUser() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('selectedUser').get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          emailAddress = snapshot.docs[0]['EmailAddress'];
          isLoading = false;
        });
        print("Email Address: $emailAddress");
      } else {
        setState(() {
          isLoading = false;
        });
        print("No user found in selectedUser collection.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching user: $e");
    }
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvailablePackagesScreen(),
                      ),
                    );
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
                  text: 'Add Exercise',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrainerExerciseManager(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                MenuButton(
                  text: 'Water Intake Graph',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WaterIntakeScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                MenuButton(
                  text: 'Log Out',
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()),
                      (route) => false,
                    );
                  },
                ),

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
