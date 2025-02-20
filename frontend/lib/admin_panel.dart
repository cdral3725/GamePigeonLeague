import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(GamePigeonLeagueApp());
}

class GamePigeonLeagueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: FirebaseAuth.instance.currentUser == null ? "/login" : "/home",
      routes: {
        "/login": (context) => LoginScreen(),
        "/home": (context) => HomeScreen(),
        "/profile": (context) => ProfileScreen(),
      },
    );
  }
}
