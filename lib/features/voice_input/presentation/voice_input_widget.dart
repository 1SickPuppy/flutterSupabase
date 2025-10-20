import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/voice_input_service.dart';
import 'dart:async'; // ⭐️ Import dart:async for StreamSubscription

class VoiceInputWidget extends StatefulWidget {
  const VoiceInputWidget({super.key});

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  late final VoiceInputService _voiceInputService;
  late StreamSubscription<String> _textSubscription; // ⭐️ Subscription to handle text updates
  String _recognizedText = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _voiceInputService = context.read<VoiceInputService>();

    // ⭐️ FIX 1: Subscribe to the stream to get recognized text
    _textSubscription = _voiceInputService.textStream.listen((text) {
      setState(() {
        _recognizedText = text;
        // The service itself should handle setting its internal _isListening to false
        // when the final result is ready, but we manage the UI state here.
        _isListening = false;
      });
    });
  }

  // ⭐️ FIX 2: Essential cleanup to prevent memory leaks ⭐️
  @override
  void dispose() {
    _textSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (Build method remains the same) ...
    // Note: In a larger app, you'd use the VoiceToDataNotifier,
    // but for now, we use the service directly.
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Voice Input',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Text(
            _recognizedText.isEmpty ? 'Tap the mic to start speaking' : _recognizedText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: _toggleListening,
            child: Icon(_isListening ? Icons.mic_off : Icons.mic),
          ),
        ],
      ),
    );
  }

  void _toggleListening() async { // ⭐️ Make the function async
    if (_isListening) {
      // Stop listening
      await _voiceInputService.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      // Start listening
      setState(() {
        _isListening = true;
        _recognizedText = ''; // Clear previous text
      });
      // ⭐️ FIX 3: Simply call the async function; do not use .then() for text result
      await _voiceInputService.startListening();
    }
  }
}