import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart'; // ان پٹ فارمیٹ کے لیے

// ان مرکزی فائلوں کو امپورٹ کریں
import 'config.dart';
import 'api_service.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  // موبائل نمبر بھیجنے کا فنکشن (جو آپ کے auth.js بیک اینڈ سے جڑے گا)
  Future<void> sendOtp() async {
    // بنیادی تصدیق (Validation)
    if (_phoneController.text.length != 11) {
      _showSnackBar("براہ کرم 11 ہندسوں کا درست نمبر درج کریں", Colors.red);
      return;
    }

    // لوڈنگ شروع کریں اور ڈیزائن اپ ڈیٹ کریں
    setState(() {
      _isLoading = true;
    });

    // بیک اینڈ کے لیے ڈیٹا تیار کریں
    final requestBody = {
      "mobile": _phoneController.text // 'mobile' کی آپ کے بیک اینڈ کے مطابق ہے
    };

    try {
      // مرکزی اے پی آئی سروس کا استعمال کرتے ہوئے بیک اینڈ کال کریں
      final response = await ApiService.postRequest(
        AppConfig.auth, // '/auth' اینڈ پوائنٹ
        requestBody
      );

      if (response['status'] == 'success') {
        // کامیابی کا پیغام
        _showSnackBar(response['message'] ?? "او ٹی پی بھیج دیا گیا ہے", Colors.green);
        
        // یہاں پر آپ اگلی OTP والی اسکرین پر جانے کے لیے نیویگیشن لکھیں گے
        // مثال کے طور پر:
        // Navigator.push(context, MaterialPageRoute(builder: (context) => OtpVerifyScreen(phone: _phoneController.text)));
      } else {
        // بیک اینڈ سے آنے والا ایرر میسج دکھائیں
        _showSnackBar(response['message'] ?? "خرابی پیش آگئی", Colors.red);
      }
    } catch (e) {
      _showSnackBar("نیٹ ورک یا سرور کا مسئلہ: $e", Colors.red);
    } finally {
      // لوڈنگ ختم کریں چاہے کامیابی ہو یا خرابی
      setState(() {
        _isLoading = false;
      });
    }
  }

  // میسج دکھانے کے لیے ایک مددگار فنکشن
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // بیک گراؤنڈ گریڈینٹ
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD4EAE2), // ہلکا ہرا رنگ
              Color(0xFFFAFBEC), // ہلکا پیلا رنگ
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SingleChildScrollView( // اسکرین چھوٹی ہونے پر سکولنگ کے لیے
              child: Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  // ہلکا سایہ (Drop Shadow)
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // کنٹینر کو صرف ضرورت جتنا بڑا رکھنا
                  children: [
                    // ویلکم لائن (تصویر کے مطابق)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("👋 ", style: TextStyle(fontSize: 24)),
                        Text(
                          "Welcome!",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F51B5), // نیلا رنگ
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Enter your 11-digit mobile number to proceed.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 25),
                    
                    // موبائل نمبر کا ان پٹ فیلڈ
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(11), // صرف 11 ہندسے
                        FilteringTextInputFormatter.digitsOnly, // صرف ہندسے
                      ],
                      decoration: InputDecoration(
                        hintText: "e.g., 03XXXXXXXXX",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        counterText: "", // نیچے کاؤنٹر ہٹا دیں
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF3F51B5)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                    ),
                    SizedBox(height: 25),
                    
                    // کنٹینیو بٹن یا لوڈنگ انڈیکیٹر
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : sendOtp, // لوڈنگ کے دوران بٹن بند
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00C853), // سبز رنگ
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
