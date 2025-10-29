// lib/features/pdf_generation/presentation/pdf_generation_widget.dart

import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../domain/pdf_generation_service.dart';

class PdfGenerationWidget extends StatefulWidget {
  const PdfGenerationWidget({super.key});

  @override
  State<PdfGenerationWidget> createState() => _PdfGenerationWidgetState();
}

class _PdfGenerationWidgetState extends State<PdfGenerationWidget> {
  // Initialiseret senere for at undgå 'const' fejl
  late final PdfGenerationService _pdfGenerationService;

  @override
  void initState() {
    super.initState();
    // Henter servicen via getIt i initState
    _pdfGenerationService = getIt<PdfGenerationService>();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('PDF Generation Widget (Under udvikling)', style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
    );
  }
}