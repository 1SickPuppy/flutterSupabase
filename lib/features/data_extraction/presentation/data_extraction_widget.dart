// lib/features/data_extraction/presentation/data_extraction_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../job_flow/job_flow_notifier.dart';

class DataExtractionWidget extends StatelessWidget {
  const DataExtractionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JobFlowNotifier>(context);
    final jobAnalysis = notifier.jobAnalysis;
    final isExtracting = notifier.isExtracting;
    final errorMessage = notifier.errorMessage;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Udtrukne Data',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (jobAnalysis != null)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => notifier.clearData(),
                  tooltip: 'Ryd data',
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Loading indicator
          if (isExtracting)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyserer data...', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

          // Error message
          if (errorMessage != null && !isExtracting)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // No data message
          if (jobAnalysis == null && !isExtracting && errorMessage == null)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Ingen data analyseret endnu.\nBrug Stemme Input til at optage en samtale.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Display structured data
          if (jobAnalysis != null && !isExtracting)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      'Kunde Information',
                      Icons.person,
                      [
                        _buildDataRow('Navn', jobAnalysis.customerName),
                        _buildDataRow('Telefon', jobAnalysis.phone),
                        _buildDataRow('Email', jobAnalysis.email),
                        _buildDataRow('Adresse', jobAnalysis.address),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      'Job Detaljer',
                      Icons.work,
                      [
                        _buildDataRow('Job Type', jobAnalysis.job),
                        _buildDataRow('Opgave', jobAnalysis.assignment, isLong: true),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      'Ønskede Datoer',
                      Icons.calendar_today,
                      jobAnalysis.preferredDates
                          .map((date) => Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Text(date),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      'Materialer & Dele',
                      Icons.hardware,
                      [
                        Table(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columnWidths: const {
                            0: FlexColumnWidth(3),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(color: Colors.grey.shade200),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Del', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('SKU', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Pris', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            ...jobAnalysis.partsNeeded.map((part) {
                              final formatter = NumberFormat.currency(locale: 'da_DK', symbol: 'kr');
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(part.name),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(part.sku),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(formatter.format(part.price)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context,
                      'Estimat',
                      Icons.attach_money,
                      [
                        Card(
                          color: Colors.green.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Samlet Estimat:',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  NumberFormat.currency(locale: 'da_DK', symbol: 'kr')
                                      .format(jobAnalysis.totalEstimate),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (jobAnalysis.notes != null && jobAnalysis.notes!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSection(
                        context,
                        'Noter',
                        Icons.note,
                        [
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Text(
                              jobAnalysis.notes!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Generer PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              notifier.generatePdf();
                              // Switch to PDF tab
                              notifier.setSelectedIndex(2);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Gem til Supabase'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              // TODO: Implement Supabase save
                              notifier.setSelectedIndex(3);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDataRow(String label, String value, {bool isLong = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: isLong
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    '$label:',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Expanded(
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
    );
  }
}