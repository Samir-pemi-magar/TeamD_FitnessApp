import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:fitnessapp/screens/user/ViewDietPlan.dart';
import 'package:fitnessapp/screens/user/WaterIntake/WaterIntake.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/senior/ExerciseDetails.dart';
import 'package:fitnessapp/screens/user/user_dashboard.dart';
import 'package:fitnessapp/screens/user/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExercisePackage extends StatefulWidget {
  @override
  _ExercisePackageState createState() => _ExercisePackageState();
}

class _ExercisePackageState extends State<ExercisePackage> {
  List<Map<String, dynamic>> fetchedExercise = [];
  String? SelectedExercise;
  int _selectedIndex = 0;
  String ageRangeLabel = "";
  String? packageName;

  @override
  void initState() {
    super.initState();
    getPackages();
    checkAndFetchPackage();
  }

  Future<void> getPackages() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('selectedUser')
          .doc('Information')
          .get();

      if (!userDoc.exists) {
        print("User document does not exist.");
        return;
      }

      int age = userDoc['Age'];
      String collectionName;

      if (age >= 15 && age <= 24) {
        collectionName = '(15-24)';
        ageRangeLabel = "Young Adults (15-24)";
      } else if (age >= 25 && age <= 39) {
        collectionName = '(25-39)';
        ageRangeLabel = "Adults (25-39)";
      } else {
        collectionName = '(40+)';
        ageRangeLabel = "Seniors (40+)";
      }

      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();

      if (!mounted) return;
      setState(() {
        fetchedExercise = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("Error fetching information: $e");
    }
  }

  Future<void> checkAndFetchPackage() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('selectedUser')
          .doc('Information')
          .get();

      if (!userDoc.exists) {
        print("User document does not exist.");
        return;
      }

      String userEmail = userDoc['EmailAddress'];

      QuerySnapshot packageSnapshot =
          await FirebaseFirestore.instance.collection('selectedpackage').get();

      for (var packageDoc in packageSnapshot.docs) {
        Map<String, dynamic> packageData =
            packageDoc.data() as Map<String, dynamic>;

        if (packageData['EmailAddress'] == userEmail) {
          packageName = packageData['packageName'];
          print("Matched package name: $packageName");

          if (mounted) {
            setState(() {
              SelectedExercise = packageName;
            });
          }
          break;
        }
      }
    } catch (e) {
      print("Error checking and fetching package: $e");
    }
  }

  void _onItemTapped(int index) {
    if (!mounted) return;
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
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserDashboard()),
            );
          },
        ),
        title: Text(
          "Weight Loss Workouts",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Recipe') {
                print("hello");
              } else if (value == 'Diet Plan') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewDietPlan()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'Recipe',
                child: Text('Recipe'),
              ),
              PopupMenuItem<String>(
                value: 'Diet Plan',
                child: Text('Diet Plan'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(102, 247, 232, 174),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Weight Loss Workout",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      ageRangeLabel,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  if (SelectedExercise != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Selected Package: $SelectedExercise",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: fetchedExercise.length,
                      itemBuilder: (context, index) {
                        final package = fetchedExercise[index];
                        return Card(
                          margin: EdgeInsets.all(10),
                          child: InkWell(
                            onTap: () async {
                              if (!mounted) return;
                              setState(() {
                                SelectedExercise = package["title"];
                              });

                              await FirebaseFirestore.instance
                                  .collection('selectedExercise')
                                  .doc('info')
                                  .set({
                                'selectedexercise': package["title"],
                              }, SetOptions(merge: true));

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExerciseDetailsPage(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListTile(
                                title: Text(
                                  "${index + 1}. ${package['title'] ?? 'No Title'}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
