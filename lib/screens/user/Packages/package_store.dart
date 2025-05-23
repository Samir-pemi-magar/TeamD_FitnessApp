import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class PackageStore extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storePackages() async {
    List<Map<String, dynamic>> packageChoose = [
      {
        "title": "Weight Loss Package (1 Month)",
        "price": "₹4999 (Discounted: ₹4500)",
      },
      {
        "title": "Overall Fitness",
        "price": "₹5999 (Discounted: ₹4999)",
      },
      {
        "title": "Weight Loss Package (3 Months)",
        "price": "₹12000",
      },
      {
        "title": "Muscle Building Package (3 Months)",
        "price": "₹12999",
      },
    ];

    try {
      for (var package in packageChoose) {
        var docRef = await _firestore.collection('packages').add({
          'title': package['title'],
          'price': package['price'],
        });
        print("Package '${package['title']}' stored with ID: ${docRef.id}");

        await _addDescriptionToPackage(docRef.id, package);
      }
    } catch (error) {
      print("Error adding package: $error");
    }
  }

  Future<void> _addDescriptionToPackage(String packageId, Map<String, dynamic> package) async {
    String description;

    if (package['title'].contains('Weight Loss')) {
      description = "💪 Includes: Light cardio, HIIT workouts, and diet consultation.\n"
          "👨‍🏫 Trainer: Included\n"
          "💰 Price: ${package['price']}";
    } else if (package['title'].contains('Muscle Building')) {
      description = "🏋️ Includes: Strength training, resistance exercises, and diet plan.\n"
          "👨‍🏫 Trainer: Included\n"
          "💰 Price: ${package['price']}";
    } else {
      description = "🔥 Includes: Intensive cardio, fat-burning exercises, and personalized diet plan.\n"
          "👨‍🏫 Trainer: Included\n"
          "💰 Price: ${package['price']}";
    }

    try {
      await _firestore.collection('packages').doc(packageId).update({
        'description': description,
      });
      print("Description updated for package '${package['title']}' with ID: $packageId");
    } catch (error) {
      print("Error updating description for package '${package['title']}': $error");
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
