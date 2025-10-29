// lib/features/voice_input/domain/voice_input_service.dart

abstract class VoiceInputService {
  Future<bool> initialize();
  Future<void> startListening();
  Future<void> stopListening();
  bool get isListening;
  Stream<String> get textStream;

  // ⭐️ RETTELSE: Tilføjer den manglende getter til interfacet ⭐️
  Stream<bool> get listeningStatusStream;

  void dispose();
}