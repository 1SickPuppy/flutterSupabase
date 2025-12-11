// lib/features/voice_input/presentation/voice_input_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/voice_input_service.dart';
import '../../../core/di/service_locator.dart';
import '../../job_flow/job_flow_notifier.dart';
import 'dart:async';

class VoiceInputWidget extends StatefulWidget {
  const VoiceInputWidget({super.key});

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  final VoiceInputService _voiceInputService = getIt<VoiceInputService>();
  String _recognizedText = '';
  bool _isInitialized = false;

  bool _isListening = false;
  bool _hasTranscription = false;

  StreamSubscription? _textSubscription;
  StreamSubscription? _statusSubscription;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final success = await _voiceInputService.initialize();

    if (mounted) {
      setState(() {
        _isInitialized = success;
      });
    }

    if (success) {
      // LYTTER TIL TEKST
      _textSubscription = _voiceInputService.textStream.listen((text) {
        if (mounted) {
          setState(() {
            _recognizedText = text;
            _hasTranscription = text.isNotEmpty;
          });
        }
      });

      // LYTTER TIL STATUS
      _statusSubscription = _voiceInputService.listeningStatusStream.listen((status) {
        if (mounted) {
          setState(() {
            _isListening = status;
          });
        }
      });
    } else {
      // Fejlhåndtering
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // ⭐️ RETTELSE: Fjerner Builder herfra for at løse kompileringsfejlen ⭐️
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fejl: Voice Service kunne ikke initialiseres.')),
          );
        }
      });
    }
  }

  void _onToggleListening() async {
    if (_isListening) {
      await _voiceInputService.stopListening();
    } else {
      await _voiceInputService.startListening();
    }
  }

  void _analyzeConversation(BuildContext context) {
    // Dette er den funktionelle logik
    final notifier = Provider.of<JobFlowNotifier>(context, listen: false);
    notifier.extractData(_recognizedText);

    // SnackBar kaldes via den lokale kontekst fra knappen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Samtale sendt til JobFlow for analyse.')),
    );
  }

  @override
  void dispose() {
    // VIGTIGT: Kalder IKKE _voiceInputService.dispose()
    // fordi servicen er en singleton i GetIt og bliver genbrugt
    // Vi stopper kun lytning og unsubscriber fra streams
    _voiceInputService.stopListening();
    _textSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isListening = _isListening;
    final icon = isListening ? Icons.mic_off : Icons.mic;
    final color = isListening ? Colors.red : Colors.green;
    final buttonText = isListening ? 'Stop Optagelse' : 'Start Optagelse';

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator(value: null));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Stemme Input',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              icon: Icon(icon),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: _onToggleListening,
            ),
          ),
          const SizedBox(height: 30),
          // Analyser Samtale knap
          if (_hasTranscription && !isListening)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Builder( // Denne Builder er VIGTIG og korrekt placeret
                  builder: (innerContext) {
                    return ElevatedButton(
                      onPressed: () => _analyzeConversation(innerContext), // Bruger den lokale kontekst
                      child: const Text('Analyser samtale'),
                    );
                  }
              ),
            ),

          const Text(
            'Transskription:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _recognizedText.isEmpty
                    ? (isListening ? 'Lytter...' : 'Tryk "Start Optagelse" for at tale.')
                    : _recognizedText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}