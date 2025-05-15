import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/user/Packages/PaymentStatement.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:fitnessapp/screens/user/WaterIntake/WaterIntake.dart';
import 'package:fitnessapp/screens/user/user_dashboard.dart';
import 'package:fitnessapp/screens/user/user_profile_screen.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ConfirmationPayment extends StatefulWidget {
  final String packageName;
  final double packagePrice;
  final dynamic age;
  final DateTime timestamp;
  final String EmailAddress;

  const ConfirmationPayment({
    super.key,
    required this.packageName,
    required this.packagePrice,
    required this.age,
    required this.timestamp,
    required this.EmailAddress,
  });

  @override
  _ConfirmationPaymentState createState() => _ConfirmationPaymentState();
}

class _ConfirmationPaymentState extends State<ConfirmationPayment> {
  int _selectedIndex = 2;
  bool isSaving = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserDashboard()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WaterIntake()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Packages()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen()),
        );
        break;
    }
  }

  Future<void> savePaymentToFirestore() async {
    setState(() {
      isSaving = true;
    });

    try {
      final docRef = FirebaseFirestore.instance
          .collection('selectedpackage')
          .doc(widget.EmailAddress);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
        final DateTime purchaseDate = timestamp.toDate();
        final DateTime now = DateTime.now();
        final Duration diff = now.difference(purchaseDate);

        if (diff.inDays < 3) {
          bool replace = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Package Already Purchased"),
              content: const Text(
                "You already have a package that was purchased less than 3 days ago.\n"
                "Do you want to replace the old package at your own risk?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Replace"),
                ),
              ],
            ),
          );

          if (!replace) {
            setState(() => isSaving = false);
            return;
          }
        }
      }

      // Save or replace package
      await docRef.set({
        'packageName': widget.packageName,
        'packagePrice': widget.packagePrice,
        'timestamp': FieldValue.serverTimestamp(),
        'EmailAddress': widget.EmailAddress,
        'Age': widget.age,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment confirmed and saved!"),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ Navigate to PaymentStatement page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentStatement(
            packageName: widget.packageName,
            packagePrice: widget.packagePrice,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save payment: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('dd MMM yyyy, hh:mm a').format(widget.timestamp);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Payment"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Package: ${widget.packageName}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Price: ₹${widget.packagePrice.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Age: ${widget.age}",
                        style: const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Date & Time: $formattedDate",
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: isSaving
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: savePaymentToFirestore,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Confirm Payment",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.droplet),
            label: 'Water Intake',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.box),
            label: 'Packages',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user),
            label: 'Profile',
          ),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        backgroundColor: Color(0xFFF7E9AE),
      ),
    );
  }
}
