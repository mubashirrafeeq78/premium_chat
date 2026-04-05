import 'package:flutter/material.dart';
import 'dart:async';
import 'api_service.dart';
import 'otp_verification.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // ریڈ ایرر پاپ اپ کا فنکشن (3 سیکنڈ کے لیے)
  void _showError(String message) {
    setState(() { _errorMessage = message; });
    Timer(Duration(seconds: 3), () {
      if (mounted) setState(() { _errorMessage = null; });
    });
  }

  void _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 11) {
      _showError("نمبر 11 ہندسوں کا ہونا ضروری ہے۔");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.postRequest('auth', {
        'mobile': phone,
      });

      setState(() => _isLoading = false);

      // اگر بیک اینڈ سے کامیابی کا پیغام آئے
      if (response['status'] == 'success') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(mobile: phone),
          ),
        );
      } else {
        _showError(response['message'] ?? "سرور سے رابطہ نہیں ہو سکا۔");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("کنکشن کا مسئلہ: براہ کرم انٹرنیٹ چیک کریں۔");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // بالکل وہی بیک گراؤنڈ جو تصویر میں ہے
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
                width: MediaQuery.of(context).size.width * 0.88,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: Offset(0, 10))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("👋 Welcome!", style: TextStyle(color: Color(0xFF4A55A2), fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("Enter your 11-digit mobile number to proceed.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    SizedBox(height: 30),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "e.g., 03XXXXXXXXX",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[300]!)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Color(0xFF00C853), width: 2)),
                      ),
                    ),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _sendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00C853), // گرین بٹن
                        minimumSize: Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        shadowColor: Color(0xFF00C853).withOpacity(0.4),
                      ),
                      child: _isLoading 
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Continue", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            
            // مخصوص ریڈ ایرر پاپ اپ (اگر ایرر ہو)
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
                      Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14))),
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
