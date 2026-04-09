import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'config.dart';
import 'security_getway.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String mobile;
  ProfileSetupScreen({required this.mobile});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _pinControllers = List.generate(5, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(5, (index) => FocusNode());

  String? _selectedRole;
  File? _profilePic, _cnicFront, _cnicBack, _liveSelfie;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // تصویر منتخب کرنے کا بہتر فنکشن (کیمرہ اور گیلری کی تفریق کے ساتھ)
  Future<void> _pickImage(String type) async {
    // پروفائل پکچر گیلری سے، باقی سب لازمی کیمرہ سے
    ImageSource source = (type == 'pfp') ? ImageSource.gallery : ImageSource.camera;
    
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 40, // سائز کم رکھنے کے لیے
    );

    if (image != null) {
      setState(() {
        if (type == 'pfp') _profilePic = File(image.path);
        if (type == 'front') _cnicFront = File(image.path);
        if (type == 'back') _cnicBack = File(image.path);
        if (type == 'selfie') _liveSelfie = File(image.path);
      });
    }
  }

  Future<String?> _toBase64(File? file) async {
    if (file == null) return null;
    return "data:image/jpeg;base64,${base64Encode(await file.readAsBytes())}";
  }

  bool _isFormValid() {
    bool baseValid = _nameController.text.length > 2 && _profilePic != null &&
        _selectedRole != null && _pinControllers.every((c) => c.text.isNotEmpty);
    if (_selectedRole == 'provider') {
      return baseValid && _cnicFront != null && _cnicBack != null && _liveSelfie != null;
    }
    return baseValid;
  }

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);
    String pin = _pinControllers.map((e) => e.text).join();

    try {
      Map<String, String?> imagesMap = {
        'profile_pic': await _toBase64(_profilePic),
        'cnic_front': await _toBase64(_cnicFront),
        'cnic_back': await _toBase64(_cnicBack),
        'live_selfie': await _toBase64(_liveSelfie),
      };

      // اینڈ پوائنٹ کو کنفیگ فائل کے مطابق درست کر دیا گیا ہے
      final response = await ApiService.postRequest(AppConfig.profile_setup, {
        'mobile_number': widget.mobile,
        'full_name': _nameController.text.trim(),
        'role': _selectedRole,
        'pin': pin,
        'images': jsonEncode(imagesMap),
      });

      if (response['status'] == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_uuid', response['uuid']);
        await prefs.setString('user_role', _selectedRole!);
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SecurityGatewayScreen(uuid: response['uuid'])),
          (route) => false,
        );
      } else {
        _showError(response['message']);
      }
    } catch (e) {
      _showError("سرور سے رابطہ نہیں ہو سکا۔");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE3FDF5), Color(0xFFFFE6FA)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(25),
            child: Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 50)]),
              child: Column(
                children: [
                  Text("Profile Setup", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3B4CA8))),
                  SizedBox(height: 20),
                  
                  // Profile Picture Preview
                  GestureDetector(
                    onTap: () => _pickImage('pfp'),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 55, backgroundColor: Colors.grey[100],
                          backgroundImage: _profilePic != null ? FileImage(_profilePic!) : null,
                          child: _profilePic == null ? Icon(Icons.person, size: 50, color: Color(0xFF3B4CA8)) : null,
                        ),
                        Positioned(bottom: 0, right: 0, child: CircleAvatar(radius: 18, backgroundColor: Color(0xFF3B4CA8), child: Icon(Icons.camera_alt, size: 16, color: Colors.white))),
                      ],
                    ),
                  ),

                  SizedBox(height: 25),
                  TextField(controller: _nameController, textAlign: TextAlign.center, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: "Your Full Name", filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none))),

                  SizedBox(height: 25),
                  Text("SET 5-DIGIT SECURITY PIN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(5, (index) => _buildPinBox(index))),

                  SizedBox(height: 30),
                  Row(children: [_roleBtn("🛠️", "Provider", "provider"), SizedBox(width: 15), _roleBtn("🤝", "Buyer", "buyer")]),

                  if (_selectedRole == 'provider') ...[
                    SizedBox(height: 25),
                    _uploadBox("CNIC FRONT (Live Camera)", _cnicFront, () => _pickImage('front')),
                    _uploadBox("CNIC BACK (Live Camera)", _cnicBack, () => _pickImage('back')),
                    _uploadBox("LIVE SELFIE", _liveSelfie, () => _pickImage('selfie')),
                  ],

                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity, height: 60,
                    child: ElevatedButton(
                      onPressed: (_isFormValid() && !_isLoading) ? _handleRegister : null,
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3B4CA8), disabledBackgroundColor: Colors.grey[200], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                      child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("GO TO APPLICATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinBox(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _pinControllers[index], focusNode: _focusNodes[index], obscureText: true, textAlign: TextAlign.center, keyboardType: TextInputType.number, maxLength: 1,
        decoration: InputDecoration(counterText: "", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        onChanged: (v) {
          if (v.isNotEmpty && index < 4) _focusNodes[index + 1].requestFocus();
          if (v.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
          setState(() {});
        },
      ),
    );
  }

  Widget _roleBtn(String emoji, String label, String r) {
    bool isActive = _selectedRole == r;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(color: isActive ? Color(0xFFF0F4FF) : Colors.grey[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: isActive ? Color(0xFF3B4CA8) : Colors.transparent, width: 2)),
          child: Column(children: [Text(emoji, style: TextStyle(fontSize: 24)), Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600]))]),
        ),
      ),
    );
  }

  Widget _uploadBox(String label, File? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        height: 120, width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50], borderRadius: BorderRadius.circular(20),
          border: Border.all(color: file != null ? Color(0xFF3B4CA8) : Colors.grey[300]!, width: 2),
          image: file != null ? DecorationImage(image: FileImage(file), fit: BoxFit.cover) : null,
        ),
        child: file == null ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.camera_enhance, color: Colors.grey, size: 30), SizedBox(height: 8), Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))],
        ) : Container(
          alignment: Alignment.bottomRight, padding: EdgeInsets.all(8),
          child: CircleAvatar(backgroundColor: Colors.green, radius: 12, child: Icon(Icons.check, size: 16, color: Colors.white)),
        ),
      ),
    );
  }
}
