import 'package:flutter/material.dart';
import 'package:lottery/LotteryScreen.dart';
import 'package:lottery/SplashScreen.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lottery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFF39C12), // Orange color from the inspiration
        scaffoldBackgroundColor: const Color(0xFFF39C12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF39C12),
          primary: const Color(0xFFF39C12),
          secondary: const Color(0xFFE74C3C), // Red color for buttons
        ),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      home: const SplashScreen(),
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/lottery', page: () => const LotteryScreen()),
      ],
    );
  }
}