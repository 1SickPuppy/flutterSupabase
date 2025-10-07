import 'package:http/http.dart' as http;
import '../domain/data_extraction_service.dart';

class DataExtractionServiceImpl implements DataExtractionService {
  @override
  Future<Map<String, dynamic>> extractDataFromText(String text) async {
    // Simpel implementering af tekstanalyse
    // I en rigtig applikation ville dette bruge NLP eller en API
    final result = <String, dynamic>{
      'text': text,
      'wordCount': text.split(' ').length,
      'characters': text.length,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    return result;
  }

  @override
  Future<Map<String, dynamic>> extractDataFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Simpel implementering - i en rigtig app ville dette bruge en HTML parser
        return {
          'url': url,
          'content': response.body.substring(0, 1000), // Første 1000 tegn
          'contentLength': response.contentLength,
          'statusCode': response.statusCode,
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        return {
          'error': 'Failed to load URL',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}