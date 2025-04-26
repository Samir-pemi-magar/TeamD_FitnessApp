import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/user/Packages/SubPackage.dart';
import 'package:fitnessapp/screens/user/user_dashboard.dart';
import 'package:flutter/material.dart';

class Packages extends StatefulWidget {
  Packages({super.key});

  @override
  State<Packages> createState() => _PackagesState();
}

class _PackagesState extends State<Packages> {
  List<Map<String, dynamic>> FetchedPackages = [];

  @override
  void initState() {
    super.initState();
    getPackages();  // Call the function to fetch data
  }

  Future<void> getPackages() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('packages').get();
      setState(() {
        FetchedPackages = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print("error fetching information: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Packages"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserDashboard()));
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
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
                margin: EdgeInsets.all(10),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SubPackage()));
                  },
                  child: ListTile(
                    title: Text(
                      FetchedPackages[index]["title"],
                      style: TextStyle(fontWeight: FontWeight.bold),
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
