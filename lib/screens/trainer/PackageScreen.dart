import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/user/Packages/SubPackage.dart';
import 'package:flutter/material.dart';

class AvailablePackagesScreen extends StatefulWidget {
  const AvailablePackagesScreen({super.key});

  @override
  State<AvailablePackagesScreen> createState() =>
      _AvailablePackagesScreenState();
}

class _AvailablePackagesScreenState extends State<AvailablePackagesScreen> {
  List<Map<String, dynamic>> FetchedPackages = [];

  @override
  void initState() {
    super.initState();
    getPackages(); // Fetch packages on init
  }

  Future<void> getPackages() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('packages').get();
      setState(() {
        FetchedPackages =
            snapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
      });
    } catch (e) {
      print("Error fetching packages: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7E9AE),
        title: const Text("Available Packages"),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListView.builder(
            itemCount: FetchedPackages.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.all(10),
                child: InkWell(
                  child: ListTile(
                    title: Text(
                      FetchedPackages[index]["title"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(FetchedPackages[index]["description"]),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
