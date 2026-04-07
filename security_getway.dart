import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'api_service.dart';
import 'config.dart';

class SecurityGatewayScreen extends StatefulWidget {
  final String uuid; // پچھلی اسکرین سے UUID آئے گی
  SecurityGatewayScreen({required this.uuid});

  @override
  _SecurityGatewayScreenState createState() => _SecurityGatewayScreenState();
}

class _SecurityGatewayScreenState extends State<SecurityGatewayScreen> {
  final List<TextEditingController> _pinControllers = List.generate(5, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(5, (index) => FocusNode());
  
  bool _isLoading = false;
  String? _accountStatus; // pending, approved, blocked, active
  String? _userRole;

  @override
  void dispose() {
    for (var controller in _pinControllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  // میسج دکھانے کا فنکشن
  void _showSnack(String msg, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // سیکیورٹی گیٹ وے ویریفیکیشن
  Future<void> _verifyGateway({String subAction = ''}) async {
    String pin = _pinControllers.map((e) => e.text).join();
    if (pin.length < 5) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.postRequest('security_getway', {
        'action': 'verify_gateway_access',
        'uuid': widget.uuid,
        'pin': pin,
        'sub_action': subAction,
      });

      if (response['status'] == 'success') {
        setState(() {
          _accountStatus = response['account_status'];
          _userRole = response['role'];
        });

        if (_accountStatus == 'active') {
          _navigateToDashboard();
        }
      } else {
        _showSnack(response['message'] ?? "Access Denied", true);
        for (var c in _pinControllers) c.clear();
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      _showSnack("Connection Error", true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToDashboard() {
    // یہاں اپنی ڈیش بورڈ لاجک لکھیں
    print("Navigating to $_userRole Dashboard...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF3F6),
      body: Stack(
        children: [
          // مین پن ان پٹ لیئر
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Security Check",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF3B4CA8)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "ENTER 5-DIGIT PIN",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 2),
                    ),
                    SizedBox(height: 48),
                    
                    // PIN Inputs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) => _buildPinBox(index)),
                    ),
                    
                    SizedBox(height: 48),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _verifyGateway(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF3B4CA8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 8,
                        ),
                        child: _isLoading 
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("UNLOCK SYSTEM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.black, letterSpacing: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // اسٹیٹس اوورلے (اگر اکاؤنٹ ایکٹیو نہ ہو)
          if (_accountStatus != null && _accountStatus != 'active')
            _buildStatusOverlay(),
        ],
      ),
    );
  }

  // پن باکس ڈیزائن
  Widget _buildPinBox(int index) {
    return Container(
      width: 55,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _focusNodes[index].hasFocus ? Color(0xFF3B4CA8) : Color(0xFFE2E8F0), width: 2),
        boxShadow: [if(_focusNodes[index].hasFocus) BoxShadow(color: Color(0xFF3B4CA8).withOpacity(0.1), blurRadius: 20)],
      ),
      child: TextField(
        controller: _pinControllers[index],
        focusNode: _focusNodes[index],
        obscureText: true,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(counterText: "", border: InputBorder.none),
        onChanged: (value) {
          if (value.isNotEmpty && index < 4) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (index == 4 && value.length == 1) _verifyGateway();
        },
      ),
    );
  }

  // اسٹیٹس کارڈ (Pending/Approved/Blocked)
  Widget _buildStatusOverlay() {
    IconData icon = Icons.hourglass_empty;
    Color iconBg = Colors.orange;
    String title = "Status";
    String msg = "";
    Widget? footer;

    if (_accountStatus == 'pending') {
      icon = Icons.check;
      iconBg = Colors.green;
      title = "Review in Progress";
      msg = "Your documents are being verified. You will be able to access the dashboard once approved.";
      footer = Text("Estimated: 5m - 24h", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold));
    } else if (_accountStatus == 'approved') {
      icon = Icons.military_tech;
      iconBg = Colors.blue;
      title = "Account Approved!";
      msg = "Great news! Your profile is verified. Click below to enter your workspace.";
      footer = ElevatedButton(
        onPressed: () => _verifyGateway(subAction: 'activate_now'),
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3B4CA8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: Text("ENTER DASHBOARD", style: TextStyle(color: Colors.white)),
      );
    } else if (_accountStatus == 'blocked') {
      icon = Icons.shield_moon;
      iconBg = Colors.red;
      title = "Access Restricted";
      msg = "Your account has been blocked due to a policy violation. Please contact support.";
      footer = TextButton(onPressed: () {}, child: Text("Contact Support", style: TextStyle(color: Colors.red)));
    }

    return Container(
      color: Color(0xFF1E293B).withOpacity(0.7),
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(32),
      child: Center(
        child: Container(
          width: 360,
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 40, backgroundColor: iconBg, child: Icon(icon, color: Colors.white, size: 40)),
              SizedBox(height: 24),
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              SizedBox(height: 16),
              Text(msg, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
              SizedBox(height: 32),
              if (footer != null) footer,
            ],
          ),
        ),
      ),
    );
  }
}
