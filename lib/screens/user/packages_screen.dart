import 'package:flutter/material.dart';

class PackagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Packages'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          _buildPackageCard(
            context: context,
            title: 'Weight Loss Package (1 Month)',
            description: 'Light cardio, HIIT workouts, and diet consultation.',
            trainer: 'Included',
            price: '₹4999 (Discounted: ₹4500)',
            icon: Icons.local_fire_department,
          ),
          _buildPackageCard(
            context: context,
            title: 'Muscle Building Package (1 Month)',
            description: 'Strength training, resistance exercises, and diet plan.',
            trainer: 'Included',
            price: '₹5999 (Discounted: ₹4999)',
            icon: Icons.fitness_center,
          ),
          _buildPackageCard(
            context: context,
            title: 'Weight Loss Package (3 Months)',
            description:
                'Intensive cardio, fat-burning exercises, and personalized diet plan.',
            trainer: 'Included',
            price: '₹12000',
            icon: Icons.local_fire_department,
          ),
          _buildPackageCard(
            context: context,
            title: 'Muscle Building Package (3 Months)',
            description:
                'Strength, hypertrophy, and endurance workouts.',
            trainer: 'Included',
            price: '₹12999',
            icon: Icons.fitness_center,
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required BuildContext context,
    required String title,
    required String description,
    required String trainer,
    required String price,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '📋 Includes: $description',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 5),
            Text(
              '👨‍🏫 Trainer: $trainer',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 5),
            Text(
              '💰 Price: $price',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Handle package selection logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected: $title')),
                  );
                },
                child: Text('Select'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}