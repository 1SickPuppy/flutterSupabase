import 'dart:typed_data';

// Interface for PDF generation service (følger Interface Segregation Principle)
abstract class PdfGenerationService {
  Future<Uint8List> generatePdfFromData(Map<String, dynamic> data);
  Future<String> savePdfToStorage(Uint8List pdfBytes, String fileName);

  // Convenience metode der kombinerer generering og gemning
  Future<Map<String, dynamic>> generatePdf(Map<String, dynamic> data);
}