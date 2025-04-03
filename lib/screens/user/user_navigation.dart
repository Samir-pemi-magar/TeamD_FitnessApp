import 'package:flutter/material.dart';

class UserNavigation extends StatelessWidget {
  const UserNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Dashboard')),
      body: const Center(child: Text('User Dashboard Content')),
    );
  }
}
