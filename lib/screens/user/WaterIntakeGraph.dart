import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:fitnessapp/screens/user/WaterIntake/WaterIntake.dart';
import 'package:fitnessapp/screens/user/user_dashboard.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class WaterIntakeGraph extends StatefulWidget {
  const WaterIntakeGraph({Key? key}) : super(key: key);

  @override
  _WaterIntakeGraphState createState() => _WaterIntakeGraphState();
}

class _WaterIntakeGraphState extends State<WaterIntakeGraph> {
  Map<String, int> intakeData = {};
  String? userEmail;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
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

  Future<void> fetchUserEmail() async {
    try {
      // Read the selected user's email from Firestore
      DocumentSnapshot selectedUserDoc = await FirebaseFirestore.instance
          .collection('selectedUser')
          .doc('Information')
          .get();

      String email = selectedUserDoc.get('EmailAddress');

      setState(() {
        userEmail = email;
      });

      await fetchData(email);
    } catch (e) {
      print("Error fetching selected user email: $e");
    }
  }

  Future<void> fetchData(String email) async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate = now.subtract(Duration(days: 6));

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('WaterIntakeDatabase')
          .where('EmailAddress', isEqualTo: email)
          .get();

      Map<String, int> tempData = {};

      for (var doc in snapshot.docs) {
        Timestamp timestamp = doc['timestamp'];
        DateTime date = timestamp.toDate();

        if (date.isAfter(startDate)) {
          String dayLabel = DateFormat('EEE').format(date);
          int waterIntake = int.tryParse(doc['WaterIntake'].toString()) ?? 0;
          tempData[dayLabel] = (tempData[dayLabel] ?? 0) + waterIntake;
        }
      }

      setState(() {
        intakeData = tempData;
      });
    } catch (e) {
      print("Error fetching graph data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> last7Days = List.generate(7, (index) {
      DateTime sunday = DateTime.now().subtract(Duration(days: DateTime.now().weekday % 7));
      DateTime date = sunday.add(Duration(days: index));
      return DateFormat('EEE').format(date);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Intake Graph"),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7E9AE),
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: userEmail == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Water Intake - Last 7 Days",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(143, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(101, 0, 0, 0),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      int index = value.toInt();
                                      return Text(
                                        index >= 0 && index < last7Days.length ? last7Days[index] : '',
                                        style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                                      );
                                    },
                                    reservedSize: 30,
                                  ),
                                ),
                              ),
                              barGroups: List.generate(last7Days.length, (i) {
                                final day = last7Days[i];
                                final intake = intakeData[day] ?? 0;
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: intake.toDouble(),
                                      color: Colors.teal,
                                      width: 16,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Water Intake History:",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(164, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(73, 0, 0, 0),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: last7Days.map((day) {
                            int intake = intakeData[day] ?? 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    day,
                                    style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "$intake ml",
                                    style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
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
