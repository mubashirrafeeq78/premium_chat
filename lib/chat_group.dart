import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class ChatGroupScreen extends StatefulWidget {
  @override
  _ChatGroupScreenState createState() => _ChatGroupScreenState();
}

class _ChatGroupScreenState extends State<ChatGroupScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isRecording = false;
  bool _isTyping = false;
  Map<String, dynamic>? _replyingTo;
  
  // Dummy Data for Preview (As you said backend later)
  List<Map<String, dynamic>> _messages = [
    {
      "id": "1",
      "user": "System",
      "text": "خوش آمدید! آپ یہاں مسائل شرعیہ پوچھ سکتے ہیں۔",
      "isMe": false,
      "type": "text",
      "time": "10:00 AM"
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({
        "id": DateTime.now().toString(),
        "user": "You",
        "text": _messageController.text,
        "isMe": true,
        "type": "text",
        "time": "${DateTime.now().hour}:${DateTime.now().minute}",
        "replyTo": _replyingTo,
      });
      _messageController.clear();
      _isTyping = false;
      _replyingTo = null;
    });
    
    Timer(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Color(0xFFE0F7FA), Color(0xFFFFE0B2)],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 40), // Top padding like your header spacer
            
            // Chat Messages Area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
              ),
            ),

            // Reply UI
            if (_replyingTo != null) _buildReplyPreview(),

            // Input Bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg['user'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF075E54))),
            if (msg['replyTo'] != null)
              Container(
                margin: EdgeInsets.only(top: 5, bottom: 5),
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  border: Border(left: BorderSide(color: Color(0xFF075E54), width: 4)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(msg['replyTo']['text'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
              ),
            SizedBox(height: 5),
            Text(msg['text'], style: TextStyle(fontSize: 15, color: Colors.black87)),
            SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg['time'], style: TextStyle(fontSize: 10, color: Colors.grey)),
                if (isMe) ...[
                  SizedBox(width: 4),
                  Icon(Icons.done_all, size: 16, color: Color(0xFF34B7F1)),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      color: Color(0xFFE9E9E9),
      child: Row(
        children: [
          Container(width: 4, height: 40, color: Color(0xFF075E54)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_replyingTo!['user'], style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF075E54), fontSize: 13)),
                Text(_replyingTo!['text'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.close, size: 20), onPressed: () => setState(() => _replyingTo = null)),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Color(0xFFF0F0F0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.attach_file, color: Color(0xFF667781)), onPressed: _showMediaOptions),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (v) => setState(() => _isTyping = v.isNotEmpty),
                      decoration: InputDecoration(
                        hintText: _isRecording ? "Recording ● 00:00" : "Type a message...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: _isRecording ? Colors.red : Colors.grey),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onLongPress: () {
              if (!_isTyping) setState(() => _isRecording = true);
            },
            onLongPressUp: () {
              if (_isRecording) {
                setState(() => _isRecording = false);
                // logic to send voice would go here
              }
            },
            onTap: _isTyping ? _sendMessage : null,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFF25D366),
              child: Icon(
                _isTyping ? Icons.send : (_isRecording ? Icons.mic : Icons.mic),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: GridView.count(
          crossAxisCount: 3,
          padding: EdgeInsets.all(20),
          children: [
            _mediaIcon(Icons.image, "Gallery", Colors.purple),
            _mediaIcon(Icons.camera_alt, "Camera", Colors.red),
            _mediaIcon(Icons.videocam, "Video", Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _mediaIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(radius: 30, backgroundColor: color, child: Icon(icon, color: Colors.white)),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
