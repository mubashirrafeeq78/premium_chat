import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class ChatGroupScreen extends StatefulWidget {
  @override
  _ChatGroupScreenState createState() => _ChatGroupScreenState();
}

class _ChatGroupScreenState extends State<ChatGroupScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isRecording = false;
  bool _isTyping = false;
  Map<String, dynamic>? _replyingTo;
  
  List<Map<String, dynamic>> _messages = [];

  // تصویر یا ویڈیو منتخب کرنے اور فوراً سینڈ کرنے کا فنکشن
  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    final XFile? file = isVideo 
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);

    if (file != null) {
      _addMessage(
        type: isVideo ? 'video' : 'image',
        content: file.path,
      );
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  // وائس ریکارڈنگ شروع کرنا
  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      setState(() => _isRecording = true);
      await _audioRecorder.start(const RecordConfig(), path: 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a');
    }
  }

  // ریکارڈنگ روکنا اور سینڈ کرنا
  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() => _isRecording = false);
    if (path != null) {
      _addMessage(type: 'voice', content: path);
    }
  }

  void _addMessage({required String type, required String content}) {
    setState(() {
      _messages.add({
        "id": DateTime.now().toString(),
        "user": "You",
        "text": content,
        "isMe": true,
        "type": type,
        "time": "${DateTime.now().hour}:${DateTime.now().minute}",
        "replyTo": _replyingTo,
      });
      _replyingTo = null;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Color(0xFFE0F7FA), Color(0xFFFFE0B2)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
              ),
            ),
            if (_replyingTo != null) _buildReplyPreview(),
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
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg['type'] == 'text') Text(msg['text']),
            if (msg['type'] == 'image') Image.file(File(msg['text'])),
            if (msg['type'] == 'video') const Icon(Icons.play_circle_fill, size: 50, color: Colors.grey),
            if (msg['type'] == 'voice') 
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.play_arrow), onPressed: () => _audioPlayer.play(DeviceFileSource(msg['text']))),
                  const Text("Voice Message"),
                ],
              ),
            Text(msg['time'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: const Color(0xFFF0F0F0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.attach_file), onPressed: _showMediaOptions),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (v) => setState(() => _isTyping = v.isNotEmpty),
                      decoration: InputDecoration(
                        hintText: _isRecording ? "Recording..." : "Type a message...",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onLongPress: _isTyping ? null : _startRecording,
            onLongPressUp: _isTyping ? null : _stopRecording,
            onTap: _isTyping ? () {
              _addMessage(type: 'text', content: _messageController.text);
              _messageController.clear();
              setState(() => _isTyping = false);
            } : null,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF25D366),
              child: Icon(_isTyping ? Icons.send : Icons.mic, color: Colors.white),
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
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _mediaOption(Icons.image, "Gallery", () => _pickMedia(ImageSource.gallery)),
            _mediaOption(Icons.camera_alt, "Camera", () => _pickMedia(ImageSource.camera)),
            _mediaOption(Icons.videocam, "Video", () => _pickMedia(ImageSource.gallery, isVideo: true)),
          ],
        ),
      ),
    );
  }

  Widget _mediaOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 30, backgroundColor: const Color(0xFF075E54), child: Icon(icon, color: Colors.white)),
          const SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }
  
  Widget _buildReplyPreview() => Container(); // Placeholder for design consistency
}
