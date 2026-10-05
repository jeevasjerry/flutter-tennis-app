import 'package:flutter/material.dart';
import 'main_screen.dart';

void main() {
  runApp(const TennisAIApp());
}

class TennisAIApp extends StatelessWidget {
  const TennisAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tennis AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MainScreen(),
    );
  }
}