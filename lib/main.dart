import 'package:flutter/material.dart';
import 'auth.dart'; // آپ کی رجسٹریشن اسکرین والی فائل

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PixoChat',
      debugShowCheckedModeBanner: false, // کونے سے 'Debug' کا بینر ہٹانے کے لیے
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A55A2)),
        useMaterial3: true,
      ),
      // یہاں ہم نے بتایا ہے کہ ایپ کھلتے ہی سب سے پہلے 'AuthScreen' دکھائے
      home: AuthScreen(), 
    );
  }
}
