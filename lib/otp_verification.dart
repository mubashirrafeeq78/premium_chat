import 'package:flutter/material.dart';
import 'dart:async';
import 'api_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String mobile;
  OTPVerificationScreen({required this.mobile});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  // 6 ہندسوں کے لیے کنٹرولرز اور فوکس نوڈس
  List<TextEditingController> controllers = List.generate(6, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  
  bool _isLoading = false;
  String? _errorMessage;
  int _timeLeft = 120; // 2 منٹ کا ٹائمر
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in controllers) controller.dispose();
    super.dispose();
  }

  // ٹائمر شروع کرنے کا فنکشن
  void _startTimer() {
    _timeLeft = 120;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  // لال بارڈر والا ایرر پاپ اپ (3 سیکنڈ)
  void _showError(String message) {
    setState(() { _errorMessage = message; });
    Timer(Duration(seconds: 3), () {
      if (mounted) setState(() { _errorMessage = null; });
    });
  }

  // او ٹی پی ویریفائی کرنے کا فنکشن
  void _verifyOTP() async {
    String otp = controllers.map((e) => e.text).join();
    if (otp.length < 6) {
      _showError("براہ کرم تمام 6 ہندسے درج کریں۔");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.postRequest('verify-otp', {
        'mobile': widget.mobile,
        'otp': otp,
      });

      setState(() => _isLoading = false);

      if (response['status'] == 'success') {
        if (response['user_exists'] == true) {
          // اگر یوزر پہلے سے موجود ہے تو ڈیش بورڈ پر بھیجیں
          print("User UUID: ${response['uuid']}");
          // Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          // اگر نیا یوزر ہے تو پروفائل سیٹ اپ پر بھیجیں
          // Navigator.pushReplacementNamed(context, '/profile-setup');
        }
      } else {
        _showError(response['message'] ?? "غلط او ٹی پی کوڈ۔");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("کنکشن فیل: سرور سے رابطہ نہیں ہو سکا۔");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE5F8ED), Color(0xFFFCFBE1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Verify OTP", style: TextStyle(color: Color(0xFF4A55A2), fontSize: 26, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("We've sent a 6-digit code to \n${widget.mobile}", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    SizedBox(height: 30),
                    
                    // 6 ہندسوں کے ان پٹ باکسز
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) => SizedBox(
                        width: 45,
                        child: TextField(
                          controller: controllers[index],
                          focusNode: focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: Color(0xFFF9F9F9),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF00C853), width: 2)),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) focusNodes[index + 1].requestFocus();
                            if (value.isEmpty && index > 0) focusNodes[index - 1].requestFocus();
                          },
                        ),
                      )),
                    ),
                    
                    SizedBox(height: 35),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00C853),
                        minimumSize: Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isLoading 
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Verify Account", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    
                    SizedBox(height: 25),
                    
                    // ٹائمر اور ری سینڈ بٹن
                    _timeLeft > 0 
                      ? Text("Wait ${_timeLeft}s to resend", style: TextStyle(color: Colors.grey))
                      : TextButton(
                          onPressed: () {
                            Navigator.pop(context); // واپس جا کر دوبارہ نمبر بھیجیں
                          },
                          child: Text("Edit Number / Resend OTP", style: TextStyle(color: Color(0xFF4A55A2), fontWeight: FontWeight.bold)),
                        ),
                  ],
                ),
              ),
            ),
            
            // مخصوص ریڈ ایرر پاپ اپ
            if (_errorMessage != null)
              Positioned(
                top: 60, left: 30, right: 30,
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
