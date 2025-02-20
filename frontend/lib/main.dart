import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/profile_screen.dart';
import 'package:frontend/auth/login_screen.dart';  // ✅ Import LoginScreen
import 'package:frontend/auth/phone_auth_screen.dart';  // ✅ Import PhoneAuthScreen
import 'package:frontend/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GamePigeonLeague',
      theme: ThemeData.dark(),
      initialRoute: '/login', // ✅ Start at Login
      routes: {
        '/': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/phone-auth': (context) => const PhoneAuthScreen(),
      },
    );
  }
}

