import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:achiver_app/services/gemini_service.dart';

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
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;
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
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.insert(0, {"type": "text", "content": text, "isUser": true});
      _isLoading = true;
    });

    try {
      final response = await _geminiService.generateResponse(text);

      setState(() {
        _messages
            .insert(0, {"type": "text", "content": response, "isUser": false});
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error sending text: $e');
      }
      setState(() {
        _messages.insert(0, {
          "type": "text",
          "content":
              "Sorry, I couldn't process your request. Please try again.",
          "isUser": false
        });
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _isLoading = true;
        _messages.insert(
            0, {"type": "image", "content": image.path, "isUser": true});
      });

      try {
        final response = await _geminiService.analyzeImage(
          image.path,
          'Please analyze this image and provide a detailed explanation.',
        );

        setState(() {
          _messages.insert(
              0, {"type": "text", "content": response, "isUser": false});
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error analyzing image: $e');
        }
        setState(() {
          _messages.insert(0, {
            "type": "text",
            "content": "Sorry, I couldn't analyze the image. Please try again.",
            "isUser": false
          });
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
    } finally {
      setState(() => _isLoading = false);
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
    final isUser = message['isUser'] == true;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.withValues(alpha: 0.1) : Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isUser ? Icons.person : Icons.auto_awesome,
                  color: isUser ? Colors.blue : Colors.amber[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isUser ? 'You' : 'Study Assistant',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUser ? Colors.blue[800] : Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            message['type'] == 'text'
                ? SelectableText(
                    message['content'],
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  )
                : message['type'] == 'image'
                    ? Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(message['content']),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (!isUser) const SizedBox(height: 8),
                          if (!isUser)
                            SelectableText(
                              message['content'] ?? 'Analyzing image...',
                              style: const TextStyle(fontSize: 14),
                            ),
                        ],
                      )
                    : const Text(
                        "Audio messages are not supported yet",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
          ],
        ),
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
              child: _isLoading && _messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      reverse: true,
                      itemCount: _messages.length,
                      itemBuilder: (_, index) =>
                          _buildMessage(_messages.reversed.toList()[index]),
                    ),
            ),
            if (_isLoading && _messages.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
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
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText:
                              _isLoading ? "Please wait..." : "Type a doubt...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: _isLoading ? Colors.grey[400] : null,
                          ),
                        ),
                        onSubmitted: _isLoading
                            ? null
                            : (value) {
                                if (value.trim().isNotEmpty) {
                                  _sendText(value.trim());
                                  _textController.clear();
                                }
                              },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!_isLoading)
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blueAccent),
                      onPressed: () {
                        if (_textController.text.trim().isNotEmpty) {
                          _sendText(_textController.text.trim());
                          _textController.clear();
                        }
                      },
                    ),
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
