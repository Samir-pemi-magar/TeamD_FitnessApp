import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:fitnessapp/screens/user/WaterIntake/WaterIntake.dart';
import 'package:fitnessapp/screens/user/user_dashboard.dart';
import 'package:fitnessapp/screens/user/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExerciseDetailsPage extends StatefulWidget {
  @override
  _ExerciseDetailsPageState createState() => _ExerciseDetailsPageState();
}

class _ExerciseDetailsPageState extends State<ExerciseDetailsPage> {
  List<Map<String, dynamic>> exercises = [];
  String ageRangeLabel = '';
  String? selectedTitle;
  int _selectedIndex = 0;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchSelectedExercise();
  }

  Future<void> fetchSelectedExercise() async {
    try {
      DocumentSnapshot selectedDoc = await FirebaseFirestore.instance
          .collection('selectedExercise')
          .doc('info')
          .get();

      if (!selectedDoc.exists) {
        print("No selected exercise found.");
        setState(() => hasError = true);
        return;
      }

      selectedTitle = selectedDoc['selectedexercise'];
      print("Selected Exercise Title: $selectedTitle");
      await getExercises();
    } catch (e) {
      print("Error fetching selected exercise: $e");
      setState(() => hasError = true);
    }
  }

  Future<void> getExercises() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('selectedUser')
          .doc('Information')
          .get();

      if (!userDoc.exists) {
        print("User document does not exist.");
        setState(() => hasError = true);
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

      List<Map<String, dynamic>> allExercises = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      List<Map<String, dynamic>> filtered = allExercises
          .where((exercise) => exercise['title'] == selectedTitle)
          .toList();

      setState(() {
        exercises = filtered;
      });
    } catch (e) {
      print("Error fetching exercises: $e");
      setState(() => hasError = true);
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
        backgroundColor: Color.fromARGB(255, 9, 188, 101),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Packages()),
            );
          },
        ),
        title: Text('Exercise Details'),
      ),
      body: hasError
          ? Center(child: Text('Something went wrong. Please try again.'))
          : exercises.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      final imagePath = exercise['imagePath'];

                      return Card(
                        color: Color.fromRGBO(255, 255, 255, 0.518),
                        margin: EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imagePath != null)
                                imagePath.toString().startsWith('http')
                                    ? Image.network(imagePath,
                                        fit: BoxFit.cover)
                                    : Image.asset(imagePath,
                                        fit: BoxFit.cover),
                              SizedBox(height: 12),
                              Text(
                                exercise['title'] ?? 'No Title',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(exercise['detail'] ?? 'No description.'),
                            ],
                          ),
                        ),
                      );
                    },
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
