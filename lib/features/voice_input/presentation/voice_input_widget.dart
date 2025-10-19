import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/voice_input_service.dart';

class VoiceInputWidget extends StatefulWidget {
  const VoiceInputWidget({Key? key}) : super(key: key);

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  late final VoiceInputService _voiceInputService;
  String _recognizedText = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _voiceInputService = context.read<VoiceInputService>();
  }

  @override
  Widget build(BuildContext context) {
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

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _voiceInputService.startListening().then((result) {
          setState(() {
            _recognizedText = result;
            _isListening = false;
          });
        });
      } else {
        _voiceInputService.stopListening();
      }
    });
  }
}