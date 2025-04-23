import 'package:fitnessapp/screens/user/select_package.dart';
import 'package:flutter/material.dart';

class PaymentStatement extends StatefulWidget {
  final String packageName;
  final double packagePrice;

  const PaymentStatement({
    super.key,
    required this.packageName,
    required this.packagePrice,
  });

  @override
  _PaymentStatementState createState() => _PaymentStatementState();
}

class _PaymentStatementState extends State<PaymentStatement> {
  String currentTime = DateTime.now().toString(); // Initialize the current time

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Statement"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'), // Your background image
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground Content
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Payment Statement",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "Selected Package: ${widget.packageName}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      "Total Cost: NPR ${widget.packagePrice.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      "Transaction Time: $currentTime",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SelectPackageScreen()),
                        );
                      },
                      child: const Text("Continue"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
