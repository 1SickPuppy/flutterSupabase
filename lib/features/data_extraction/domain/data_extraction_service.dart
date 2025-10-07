// Interface for data extraction service (følger Interface Segregation Principle)
abstract class DataExtractionService {
  Future<Map<String, dynamic>> extractDataFromText(String text);
  Future<Map<String, dynamic>> extractDataFromUrl(String url);
}