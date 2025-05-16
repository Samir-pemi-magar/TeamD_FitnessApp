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
  String _message = "";
  bool _isSuccess = false;

  void _submitFeedback() async {
    final feedback = _feedbackController.text.trim();

    if (feedback.isEmpty) {
      setState(() {
        _message = "Feedback cannot be empty.";
        _isSuccess = false;
      });
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _message = "User not logged in.";
          _isSuccess = false;
        });
        return;
      }

      await FirebaseFirestore.instance.collection('feedback').add({
        'userId': user.uid,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
        'trainerReply': null, 
      });

      setState(() {
        _message = "✅ Feedback submitted successfully!";
        _isSuccess = true;
      });

      _feedbackController.clear();
    } catch (e) {
      setState(() {
        _message = "❌ Error submitting feedback: $e";
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Enter your feedback',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text('Submit Feedback'),
            ),
            if (_message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _message,
                style: TextStyle(
                  color: _isSuccess ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
