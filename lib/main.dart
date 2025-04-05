import 'package:fitnessapp/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/user/user_dashboard.dart'; // Import the UserDashboard screen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenFit',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/user_dashboard', // Set UserDashboard as the initial route
      routes: {
        '/user_dashboard': (context) => UserDashboard(), // UserDashboard route
      },
    );
  }
}