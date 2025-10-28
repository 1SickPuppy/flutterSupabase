// lib/features/data_extraction/data/data_extraction_service_impl.dart

import 'dart:async';
import '../domain/data_extraction_service.dart';
import 'mock_data.dart'; // Sikker på du har denne import

class DataExtractionServiceImpl implements DataExtractionService {

  @override
  Future<Map<String, dynamic>> extractDataFromText(String transcription) async {
    await Future.delayed(const Duration(seconds: 2));
    // Antager at mockAnalysisData er defineret i mock_data.dart
    return mockAnalysisData;
  }

  // ⭐️ VIGTIGT: Denne metode opfylder DataExtractionService interfacet ⭐️
  @override
  Future<Map<String, dynamic>> extractDataFromUrl(String url) async {
    throw UnimplementedError('URL extraction not implemented for this service.');
  }
}