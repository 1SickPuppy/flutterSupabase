// lib/features/job_flow/job_flow_notifier.dart

import 'package:flutter/foundation.dart';
import '../voice_input/domain/voice_input_service.dart';
import '../data_extraction/domain/data_extraction_service.dart';
import '../pdf_generation/domain/pdf_generation_service.dart';
import '../../models/job_analysis_model.dart';
// import '../supabase_integration/domain/supabase_service.dart';

class JobFlowNotifier extends ChangeNotifier {

  final VoiceInputService _voiceInputService;
  final DataExtractionService _dataExtractionService;
  final PdfGenerationService _pdfGenerationService;

  // ⭐️ Ny State 1: Gem det aktuelle fane-index ⭐️
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  // ⭐️ Ny State 2: Gem de udtrukne data som JobAnalysisModel ⭐️
  JobAnalysisModel? _jobAnalysis;
  JobAnalysisModel? get jobAnalysis => _jobAnalysis;

  // Loading states
  bool _isExtracting = false;
  bool get isExtracting => _isExtracting;

  bool _isGeneratingPdf = false;
  bool get isGeneratingPdf => _isGeneratingPdf;

  // Error state
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // PDF path after generation
  String? _pdfPath;
  String? get pdfPath => _pdfPath;

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
      _errorMessage = 'Ingen tekst at analysere';
      notifyListeners();
      return;
    }

    // Start loading
    _isExtracting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Kald data extraction service
      final result = await _dataExtractionService.extractDataFromText(text);

      // Parse result til JobAnalysisModel
      _jobAnalysis = JobAnalysisModel.fromJson(result);

      // ⭐️ VIGTIGT: Skift til Data-fanen (index 1) for at vise resultatet ⭐️
      _selectedIndex = 1;

      print('Data extraction successful: ${_jobAnalysis?.customerName}');
    } catch (e) {
      _errorMessage = 'Fejl under dataudtræk: $e';
      print('Fejl under dataudtræk: $e');
    } finally {
      _isExtracting = false;
      notifyListeners();
    }
  }

  // --- Implementering af 'generatePdf' metode ---
  Future<void> generatePdf() async {
    if (_jobAnalysis == null) {
      _errorMessage = 'Ingen data at generere PDF fra';
      notifyListeners();
      return;
    }

    _isGeneratingPdf = true;
    _errorMessage = null;
    _pdfPath = null;
    notifyListeners();

    try {
      final result = await _pdfGenerationService.generatePdf(_jobAnalysis!.toJson());

      if (result['success'] == true) {
        _pdfPath = result['path'];
        print('PDF genereret: $_pdfPath');
      } else {
        _errorMessage = result['error'] ?? 'Ukendt fejl ved PDF generering';
      }
    } catch (e) {
      _errorMessage = 'Fejl ved PDF generering: $e';
      print('Fejl ved PDF generering: $e');
    } finally {
      _isGeneratingPdf = false;
      notifyListeners();
    }
  }

  // --- Metode til at rydde data ---
  void clearData() {
    _jobAnalysis = null;
    _errorMessage = null;
    _pdfPath = null;
    notifyListeners();
  }

  // --- Metode til at opdatere job analysis (til editing) ---
  void updateJobAnalysis(JobAnalysisModel updatedModel) {
    _jobAnalysis = updatedModel;
    notifyListeners();
  }

}