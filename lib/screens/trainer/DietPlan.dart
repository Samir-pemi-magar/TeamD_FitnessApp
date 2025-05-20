import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:fitnessapp/screens/user/WaterIntake/WaterIntake.dart';
import 'package:fitnessapp/screens/user/user_dashboard.dart';
import 'package:fitnessapp/screens/user/user_profile_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class WeightAndMealTracker extends StatefulWidget {
  const WeightAndMealTracker({super.key});

  @override
  State<WeightAndMealTracker> createState() => _WeightAndMealTrackerState();
}

class _WeightAndMealTrackerState extends State<WeightAndMealTracker> {
  List<Map<String, dynamic>> weightData = [];
  String? emailAddress;
  Map<String, String> mealInput = {
    'breakfast': '',
    'lunch': '',
    'snack': '',
    'dinner': '',
    'package': '',
    'age': '',
    'goal': '',
  };

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, showEmailPrompt); // Ask for email on load
  }

  Future<void> showEmailPrompt() async {
    TextEditingController emailController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false, // Force the user to input email
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Your Email'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(hintText: 'Email Address'),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (emailController.text.isNotEmpty &&
                    emailController.text.contains('@')) {
                  setState(() {
                    emailAddress = emailController.text.trim();
                  });
                  fetchWeightData();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid email')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchWeightData() async {
    try {
      if (emailAddress == null || emailAddress!.isEmpty) return;

      final weightSnapshot =
          await FirebaseFirestore.instance
              .collection('WeightDataset')
              .where('EmailAddress', isEqualTo: emailAddress)
              .get();

      weightData =
          weightSnapshot.docs.map((doc) {
              return {
                'weight': doc['Weight'] ?? 0,
                'timestamp':
                    (doc['timestamp'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
              };
            }).toList()
            ..sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

      setState(() {});
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data')));
    }
  }

  List<FlSpot> getWeightSpots() {
    return List.generate(weightData.length, (index) {
      return FlSpot(
        index.toDouble(),
        (weightData[index]['weight'] as num).toDouble(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress & Meals'),
        backgroundColor: Color(0xFFF7E9AE),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          emailAddress == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSectionTitle('Weight Progress'),
                      SizedBox(height: 10),
                      _buildWeightChart(),
                      SizedBox(height: 30),
                      _buildSectionTitle('Enter Meal Goals'),
                      SizedBox(height: 10),
                      _buildMealInputCard('Breakfast'),
                      _buildMealInputCard('Lunch'),
                      _buildMealInputCard('Snack'),
                      _buildMealInputCard('Dinner'),
                      _buildMealInputCard('Package'),
                      _buildMealInputCard('Age'),
                      _buildMealInputCard('Goal'),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: saveMealData,
                        child: Text("Save Meals"),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
    if (weightData.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Text('No weight data available'),
      );
    }

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine:
                (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
            getDrawingVerticalLine:
                (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: getWeightSpots(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int i = value.toInt();
                  if (i >= 0 && i < weightData.length) {
                    final date = weightData[i]['timestamp'] as DateTime;
                    return Text(
                      DateFormat('M/d').format(date),
                      style: TextStyle(fontSize: 10),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 40,
                getTitlesWidget:
                    (value, meta) => Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        '${value.toInt()}',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black, width: 1),
          ),
          minX: 0,
          maxX: weightData.length.toDouble() - 1,
          minY: 0,
          maxY: 150,
        ),
      ),
    );
  }

  Widget _buildMealInputCard(String mealType) {
    IconData icon;
    switch (mealType.toLowerCase()) {
      case 'package':
        icon = FontAwesomeIcons.box;
        break;
      case 'age':
        icon = FontAwesomeIcons.cake;
        break;
      case 'goal':
        icon = FontAwesomeIcons.dumbbell;
        break;
      default:
        icon = Icons.restaurant_menu;
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[800]),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (value) {
                mealInput[mealType.toLowerCase()] = value;
              },
              decoration: InputDecoration(hintText: '$mealType'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveMealData() async {
    if (emailAddress == null || emailAddress!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Email is required')));
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('MealDataset')
          .doc(emailAddress)
          .set({
            'EmailAddress': emailAddress,
            'breakfast': mealInput['breakfast'],
            'lunch': mealInput['lunch'],
            'snack': mealInput['snack'],
            'dinner': mealInput['dinner'],
            'package': mealInput['package'],
            'age': mealInput['age'],
            'goal': mealInput['goal'],
            'timestamp': DateTime.now(),
          }, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Meal goals saved successfully')));
    } catch (e) {
      print('Error saving meal data: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save meal data')));
    }
  }
}
