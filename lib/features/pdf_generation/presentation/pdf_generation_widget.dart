// lib/features/pdf_generation/presentation/pdf_generation_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../job_flow/job_flow_notifier.dart';

class PdfGenerationWidget extends StatelessWidget {
  const PdfGenerationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JobFlowNotifier>(context);
    final jobAnalysis = notifier.jobAnalysis;
    final isGeneratingPdf = notifier.isGeneratingPdf;
    final pdfPath = notifier.pdfPath;
    final errorMessage = notifier.errorMessage;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PDF Generering',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),

          // Loading indicator
          if (isGeneratingPdf)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Genererer PDF...', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

          // Error message
          if (errorMessage != null && !isGeneratingPdf && pdfPath == null)
            Expanded(
              child: Center(
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => notifier.generatePdf(),
                      child: const Text('Prøv igen'),
                    ),
                  ],
                ),
              ),
            ),

          // No data message
          if (jobAnalysis == null && !isGeneratingPdf)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Ingen data at generere PDF fra.\nAnalyser først en samtale.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // PDF success message
          if (pdfPath != null && !isGeneratingPdf)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 64, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      'PDF genereret med succes!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SelectableText(
                        pdfPath,
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Generer Ny PDF'),
                      onPressed: () => notifier.generatePdf(),
                    ),
                  ],
                ),
              ),
            ),

          // PDF Preview when data exists but no PDF generated yet
          if (jobAnalysis != null && pdfPath == null && !isGeneratingPdf && errorMessage == null)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.preview, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'PDF Preview',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const Divider(height: 30),

                            // Titel
                            Text(
                              'Tilbud: ${jobAnalysis.job}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            // Kundedetaljer
                            Text('Kundenavn: ${jobAnalysis.customerName}'),
                            Text('Adresse: ${jobAnalysis.address}'),
                            Text('Tlf: ${jobAnalysis.phone} | Email: ${jobAnalysis.email}'),
                            const SizedBox(height: 16),

                            // Opgavebeskrivelse
                            const Divider(),
                            const Text(
                              'Opgavebeskrivelse:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(jobAnalysis.assignment),
                            const SizedBox(height: 16),

                            // Materialer & Estimat
                            const Divider(),
                            const Text(
                              'Materialer & Estimat:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Table(
                              border: TableBorder.all(color: Colors.grey.shade300),
                              columnWidths: const {
                                0: FlexColumnWidth(3),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(2),
                                3: FlexColumnWidth(2),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(color: Colors.grey.shade200),
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Vare', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Antal', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Pris pr. stk.', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('1'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(formatter.format(part.price)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(formatter.format(part.price)),
                                      ),
                                    ],
                                  );
                                }).toList(),
                                TableRow(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Arbejdsløn (Estimeret)', style: TextStyle(fontStyle: FontStyle.italic)),
                                    ),
                                    const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                                    const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(NumberFormat.currency(locale: 'da_DK', symbol: 'kr').format(1500.0)),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  decoration: BoxDecoration(color: Colors.green.shade50),
                                  children: [
                                    const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                                    const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('TOTAL (DKK)', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        NumberFormat.currency(locale: 'da_DK', symbol: 'kr').format(jobAnalysis.totalEstimate),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Noter
                            if (jobAnalysis.notes != null && jobAnalysis.notes!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const Text(
                                'Noter:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(jobAnalysis.notes!),
                            ],

                            const SizedBox(height: 20),
                            const Center(
                              child: Text(
                                'Med venlig hilsen, DeveloperCat DK.',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Generer PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        onPressed: () => notifier.generatePdf(),
                      ),
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