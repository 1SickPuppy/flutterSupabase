// lib/features/voice_input/presentation/voice_input_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/voice_input_service.dart';
import '../../../core/di/service_locator.dart';
import '../../job_flow/job_flow_notifier.dart';
import 'dart:async'; // Husk denne import

class VoiceInputWidget extends StatefulWidget {
  const VoiceInputWidget({super.key});

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  final VoiceInputService _voiceInputService = getIt<VoiceInputService>();
  String _recognizedText = '';
  bool _isInitialized = false;

  // ⭐️ TILFØJELSE: Statusser ⭐️
  bool _isListening = false;
  bool _hasTranscription = false;

  late StreamSubscription _textSubscription;
  late StreamSubscription _statusSubscription;

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
      // ⭐️ LYTTER TIL TEKST (Realtidsopdatering) ⭐️
      _textSubscription = _voiceInputService.textStream.listen((text) {
        if (mounted) {
          setState(() {
            _recognizedText = text;
            _hasTranscription = text.isNotEmpty;
          });
        }

        // Kalder Notifieren kun når optagelsen stopper
        if (!_voiceInputService.isListening && text.isNotEmpty) {
          final notifier = Provider.of<JobFlowNotifier>(context, listen: false);
          notifier.extractData(text);
          // Viser status besked for succes
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transskription sendt til analyse!')),
          );
        }
      });

      // ⭐️ LYTTER TIL STATUS (Knapstatusopdatering) ⭐️
      _statusSubscription = _voiceInputService.listeningStatusStream.listen((status) {
        if (mounted) {
          setState(() {
            _isListening = status;
          });
        }
      });
    } else {
      // Viser fejlmeddelelse, hvis init fejler
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fejl: Voice Service kunne ikke initialiseres.')),
        );
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

  void _analyzeConversation() {
    // Denne logik kaldes, når brugeren trykker 'Analyser samtale'
    final notifier = Provider.of<JobFlowNotifier>(context, listen: false);
    notifier.extractData(_recognizedText);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Samtale sendt til JobFlow for analyse.')),
    );
  }

  @override
  void dispose() {
    _voiceInputService.dispose();
    _textSubscription.cancel(); // ⭐️ Husk at annullere streams ⭐️
    _statusSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Builder er ikke nødvendig her, hvis den er i en Scaffold, men skader ikke
    return Builder(
      builder: (context) {
        final icon = _isListening ? Icons.mic_off : Icons.mic;
        final color = _isListening ? Colors.red : Colors.green;
        // ⭐️ RETTELSE: Knaptekst skifter ⭐️
        final buttonText = _isListening ? 'Stop Optagelse' : 'Start Optagelse';

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
              // ⭐️ NYT: Analyser Samtale knap ⭐️
              if (_hasTranscription && !_isListening)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: _analyzeConversation,
                    child: const Text('Analyser samtale'),
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
                        ? (_isListening ? 'Lytter...' : 'Tryk "Start Optagelse" for at tale.')
                        : _recognizedText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}