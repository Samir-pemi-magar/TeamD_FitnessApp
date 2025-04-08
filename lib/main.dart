import 'package:fitnessapp/firebase_options.dart';
import 'package:fitnessapp/screens/user/WaterIntake/WaterIntake.dart';
//import 'package:fitnessapp/screens/user/Packages/package_store.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/user/user_dashboard.dart';
import 'screens/user/user_login.dart';
import 'screens/user/user_signup.dart';
import 'screens/user/packages_screen.dart';
import 'screens/common/welcome_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenFit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const UserLogin(),
        '/signup': (context) => const UserSignup(),
        '/user_dashboard': (context) => UserDashboard(),
        '/packages': (context) => PackagesScreen(),
      },
    );
  }
}
