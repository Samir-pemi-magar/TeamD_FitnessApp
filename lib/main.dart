import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

// Screens
import 'screens/common/welcome_screen.dart';
import 'screens/user/user_login.dart';
import 'screens/user/user_signup.dart';
import 'screens/user/user_dashboard.dart';
import 'screens/user/Packages/packages.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/trainer/trainer_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_package.dart';
import 'screens/admin/admin_user_stats.dart';
import 'screens/admin/admin_add_trainer.dart';

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
        '/admin_dashboard': (context) => AdminDashboard(),
        // '/trainer_dashboard': (context) => TrainerDashboard(),
        '/packages': (context) => Packages(),
        '/admin_user_stats': (context) => const AdminUserStatsPage(),
        '/admin_packages': (context) => const AdminPackagesScreen(),
        '/admin_add_trainer': (context) => const AdminAddTrainer(),
      },
    );
  }
}
