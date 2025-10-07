// Interface for voice input service (følger Interface Segregation Principle)
abstract class VoiceInputService {
  Future<bool> initialize();
  Future<void> startListening();
  Future<void> stopListening();
  Stream<String> get textStream;
  bool get isListening;
}