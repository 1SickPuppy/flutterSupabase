import 'package:flutter/material.dart';
import '../domain/data_extraction_service.dart';
import '../../../core/di/service_locator.dart';

class DataExtractionWidget extends StatefulWidget {
  const DataExtractionWidget({super.key});

  @override
  State<DataExtractionWidget> createState() => _DataExtractionWidgetState();
}

class _DataExtractionWidgetState extends State<DataExtractionWidget> {
  final DataExtractionService _dataExtractionService = dataExtractionService;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  Map<String, dynamic>? _extractionResult;
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _extractFromText() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _dataExtractionService.extractDataFromText(_textController.text);
      setState(() {
        _extractionResult = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _extractFromUrl() async {
    if (_urlController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _dataExtractionService.extractDataFromUrl(_urlController.text);
      setState(() {
        _extractionResult = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
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
            'Data Extraction',
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
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Indtast tekst til analyse',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _extractFromText,
                    child: const Text('Analyser tekst'),
                  ),
                ],
              ),
            ),
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
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Indtast URL til analyse',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _extractFromUrl,
                    child: const Text('Analyser URL'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_extractionResult != null)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resultat:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ..._extractionResult!.entries.map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text('${entry.key}: ${entry.value}'),
                        )),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Her kunne man sende data videre til PDF generation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data sendt til PDF generering')),
                        );
                      },
                      child: const Text('Generer PDF'),
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