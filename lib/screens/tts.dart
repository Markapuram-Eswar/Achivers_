import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart'; // Add permission_handler

void main() => runApp(const MaterialApp(home: SimpleReadingTracker()));

class SimpleReadingTracker extends StatefulWidget {
  const SimpleReadingTracker({super.key});

  @override
  SimpleReadingTrackerState createState() => SimpleReadingTrackerState();
}

class SimpleReadingTrackerState extends State<SimpleReadingTracker> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  int _currentWordIndex = 0;

  final String paragraph = 'Flutter is an open-source UI toolkit by Google';
  List<String> _textWords = [];
  final Set<int> _readIndices = {};
  final Set<int> _skippedIndices = {};

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeText();
    _checkPermissions(); // Check permissions on init
  }

  // Check and request microphone permissions
  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
    }
  }

  void _initializeText() {
    _textWords = paragraph.split(' ').where((word) => word.isNotEmpty).toList();
    _readIndices.clear();
    _skippedIndices.clear();
    _currentWordIndex = 0;
  }

  void _startListening() async {
    // Ensure permissions are granted
    if (await Permission.microphone.status != PermissionStatus.granted) {
      await _checkPermissions();
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == 'done' && _isListening && mounted) {
          _startListening(); // Restart listening
        }
      },
      onError: (val) {
        debugPrint('Speech error: $val');
        if (mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Speech error: $val')),
          );
        }
      },
    );

    if (available && mounted) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          if (!mounted) return;
          final spokenWords = val.recognizedWords.toLowerCase().split(' ');
          debugPrint('Recognized: $spokenWords'); // Debug spoken words
          for (final spoken in spokenWords) {
            if (_currentWordIndex >= _textWords.length) break;
            final expected = _textWords[_currentWordIndex].toLowerCase();
            if (spoken.contains(expected)) {
              // More flexible matching
              setState(() {
                _readIndices.add(_currentWordIndex);
                _currentWordIndex++;
              });
              break;
            }
          }
          // Notify user if no match
          if (spokenWords.isNotEmpty &&
              !spokenWords
                  .contains(_textWords[_currentWordIndex].toLowerCase())) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Expected: ${_textWords[_currentWordIndex]}')),
            );
          }
        },
      );
    } else if (mounted) {
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to initialize speech recognition')),
      );
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _skipCurrentWord() {
    if (_currentWordIndex < _textWords.length) {
      setState(() {
        _skippedIndices.add(_currentWordIndex);
        _currentWordIndex++;
      });
    }
  }

  void _reset() {
    _stopListening();
    setState(() => _initializeText());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Tracker'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: _skipCurrentWord,
            tooltip: 'Skip Word',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _textWords.isEmpty
                ? 0
                : (_readIndices.length + _skippedIndices.length) /
                    _textWords.length,
            backgroundColor: Colors.grey[300],
            color: Colors.green[600],
            minHeight: 8,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 6,
                runSpacing: 10,
                children: _textWords.asMap().entries.map((entry) {
                  final index = entry.key;
                  final word = entry.value;
                  final isCurrent = index == _currentWordIndex;
                  final color = _skippedIndices.contains(index)
                      ? Colors.red
                      : _readIndices.contains(index)
                          ? Colors.green
                          : isCurrent
                              ? Colors.blue
                              : Colors.black;

                  return AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: isCurrent ? 28 : 20,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: color,
                    ),
                    child: Text('$word '),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopListening();
    _speech.cancel(); // More robust cleanup
    super.dispose();
  }
}
