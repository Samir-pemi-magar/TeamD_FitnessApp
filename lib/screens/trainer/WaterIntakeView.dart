import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WaterIntakeGraph extends StatefulWidget {
  final String emailAddress;
  const WaterIntakeGraph({required this.emailAddress});

  @override
  _WaterIntakeGraphState createState() => _WaterIntakeGraphState();
}

class _WaterIntakeGraphState extends State<WaterIntakeGraph> {
  Map<String, int> intakeData = {}; // Date -> WaterIntake

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate = now.subtract(Duration(days: 6));

      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('WaterIntakeDatabase')
              .where('EmailAddress', isEqualTo: widget.emailAddress)
              .get();

      Map<String, int> tempData = {};

      for (var doc in snapshot.docs) {
        Timestamp timestamp = doc['timestamp'];
        DateTime date = timestamp.toDate();

        if (date.isAfter(startDate)) {
          String dayLabel = DateFormat('EEE').format(date); // Mon, Tue, ...
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

    return Card(
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Water Intake - Last 7 Days",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1), // Add border
                borderRadius: BorderRadius.circular(8), // Optional: rounded corners
              ),
              padding: EdgeInsets.all(8), // Add padding inside the border
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false), // Disable left Y-axis titles
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            int index = value.toInt();
                            return Text(
                              index >= 0 && index < last7Days.length
                                  ? last7Days[index]
                                  : '',
                              style: TextStyle(fontSize: 12),
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
                            color: Colors.green,
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
          ],
        ),
      ),
    );
  }
}