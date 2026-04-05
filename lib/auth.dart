import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // موبائل نمبر کے لیے کنٹرولر
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;
  String _message = "";

  void _handleContinue() async {
    String mobile = _mobileController.text.trim();

    // 1. بنیادی ویلیڈیشن
    if (mobile.length != 11 || !mobile.startsWith('03')) {
      setState(() => _message = "براہ کرم درست 11 ہندسوں کا نمبر درج کریں۔");
      return;
    }

    setState(() {
      _isLoading = true;
      _message = "";
    });

    // 2. بیک اینڈ (auth.js) کو ریکویسٹ بھیجنا
    final response = await ApiService.postRequest('auth', {
      'mobile': mobile,
      'action': 'send_otp'
    });

    setState(() => _isLoading = false);

    // 3. جواب کی بنیاد پر ایکشن لینا
    if (response['status'] == 'success') {
      // اگلے پیج پر جانا اور نمبر ساتھ لے جانا (جیسے او ٹی پی ویریفیکیشن)
      print("OTP Sent Successfully!");
      // یہاں آپ Navigator.push استعمال کر کے OTP اسکرین پر بھیج سکتے ہیں
    } else {
      setState(() => _message = response['message'] ?? "خرابی پیش آگئی۔");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Color(0xFFE3FDF5), Color(0xFFFFE6FA)],
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 50, horizontal: 25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("👋", style: TextStyle(fontSize: 40)),
                SizedBox(height: 10),
                Text("Welcome!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4A55A2))),
                SizedBox(height: 15),
                Text("Enter your 11-digit mobile number to proceed.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                SizedBox(height: 35),
                
                // موبائل ان پٹ فیلڈ
                TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  decoration: InputDecoration(
                    hintText: "e.g., 03XXXXXXXXX",
                    filled: true,
                    fillColor: Color(0xFFF9F9F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                
                SizedBox(height: 20),
                Text(_message, style: TextStyle(color: Colors.red, fontSize: 14)),

                // بٹن
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00C853),
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading 
                      ? CircularProgressIndicator(color: Colors.white) 
                      : Text("Continue", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
