import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../domain/pdf_generation_service.dart';

class PdfGenerationServiceImpl implements PdfGenerationService {
  @override
  Future<Uint8List> generatePdfFromData(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('DeveloperCat DK - Rapport', 
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Genereret: ${DateTime.now().toString()}'),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              // Dynamisk indhold baseret på data
              ...data.entries.map((entry) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${entry.key}: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Expanded(
                      child: pw.Text(entry.value.toString()),
                    ),
                  ],
                ),
              )),
              
              pw.SizedBox(height: 40),
              pw.Footer(
                title: pw.Text('© DeveloperCat DK ${DateTime.now().year}'),
              ),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }

  @override
  Future<String> savePdfToStorage(Uint8List pdfBytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);
      return file.path;
    } catch (e) {
      throw Exception('Kunne ikke gemme PDF: ${e.toString()}');
    }
  }
}