import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseDetailsPage extends StatefulWidget {
  @override
  _ExerciseDetailsPageState createState() => _ExerciseDetailsPageState();
}

class _ExerciseDetailsPageState extends State<ExerciseDetailsPage> {
  List<Map<String, dynamic>> exercises = [];
  String ageRangeLabel = '';
  String? selectedTitle;

  @override
  void initState() {
    super.initState();
    fetchSelectedExercise();
  }

  Future<void> fetchSelectedExercise() async {
    try {
      // Fetch selected exercise title
      DocumentSnapshot selectedDoc = await FirebaseFirestore.instance
          .collection('selectedExercise')
          .doc('info')
          .get();

      if (!selectedDoc.exists) {
        print("No selected exercise found.");
        return;
      }

      selectedTitle = selectedDoc['selectedexercise'];
      print("Selected Exercise Title: $selectedTitle");

      // After getting the title, fetch exercises
      await getExercises();
    } catch (e) {
      print("Error fetching selected exercise: $e");
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

      // Filter only selected exercise
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Details'),
      ),
      body: exercises.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return Card(
                  margin: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (exercise['imagePath'] != null)
                          Image.asset(exercise['imagePath'], fit: BoxFit.cover),
                        SizedBox(height: 12),
                        Text(
                          exercise['title'],
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(exercise['detail']),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
