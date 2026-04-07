import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config.dart';
import 'api_service.dart';
import 'otp_verification.dart'; // اس فائل کا نام یقینی بنائیں

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> sendOtp() async {
    // 1. بیک اینڈ کی ضرورت کے مطابق 11 ہندسوں کی تصدیق
    if (_phoneController.text.length != 11) {
      _showStatusMessage("Please enter a valid 11-digit number", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. آپ کے auth.js کے مطابق 'mobile' کی ورڈ کے ساتھ ڈیٹا بھیجنا
      final response = await ApiService.postRequest(
        AppConfig.auth, 
        {"mobile": _phoneController.text}
      );

      // 3. بیک اینڈ کے 'status' چیک کرنا
      if (response['status'] == 'success') {
        _showStatusMessage("Verification code sent successfully!", isError: false);
        
        // کامیابی کی صورت میں 2 سیکنڈ بعد منتقلی
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => OTPVerificationScreen(mobile: _phoneController.text)
              ),
            );
          }
        });
      } else {
        // بیک اینڈ سے آنے والا ایرر میسج دکھانا
        _showStatusMessage(response['message'] ?? "Failed to send code.", isError: true);
      }
    } catch (e) {
      // سیکیورٹی کے لیے عام ایرر میسج
      _showStatusMessage("System busy. Please try again later.", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // میسج دکھانے کا خوبصورت فنکشن (پہلے والا ڈیزائن)
  void _showStatusMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).clearSnackBars(); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 3),
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isError ? Color(0xFFFFEBEE) : Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isError ? Colors.redAccent : Colors.green,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(isError ? Icons.error_outline : Icons.check_circle_outline, 
                   color: isError ? Colors.red : Colors.green),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: isError ? Colors.red[900] : Colors.green[900],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 450 : screenWidth * 0.9;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFF1F8E9)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: containerWidth,
              padding: EdgeInsets.all(32),
              margin: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 25,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF3F51B5).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_person_rounded, size: 40, color: Color(0xFF3F51B5)),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Secure Login",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Global Authentication System",
                    style: TextStyle(color: Colors.blueGrey[400], fontSize: 14),
                  ),
                  SizedBox(height: 35),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11), // 11 ہندسوں کی حد
                    ],
                    decoration: InputDecoration(
                      labelText: "Mobile Number",
                      hintText: "03XXXXXXXXX",
                      prefixIcon: Icon(Icons.phone_android_rounded, color: Color(0xFF3F51B5)),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Color(0xFF3F51B5), width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              "GET OTP",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "By proceeding, you agree to our Terms",
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
