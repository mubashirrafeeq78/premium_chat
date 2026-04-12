import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ChatGroupPage extends StatefulWidget {
  @override
  _ChatGroupPageState createState() => _ChatGroupPageState();
}

class _ChatGroupPageState extends State<ChatGroupPage> {
  // --- کنفیگریشن ---
  final String _baseUrl = "https://paxochat.com"; // اپنا یو آر ایل یہاں لکھیں
  final String _apiKey = "PixoChat_Master_Secure_2026";
  final String _masterPin = "123456";

  bool _isLocked = true;
  bool _isRegistered = false;
  String _myNumber = "";
  List<dynamic> _messages = [];
  TextEditingController _pinController = TextEditingController();
  TextEditingController _msgController = TextEditingController();
  TextEditingController _numController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  // اسٹیٹس چیک کریں (لاک اور رجسٹریشن)
  _checkStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? num = prefs.getString('mobile_number');
    if (num != null) {
      setState(() {
        _myNumber = num;
        _isRegistered = true;
      });
      _loadChat();
    }
  }

  // --- API کال فنکشن ---
  Future<Map<String, dynamic>> _apiCall(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl$endpoint"),
        headers: {"x-api-key": _apiKey, "Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Connection Failed"};
    }
  }

  // چیٹ لوڈ کرنا
  _loadChat() async {
    if (_isLocked) return;
    var res = await _apiCall("/load_message", {});
    if (res['status'] == 'success') {
      setState(() { _messages = res['data']; });
    }
  }

  // میسج بھیجنا
  _sendMsg(String type, {String? content, String? url}) async {
    var res = await _apiCall("/save_Message", {
      "mobile_number": _myNumber,
      "content": content,
      "media_url": url,
      "media_type": type
    });
    if (res['status'] == 'success') {
      _msgController.clear();
      _loadChat();
    }
  }

  // میسج ڈیلیٹ کرنا
  _deleteMsg(int id) async {
    var res = await _apiCall("/delete_massege", {
      "message_id": id,
      "mobile_number": _myNumber
    });
    if (res['status'] == 'success') _loadChat();
  }

  // --- ڈیزائن سیکشن ---

  // 1. پن لاک اسکرین
  Widget _buildLockScreen() {
    return Scaffold(
      backgroundColor: Color(0xFF075E54),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          width: 300,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("6 ہندسوں کا پن کوڈ درج کریں", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, letterSpacing: 10),
                decoration: InputDecoration(border: OutlineInputBorder()),
                onChanged: (val) {
                  if (val == _masterPin) {
                    setState(() { _isLocked = false; });
                    _loadChat();
                  } else if (val.length == 6) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("غلط پن کوڈ")));
                    _pinController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. رجسٹریشن اسکرین
  Widget _buildRegScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("موبائل نمبر درج کریں", style: TextStyle(fontSize: 20)),
              TextField(controller: _numController, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: "03XXXXXXXXX")),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_numController.text.length == 11) {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('mobile_number', _numController.text);
                    setState(() { _myNumber = _numController.text; _isRegistered = true; });
                  }
                },
                child: Text("آگے بڑھیں"),
              )
            ],
          ),
        ),
      ),
    );
  }

  // 3. مین چیٹ UI
  @override
  Widget build(BuildContext context) {
    if (_isLocked) return _buildLockScreen();
    if (!_isRegistered) return _buildRegScreen();

    return Scaffold(
      appBar: AppBar(
        title: Text("مسائل شرعیہ"),
        backgroundColor: Color(0xFF075E54),
        leading: IconButton(icon: Icon(Icons.lock), onPressed: () => setState(() => _isLocked = true)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                var m = _messages[index];
                bool isMe = m['mobile_number'] == _myNumber;
                return GestureDetector(
                  onLongPress: () => _deleteMsg(m['id']),
                  child: Container(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    padding: EdgeInsets.all(8),
                    child: Card(
                      color: isMe ? Color(0xFFDCF8C6) : Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['mobile_number'], style: TextStyle(fontSize: 10, color: Colors.blueGrey)),
                            if (m['media_type'] == 'text') Text(m['content']),
                            if (m['media_type'] == 'image') Image.network(m['media_url'], width: 200),
                            // ویڈیو اور آڈیو کے لیے پلیئر یہاں ایڈ کیا جا سکتا ہے
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.attach_file), onPressed: () {}), // میڈیا اپ لوڈ لاجک
                Expanded(child: TextField(controller: _msgController, decoration: InputDecoration(hintText: "میسج لکھیں..."))),
                IconButton(icon: Icon(Icons.send, color: Colors.green), onPressed: () => _sendMsg("text", content: _msgController.text)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
