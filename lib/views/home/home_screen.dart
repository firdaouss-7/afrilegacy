import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F3),
      body: const Center(
        child: Text(
          '🌍 Bienvenue sur AfriLegacy !',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF3D2B1A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
