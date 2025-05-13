import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/trainer/DietPlan.dart';
import 'package:fitnessapp/screens/trainer/editexercise.dart';
import 'package:fitnessapp/screens/trainer/trainer_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitnessapp/screens/user/WaterIntake/WaterIntake.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';

class TrainerExerciseManager extends StatefulWidget {
  const TrainerExerciseManager({super.key});

  @override
  State<TrainerExerciseManager> createState() => _TrainerExerciseManagerState();
}

class _TrainerExerciseManagerState extends State<TrainerExerciseManager> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _imagePathController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _packageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void AddToDatabase() {
    if (_formKey.currentState!.validate()) {
      String title = _titleController.text.trim();
      String detail = _detailController.text.trim();
      String imagePath = _imagePathController.text.trim();
      String package = _packageController.text.trim();
      int age = int.parse(_ageController.text.trim());

      String collectionName;
      if (age >= 15 && age <= 24) {
        collectionName = '(15-24)';
      } else if (age >= 25 && age <= 39) {
        collectionName = '(25-39)';
      } else {
        collectionName = '(40+)';
      }

      FirebaseFirestore.instance
          .collection(collectionName)
          .add({
            "title": title,
            "detail": detail,
            "imagePath": imagePath,
            "package": package,
          })
          .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Exercise added successfully."),
                backgroundColor: Colors.green,
              ),
            );
            _titleController.clear();
            _detailController.clear();
            _imagePathController.clear();
            _ageController.clear();
            _packageController.clear();
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to add exercise: $error"),
                backgroundColor: Colors.red,
              ),
            );
          });
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
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Exercise Manager: Add"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TrainerExerciseEditor()),
            );
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Edit clicked")));
              } else if (value == 'diet') {
                Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WeightAndMealTracker()),
            );
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Diet Plan clicked")));
              } else if (value == 'recipe') {
                print("not made yet");
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Recipe clicked")));
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'diet', child: Text('Diet Plan')),
                  PopupMenuItem(value: 'recipe', child: Text('Recipe')),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Text(
                  "Add Exercise",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(121, 255, 248, 220),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black54, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Title",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextFormField(
                        controller: _titleController,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Title is required"
                                    : null,
                        decoration: InputDecoration(
                          hintText: "Enter exercise title",
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Image File Path",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextFormField(
                        controller: _imagePathController,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Image path is required"
                                    : null,
                        decoration: InputDecoration(
                          hintText: "Enter image file path",
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Age",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Age is required";
                          final age = int.tryParse(value);
                          if (age == null || age < 15)
                            return "Enter a valid age (15+)";
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter user's age",
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Package",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextFormField(
                        controller: _packageController,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Package is required"
                                    : null,
                        decoration: InputDecoration(
                          hintText: "Enter package name",
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Exercise Detail",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextFormField(
                        controller: _detailController,
                        maxLines: 5,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Details are required"
                                    : null,
                        decoration: InputDecoration(
                          hintText: "Enter exercise details",
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: AddToDatabase,
                  child: Text("Save Exercise"),
                ),
              ],
            ),
          ),
        ),
      ),
      
    );
  }
}
