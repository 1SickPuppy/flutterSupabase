// lib/features/voice_input/data/voice_input_service_impl.dart

import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import '../domain/voice_input_service.dart';

class VoiceInputServiceImpl implements VoiceInputService {
  final SpeechToText _speech = SpeechToText();
  final StreamController<String> _textStreamController = StreamController<String>.broadcast();
  final StreamController<bool> _listeningStatusController = StreamController<bool>.broadcast();

  // Vi bruger kun denne, da den virkede
  static const String _danishLocaleId = 'da-DK';

  @override
  Stream<bool> get listeningStatusStream => _listeningStatusController.stream;

  bool _isInitialized = false;

  @override
  bool get isListening => _speech.isListening;

  @override
  Stream<String> get textStream => _textStreamController.stream;

  @override
  Future<bool> initialize() async {
    _isInitialized = await _speech.initialize(
      onStatus: (status) {
        print('Status: $status');
        _listeningStatusController.add(_speech.isListening);
      },
      onError: (error) => print('Speech to text fejl: ${error.errorMsg}'),
    );

    // Fjernede al logik for at finde understøttede locales
    print('SpeechToText initialiseret. Bruger eksplicit sprogkode: $_danishLocaleId');
    return _isInitialized;
  }

  @override
  Future<void> startListening() async {
    print('DEBUG: startListening kaldt');

    if (!_isInitialized) {
      print('Fejl: Voice service er ikke initialiseret.');
      return;
    }

    print('DEBUG: Service er initialiseret, starter lytning');
    _textStreamController.add('');

    try {
      await _speech.listen(
        // ⭐️ Direkte brug af den virkende sprogkode ⭐️
        localeId: _danishLocaleId,

        onResult: (result) {
          print('DEBUG: Modtog resultat: ${result.recognizedWords}');
          print('DEBUG: Is final: ${result.finalResult}');
          // Sender ALLE resultater til streamen for realtidsopdatering
          _textStreamController.add(result.recognizedWords);
        },

        // Lyt i op til 60 sekunder
        listenFor: const Duration(seconds: 60),

        // VIGTIGT: Vent længere tid før stop ved stilhed (15 sekunder)
        pauseFor: const Duration(seconds: 15),

        // Vis partial/interim resultater mens der tales
        partialResults: true,

        // Fortsæt lytning efter første resultat
        listenMode: ListenMode.confirmation,

        // Stop IKKE automatisk på fejl
        cancelOnError: false,
      );
      print('DEBUG: Listen kommando sendt');
    } catch (e) {
      print('DEBUG: Fejl ved start af lytning: $e');
    }
  }

  @override
  Future<void> stopListening() async {
    await _speech.stop();
  }

  @override
  void dispose() {
    _speech.stop();
    _speech.cancel();
    _textStreamController.close();
    _listeningStatusController.close();
  }
}