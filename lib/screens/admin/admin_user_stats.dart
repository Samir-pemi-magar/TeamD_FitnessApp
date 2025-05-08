import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserStatsPage extends StatelessWidget {
  const AdminUserStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar: Back button, Title, Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Login stats",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 40,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Main content
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Table headers with rounded top corners
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Container(
                              color: const Color.fromARGB(162, 73, 73, 78),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: const Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Name",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Contact number",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // User list
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .where('role', isEqualTo: 'user')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(child: Text('Error: ${snapshot.error}'));
                                }

                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                                  return const Center(child: Text('No users found.'));
                                }

                                return ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    final doc = snapshot.data!.docs[index];
                                    final name = doc['name'] ?? 'N/A';
                                    final phone = doc['phoneNumber'] ?? 'N/A';
                                    return _buildStatRow(name: name, contactNumber: phone);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildStatRow({required String name, required String contactNumber}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
      child: Row(
        children: [
          Expanded(child: Text(name, textAlign: TextAlign.center)),
          Expanded(child: Text(contactNumber, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
