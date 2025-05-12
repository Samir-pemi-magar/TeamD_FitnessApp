import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  final String userId;

  const FeedbackScreen({super.key, required this.userId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final Map<String, TextEditingController> _replyControllers = {};

  void _submitReply(String docId, String reply) async {
    await FirebaseFirestore.instance
        .collection('feedback')
        .doc(docId)
        .update({'trainerReply': reply});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reply submitted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Feedback")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedback')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading feedback.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No feedback found for this user.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;
              final feedbackText = data['feedback'] ?? 'No message';
              final trainerReply = data['trainerReply'] ?? '';
              final timestamp = data['timestamp'] != null
                  ? (data['timestamp'] as Timestamp).toDate()
                  : null;

              _replyControllers.putIfAbsent(
                  docId, () => TextEditingController(text: trainerReply));

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Feedback: $feedbackText"),
                      const SizedBox(height: 8),
                      if (timestamp != null)
                        Text(
                          "Submitted on: ${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      const Divider(height: 20),
                      const Text(
                        "Your Reply:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _replyControllers[docId],
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: "Type your reply...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            final replyText = _replyControllers[docId]!.text.trim();
                            if (replyText.isNotEmpty) {
                              _submitReply(docId, replyText);
                            }
                          },
                          child: const Text("Send Reply"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
