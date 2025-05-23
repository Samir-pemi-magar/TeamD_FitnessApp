import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:fitnessapp/screens/user/WaterIntake/WaterIntake.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/senior/ExercisePackage.dart';
import 'package:fitnessapp/screens/user/user_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ADULT SCREENS
import 'package:fitnessapp/screens/user/WorkoutScreens/adult/adult_weight_loss.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/adult/adult_weight_loss_3m.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/adult/adult_muscle_building.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/adult/adult_muscle_building_3m.dart';

// SENIOR SCREENS
import 'package:fitnessapp/screens/user/WorkoutScreens/senior/senior_weight_loss.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/senior/senior_muscle_building.dart';
import 'package:fitnessapp/screens/user/WorkoutScreens/senior/senior_muscle_building_3m.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

final Map<String, Widget Function()> workoutScreenRoutes = {
  'senior|Weight Loss Package (1 Month)': () => SeniorWeightLossScreen(),
  'senior|Weight Loss Package (3 Months)': () => ExercisePackage(),
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
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

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
        break;
    }
  }

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Updated"), duration: Duration(seconds: 1)),
      );

      await Future.delayed(Duration(seconds: 1));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserDashboard()),
      );
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
