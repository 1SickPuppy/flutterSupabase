// lib/features/data_extraction/presentation/data_extraction_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../job_flow/job_flow_notifier.dart';

class DataExtractionWidget extends StatelessWidget {
  const DataExtractionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Lytter til notifieren for at hente data
    final notifier = Provider.of<JobFlowNotifier>(context);
    final data = notifier.extractedData;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Udtrukne Data',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                data.isEmpty
                    ? 'Ingen data analyseret endnu.'
                    : data,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}