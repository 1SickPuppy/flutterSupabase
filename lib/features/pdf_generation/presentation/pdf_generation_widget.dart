import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/pdf_generation_service.dart';

class PdfGenerationWidget extends StatefulWidget {
  const PdfGenerationWidget({super.key});

  @override
  State<PdfGenerationWidget> createState() => _PdfGenerationWidgetState();
}

class _PdfGenerationWidgetState extends State<PdfGenerationWidget> {
  final _contentController = TextEditingController();
  bool _isGenerating = false;
  String _status = '';

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pdfService = context.read<PdfGenerationService>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'PDF Generation',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Enter content for PDF',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isGenerating
                ? null
                : () async {
                    setState(() {
                      _isGenerating = true;
                      _status = 'Generating PDF...';
                    });
                    try {
                      final filePath = await pdfService.generatePdf(_contentController.text);
                      setState(() => _status = 'PDF saved to: $filePath');
                    } catch (e) {
                      setState(() => _status = 'Error: ${e.toString()}');
                    } finally {
                      setState(() => _isGenerating = false);
                    }
                  },
            child: _isGenerating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Generate PDF'),
          ),
          if (_status.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              _status,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}