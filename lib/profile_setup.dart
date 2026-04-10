import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; 
// ApiService کی جگہ اب Config استعمال ہوگا
import 'config.dart';
import 'security_getway.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String mobile;
  ProfileSetupScreen({required this.mobile});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  
  String _selectedRole = 'buyer'; 
  File? _profilePic, _cnicFront, _cnicBack, _selfie;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String type) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        if (type == 'pfp') _profilePic = File(pickedFile.path);
        if (type == 'front') _cnicFront = File(pickedFile.path);
        if (type == 'back') _cnicBack = File(pickedFile.path);
        if (type == 'selfie') _selfie = File(pickedFile.path);
      });
    }
  }

  String? _fileToBase64(File? file) {
    if (file == null) return null;
    List<int> imageBytes = file.readAsBytesSync();
    return "data:image/jpeg;base64," + base64Encode(imageBytes);
  }

  Future<void> _registerUser() async {
    if (_nameController.text.isEmpty || _pinController.text.length < 4 || _profilePic == null) {
      _showSnack("Please fill basic info and select profile picture", true);
      return;
    }

    if (_selectedRole == 'provider' && (_cnicFront == null || _cnicBack == null || _selfie == null)) {
      _showSnack("Providers must upload CNIC and Selfie", true);
      return;
    }

    setState(() => _isLoading = true);

    Map<String, String?> imagesData = {
      "profile_pic": _fileToBase64(_profilePic),
      "cnic_front": _fileToBase64(_cnicFront),
      "cnic_back": _fileToBase64(_cnicBack),
      "live_selfie": _fileToBase64(_selfie),
    };

    try {
      // --- نئی ترتیب کا استعمال ---
      // اب یہاں براہ راست اینڈ پوائنٹ کے بجائے 'profile_setup' کی (Key) استعمال ہوگی
      final response = await Config.send('profile_setup', {
        "mobile_number": widget.mobile,
        "full_name": _nameController.text.trim(),
        "role": _selectedRole,
        "pin": _pinController.text,
        "images": jsonEncode(imagesData),
      });

      if (response['status'] == 'success') {
        _showSnack("Registration Successful!", false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SecurityGatewayScreen(uuid: response['uuid'])),
          (route) => false,
        );
      } else {
        _showSnack(response['message'] ?? "Registration Failed", true);
      }
    } catch (e) {
      _showSnack("Error: $e", true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  // باقی تمام UI ڈیزائن (جوں کا توں)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complete Your Profile"), backgroundColor: Color(0xFF3F51B5), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _pickImage('pfp'),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _profilePic != null ? FileImage(_profilePic!) : null,
                child: _profilePic == null ? Icon(Icons.camera_alt, size: 40, color: Colors.grey) : null,
              ),
            ),
            SizedBox(height: 20),
            
            _buildTextField(_nameController, "Full Name", Icons.person),
            SizedBox(height: 15),
            _buildTextField(_pinController, "Security PIN (4-Digits)", Icons.lock, isPin: true),
            
            SizedBox(height: 25),
            Text("Select Your Role", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(
              children: [
                Expanded(child: _roleCard("buyer", "Buyer", Icons.shopping_bag)),
                SizedBox(width: 10),
                Expanded(child: _roleCard("provider", "Provider", Icons.engineering)),
              ],
            ),

            if (_selectedRole == 'provider') ...[
              SizedBox(height: 25),
              Text("Identity Verification (Required for Providers)"),
              _uploadTile("CNIC Front Side", _cnicFront, () => _pickImage('front')),
              _uploadTile("CNIC Back Side", _cnicBack, () => _pickImage('back')),
              _uploadTile("Live Selfie", _selfie, () => _pickImage('selfie')),
            ],

            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerUser,
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00C853), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("FINISH REGISTRATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPin = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPin ? TextInputType.number : TextInputType.text,
      obscureText: isPin,
      maxLength: isPin ? 4 : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF3F51B5)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _roleCard(String role, String label, IconData icon) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF3F51B5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF3F51B5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Color(0xFF3F51B5)),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Color(0xFF3F51B5))),
          ],
        ),
      ),
    );
  }

  Widget _uploadTile(String title, File? file, VoidCallback onTap) {
    return ListTile(
      leading: Icon(file == null ? Icons.upload_file : Icons.check_circle, color: file == null ? Colors.grey : Colors.green),
      title: Text(title),
      trailing: TextButton(onPressed: onTap, child: Text("Select")),
    );
  }
}
