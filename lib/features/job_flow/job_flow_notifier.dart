// lib/features/job_flow/job_flow_notifier.dart

import 'package:flutter/foundation.dart';

// Importér alle de interfaces, som denne Notifier skal bruge
import '../voice_input/domain/voice_input_service.dart';
import '../data_extraction/domain/data_extraction_service.dart';
import '../pdf_generation/domain/pdf_generation_service.dart';
// import '../supabase_integration/domain/supabase_service.dart'; // Tilføj hvis du bruger den

class JobFlowNotifier extends ChangeNotifier {

  // Opret private felter for de services, du modtager via constructoren
  final VoiceInputService _voiceInputService;
  final DataExtractionService _dataExtractionService;
  final PdfGenerationService _pdfGenerationService;
  // final SupabaseService _supabaseService; // Tilføj hvis du bruger den

  // Constructor: Modtager alle services fra MultiProvider/GetIt i main.dart
  JobFlowNotifier(
      this._voiceInputService,
      this._dataExtractionService,
      this._pdfGenerationService,
      // this._supabaseService,
      );

  // --- Implementering af den manglende 'extractData' metode ---
  // ⭐️ Denne metode løser fejlen: "The method 'extractData' isn't defined for the type 'JobFlowNotifier'".
  // Den kaldes fra din VoiceInputWidget.
  Future<void> extractData(String text) async {
    print('Notifier modtog tekst til analyse: $text');

    if (text.isEmpty) {
      // Du kan sætte en fejlmeddelelse her senere
      return;
    }

    // Simuler/kald data extraction service
    // For at implementere hele flowet senere:
    // try {
    //   final result = await _dataExtractionService.extractDataFromText(text);
    //   // Opdater appens state baseret på 'result'
    //   notifyListeners();
    // } catch (e) {
    //   print('Fejl under dataudtræk: $e');
    //   // Håndter fejlmeddelelse i UI
    // }
  }

// --- Andre state-variabler og metoder kan komme her ---
}