import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatGroupPage extends StatefulWidget {
  @override
  _ChatGroupPageState createState() => _ChatGroupPageState();
}

class _ChatGroupPageState extends State<ChatGroupPage> {
  final TextEditingController _msgController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  // عارضی لسٹ (صرف ڈیزائن چیک کرنے کے لیے)
  final List<Map<String, dynamic>> _dummyMessages = [
    {
      "type": "text",
      "content": "السلام علیکم! یہ پریمیم ڈیزائن کیسا ہے؟",
      "time": "11:30 AM",
      "date": "13 April 2026",
      "isMe": false
    },
    {
      "type": "audio",
      "content": "Voice Message",
      "time": "11:32 AM",
      "date": "13 April 2026",
      "isMe": true
    },
    {
      "type": "image",
      "content": "https://paxochat.com/sample.jpg",
      "time": "11:35 AM",
      "date": "13 April 2026",
      "isMe": true
    }
  ];

  // میسج ایڈ کرنے کا فنکشن (صرف ڈیزائن ٹیسٹ کے لیے)
  void _addDummyMessage(String type, {String? content}) {
    setState(() {
      _dummyMessages.insert(0, {
        "type": type,
        "content": content ?? _msgController.text,
        "time": DateFormat('hh:mm a').format(DateTime.now()),
        "date": DateFormat('dd MMMM yyyy').format(DateTime.now()),
        "isMe": true
      });
      _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: Row(
          children: [
            CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("مسائل شرعیہ گروپ", style: TextStyle(color: Colors.white, fontSize: 16)),
                Text("آن لائن", style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [Icon(Icons.videocam, color: Colors.white), SizedBox(width: 15), Icon(Icons.call, color: Colors.white), Icon(Icons.more_vert, color: Colors.white)],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png"),
            fit: BoxFit.cover,
            opacity: 0.08,
          ),
          color: Color(0xFFE5DDD5),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: EdgeInsets.all(12),
                itemCount: _dummyMessages.length,
                itemBuilder: (context, index) => _buildMessageItem(_dummyMessages[index]),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
            bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 1)],
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (msg['type'] == 'text') Text(msg['content'], style: TextStyle(fontSize: 15)),
            if (msg['type'] == 'image') ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network("https://via.placeholder.com/200")),
            if (msg['type'] == 'audio') Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.play_arrow, color: Colors.grey), Container(width: 100, height: 2, color: Colors.grey[300]), Icon(Icons.mic, size: 16, color: Colors.blue)],
            ),
            S Weiss(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${msg['date']} | ${msg['time']}", style: TextStyle(fontSize: 9, color: Colors.black45)),
                if (isMe) SizedBox(width: 4),
                if (isMe) Icon(Icons.done_all, size: 15, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey[600]), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      onChanged: (v) => setState(() {}),
                      decoration: InputDecoration(hintText: "میسج لکھیں...", border: InputBorder.none),
                    ),
                  ),
                  IconButton(icon: Icon(Icons.attach_file, color: Colors.grey[600]), onPressed: () => _showMediaPicker()),
                  IconButton(icon: Icon(Icons.camera_alt, color: Colors.grey[600]), onPressed: () {}),
                ],
              ),
            ),
          ),
          SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              if (_msgController.text.isNotEmpty) _addDummyMessage("text");
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF075E54),
              child: Icon(_msgController.text.isEmpty ? Icons.mic : Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _mediaIcon(Icons.image, "گیلری", Colors.purple, () => _addDummyMessage("image")),
            _mediaIcon(Icons.camera_alt, "کیمرہ", Colors.red, () {}),
            _mediaIcon(Icons.videocam, "ویڈیو", Colors.orange, () {}),
          ],
        ),
      ),
    );
  }

  Widget _mediaIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () { Navigator.pop(context); onTap(); },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [CircleAvatar(radius: 30, backgroundColor: color, child: Icon(icon, color: Colors.white)), Text(label)],
      ),
    );
  }
}
