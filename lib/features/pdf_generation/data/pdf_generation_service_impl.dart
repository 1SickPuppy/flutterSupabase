// lib/features/pdf_generation/data/pdf_generation_service_impl.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart'; // ⭐️ VIGTIGT: Tilføj denne import! ⭐️

import '../../pdf_generation/domain/pdf_generation_service.dart';

/// Implementering af PdfGenerationService, der bruger 'pdf' pakken.
class PdfGenerationServiceImpl implements PdfGenerationService {

  // Dansk valutaformatering
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'da_DK',
    symbol: 'DKK',
    decimalDigits: 2,
  );

  @override
  Future<Uint8List> generatePdfFromData(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // Henter data fra Map
    final List<dynamic> parts = data['partsNeeded'] as List<dynamic>;
    final double totalEstimate = data['totalEstimate'] as double;
    final String customerName = data['customerName'] as String;

    // --- Bygger PDF-dokumentets struktur (Med Valuta og Tabel) ---
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Tilbud: ${data['job']}',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),

              // --- Kundedetaljer ---
              pw.Text('Kundenavn: $customerName'),
              pw.Text('Adresse: ${data['address']}'),
              pw.Text('Tlf: ${data['phone']} | Email: ${data['email']}'),
              pw.SizedBox(height: 20),

              // --- Opgavebeskrivelse ---
              pw.Divider(),
              pw.Text(
                'Opgavebeskrivelse:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(data['assignment'] as String),
              pw.SizedBox(height: 20),

              // --- Dele og Estimater (Tabel) ---
              pw.Divider(),
              pw.Text(
                'Materialer & Estimat:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Vare', 'Antal', 'Pris pr. stk.', 'Total'],
                  ...parts.map((p) => [
                    p['name'] as String,
                    '1',
                    _currencyFormat.format(p['price']), // ⭐️ Formatering her
                    _currencyFormat.format(p['price']),
                  ]),
                  // Mock Arbejdsløn
                  <String>['Arbejdsløn (Estimeret)', '', '', _currencyFormat.format(1500.0)],
                  // Total
                  <String>['', '', 'TOTAL (DKK)', _currencyFormat.format(totalEstimate)],
                ],
                cellStyle: const pw.TextStyle(fontSize: 10),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                border: null,
              ),

              // --- Noter ---
              pw.SizedBox(height: 30),
              if (data['notes'] != null && (data['notes'] as String).isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Noter:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(data['notes'] as String),
                  ],
                ),

              pw.Spacer(),
              pw.Center(
                child: pw.Text('Med venlig hilsen, DeveloperCat DK.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              )
            ],
          );
        },
      ),
    );

    // Returnerer PDF som bytes
    return pdf.save();
  }

  // savePdfToStorage forbliver den samme:
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