import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:afrilegacy/views/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ← AJOUTE CETTE LIGNE

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signOut(); // ← AJOUTE CETTE LIGNE
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AfriLegacy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC4A96A)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
