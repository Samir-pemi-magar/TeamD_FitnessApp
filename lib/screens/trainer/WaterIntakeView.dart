import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WaterIntakeScreen extends StatefulWidget {
  @override
  _WaterIntakeScreenState createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _showGraph = false;
  bool _isLoading = false;
  Map<String, int> intakeData = {}; // Date -> Intake

  Future<void> fetchData(String email) async {
    setState(() {
      _isLoading = true;
      intakeData.clear();
    });

    try {
      DateTime now = DateTime.now();
      DateTime startDate = now.subtract(Duration(days: 6));

      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('WaterIntakeDatabase')
              .where('EmailAddress', isEqualTo: email)
              .get();

      Map<String, int> tempData = {};

      for (var doc in snapshot.docs) {
        Timestamp timestamp = doc['timestamp'];
        DateTime date = timestamp.toDate();

        if (date.isAfter(startDate)) {
          String dayLabel = DateFormat('EEE').format(date); // Mon, Tue, etc.
          int waterIntake = int.tryParse(doc['WaterIntake'].toString()) ?? 0;
          tempData[dayLabel] = (tempData[dayLabel] ?? 0) + waterIntake;
        }
      }

      setState(() {
        intakeData = tempData;
        _isLoading = false;
        _showGraph = true;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        _isLoading = false;
        _showGraph = false;
      });
    }
  }

  List<String> getLast7Days() {
    return List.generate(7, (index) {
      DateTime sunday = DateTime.now().subtract(
        Duration(days: DateTime.now().weekday % 7),
      );
      return DateFormat('EEE').format(sunday.add(Duration(days: index)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final last7Days = getLast7Days();

    return Scaffold(
      appBar: AppBar(
        title: Text("Water Intake Tracker"),
        backgroundColor: Color(0xFFF7E9AE),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              !_showGraph
                  ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFFF7E9AE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enter your email:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: "example@email.com",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_emailController.text.trim().isNotEmpty) {
                                  fetchData(_emailController.text.trim());
                                }
                              },
                              child: Text("Show Graph"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : intakeData.isEmpty
                  ? Center(child: Text("No water intake data found."))
                  : Center(
                    child: Card(
                      color: Colors.white.withOpacity(0.88),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Water Intake - Last 7 Days",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            SizedBox(
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
                                        reservedSize: 30,
                                        getTitlesWidget: (value, _) {
                                          int i = value.toInt();
                                          return Text(
                                            i >= 0 && i < last7Days.length
                                                ? last7Days[i]
                                                : '',
                                            style: TextStyle(fontSize: 12),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  barGroups: List.generate(7, (i) {
                                    final day = last7Days[i];
                                    final intake = intakeData[day] ?? 0;
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: intake.toDouble(),
                                          color: Colors.blue,
                                          width: 14,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _showGraph = false;
                                  });
                                },
                                child: Text("Back"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
