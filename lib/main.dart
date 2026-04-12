import 'package:flutter/material.dart';
import 'chat_group.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مسائل شرعیہ',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        // واٹس ایپ جیسا پروفیشنل رنگ
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF075E54)),
        useMaterial3: true,
      ),
      // یہاں کلاس کا نام ٹھیک کر دیا گیا ہے تاکہ chat_group.dart سے میچ کرے
      home: ChatGroupScreen(), 
    );
  }
}
