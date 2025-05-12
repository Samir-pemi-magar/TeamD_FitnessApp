import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'view_feedback.dart';

class ViewClientsScreen extends StatelessWidget {
  const ViewClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button and logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Image.asset('assets/images/logo.png', width: 50),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Clients',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                // Table Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 4,
                          child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Age', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text('Package', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Table Data
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('role', isEqualTo: 'user')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(child: Text('Something went wrong'));
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final users = snapshot.data!.docs;

                        if (users.isEmpty) {
                          return const Center(child: Text('No user clients found'));
                        }

                        return ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final data = users[index].data() as Map<String, dynamic>;
                            final userId = users[index].id;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => FeedbackScreen(userId: userId),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        data['name'] ?? 'No Name',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('${data['age'] ?? '--'}'),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(data['package'] ?? 'N/A'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
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
