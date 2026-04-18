import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bac_monitor/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  Future<Timer> startTime() async {
    var duration = const Duration(seconds: 6);
    return Timer(duration, navigateToDeviceScreen);
  }

  void navigateToDeviceScreen() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,     // 🔵 Cyan background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 Droplet Icon
            Icon(
              Icons.water_drop,
              size: 120,
              color: Colors.white,
            ),

            const SizedBox(height: 20),

            // 🔹 App Title
            const Text(
              "BAC Tracker",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Text(
              "(Blood Alcohol Concentration)",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),


          ],
        ),
      ),
    );
  }
}
