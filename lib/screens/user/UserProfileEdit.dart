import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:fitnessapp/screens/user/WaterIntake/WaterIntake.dart';
import 'package:fitnessapp/screens/user/user_dashboard.dart';
import 'package:fitnessapp/screens/user/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserProfileEdit extends StatefulWidget {
  const UserProfileEdit({super.key});

  @override
  State<UserProfileEdit> createState() => _UserProfileEditState();
}

class _UserProfileEditState extends State<UserProfileEdit> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController =
      TextEditingController(); // New controller
  final TextEditingController _imagePathController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _selectedIndex = 0;

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      int age = int.parse(_ageController.text.trim());
      double height = double.parse(_heightController.text.trim());
      String imagePath = _imagePathController.text.trim();

      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
            'name': name,
            'email': email,
            'age': age,
            'height': height,
            'imagePath': imagePath,
          })
          .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Profile updated successfully."),
                backgroundColor: Colors.green,
              ),
            );
            _nameController.clear();
            _emailController.clear();
            _ageController.clear();
            _heightController.clear();
            _imagePathController.clear();
          })
          .catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to update profile: $error"),
                backgroundColor: Colors.red,
              ),
            );
          });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserDashboard()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WaterIntake()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Packages()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF7E9AE),
        title: Text("Edit Profile"),
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
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Text(
                  "Edit Your Profile",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(121, 255, 248, 220),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black54, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Name is required"
                                    : null,
                        decoration: InputDecoration(
                          hintText: "Enter your name",
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Email is required"
                                    : null,
                        decoration: InputDecoration(
                          hintText: "Enter your email",
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Age",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Age is required";
                          final age = int.tryParse(value);
                          if (age == null || age < 15)
                            return "Enter a valid age (15+)";
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your age",
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Height",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Height is required";
                          final height = double.tryParse(value);
                          if (height == null || height < 3.0 || height > 8.0)
                            return "Enter a valid height (3.0 - 8.0 ft)";
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your height",
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Profile Image File Path",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextFormField(
                        controller: _imagePathController,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Image path is required"
                                    : null,
                        decoration: InputDecoration(
                          hintText: "Enter image file path",
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: Text("Save Changes"),
                ),
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
}
