// lib/features/job_flow/job_flow_notifier.dart

import 'package:flutter/foundation.dart';
import '../voice_input/domain/voice_input_service.dart';
import '../data_extraction/domain/data_extraction_service.dart';
import '../pdf_generation/domain/pdf_generation_service.dart';
// import '../supabase_integration/domain/supabase_service.dart';

class JobFlowNotifier extends ChangeNotifier {

  final VoiceInputService _voiceInputService;
  final DataExtractionService _dataExtractionService;
  final PdfGenerationService _pdfGenerationService;

  // ⭐️ Ny State 1: Gem det aktuelle fane-index ⭐️
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  // ⭐️ Ny State 2: Gem de udtrukne data ⭐️
  String _extractedData = '';
  String get extractedData => _extractedData;

  // Constructor
  JobFlowNotifier(
      this._voiceInputService,
      this._dataExtractionService,
      this._pdfGenerationService,
      );

  // Metode til at skifte fane (kaldes fra HomeScreen)
  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  // --- Implementering af 'extractData' metode ---
  Future<void> extractData(String text) async {
    print('Notifier modtog tekst til analyse: $text');

    if (text.isEmpty) {
      return;
    }

    // For nu simulerer vi et resultat
    _extractedData = 'Data udtrukket fra samtalen: "$text"';

    // ⭐️ VIGTIGT: Skift til Data-fanen (index 1) for at vise resultatet ⭐️
    _selectedIndex = 1;

    notifyListeners();

    // Senere, når du implementerer DataExtractionService:
    // try {
    //   final result = await _dataExtractionService.extractDataFromText(text);
    //   _extractedData = result; // Antager at servicen returnerer en streng
    //   _selectedIndex = 1;
    //   notifyListeners();
    // } catch (e) {
    //   print('Fejl under dataudtræk: $e');
    // }
  }

}