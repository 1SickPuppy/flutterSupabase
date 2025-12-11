// lib/features/data_extraction/data/data_extraction_service_impl.dart

import 'dart:async';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../domain/data_extraction_service.dart';
import 'mock_data.dart';

class DataExtractionServiceImpl implements DataExtractionService {
  // Hent API key fra environment variable
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  @override
  Future<Map<String, dynamic>> extractDataFromText(String transcription) async {
    print('DEBUG: Modtog transcription til analyse: $transcription');

    if (transcription.isEmpty) {
      print('ERROR: Tom transcription');
      return mockAnalysisData;
    }

    // Hvis ingen API key, brug mock data
    if (_apiKey.isEmpty) {
      print('WARNING: GEMINI_API_KEY ikke sat, bruger mock data');
      final Map<String, dynamic> result = Map.from(mockAnalysisData);
      result['notes'] = 'TRANSCRIPTION: $transcription\n\n${mockAnalysisData['notes']}';
      return result;
    }

    try {
      // Initialiser Gemini model
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      // Opret prompt til data extraction
      final prompt = _buildExtractionPrompt(transcription);

      print('DEBUG: Sender til Gemini...');

      // Kald Gemini API
      final response = await model.generateContent([Content.text(prompt)]);

      print('DEBUG: Gemini response modtaget');

      if (response.text == null || response.text!.isEmpty) {
        print('ERROR: Tom response fra Gemini');
        return _fallbackToMock(transcription);
      }

      // Parse JSON response
      final extractedData = _parseGeminiResponse(response.text!);

      if (extractedData != null) {
        print('DEBUG: Data extraction successful');
        return extractedData;
      } else {
        print('ERROR: Kunne ikke parse Gemini response');
        return _fallbackToMock(transcription);
      }
    } catch (e) {
      print('ERROR: Gemini API fejl: $e');
      return _fallbackToMock(transcription);
    }
  }

  String _buildExtractionPrompt(String transcription) {
    return '''
Du er en ekspert i at analysere danske business samtaler om håndværker jobs (VVS, elektrik, snedker, osv.).

Analyser følgende danske samtale og udtræk information til et job tilbud. Returner UDELUKKENDE valid JSON uden markdown kodeblokke.

SAMTALE:
"""
$transcription
"""

Udtræk følgende information og returner som JSON:
{
  "customerName": "Kundens fulde navn (find i samtalen, eller brug 'Ikke angivet')",
  "phone": "Telefonnummer (find i samtalen, eller brug 'Ikke angivet')",
  "email": "Email adresse (find i samtalen, eller brug 'ikke@angivet.dk')",
  "address": "Fuld adresse (find i samtalen, eller brug 'Ikke angivet')",
  "job": "Type af job (f.eks. 'VVS Installation', 'Elektriker Arbejde', 'Snedker Job')",
  "assignment": "Detaljeret beskrivelse af opgaven baseret på samtalen (2-4 sætninger)",
  "preferredDates": ["Liste over ønskede datoer/tidspunkter som nævnt i samtalen"],
  "partsNeeded": [
    {
      "name": "Beskrivelse af materiale/del",
      "sku": "Generer et SKU nummer (f.eks. 'VVS-001')",
      "price": estimeret pris i DKK som nummer (f.eks. 500.0)
    }
  ],
  "totalEstimate": Total estimeret pris inkl. arbejdsløn (nummer i DKK),
  "notes": "Eventuelle ekstra noter, vigtige detaljer eller specielle krav fra samtalen"
}

VIGTIGE REGLER:
- ALLE priser skal være numre uden "kr" eller currency symboler
- Hvis information mangler, brug "Ikke angivet" for tekst felter
- Estimér realistiske danske priser for materialer og arbejde
- Inkluder arbejdsløn i totalEstimate (typisk 400-800 kr/time)
- Returner KUN valid JSON, ingen markdown, ingen forklaring
''';
  }

  Map<String, dynamic>? _parseGeminiResponse(String responseText) {
    try {
      // Fjern markdown kodeblokke hvis de findes
      String cleanedText = responseText.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      }
      if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      // Parse JSON
      final Map<String, dynamic> data = json.decode(cleanedText);

      // Validér at vi har de nødvendige felter
      if (!data.containsKey('customerName') || !data.containsKey('job')) {
        print('ERROR: Manglende required felter i Gemini response');
        return null;
      }

      return data;
    } catch (e) {
      print('ERROR: JSON parse fejl: $e');
      print('DEBUG: Response text var: $responseText');
      return null;
    }
  }

  Map<String, dynamic> _fallbackToMock(String transcription) {
    print('DEBUG: Bruger mock data fallback');
    final Map<String, dynamic> result = Map.from(mockAnalysisData);
    result['notes'] = 'TRANSCRIPTION: $transcription\n\n${mockAnalysisData['notes']}';
    return result;
  }

  @override
  Future<Map<String, dynamic>> extractDataFromUrl(String url) async {
    throw UnimplementedError('URL extraction not implemented for this service.');
  }
}