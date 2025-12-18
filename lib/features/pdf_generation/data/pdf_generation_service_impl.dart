// lib/features/pdf_generation/data/pdf_generation_service_impl.dart

import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

import '../../pdf_generation/domain/pdf_generation_service.dart';

/// Implementering af PdfGenerationService, der bruger 'pdf' pakken.
class PdfGenerationServiceImpl implements PdfGenerationService {

  // Dansk valutaformatering
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'da_DK',
    symbol: 'DKK',
    decimalDigits: 2,
  );

  // Helper function to remove Danish characters for PDF compatibility
  String _sanitizeText(String text) {
    return text
        .replaceAll('æ', 'ae')
        .replaceAll('ø', 'o')
        .replaceAll('å', 'aa')
        .replaceAll('Æ', 'AE')
        .replaceAll('Ø', 'O')
        .replaceAll('Å', 'AA');
  }

  @override
  Future<Uint8List> generatePdfFromData(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // Henter data fra Map og saniterer for PDF
    final List<dynamic> parts = data['partsNeeded'] as List<dynamic>;
    final double totalEstimate = data['totalEstimate'] as double;
    final String customerName = _sanitizeText(data['customerName'] as String);

    // Sanitize all text to avoid Unicode issues
    final String job = _sanitizeText(data['job'] as String);
    final String address = _sanitizeText(data['address'] as String);
    final String phone = data['phone'] as String;
    final String email = data['email'] as String;
    final String assignment = _sanitizeText(data['assignment'] as String);
    final String notes = data['notes'] != null ? _sanitizeText(data['notes'] as String) : '';

    // --- Bygger PDF-dokumentets struktur (Med Valuta og Tabel) ---
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('TILBUD: $job'),
              pw.Text(''),
              pw.Text(''),

              // --- Kundedetaljer ---
              pw.Text('Kundenavn: $customerName'),
              pw.Text('Adresse: $address'),
              pw.Text('Tlf: $phone | Email: $email'),
              pw.Text(''),
              pw.Text(''),

              // --- Opgavebeskrivelse ---
              pw.Text('----------------------------------------'),
              pw.Text('Opgavebeskrivelse:'),
              pw.Text(assignment),
              pw.Text(''),
              pw.Text(''),

              // --- Dele og Estimater (Simple list instead of table) ---
              pw.Text('----------------------------------------'),
              pw.Text('Materialer & Estimat:'),
              pw.Text(''),
              pw.Text('Vare | Antal | Pris pr. stk. | Total'),
              pw.Text('----------------------------------------'),
              ...parts.map((p) => pw.Text(
                '${_sanitizeText(p['name'] as String)} | 1 | ${(p['price'] as num).toStringAsFixed(2)} kr | ${(p['price'] as num).toStringAsFixed(2)} kr'
              )),
              pw.Text(''),
              pw.Text('Arbejdslon (Estimeret) | | | ${1500.0.toStringAsFixed(2)} kr'),
              pw.Text('========================================'),
              pw.Text('TOTAL (DKK): ${totalEstimate.toStringAsFixed(2)} kr'),

              // --- Noter ---
              pw.Text(''),
              pw.Text(''),
              if (notes.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Noter:'),
                    pw.Text(notes),
                  ],
                ),

              pw.SizedBox(height: 50),
              pw.Text('              Med venlig hilsen, DeveloperCat DK.')
            ],
          );
        },
      ),
    );

    // Returnerer PDF som bytes
    return pdf.save();
  }

  @override
  Future<String> savePdfToStorage(Uint8List pdfBytes, String fileName) async {
    try {
      if (kIsWeb) {
        // Web: Trigger browser download using universal_html
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        return 'Downloaded: $fileName';
      } else {
        // Mobile: Save to file system
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(pdfBytes);
        return file.path;
      }
    } catch (e) {
      throw Exception('Kunne ikke gemme PDF: ${e.toString()}');
    }
  }

  // Convenience metode der kombinerer generering og gemning
  @override
  Future<Map<String, dynamic>> generatePdf(Map<String, dynamic> data) async {
    try {
      // Genererer PDF bytes
      final pdfBytes = await generatePdfFromData(data);

      // Laver filnavn baseret på kundenavn og timestamp (sanitized for file system)
      final customerName = _sanitizeText(data['customerName'] as String? ?? 'kunde');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'tilbud_${customerName.replaceAll(' ', '_')}_$timestamp.pdf';

      // Gemmer til storage
      final path = await savePdfToStorage(pdfBytes, fileName);

      return {
        'success': true,
        'path': path,
        'fileName': fileName,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Fejl ved PDF generering: ${e.toString()}',
      };
    }
  }
}