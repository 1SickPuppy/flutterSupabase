// lib/features/job_flow/job_flow_notifier.dart

import 'package:flutter/material.dart';

import '../voice_input/domain/voice_input_service.dart';
import '../data_extraction/domain/data_extraction_service.dart';
import '../pdf_generation/domain/pdf_generation_service.dart';
import '../../models/job_analysis_model.dart';

enum JobFlowState { recording, analyzing, analysisResult, finalOffer }

class JobFlowNotifier extends ChangeNotifier {
  final VoiceInputService _voiceInputService;
  final DataExtractionService _dataExtractionService;
  final PdfGenerationService _pdfGenerationService;

  JobFlowState _currentState = JobFlowState.recording;
  String _currentTranscription = '';
  JobAnalysisModel? _analysisModel;
  bool _isInitializing = true;
  String? _errorMessage;

  JobFlowNotifier(
      this._voiceInputService,
      this._dataExtractionService,
      this._pdfGenerationService,
      ) {
    _init(); // Starter initialisering, når notifieren oprettes
  }

  JobFlowState get currentState => _currentState;
  String get currentTranscription => _currentTranscription;
  JobAnalysisModel? get analysisModel => _analysisModel;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;

  // Initialiserer service og lytter til transkriptionsstream
  void _init() async {
    final success = await _voiceInputService.initialize();
    _isInitializing = false;
    if (!success) {
      _errorMessage = 'Fejl: Mikrofonen er ikke tilgængelig eller tilladelser mangler.';
    }

    _voiceInputService.textStream.listen((text) {
      _currentTranscription = text;
      notifyListeners();
    });

    notifyListeners();
  }

  // --- Actions ---

  void toggleRecording() async {
    if (_voiceInputService.isListening) {
      await _voiceInputService.stopListening();
    } else {
      _currentTranscription = '';
      await _voiceInputService.startListening();
    }
    notifyListeners();
  }

  Future<void> analyzeTranscription() async {
    if (_currentTranscription.isEmpty) {
      _errorMessage = 'Ingen tale registreret. Prøv igen.';
      return;
    }

    _currentState = JobFlowState.analyzing;
    _errorMessage = null;
    notifyListeners();

    try {
      final rawData = await _dataExtractionService.extractDataFromText(_currentTranscription);
      _analysisModel = JobAnalysisModel.fromJson(rawData);
      _currentState = JobFlowState.analysisResult;
    } catch (e) {
      _errorMessage = 'Analyse mislykkedes: ${e.toString()}';
      _currentState = JobFlowState.recording;
    }
    notifyListeners();
  }

  Future<String> generatePdfOffer() async {
    if (_analysisModel == null) {
      _errorMessage = 'Fejl: Analysemodellen mangler data.';
      return '';
    }

    try {
      final pdfBytes = await _pdfGenerationService.generatePdfFromData(_analysisModel!.toJson());
      final path = await _pdfGenerationService.savePdfToStorage(pdfBytes, 'Tilbud-${_analysisModel!.customerName}.pdf');

      _currentState = JobFlowState.finalOffer;
      notifyListeners();

      return path;
    } catch (e) {
      _errorMessage = 'PDF generering mislykkedes: ${e.toString()}';
      notifyListeners();
      return '';
    }
  }

  void reset() {
    _currentTranscription = '';
    _analysisModel = null;
    _errorMessage = null;
    _currentState = JobFlowState.recording;
    notifyListeners();
  }
}