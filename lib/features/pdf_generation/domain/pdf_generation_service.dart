import 'dart:typed_data';

// Interface for PDF generation service (følger Interface Segregation Principle)
abstract class PdfGenerationService {
  Future<Uint8List> generatePdfFromData(Map<String, dynamic> data);
  Future<String> savePdfToStorage(Uint8List pdfBytes, String fileName);
  Future<String> generatePdf(Map<String, dynamic> offerData);
}