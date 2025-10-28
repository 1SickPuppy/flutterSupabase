// lib/features/data_extraction/data/data_extraction_service_impl.dart

import 'dart:async'; // Til Future.delayed
import '../domain/data_extraction_service.dart';
import 'mock_data.dart'; // Importér de mock data

/// Mock-implementering af Data Extraction Service.
/// Simulerer AI-analyse ved at returnere strukturerede data.
class DataExtractionServiceImpl implements DataExtractionService {

  @override
  Future<Map<String, dynamic>> extractDataFromText(String transcription) async {
    // ⭐️ Simulerer netværksforsinkelse (2 sekunder) for at vise loading state ⭐️
    await Future.delayed(const Duration(seconds: 2));

    // Her ville du normalt kalde din AI-API.
    // For nu returnerer vi de forventede mock-data, uanset transkriptionen.

    if (transcription.trim().isEmpty) {
      // Hvis transkriptionen er tom, kan du vælge at kaste en fejl
      // eller returnere et tomt resultat, men vi tillader mock-data for at teste flowet.
    }

    return mockAnalysisData;
  }
}