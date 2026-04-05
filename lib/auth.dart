import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // اسٹیٹس بار کو ڈارک تھیم کے لیے سیٹ کریں تاکہ سفید ٹیکسٹ نظر آئے
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Approval Screen',
      theme: ThemeData(
        fontFamily: 'Inter', // یہ فونٹ ڈیزائن سے ملتا جلتا ہے
        useMaterial3: true,
      ),
      home: const ApprovalScreen(),
    );
  }
}

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ڈیزائن کا گراڈینٹ بیک گراؤنڈ
    const backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF323B42), // ڈارک گرے ٹاپ
        Color(0xFF232D34), // اور زیادہ ڈارک باٹم
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF232D34), // فال بیک کلر
      // پورے اسکرین پر بیک گراؤنڈ سیٹ کریں
      body: Container(
        decoration: const BoxDecoration(
          gradient: backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. کسٹم اسٹیٹس بار (آپ کی تصویر میں موجود)
              _buildStatusBar(),
              
              const Spacer(flex: 2), // کارڈ کو اوپر سے دھکیلنے کے لیے

              // 2. مین کارڈ (ڈیزائن کا مرکزی حصہ)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    // کارڈ کا ہلکا سا سایہ
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // میڈل آئیکن
                      _buildMedalIcon(),
                      
                      const SizedBox(height: 24),

                      // مبارکباد کا ٹیکسٹ
                      const Text(
                        'Congratulations!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700, // Semi-Bold
                          color: Color(0xFF2E3890), // نیلا رنگ
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // تفصیلی متن
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A4A4A), // درمیانہ گرے
                            height: 1.5, // لائن ہائٹ
                          ),
                          children: [
                            const TextSpan(text: 'Your account has been '),
                            const TextSpan(
                              text: 'approved',
                              style: TextStyle(fontWeight: FontWeight.w700), // بولڈ "approved"
                            ),
                            const TextSpan(text: '! You can now use the Provider Mode.'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // بٹن
                      _buildActionButton(),
                    ],
                  ),
                ),
              ),

              // ماؤس کرسر کا آئیکن (یہ صرف دکھانے کے لیے ہے)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(Icons.arrow_drop_down_sharp, color: Colors.black.withOpacity(0.6), size: 28,),
                ),
              ),

              const Spacer(flex: 3), // کارڈ کو نیچے سے دھکیلنے کے لیے

              // 3. کسٹم نیویگیشن بار (آپ کی تصویر میں موجود)
              _buildNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  // میڈل آئیکن بنانے والا فنکشن
  Widget _buildMedalIcon() {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF53BF6B), // سبز رنگ
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -5), // ربن کو تھوڑا اوپر سیٹ کرنے کے لیے
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ربن کا اوپری حصہ (تین گنا چوڑائی والا)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 14, height: 18, color: Colors.white, margin: const EdgeInsets.symmetric(horizontal: 1.5),),
                  Container(width: 14, height: 18, color: Colors.white, margin: const EdgeInsets.symmetric(horizontal: 1.5),),
                  Container(width: 14, height: 18, color: Colors.white, margin: const EdgeInsets.symmetric(horizontal: 1.5),),
                ],
              ),
              // ستارہ
              const Icon(
                Icons.star,
                size: 24,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بٹن بنانے والا فنکشن
  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 48, // بٹن کی اونچائی
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0DBC61), // سبز بٹن
          foregroundColor: Colors.white, // سفید ٹیکسٹ
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text(
          'Go to Application',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // کسٹم اسٹیٹس بار بنانے والا فنکشن
  Widget _buildStatusBar() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('9:11', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              SizedBox(width: 6),
              Icon(Icons.video_camera_back, color: Colors.white, size: 14),
            ],
          ),
          Row(
            children: [
              Icon(Icons.headset, color: Colors.white, size: 14),
              SizedBox(width: 6),
              Icon(Icons.vo_lte, color: Colors.white, size: 20),
              SizedBox(width: 6),
              Icon(Icons.signal_cellular_alt, color: Colors.white, size: 14),
              SizedBox(width: 6),
              Icon(Icons.battery_3_bar, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text('39', style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  // کسٹم نیویگیشن بار بنانے والا فنکشن
  Widget _buildNavigationBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.menu, color: Colors.black.withOpacity(0.6), size: 24),
          Icon(Icons.home_outlined, color: Colors.black.withOpacity(0.6), size: 24),
          Icon(Icons.chevron_left, color: Colors.black.withOpacity(0.6), size: 24),
          // "ایکسیسبلٹی" آئیکن آپ کی تصویر میں
          Transform.rotate(
            angle: 180 * 3.14159 / 180, // اسے الٹا کریں تاکہ تصویر جیسا لگے
            child: Icon(Icons.accessibility_new, color: Colors.black.withOpacity(0.6), size: 24),
          ),
        ],
      ),
    );
  }
}
