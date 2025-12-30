// lib/features/quote/domain/quote_service.dart

import '../../../models/job_analysis_model.dart';
import '../../../models/appointment_model.dart';

abstract class QuoteService {
  /// Send a quote via email
  /// Saves job analysis, creates appointment, generates token, and opens mailto
  Future<Map<String, dynamic>> sendQuote({
    required JobAnalysisModel jobAnalysis,
    required DateTime proposedDate,
    String? pdfPath,
  });

  /// Handle quote acceptance via token
  Future<Map<String, dynamic>> acceptQuote(String token);

  /// Handle quote rejection via token
  Future<Map<String, dynamic>> rejectQuote(String token);

  /// Get appointment by acceptance token
  Future<AppointmentModel?> getAppointmentByToken(String token);

  /// Generate mailto URL for quote
  String generateQuoteEmail({
    required String customerEmail,
    required String customerName,
    required String jobDescription,
    required double totalEstimate,
    required String acceptanceToken,
  });
}
