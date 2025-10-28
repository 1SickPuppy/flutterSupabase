import 'package:flutter/material.dart';
import '../domain/voice_input_service.dart';
import '../../../core/di/service_locator.dart'; // Importerer din GetIt instance
import 'package:provider/provider.dart'; // Importér Provider
import '../../job_flow/job_flow_notifier.dart'; // Du skal bruge denne til JobFlow

class VoiceInputWidget extends StatefulWidget {
  const VoiceInputWidget({super.key});

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  // ⭐️ FEJLFRI LINJE: Hent VoiceInputService via GetIt ⭐️
  final VoiceInputService _voiceInputService = getIt<VoiceInputService>();

  String _recognizedText = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognition();
    _voiceInputService.textStream.listen((text) {
      setState(() {
        _recognizedText = text;
      });
    });
  }

  Future<void> _initializeSpeechRecognition() async {
    final isAvailable = await _voiceInputService.initialize();
    setState(() {
      _isInitialized = isAvailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Du skal bruge Notifier'en til at trigge Data Extraction, som vi har diskuteret:
    final jobFlowNotifier = Provider.of<JobFlowNotifier>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Voice Input',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    _recognizedText.isEmpty ? 'Tryk på mikrofonen for at starte' : _recognizedText,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isInitialized
                        ? () {
                      if (_voiceInputService.isListening) {
                        _voiceInputService.stopListening();
                      } else {
                        _voiceInputService.startListening();
                      }
                      setState(() {});
                    }
                        : null,
                    icon: Icon(_voiceInputService.isListening ? Icons.stop : Icons.mic),
                    label: Text(_voiceInputService.isListening ? 'Stop' : 'Start optagelse'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_recognizedText.isNotEmpty)
            ElevatedButton(
              // ⭐️ BRUG NOTIFIEREN HER ⭐️
              onPressed: () {
                // Sender teksten til Data Extraction via Notifier'en
                jobFlowNotifier.extractData(_recognizedText);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tekst sendt til databehandling')),
                );
              },
              child: const Text('Behandl tekst'),
            ),
        ],
      ),
    );
  }
}