import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/user/user_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WaterIntake extends StatefulWidget {
  @override
  _WaterIntakeState createState() => _WaterIntakeState();
}

class _WaterIntakeState extends State<WaterIntake> {
  int waterIntake = 0;
  TextEditingController _controller = TextEditingController();

  void _Twofiftey() {
    setState(() {
      waterIntake += 250;
    });
  }

  void _FiveHundred() {
    setState(() {
      waterIntake += 500;
    });
  }

  void _Custom() {
    setState(() {
      waterIntake += int.tryParse(_controller.text) ?? 0;
      _controller.clear();
    });
  }

  void _SaveIntake() {
    FirebaseFirestore.instance.collection('WaterIntakeDatabase').doc('WaterIntake').set({
      'waterintake': waterIntake,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserDashboard()));
          },
        ),
        title: Text('Water Intake'),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 120),
              Text(
                "Your Daily Goal : 2,500 ml",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Total Volume", style: TextStyle(fontSize: 16)),
                      Text("$waterIntake ml",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 130),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter custom amount (ml)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: _Twofiftey,
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.green,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_drink),
                          Text("250 ml"),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _FiveHundred,
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.green,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.bottleWater),
                          Text("500 ml"),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _Custom,
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.green,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.plus),
                          Text("Custom"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: _SaveIntake,
                child: Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
