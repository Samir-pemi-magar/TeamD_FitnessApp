import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllUsersWeightRecordView extends StatefulWidget {
  @override
  State<AllUsersWeightRecordView> createState() => _AllUsersWeightRecordViewState();
}

class _AllUsersWeightRecordViewState extends State<AllUsersWeightRecordView> {
  Map<String, List<Map<String, dynamic>>> groupedWeightData = {};

  @override
  void initState() {
    super.initState();
    fetchAllWeightData();
  }

  Future<void> fetchAllWeightData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('WeightDataset').get();
      Map<String, List<Map<String, dynamic>>> tempGrouped = {};

      for (var doc in querySnapshot.docs) {
        String email = doc['EmailAddress'];
        double weight = (doc['Weight'] as num?)?.toDouble() ?? 0.0;
        DateTime timestamp = (doc['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

        if (!tempGrouped.containsKey(email)) {
          tempGrouped[email] = [];
        }

        tempGrouped[email]!.add({'weight': weight, 'timestamp': timestamp});
      }

      // Sort data by timestamp for each user
      tempGrouped.forEach((email, entries) {
        entries.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      });

      setState(() {
        groupedWeightData = tempGrouped;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  List<FlSpot> getWeightSpots(List<Map<String, dynamic>> entries) {
    return List.generate(entries.length, (index) {
      return FlSpot(index.toDouble(), entries[index]['weight']);
    });
  }

  List<String> getDateLabels(List<Map<String, dynamic>> entries) {
    return entries.map((entry) {
      return DateFormat.Md().format(entry['timestamp']);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Users' Weight Records")),
      body: groupedWeightData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: groupedWeightData.entries.map((entry) {
                final email = entry.key;
                final data = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Container(
                      height: 250,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.grey.shade300)],
                      ),
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: getWeightSpots(data),
                              isCurved: true,
                              barWidth: 3,
                              color: Colors.blue,
                              dotData: FlDotData(show: true),
                            )
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, _) {
                                  int index = value.toInt();
                                  final labels = getDateLabels(data);
                                  if (index >= 0 && index < labels.length) {
                                    return Text(labels[index], style: TextStyle(fontSize: 10));
                                  }
                                  return Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: data.length.toDouble() - 1,
                          minY: 0,
                          maxY: 150,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("History", style: TextStyle(fontWeight: FontWeight.bold)),
                    ...data.map((item) => ListTile(
                          leading: Icon(Icons.monitor_weight),
                          title: Text("Weight: ${item['weight']} kg"),
                          subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm').format(item['timestamp'])),
                        )),
                    Divider(thickness: 2, height: 40),
                  ],
                );
              }).toList(),
            ),
    );
  }
}
