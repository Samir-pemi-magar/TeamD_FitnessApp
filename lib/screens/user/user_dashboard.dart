import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:fitnessapp/screens/user/WaterIntake/WaterIntake.dart';
import 'package:fitnessapp/screens/user/WeightRecordView.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/senior/ExercisePackage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitnessapp/screens/user/user_profile_screen.dart';

class UserDashboard extends StatefulWidget {
  UserDashboard({super.key});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  double cal = 0;
  String? emailAddress;
  List<dynamic> calories = [];
  List<dynamic> weights = [];
  TextEditingController _controller = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _readEmailAddress();
      getCaloriesData();
      getWeightsData();
    });
  }

  void _createCaloriesData() async {
    await FirebaseFirestore.instance
        .collection('CaloriesDataset')
        .doc('Calories')
        .set({'Calories': cal}, SetOptions(merge: true));
    getCaloriesData();
  }

  Future<void> _readEmailAddress() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
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

  void _createWeightData() async {
    if (emailAddress == null) {
      print("EmailAddress is not loaded yet.");
      return;
    }

    await FirebaseFirestore.instance.collection('WeightDataset').add({
      'EmailAddress': emailAddress,
      'Weight': cal,
      'timestamp': FieldValue.serverTimestamp(),
    });

    getWeightsData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Weight saved successfully!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void getCaloriesData() async {
    if (emailAddress == null) {
      print("EmailAddress is not loaded yet.");
      return;
    }

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('FitnessTracking')
              .where('EmailAddress', isEqualTo: emailAddress)
              .get();

      double totalCalories = snapshot.docs.fold(
        0.0,
        (sum, doc) =>
            sum + (doc.data() as Map<String, dynamic>)['CaloriesBurnt'],
      );

      setState(() {
        calories = [
          {'Calories': totalCalories},
        ];
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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
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
                                Text("Calories Burnt:"),
                                Text(
                                  calories.isNotEmpty
                                      ? (calories.first['Calories']
                                                  ?.toString() ??
                                              "0") +
                                          " cal"
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
                            onPressed:
                                emailAddress == null
                                    ? null
                                    : () {
                                      if (_controller.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Weight field cannot be empty!',
                                            ),
                                            duration: Duration(seconds: 2),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } else {
                                        setState(() {
                                          cal =
                                              double.tryParse(
                                                _controller.text,
                                              ) ??
                                              0;
                                          _createWeightData();
                                          _controller.clear();
                                        });
                                      }
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WaterIntake(),
                            ),
                          );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExercisePackage(),
                            ),
                          );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WeightRecordView(),
                            ),
                          );
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
