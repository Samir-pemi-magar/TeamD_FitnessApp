import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LeaveFeedbackScreen extends StatefulWidget {
  const LeaveFeedbackScreen({super.key});

  @override
  _LeaveFeedbackScreenState createState() => _LeaveFeedbackScreenState();
}

class _LeaveFeedbackScreenState extends State<LeaveFeedbackScreen> {
  final _feedbackController = TextEditingController();
  String _errorMessage = "";

  void _submitFeedback() async {
    String feedback = _feedbackController.text;
    if (feedback.isEmpty) {
      setState(() {
        _errorMessage = "Feedback cannot be empty";
      });
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('feedback').add({
        'userId': user?.uid,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _errorMessage = "Feedback submitted successfully!";
      });
      _feedbackController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Enter your feedback',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: Text('Submit Feedback'),
            ),
            if (_errorMessage.isNotEmpty) ...[
              SizedBox(height: 10),
              Text(_errorMessage, style: TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}
