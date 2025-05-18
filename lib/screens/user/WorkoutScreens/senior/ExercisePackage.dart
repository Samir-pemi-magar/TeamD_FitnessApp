import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? loggedInUser;
  String? selectedPackage;
  String? ageRangeLabel;
  List<Map<String, dynamic>>? fetchedExercise;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      loggedInUser = user.email;
      fetchSelectedPackage();
    }
  }

  Future<void> fetchSelectedPackage() async {
    if (loggedInUser == null) return;

    try {
      print(loggedInUser);
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('selectedpackage')
          .where('EmailAddress', isEqualTo: loggedInUser)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          selectedPackage = snapshot.docs.first.get('packageName');
        });
        await getPackages(); // Fetch exercises after package is selected
      } else {
        setState(() {
          selectedPackage = 'No package selected';
          fetchedExercise = null;
        });
      }
    } catch (e) {
      setState(() {
        selectedPackage = 'Error loading package';
        fetchedExercise = null;
      });
      print('Error fetching selected package: $e');
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

  Future<void> getPackages() async {
    if (selectedPackage == null || loggedInUser == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('selectedUser')
          .doc('Information')
          .get();

      if (!userDoc.exists) {
        print("User document does not exist.");
        setState(() {
          fetchedExercise = null;
        });
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

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('package', isEqualTo: selectedPackage)
          .get();

      if (!mounted) return;

      setState(() {
        fetchedExercise =
            snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print("Error fetching information: $e");
      setState(() {
        fetchedExercise = null;
      });
    }
  }

  Future<void> storeSelectedExercise(String title) async {
    try {
      await FirebaseFirestore.instance
          .collection('selectedExercise')
          .doc('info')
          .set({'selectedexercise': title});
      print('Selected exercise stored successfully');
    } catch (e) {
      print('Error storing selected exercise: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Packages'),
        backgroundColor: Color(0xFFF7E9AE),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserDashboard()));
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (loggedInUser != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Logged in as: $loggedInUser',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (selectedPackage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Selected Package: $selectedPackage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                if (ageRangeLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Age Group: $ageRangeLabel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                SizedBox(height: 8),
                Expanded(
                  child: fetchedExercise != null && fetchedExercise!.isNotEmpty
                      ? ListView.builder(
                          itemCount: fetchedExercise!.length,
                          itemBuilder: (context, index) {
                            final title = fetchedExercise![index]['title'] ?? 'No title';

                            return GestureDetector(
                              onTap: () {
                                storeSelectedExercise(title);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ExerciseDetailsPage(),
                                  ),
                                );
                              },
                              child: Card(
                                color: Colors.white70,
                                elevation: 3,
                                margin: EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            'No exercise data available',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                ),
                SizedBox(height: 8), // Add some spacing between the cards and buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(FontAwesomeIcons.bookOpen),
                        label: Text('Recipe Name'),
                        onPressed: () {
                          print('Recipe Name pressed');
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(FontAwesomeIcons.utensils),
                        label: Text('Diet Plan'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ViewDietPlan()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
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