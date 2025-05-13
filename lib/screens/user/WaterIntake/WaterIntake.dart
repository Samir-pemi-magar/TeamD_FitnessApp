import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:fitnessapp/screens/user/user_dashboard.dart';
import 'package:fitnessapp/screens/user/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WaterIntake extends StatefulWidget {
  @override
  _WaterIntakeState createState() => _WaterIntakeState();
}

class _WaterIntakeState extends State<WaterIntake> {
  int _selectedIndex = 1;
  int waterIntake = 0;
  dynamic emailAddress;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _readEmailAddress();
  }

  void _addWater(int amount) {
    setState(() {
      waterIntake += amount;
    });
  }

  void _customAdd() {
    final customAmount = int.tryParse(_controller.text) ?? 0;
    if (customAmount > 0) {
      _addWater(customAmount);
      _controller.clear();
    }
  }

  Future<void> _readEmailAddress() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('selectedUser')
          .doc('Information')
          .get();

      if (doc.exists) {
        setState(() {
          emailAddress = doc.get('EmailAddress');
        });
      } else {
        print("Document does not exist.");
      }
    } catch (e) {
      print("Error fetching email address: $e");
    }
  }

  void _saveIntake() async {
    if (emailAddress == null) {
      print("EmailAddress is not loaded yet.");
      return;
    }

    DateTime today = DateTime.now();
    String todayDateOnly = "${today.year}-${today.month}-${today.day}";

    try {
      QuerySnapshot existingEntries = await FirebaseFirestore.instance
          .collection('WaterIntakeDatabase')
          .where('EmailAddress', isEqualTo: emailAddress)
          .get();

      DocumentSnapshot? existingDoc;
      for (var doc in existingEntries.docs) {
        Timestamp timestamp = doc['timestamp'];
        DateTime docDate = timestamp.toDate();
        String docDateOnly = "${docDate.year}-${docDate.month}-${docDate.day}";

        if (docDateOnly == todayDateOnly) {
          existingDoc = doc;
          break;
        }
      }

      if (existingDoc != null) {
        int existingIntake = existingDoc['WaterIntake'];
        await FirebaseFirestore.instance
            .collection('WaterIntakeDatabase')
            .doc(existingDoc.id)
            .update({
          'WaterIntake': existingIntake + waterIntake,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance.collection('WaterIntakeDatabase').add({
          'EmailAddress': emailAddress,
          'WaterIntake': waterIntake,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Water intake saved successfully!')),
      );
    } catch (e) {
      print("Error saving intake: $e");
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserDashboard()),
            );
          },
        ),
        title: const Text('Water Intake'),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Your Daily Goal : 2,500 ml",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Total Volume",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "$waterIntake ml",
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Enter custom amount (ml)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWaterButton(Icons.local_drink, "250 ml", () => _addWater(250)),
                        _buildWaterButton(FontAwesomeIcons.bottleWater, "500 ml", () => _addWater(500)),
                        _buildWaterButton(FontAwesomeIcons.plus, "Custom", _customAdd),
                      ],
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: _saveIntake,
                      icon: const Icon(Icons.save_alt),
                      label: const Text("Save Intake"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildWaterButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
