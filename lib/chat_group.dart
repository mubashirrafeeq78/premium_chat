import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(home: PremiumChatScreen(), debugShowCheckedModeBanner: false));

class PremiumChatScreen extends StatefulWidget {
  const PremiumChatScreen({super.key});

  @override
  _PremiumChatScreenState createState() => _PremiumChatScreenState();
}

class _PremiumChatScreenState extends State<PremiumChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final ImagePicker _picker = ImagePicker();
  bool _isRecording = false;

  void _sendMessage(String content, String type) {
    if (content.trim().isEmpty && type == 'text') return;
    setState(() {
      _messages.add({
        'content': content,
        'type': type,
        'isMe': true,
        'time': '10:32 AM', // آپ یہاں dynamic وقت بھی ڈال سکتے ہیں
      });
    });
    _controller.clear();
  }

  Future<void> _handleMedia(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) _sendMessage(image.path, 'image');
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      if (path != null) _sendMessage(path, 'voice');
      setState(() => _isRecording = false);
    } else {
      if (await _recorder.hasPermission()) {
        final directory = Directory.systemTemp.path;
        await _recorder.start(const RecordConfig(), path: '$directory/audio.m4a');
        setState(() => _isRecording = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3F7F9), Color(0xFFE6F3F5), Color(0xFFFDF1E1)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(10, 60, 10, 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildMessageItem(_messages[index]),
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
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(15),
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))],
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg['type'] == 'text')
              Text(msg['content'], style: const TextStyle(fontSize: 16)),
            if (msg['type'] == 'image')
              ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(msg['content']))),
            if (msg['type'] == 'voice')
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.blue),
                    onPressed: () => _player.play(DeviceFileSource(msg['content'])),
                  ),
                  const Text("Voice Message 0:12"),
                ],
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg['time'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(width: 4),
                if (isMe) const Icon(Icons.done_all, size: 15, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.attach_file, color: Colors.grey), onPressed: () => _handleMedia(ImageSource.gallery)),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: "Type a message...", border: InputBorder.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onLongPress: _toggleRecording,
            onLongPressUp: _toggleRecording,
            onTap: () => _sendMessage(_controller.text, 'text'),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF25D366),
              child: Icon(_controller.text.isNotEmpty ? Icons.send : Icons.mic, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
