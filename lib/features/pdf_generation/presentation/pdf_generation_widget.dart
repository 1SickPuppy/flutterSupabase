import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../domain/pdf_generation_service.dart';
import '../../../core/di/service_locator.dart';

class PdfGenerationWidget extends StatefulWidget {
  const PdfGenerationWidget({Key? key}) : super(key: key);

  @override
  State<PdfGenerationWidget> createState() => _PdfGenerationWidgetState();
}

class _PdfGenerationWidgetState extends State<PdfGenerationWidget> {
  final PdfGenerationService _pdfService = pdfGenerationService;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isGenerating = false;
  String? _pdfPath;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _generatePdf() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Udfyld venligst både titel og indhold')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Opret data til PDF
      final data = {
        'title': _titleController.text,
        'content': _contentController.text,
        'timestamp': DateTime.now().toString(),
      };

      // Generer PDF
      final Uint8List pdfBytes = await _pdfService.generatePdfFromData(data);
      
      // Gem PDF
      final fileName = 'rapport_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final path = await _pdfService.savePdfToStorage(pdfBytes, fileName);
      
      setState(() {
        _pdfPath = path;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF gemt: $path')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl ved generering af PDF: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'PDF Generation',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titel',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Indhold',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generatePdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Generer PDF'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_isGenerating)
            const Center(child: CircularProgressIndicator())
          else if (_pdfPath != null)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PDF genereret:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(_pdfPath!),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Her kunne man åbne PDF'en
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Åbner PDF...')),
                        );
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Åbn PDF'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}