// lib\features\pdf_generation\presentation\pdf_generation_widget.dart

import 'package:flutter/material.dart';
import '../domain/pdf_generation_service.dart';
import '../../../core/di/service_locator.dart'; // ⭐️ RETTELSE: Importerer GetIt

class PdfGenerationWidget extends StatelessWidget {
  // ⭐️ RETTELSE: Henter service via getIt<T>() ⭐️
  final PdfGenerationService _pdfGenerationService = getIt<PdfGenerationService>();

  const PdfGenerationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder UI
    return const Center(
      child: Text('PDF Generation Widget (Ready)'),
    );
  }
}