import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

MaterialApp(
  title: 'GamePigeonLeague',
  theme: ThemeData.dark(),
  initialRoute: '/login', // ⬅ Change this to login
  routes: {
    '/': (context) => HomeScreen(),
    '/profile': (context) => ProfileScreen(),
    '/login': (context) => LoginScreen(),
  },
);

