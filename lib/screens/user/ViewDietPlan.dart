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
  List<Map<String, dynamic>> fetchedPackages = [];
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserDashboard()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WaterIntake()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Packages()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserProfileScreen()));
        break;
    }
  }

  void _fetchUser() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('selectedUser').get();
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        emailAddress = snapshot.docs[0]['EmailAddress'];
      });
      _fetchPackage();
    }
  }

  void _fetchPackage() async {
    if (emailAddress == null) return;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('selectedpackage')
        .where('EmailAddress', isEqualTo: emailAddress)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        selectedPackage = snapshot.docs[0]['packageName'];
      });
      _fetchDietPlan();
    }
  }

  void _fetchDietPlan() async {
    if (emailAddress == null || selectedPackage == null) return;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('MealDataset')
        .where('EmailAddress', isEqualTo: emailAddress)
        .where('package', isEqualTo: selectedPackage)
        .get();

    setState(() {
      fetchedPackages = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
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
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Recipes') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RecipesScreen()));
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(value: 'Recipes', child: Text('Recipes')),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: Text("ZenFit", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.green)),
            ),
          ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "🎯 Goal: Fat loss with balanced, lower-calorie meals",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                _buildMealSection("Breakfast:", [
                  "Oatmeal with banana & almonds 🍌",
                  "Herbal tea or black coffee (no sugar) ☕",
                ]),
                SizedBox(height: 16),
                _buildMealSection("Lunch:", [
                  "Grilled chicken or tofu with quinoa & steamed vegetables 🥗",
                  "Greek yogurt with flaxseeds 🥄",
                ]),
                SizedBox(height: 16),
                _buildMealSection("Snack:", [
                  "Handful of almonds & walnuts 🌰",
                  "Green tea 🍵",
                ]),
                SizedBox(height: 16),
                _buildMealSection("Dinner:", [
                  "Lentils with whole wheat bread 🍲",
                  "Sautéed spinach & mushrooms 🍄",
                ]),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.house), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.droplet), label: 'Water Intake'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.box), label: 'Packages'),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.user), label: 'Profile'),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        backgroundColor: Color(0xFFF7E9AE),
      ),
    );
  }

  Widget _buildMealSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(item, style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
