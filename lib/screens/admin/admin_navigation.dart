import 'package:flutter/material.dart';

class AdminNavigation extends StatelessWidget {
  const AdminNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const Center(child: Text('Admin Dashboard Content')),
    );
  }
}
