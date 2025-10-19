import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/data_extraction_service.dart';

class DataExtractionWidget extends StatefulWidget {
  const DataExtractionWidget({Key? key}) : super(key: key);

  @override
  State<DataExtractionWidget> createState() => _DataExtractionWidgetState();
}

class _DataExtractionWidgetState extends State<DataExtractionWidget> {
  final _textController = TextEditingController();
  String _extractedData = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataService = context.read<DataExtractionService>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Data Extraction',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Enter text to analyze',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() => _isLoading = true);
                    try {
                      final result = await dataService.extractData(_textController.text);
                      setState(() => _extractedData = result);
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Extract Data'),
          ),
          if (_extractedData.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Extracted Data:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(_extractedData),
          ],
        ],
      ),
    );
  }
}