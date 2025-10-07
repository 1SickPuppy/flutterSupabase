import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import '../domain/voice_input_service.dart';

// Implementation af voice input service (følger Single Responsibility Principle)
class VoiceInputServiceImpl implements VoiceInputService {
  final SpeechToText _speechToText = SpeechToText();
  final StreamController<String> _textStreamController = StreamController<String>.broadcast();
  bool _isListening = false;

  @override
  Future<bool> initialize() async {
    final available = await _speechToText.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
    );
    return available;
  }

  @override
  Future<void> startListening() async {
    if (!_isListening) {
      _isListening = await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _textStreamController.add(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'da_DK', // Dansk sprog
      );
    }
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    await _speechToText.stop();
  }

  @override
  Stream<String> get textStream => _textStreamController.stream;

  @override
  bool get isListening => _isListening;
}