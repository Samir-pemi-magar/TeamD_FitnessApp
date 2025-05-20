import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:fitnessapp/screens/user/view_recipes.dart';
import 'package:fitnessapp/screens/user/WaterIntake/WaterIntake.dart';
import 'package:fitnessapp/screens/user/user_dashboard.dart';
import 'package:fitnessapp/screens/user/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewDietPlan extends StatefulWidget {
  @override
  _ViewDietPlanState createState() => _ViewDietPlanState();
}

class _ViewDietPlanState extends State<ViewDietPlan> {
  Map<String, dynamic>? dietData;
  String? emailAddress;
  String? selectedPackage;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen()),
        );
        break;
    }
  }

  void _fetchUser() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('selectedUser').get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          emailAddress = snapshot.docs[0]['EmailAddress'];
        });
        print('Email fetched: $emailAddress');
        _fetchPackage();
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  void _fetchPackage() async {
    if (emailAddress == null) return;
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('selectedpackage')
              .where('EmailAddress', isEqualTo: emailAddress)
              .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          selectedPackage = snapshot.docs[0]['packageName'];
        });
        print('Selected package: $selectedPackage');
        _fetchDietPlan();
      }
    } catch (e) {
      print('Error fetching package: $e');
    }
  }

  void _fetchDietPlan() async {
    if (emailAddress == null || selectedPackage == null) return;

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('MealDataset')
              .where('EmailAddress', isEqualTo: emailAddress)
              .where('package', isEqualTo: selectedPackage)
              .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          dietData = snapshot.docs[0].data() as Map<String, dynamic>;
        });
      } else {
        setState(() {
          dietData = null;
        });
      }
    } catch (e) {
      print('Error fetching diet plan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Diet Plan", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFFF7E9AE),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Recipes') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecipesScreen()),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'Recipes',
                    child: Text('Recipes'),
                  ),
                ],
          ),
          // Logo removed
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child:
                dietData == null
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(111, 247, 232, 174),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (dietData?['goal'] != null)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "🎯 Goal: ${dietData?['goal'] ?? ''}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          SizedBox(height: 16),
                          _buildMealSection(
                            "Breakfast:",
                            dietData?['breakfast'],
                          ),
                          SizedBox(height: 16),
                          _buildMealSection("Lunch:", dietData?['lunch']),
                          SizedBox(height: 16),
                          _buildMealSection("Snack:", dietData?['snack']),
                          SizedBox(height: 16),
                          _buildMealSection("Dinner:", dietData?['dinner']),
                        ],
                      ),
                    ),
          ),
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

  Widget _buildMealSection(String title, dynamic meal) {
    if (meal == null || meal.toString().isEmpty) {
      return SizedBox.shrink();
    }
    List<String> items;
    if (meal is List) {
      items = meal.cast<String>();
    } else {
      items = [meal.toString()];
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.black, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
