import 'package:flutter/material.dart';
import 'package:bac_monitor/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCvx_Nq7UBrmhGqSO0a8BwATOqu4URHTnA",
      authDomain: "bac-monitor-9e9a4.firebaseapp.com",
      projectId: "bac-monitor-9e9a4",
      storageBucket: "bac-monitor-9e9a4.firebasestorage.app",
      messagingSenderId: "361905360400",
      appId: "1:361905360400:web:44dff46e0f1f52b98dc495",
      measurementId: "G-NK37TX25GB"
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter BLE APP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}
