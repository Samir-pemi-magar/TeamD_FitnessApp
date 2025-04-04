
import 'package:fitnessapp/screens/user/Packages/PaymentStatement.dart';
import 'package:flutter/material.dart';

class Confirmationpayment extends StatefulWidget {
  final String packageName;
  final double packagePrice;

  const Confirmationpayment({super.key, required this.packageName, required this.packagePrice});

  @override
  _ConfirmationpaymentState createState() => _ConfirmationpaymentState();
}

class _ConfirmationpaymentState extends State<Confirmationpayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Send money:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,//.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("You are paying", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Text(
                      "NPR ${widget.packagePrice.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Receiver name: ZenFit fitness club", style: TextStyle(fontSize: 16)),
                  Text("Purpose: Package payment", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentStatement(
                      packageName: widget.packageName,
                      packagePrice: widget.packagePrice,
                    ),
                  ),
                );
              },
              child: Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }
}