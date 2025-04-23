import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:fitnessapp/screens/user/WaterIntake/WaterIntake.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserDashboard extends StatefulWidget {
  UserDashboard({super.key});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  double cal = 0;
  List<dynamic> calories = [];
  List<dynamic> weights = [];
  TextEditingController _controller = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getCaloriesData();
    getWeightsData();
  }

  void _createCaloriesData() async {
    await FirebaseFirestore.instance
        .collection('CaloriesDataset')
        .doc('Calories')
        .set({'Calories': cal}, SetOptions(merge: true));

    getCaloriesData();
  }

  void _createWeightData() async {
    await FirebaseFirestore.instance.collection('WeightDataset').add({
      'Weight': cal,
      'timestamp': FieldValue.serverTimestamp(),
    });

    getWeightsData();
  }

  void getCaloriesData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('CaloriesDataset').get();
      setState(() {
        calories = snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print("Error fetching calories data: $e");
    }
  }

  void getWeightsData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('WeightDataset').get();
      setState(() {
        weights = snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      print("Error fetching weights data: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Navigate to UserDashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserDashboard()),
        );
        break;
      case 1:
        // Navigate to WaterIntake
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WaterIntake()),
        );
        break;
      case 2:
        // Navigate to Packages
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Packages()),  // Replace with actual class
        );
        break;
      case 3:
        // Profile navigation placeholder
        print("Profile screen not made yet");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 106, 165, 43),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Text(
                  "ZenFit",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 300,
                  height: 100,
                  decoration: BoxDecoration(  
                    color: Color(0xFFF7E9AE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Calories aim:"),
                              Text(
                                calories.isNotEmpty
                                    ? (calories.first['Calories']?.toString() ?? "0") + " cal"
                                    : "Loading... cal",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.heartbeat,
                              size: 24,
                              color: Colors.red,
                            ),
                            Icon(
                              FontAwesomeIcons.lungs,
                              size: 24,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 300,
                  height: 190,
                  decoration: BoxDecoration(
                    color: Color(0xFFF7E9AE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Weight Record: "),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Enter your weight',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              cal = double.tryParse(_controller.text) ?? 0;
                              _createWeightData();
                              _controller.clear();
                            });
                          },
                          child: Text('Save Weight'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => WaterIntake()));
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Color(0xFFF7E9AE),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "Water Intake",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 100),
                    GestureDetector(
                      onTap: () {
                        print("Fitness Goal tapped!");
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Color(0xFFF7E9AE),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "Fitness Goal",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("Weight Record tapped!");
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Color(0xFFF7E9AE),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "Weight Record",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
      ),
    );
  }
}
