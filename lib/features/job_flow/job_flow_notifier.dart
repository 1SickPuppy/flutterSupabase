// lib/features/job_flow/job_flow_notifier.dart

import 'package:flutter/foundation.dart';
import '../../models/job_analysis_model.dart';
import '../voice_input/domain/voice_input_service.dart';
import '../data_extraction/domain/data_extraction_service.dart';
import '../pdf_generation/domain/pdf_generation_service.dart';

class JobFlowNotifier extends ChangeNotifier {
  final VoiceInputService _voiceService;
  final DataExtractionService _dataExtractionService;
  final PdfGenerationService _pdfService;

  // --- State Variables ---
  String _screen = 'recording'; // recording, analysis, offer
  bool _isLoading = false;
  String _transcription = '';
  JobAnalysisModel? _analysisData;
  String? _offerPdfPath;

  // --- Getters ---
  String get screen => _screen;
  bool get isRecording => _voiceService.isListening;
  bool get isLoading => _isLoading;
  String get transcription => _transcription;
  JobAnalysisModel? get analysisData => _analysisData;
  String? get offerPdfPath => _offerPdfPath;

  JobFlowNotifier(
      this._voiceService,
      this._dataExtractionService,
      this._pdfService,
      ) {
    // Lyt til real-time transkriptioner fra voice service
    _voiceService.textStream.listen((text) {
      _transcription = text;
      notifyListeners();
    });
    // Initialiser voice service
    _voiceService.initialize();
  }

  // --- Handlers / Logic ---

  void toggleRecording() async {
    if (isRecording) {
      await _voiceService.stopListening();
    } else {
      // Nulstil transkription ved ny optagelse
      _transcription = '';
      await _voiceService.startListening();
    }
    notifyListeners();
  }

  void handleAnalyze() async {
    if (_transcription.isEmpty || _isLoading) return;

    _isLoading = true;
    _screen = 'recording'; // Vis loading på recordingskærmen
    notifyListeners();

    try {
      // 1. Send transkriptionen til din Data Extraction Service
      final rawData = await _dataExtractionService.extractDataFromText(_transcription);

      // 2. Opret den strukturerede model
      _analysisData = JobAnalysisModel.fromJson(rawData);

      // 3. Skift til Analysis Screen
      _screen = 'analysis';
    } catch (e) {
      debugPrint('Error during analysis: $e');
      // Her kan du vise en fejlbesked til brugeren
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void handleCreateOffer() async {
    if (_analysisData == null || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Generer PDF bytes
      final pdfBytes = await _pdfService.generatePdfFromData(_analysisData!.toJson());

      // 2. Gem PDF filen lokalt
      _offerPdfPath = await _pdfService.savePdfToStorage(
          pdfBytes,
          'offer_${DateTime.now().millisecondsSinceEpoch}.pdf'
      );

      // 3. Skift til Offer Screen
      _screen = 'offer';
    } catch (e) {
      debugPrint('Error creating PDF: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Plads til handleSendOffer, handleAddToPlanner, osv.
  void handleSendOffer() {
    debugPrint('Offer sent logic started.');
    // Her kalder du din SupabaseService til at sende email
    // ...
  }

  void handleAddToPlanner() {
    debugPrint('Added to Planner!');
  }

  void handleOrderParts() {
    debugPrint('Parts order initiated!');
  }

  void handleReset() {
    _voiceService.stopListening();
    _screen = 'recording';
    _isLoading = false;
    _transcription = '';
    _analysisData = null;
    _offerPdfPath = null;
    notifyListeners();
  }
}

// Vi tilføjer en simpel toJson metode til JobAnalysisModel for at undgå fejl i koden ovenfor
extension JobAnalysisModelExtension on JobAnalysisModel {
  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'phone': phone,
      'email': email,
      'address': address,
      'job': job,
      'assignment': assignment,
      'preferredDates': preferredDates,
      'partsNeeded': partsNeeded.map((p) => {'name': p.name, 'price': p.price, 'sku': p.sku}).toList(),
      'totalEstimate': totalEstimate,
      'notes': notes,
    };
  }
}