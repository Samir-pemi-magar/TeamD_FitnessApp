import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';
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
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('selectedUser').get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        emailAddress = snapshot.docs[0]['EmailAddress'];
      });
      _fetchPackage();
      print(emailAddress);
    }
  }

  void _fetchPackage() async {
    if (emailAddress == null) return;

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('selectedpackage')
            .where('EmailAddress', isEqualTo: emailAddress)
            .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        selectedPackage = snapshot.docs[0]['packageName'];
      });
      _fetchDietPlan();
      print(selectedPackage);
    }
  }

  void _fetchDietPlan() async {
    if (emailAddress == null || selectedPackage == null) return;

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('MealDataset')
            .where('EmailAddress', isEqualTo: emailAddress)
            .where('package', isEqualTo: selectedPackage)
            .get();

    setState(() {
      fetchedPackages =
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
      print(fetchedPackages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Diet Plan"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child:
            fetchedPackages.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  itemCount: fetchedPackages.length,
                  itemBuilder: (context, index) {
                    final package = fetchedPackages[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Card(
                        color: Color.fromARGB(144, 136, 125, 79),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                package['package'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "💡 Goal: ${package['goal'] ?? 'Sustainable weight loss with nutrient-dense foods.'}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 24),
                              _buildSection(
                                "🥣 Breakfast",
                                package['breakfast'],
                              ),
                              SizedBox(height: 10),
                              _buildSection("🍱 Lunch", package['lunch']),
                              SizedBox(height: 10),
                              _buildSection("🍏 Snack", package['snack']),
                              SizedBox(height: 10),
                              _buildSection("🍽️ Dinner", package['dinner']),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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

  Widget _buildSection(String title, String? content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orangeAccent,
          ),
        ),
        SizedBox(height: 6),
        Text(
          content ?? 'No description',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        SizedBox(height: 20), // increased space between sections
      ],
    );
  }
}
