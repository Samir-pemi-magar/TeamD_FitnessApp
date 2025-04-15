import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// TEEN SCREENS
import 'package:fitnessapp/screens/user/WorkoutScreens/teens/teen_weight_loss.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/teens/teen_weight_loss_3m.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/teens/teen_muscle_building.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/teens/teen_muscle_building_3m.dart';

// ADULT SCREENS
import 'package:fitnessapp/screens/user/WorkoutScreens/adult/adult_weight_loss.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/adult/adult_weight_loss_3m.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/adult/adult_muscle_building.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/adult/adult_muscle_building_3m.dart';

// SENIOR SCREENS
import 'package:fitnessapp/screens/user/WorkoutScreens/senior/senior_weight_loss.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/senior/senior_weight_loss_3m.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/senior/senior_muscle_building.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/senior/senior_muscle_building_3m.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

final Map<String, Widget Function()> workoutScreenRoutes = {
  // Teen
  'teen|Weight Loss Package (1 Month)': () => TeenWeightLossScreen(),
  'teen|Weight Loss Package (3 Months)': () => TeenWeightLoss3MonthScreen(),
  'teen|Muscle Building Package (1 Month)': () => TeenMuscleBuildingScreen(),
  'teen|Muscle Building Package (3 Months)':
      () => TeenMuscleBuilding3MonthScreen(),

  // Adult
  'adult|Weight Loss Package (1 Month)': () => AdultWeightLossScreen(),
  'adult|Weight Loss Package (3 Months)': () => AdultWeightLoss3MonthScreen(),
  'adult|Muscle Building Package (1 Month)': () => AdultMuscleBuildingScreen(),
  'adult|Muscle Building Package (3 Months)':
      () => AdultMuscleBuilding3MonthScreen(),

  // Senior
  'senior|Weight Loss Package (1 Month)': () => SeniorWeightLossScreen(),
  'senior|Weight Loss Package (3 Months)': () => SeniorWeightLoss3MonthScreen(),
  'senior|Muscle Building Package (1 Month)':
      () => SeniorMuscleBuildingScreen(),
  'senior|Muscle Building Package (3 Months)':
      () => SeniorMuscleBuilding3MonthScreen(),
};

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  String? gender;
  int? age;
  double? height;
  double? weight;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User not logged in")));
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'age': age,
        'height': height,
        'weight': weight,
        'gender': gender,
      }, SetOptions(merge: true));

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final package = snapshot.data()?['package'];
      final cleanedPackage = package?.toString().trim(); // clean extra spaces

      print('DEBUG -- age: $age');
      print('DEBUG -- gender: $gender');
      print('DEBUG -- height: $height');
      print('DEBUG -- weight: $weight');
      print('DEBUG -- selected package: $cleanedPackage');

      String ageGroup;
      if (age! >= 15 && age! <= 24) {
        ageGroup = 'teen';
      } else if (age! >= 25 && age! <= 39) {
        ageGroup = 'adult';
      } else {
        ageGroup = 'senior';
      }

      print('DEBUG -- age group: $ageGroup');
      print('DEBUG -- switch key: ${'$ageGroup|$cleanedPackage'}');

      if (package == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Package not found. Please select a package."),
          ),
        );
        return;
      }

      Widget nextScreen;
      // String ageGroup;

      if (age! >= 15 && age! <= 24) {
        ageGroup = 'teen';
      } else if (age! >= 25 && age! <= 39) {
        ageGroup = 'adult';
      } else {
        ageGroup = 'senior';
      }

      final routeKey = '$ageGroup|$cleanedPackage';
      final screenBuilder = workoutScreenRoutes[routeKey];
      if (screenBuilder != null) {
        nextScreen = screenBuilder();
      } else {
        nextScreen = Scaffold(
          body: Center(
            child: Text(
              "No screen found for:\nAge Group: $ageGroup\nPackage: $cleanedPackage",
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => nextScreen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Tell us a Little bit about yourself",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _genderButton("Male"),
                        _genderButton("Female"),
                      ],
                    ),
                    SizedBox(height: 20),
                    _inputField(
                      hint: "How old are you?",
                      onSaved: (val) => age = int.tryParse(val!),
                      validator:
                          (val) =>
                              val == null || int.tryParse(val) == null
                                  ? 'Enter valid age'
                                  : null,
                    ),
                    _inputField(
                      hint: "What is your height?",
                      onSaved: (val) => height = double.tryParse(val!),
                      validator:
                          (val) =>
                              val == null || double.tryParse(val) == null
                                  ? 'Enter valid height'
                                  : null,
                    ),
                    _inputField(
                      hint: "What is your weight?",
                      onSaved: (val) => weight = double.tryParse(val!),
                      validator:
                          (val) =>
                              val == null || double.tryParse(val) == null
                                  ? 'Enter valid weight'
                                  : null,
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _submit,
                        child: Text("Submit", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderButton(String value) {
    final isSelected = gender == value;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.white : Colors.white.withOpacity(0.6),
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => setState(() => gender = value),
      child: Text(value),
    );
  }

  Widget _inputField({
    required String hint,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: TextInputType.number,
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }
}
