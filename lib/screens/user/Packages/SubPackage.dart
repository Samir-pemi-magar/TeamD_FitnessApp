import 'package:fitnessapp/screens/user/Packages/ConfirmationPayment.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:flutter/material.dart';

class SubPackage extends StatefulWidget {
  const SubPackage({super.key});

  @override
  State<SubPackage> createState() => _SubPackageState();
}

class _SubPackageState extends State<SubPackage> {
  String? selectedPackage = "Weight Loss Package (1 month)";
  double totalCost = 4500;

  List<Map<String, dynamic>> dropDownPackages = [
    {
      "title": "Weight Loss Package (1 month)",
      "price": 4500,
    },
    {
      "title": "Weight Loss Package (3 month)",
      "price": 12000,
    },
    {
      "title": "Overall Fitness Package (1 month)",
      "price": 3200,
    },
    {
      "title": "Muscle Build Package (3 month)",
      "price": 12999,
    },
  ];

  void updatePrice(String? newValue) {
    if (newValue != null) {
      setState(() {
        selectedPackage = newValue;
        totalCost = dropDownPackages
            .firstWhere((package) => package["title"] == newValue)["price"]
            .toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Packages()));
          },
        ),
        title: const Text("Payment"),
        backgroundColor: Colors.green,
      ),
      body: Center( // Center everything horizontally
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Center everything vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Align items in the center horizontally
          children: [
            const Text(
              "Select Package:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 300, // Set a fixed width to keep it aligned
              child: DropdownButton<String>(
                value: selectedPackage,
                isExpanded: true,
                onChanged: updatePrice,
                items: dropDownPackages.map((package) {
                  return DropdownMenuItem<String>(
                    value: package["title"],
                    child: Text(package["title"]),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 170),
            Text(
              "Total Cost: \$${totalCost.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Confirmationpayment(
                            packageName: selectedPackage!,
                            packagePrice: totalCost)));
              },
              child: const Text("Proceed to Payment"),
            ),
          ],
        ),
      ),
    );
  }
}
