import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class PackageStore extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storePackages() async {
    List<Map<String, dynamic>> packageChoose = [
      {
        "title": "Weight Loss Package (1 Month)",
        "description": "💪 Includes: Light cardio, HIIT workouts, and diet consultation.\n"
            "👨‍🏫 Trainer: Included\n"
            "💰 Price: ₹4999 (Discounted: ₹4500)",
      },
      {
        "title": "Muscle Building Package (1 Month)",
        "description": "🏋️ Includes: Strength training, resistance exercises, and diet plan.\n"
            "👨‍🏫 Trainer: Included\n"
            "💰 Price: ₹5999 (Discounted: ₹4999)",
      },
      {
        "title": "Weight Loss Package (3 Months)",
        "description": "🔥 Includes: Intensive cardio, fat-burning exercises, and personalized diet plan.\n"
            "👨‍🏫 Trainer: Included\n"
            "💰 Price: ₹12000",
      },
      {
        "title": "Muscle Building Package (3 Months)",
        "description": "🏋️ Includes: Strength, hypertrophy, and endurance workouts.\n"
            "👨‍🏫 Trainer: Included\n"
            "💰 Price: ₹12999",
      },
    ];

    try {
      for (var package in packageChoose) {
        var docRef = await _firestore.collection('packages').add(package);
        print("Package '${package['title']}' stored with ID: ${docRef.id}");
      }
    } catch (error) {
      print("Error adding package: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: storePackages,
      child: Text("Store Packages"),
    );
  }
}
