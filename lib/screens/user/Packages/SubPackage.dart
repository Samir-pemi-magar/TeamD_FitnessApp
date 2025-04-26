import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/user/Packages/ConfirmationPayment.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:flutter/material.dart';

class SubPackage extends StatefulWidget {
  const SubPackage({super.key});

  @override
  State<SubPackage> createState() => _SubPackageState();
}

class _SubPackageState extends State<SubPackage> {
  String? selectedPackage;
  double totalCost = 0.0;
  List<Map<String, dynamic>> dropDownPackages = [];

  @override
  void initState() {
    super.initState();
    fetchPackages();
  }

  void fetchPackages() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('packages').get();
    final data = snapshot.docs.map((doc) => doc.data()).toList();

    setState(() {
      dropDownPackages = data.map((package) {
        String priceString = package["price"].toString();
        RegExp regex = RegExp(r'Discounted:\s*₹(\d+)');
        Match? match = regex.firstMatch(priceString);

        double price = match != null
            ? double.tryParse(match.group(1) ?? '0') ?? 0.0
            : double.tryParse(priceString.replaceAll(RegExp(r'[^\d.]'), '')) ??
                0.0;

        return {
          "title": package["title"],
          "price": price,
        };
      }).toList();

      if (dropDownPackages.isNotEmpty) {
        selectedPackage = dropDownPackages[0]["title"];
        totalCost = dropDownPackages[0]["price"];
      }
    });
  }

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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Packages()),
            );
          },
        ),
        title: const Text("Payment"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          dropDownPackages.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.8),
                        ),
                        child: const Text(
                          "Select Package:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.8),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: DropdownButton<String>(
                            value: selectedPackage,
                            isExpanded: true,
                            underline: SizedBox(),
                            onChanged: updatePrice,
                            items: dropDownPackages.map((package) {
                              return DropdownMenuItem<String>(
                                value: package["title"],
                                child: Text(package["title"]),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Total Cost: ₹${totalCost.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                if (selectedPackage != null) {
                                  try {
                                    // Fetch user info
                                    DocumentSnapshot userInfoSnapshot =
                                        await FirebaseFirestore.instance
                                            .collection('selectedUser')
                                            .doc('Information')
                                            .get();

                                    final userInfo = userInfoSnapshot.data()
                                        as Map<String, dynamic>?;

                                    String userEmail =
                                        userInfo?['EmailAddress'] ?? 'N/A';
                                    dynamic userAge =
                                        userInfo?['Age'] ?? 'N/A';

                                    // Save package info under package title as doc ID
                                    await FirebaseFirestore.instance
                                        .collection('selectedpackage')
                                        .doc(selectedPackage)
                                        .set({
                                      'packageName': selectedPackage,
                                      'packagePrice': totalCost,
                                      'timestamp':
                                          FieldValue.serverTimestamp(),
                                      'EmailAddress': userEmail,
                                      'Age': userAge,
                                    }, SetOptions(merge: true));

                                    // Navigate to confirmation
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Confirmationpayment(
                                          packageName: selectedPackage!,
                                          packagePrice: totalCost,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Error saving package: $e"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Proceed to Payment",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
