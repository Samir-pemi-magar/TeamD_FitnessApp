import 'package:flutter/material.dart';

class PaymentStatement extends StatefulWidget {
  final String packageName;
  final double packagePrice;

  const PaymentStatement({super.key, required this.packageName, required this.packagePrice});

  @override
  _PaymentStatementState createState() => _PaymentStatementState();
}

class _PaymentStatementState extends State<PaymentStatement> {
  String currentTime = DateTime.now().toString(); // Initialize the current time

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment Statement")),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Payment Statement", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Selected Package: ${widget.packageName}", style: TextStyle(fontSize: 16)),
              Text("Total Cost: \$${widget.packagePrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Current Time: $currentTime", style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous page
                },
                child: Text("Done"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
