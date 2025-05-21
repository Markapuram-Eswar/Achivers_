import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DoubtsPage extends StatefulWidget {
  const DoubtsPage({super.key});

  @override
  State<DoubtsPage> createState() => _DoubtsPageState();
}

class _DoubtsPageState extends State<DoubtsPage> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ImagePicker _picker = ImagePicker();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _recorder.openRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendText(String text) async {
    setState(() {
      _messages.add({"type": "text", "content": text});
    });

    await http.post(
      Uri.parse("http://your-backend.com/ask-doubt"),
      headers: {"Content-Type": "application/json"},
      body: '{"type": "text", "content": "$text", "user_id": "student123"}',
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _messages.add({"type": "image", "content": image.path});
      });

      final req = http.MultipartRequest(
        'POST',
        Uri.parse('http://your-backend.com/upload'),
      );
      req.files.add(await http.MultipartFile.fromPath('file', image.path));
      req.fields['type'] = 'image';
      req.fields['user_id'] = 'student123';

      final response = await req.send();
      final res = await http.Response.fromStream(response);
      if (kDebugMode) {
        print(res.body);
      }
    }
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      final dir = await getApplicationDocumentsDirectory();
      final path =
          "${dir.path}/doubt_${DateTime.now().millisecondsSinceEpoch}.aac";
      await _recorder.startRecorder(toFile: path);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });

    if (path != null) {
      _messages.add({"type": "audio", "content": path});

      final req = http.MultipartRequest(
        'POST',
        Uri.parse('http://your-backend.com/upload'),
      );
      req.files.add(await http.MultipartFile.fromPath('file', path));
      req.fields['type'] = 'audio';
      req.fields['user_id'] = 'student123';

      final response = await req.send();
      final res = await http.Response.fromStream(response);
      if (kDebugMode) {
        print(res.body);
      }
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(
            message['type'] == 'text'
                ? Icons.text_fields
                : message['type'] == 'image'
                    ? Icons.image
                    : Icons.mic,
            color: Colors.blueAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: message['type'] == 'text'
                ? Text(message['content'])
                : message['type'] == 'image'
                    ? Image.file(File(message['content']))
                    : const Text("Audio Doubt (tap to play)",
                        style: TextStyle(fontStyle: FontStyle.italic)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Ask a Doubt",
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (_, index) =>
                    _buildMessage(_messages.reversed.toList()[index]),
              ),
            ),
            if (_isRecording)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Recording...",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.blueAccent),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic,
                        color: Colors.blueAccent),
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: "Type a doubt...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        final text = _textController.text.trim();
                        if (text.isNotEmpty) {
                          _sendText(text);
                          _textController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
