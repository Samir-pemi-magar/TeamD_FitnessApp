import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:fitnessapp/screens/user/UserProfileEdit.dart';
import 'package:fitnessapp/screens/user/WaterIntake/WaterIntake.dart';
import 'package:fitnessapp/screens/user/user_dashboard.dart';
import 'package:fitnessapp/screens/user/user_feedback.dart';
import 'package:fitnessapp/screens/user/user_login.dart';
import 'package:fitnessapp/screens/user/user_update_password.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _selectedIndex = 3;

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserLogin(),
                  ), // Or your Welcome Page
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: Icon(Icons.lock),
                title: Text('Update Password'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdatePasswordScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.feedback),
                title: Text('Leave Feedback for Trainer'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeaveFeedbackScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () => _logout(context),
              ),
            ],
          ),
        );
      },
    );
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
        break;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<FitnessTrackingData> data) {
    if (data.isEmpty) {
      return Center(child: Text("No fitness data to display"));
    }

    data.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));

    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      double y = point.caloriesBurnt.toDouble();
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: y,
              color: Colors.green,
              width: 16,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: y + 10,
                color: Colors.green.withOpacity(0.1),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                getTitlesWidget:
                    (value, _) => Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 10),
                    ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= data.length) return SizedBox.shrink();
                  final date = data[value.toInt()].timeStamp;
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      "${date.month}/${date.day}",
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(body: Center(child: Text("User not logged in")));
    }

    final userEmail = user.email;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: userEmail)
              .limit(1)
              .snapshots(),
      builder: (context, snapshot) {
        final bool noData = !snapshot.hasData || snapshot.data!.docs.isEmpty;

        final userData = noData ? {} : snapshot.data!.docs.first.data();
        final imagePath = userData['imagePath'] as String?;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Color(0xFFF7E9AE),
            elevation: 0,
            title: Text('User Profile', style: TextStyle(color: Colors.black)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.black),
                onPressed: () => _showSettingsMenu(context),
              ),
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 70),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          imagePath != null
                              ? (imagePath.startsWith('http')
                                  ? NetworkImage(imagePath)
                                  : AssetImage(imagePath) as ImageProvider)
                              : AssetImage('assets/images/avatar.png'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      userData['name'] ?? 'Name',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UserProfileEdit()),
                        );
                      },
                      child: Text("Edit Profile"),
                    ),
                    if (noData)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          "You haven't updated your profile yet.",
                          style: TextStyle(
                            color: const Color.fromARGB(179, 0, 0, 0),
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Age',
                            userData['age']?.toString() ?? 'N/A',
                          ),
                          _buildInfoRow(
                            'Height',
                            userData['height']?.toString() ?? 'N/A',
                          ),
                          _buildInfoRow(
                            'Selected Package',
                            userData['package'] ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('FitnessTracking')
                              .where('EmailAddress', isEqualTo: userEmail)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text("No fitness tracking data found."),
                          );
                        }

                        final fitnessData =
                            snapshot.data!.docs.map((doc) {
                              final map = doc.data();
                              return FitnessTrackingData(
                                caloriesBurnt: map['CaloriesBurnt'] ?? 0,
                                timeStamp:
                                    (map['TimeStamp'] as Timestamp).toDate(),
                              );
                            }).toList();

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Calories Burnt Over Time",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 12),
                              _buildBarChart(fitnessData),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
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
      },
    );
  }
}

class FitnessTrackingData {
  final int caloriesBurnt;
  final DateTime timeStamp;

  FitnessTrackingData({required this.caloriesBurnt, required this.timeStamp});
}
