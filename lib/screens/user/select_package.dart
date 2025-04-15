import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp/screens/user/user_info.dart';


class SelectPackageScreen extends StatelessWidget {
  const SelectPackageScreen({super.key});

  Future<void> _selectPackage(String title, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'package': title,
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UserInfoScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose Your Package")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('packages').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No packages found."));
          }

          final packages = snapshot.data!.docs;

          return ListView.builder(
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final package = packages[index];
              final title = package['title'];
              final description = package['description'];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(description),
                  onTap: () => _selectPackage(title, context),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
