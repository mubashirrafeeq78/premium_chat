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
  List<TextEditingController> controllers = List.generate(6, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;

  void _showError(String message) {
    setState(() { _errorMessage = message; });
    Timer(Duration(seconds: 3), () {
      if (mounted) setState(() { _errorMessage = null; });
    });
  }

  void _verifyOTP() async {
    String otp = controllers.map((e) => e.text).join();
    if (otp.length < 6) {
      _showError("تمام 6 ہندسے درج کریں۔");
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.postRequest('verify-otp', {
      'mobile': widget.mobile,
      'otp': otp,
      'action': 'verify'
    });

    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      // کامیابی پر ہوم یا پروفائل اسکرین پر لے جائیں
      print("Verified! UUID: ${response['uuid']}");
    } else {
      _showError(response['message'] ?? "غلط OTP کوڈ۔");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFE3FDF5), Color(0xFFFFE6FA)], begin: Alignment.topLeft),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Verify OTP", style: TextStyle(color: Color(0xFF4A55A2), fontSize: 26, fontWeight: FontWeight.w800)),
                    SizedBox(height: 10),
                    Text("Code sent to ${widget.mobile}", style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) => SizedBox(
                        width: 45,
                        child: TextField(
                          controller: controllers[index],
                          focusNode: focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: Color(0xFFF9F9F9),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFFF1F1F1), width: 2)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF00C853), width: 2.5)),
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
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00C853), minimumSize: Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Verify Account", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            if (_errorMessage != null)
              Positioned(
                top: 50, left: 20, right: 20,
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.red, width: 2)),
                  child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
