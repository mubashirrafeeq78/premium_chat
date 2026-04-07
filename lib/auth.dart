import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'config.dart';
import 'api_service.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> sendOtp() async {
    // 1. Validation Check
    if (_phoneController.text.length != 11) {
      _showSnackBar("براہ کرم 11 ہندسوں کا درست نمبر درج کریں", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    // --- اصل جڑ پکڑنے کے لیے ٹریکنگ یہاں سے شروع ہوتی ہے ---
    print("--- DEBUG START ---");
    print("Step 1: Button Clicked. Number: ${_phoneController.text}");
    
    try {
      final fullUrl = "${AppConfig.baseUrl}${AppConfig.auth}";
      print("Step 2: Sending Request to: $fullUrl");
      print("Step 3: Headers: {'x-api-key': ${AppConfig.apiKey}}");

      // اے پی آئی کال
      final response = await ApiService.postRequest(
        AppConfig.auth, 
        {"mobile": _phoneController.text}
      );

      print("Step 4: Server Response Received: $response");

      if (response['status'] == 'success') {
        print("RESULT: SUCCESS");
        _showSnackBar(response['message'] ?? "او ٹی پی بھیج دیا گیا ہے", Colors.green);
      } else {
        print("RESULT: SERVER RETURNED ERROR -> ${response['message']}");
        _showSnackBar("سرور کی طرف سے پیغام: ${response['message']}", Colors.orange);
      }
    } catch (e) {
      // اگر ریکویسٹ سرور تک نہ پہنچے تو یہاں پتہ چلے گا
      print("--- CRITICAL ERROR ---");
      print("Step 5: Catch Block Triggered.");
      print("Error Type: ${e.runtimeType}");
      print("Actual Error: $e");
      
      // جڑ پکڑنے کے لیے مخصوص پیغامات
      String errorMessage = e.toString();
      if (errorMessage.contains('XMLHttpRequest')) {
        errorMessage = "براؤزر نے ریکویسٹ بلاک کر دی (CORS issue)";
      } else if (errorMessage.contains('HandshakeException')) {
        errorMessage = "سیکیورٹی سرٹیفکیٹ (SSL) کا مسئلہ ہے";
      } else if (errorMessage.contains('SocketException')) {
        errorMessage = "انٹرنیٹ یا سرور کا ایڈریس درست نہیں ہے";
      }
      
      _showSnackBar("اصل مسئلہ: $errorMessage", Colors.red);
    } finally {
      print("--- DEBUG END ---");
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: 'sans-serif')),
        backgroundColor: color,
        duration: Duration(seconds: 5), // وقت بڑھا دیا تاکہ آپ پڑھ سکیں
        action: SnackBarAction(label: "ٹھیک ہے", textColor: Colors.white, onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ڈیزائن وہی رہے گا جو آپ نے پسند کیا تھا
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD4EAE2), Color(0xFFFAFBEC)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 10))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("👋 ", style: TextStyle(fontSize: 24)),
                        Text("Welcome!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF3F51B5))),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text("Enter your 11-digit mobile number to proceed.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    SizedBox(height: 25),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [LengthLimitingTextInputFormatter(11), FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: "e.g., 03XXXXXXXXX",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      ),
                    ),
                    SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : sendOtp,
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00C853), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Continue", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
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
