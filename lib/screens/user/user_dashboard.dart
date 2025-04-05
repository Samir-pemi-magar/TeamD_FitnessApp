import 'package:fitnessapp/screens/user/packages_screen.dart';
import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo and Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      Text(
                        'ZenFit',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Calories Aim
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Calories aim:', style: TextStyle(fontSize: 18)),
                        Row(
                          children: [
                            Text('2000 cal', style: TextStyle(fontSize: 18)),
                            Icon(Icons.favorite, color: Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Weight Record
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weight record', style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Enter your weight...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Save weight record logic
                          },
                          child: Text('Save Weight'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Circular Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCircularButton(
                        'Water intake',
                        Icons.opacity,
                        () {},
                      ),
                      _buildCircularButton('Fitness goal', Icons.flag, () {}),
                      _buildCircularButton(
                        'Weight record',
                        Icons.assessment,
                        () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomNavigationBar(context),
          ),
        ],
      ),
    );
  }

  // Helper function to build circular buttons
  Widget _buildCircularButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
            backgroundColor: Colors.white,
          ),
          child: Icon(icon, size: 30, color: Colors.blue),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Helper function to build bottom navigation bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 65,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Navigate to UserDashboard (already the current page)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UserDashboard()),
              );
            },
          ),
          IconButton(icon: Icon(Icons.local_drink), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.inventory),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PackagesScreen()),
              );
            },
          ),
          IconButton(icon: Icon(Icons.person), onPressed: () {}),
        ],
      ),
    );
  }
}
