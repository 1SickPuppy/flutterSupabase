// lib/features/quote/data/quote_service_impl.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../../models/job_analysis_model.dart';
import '../../../models/appointment_model.dart';
import '../domain/quote_service.dart';
import '../../data_extraction/domain/job_analysis_repository.dart';
import '../../calendar/domain/appointment_service.dart';

// Conditional import for web-only functionality
import 'package:universal_html/html.dart' as html show window;

class QuoteServiceImpl implements QuoteService {
  final _supabase = Supabase.instance.client;
  final JobAnalysisRepository _jobAnalysisRepo;
  final AppointmentService _appointmentService;
  final _uuid = const Uuid();

  QuoteServiceImpl(this._jobAnalysisRepo, this._appointmentService);

  @override
  Future<Map<String, dynamic>> sendQuote({
    required JobAnalysisModel jobAnalysis,
    required DateTime proposedDate,
    String? pdfPath,
  }) async {
    try {
      final userEmail = _supabase.auth.currentUser?.email;
      if (userEmail == null) {
        return {
          'success': false,
          'error': 'Bruger ikke logget ind',
        };
      }

      // 1. Save job analysis
      final saveResult = await _jobAnalysisRepo.saveJobAnalysis(jobAnalysis);
      if (saveResult['success'] != true) {
        return saveResult;
      }

      final jobAnalysisId = saveResult['id'] as int;

      // 2. Generate acceptance token
      final acceptanceToken = _uuid.v4();

      // 3. Create appointment with quote status 'sent'
      final appointment = AppointmentModel(
        jobAnalysisId: jobAnalysisId,
        userEmail: userEmail,
        title: 'Tilbud: ${jobAnalysis.job}',
        description: jobAnalysis.assignment,
        location: jobAnalysis.address,
        startTime: proposedDate,
        endTime: proposedDate.add(const Duration(hours: 2)), // Default 2 timer
        status: 'planned',
        quoteStatus: 'sent',
        quoteSentAt: DateTime.now(),
        acceptanceToken: acceptanceToken,
      );

      final appointmentResult = await _appointmentService.createAppointment(appointment);
      if (appointmentResult['success'] != true) {
        return appointmentResult;
      }

      // 4. Generate mailto URL
      final mailtoUrl = generateQuoteEmail(
        customerEmail: jobAnalysis.email,
        customerName: jobAnalysis.customerName,
        jobDescription: jobAnalysis.job,
        totalEstimate: jobAnalysis.totalEstimate,
        acceptanceToken: acceptanceToken,
      );

      // 5. Open mailto link (cross-platform)
      final uri = Uri.parse(mailtoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        return {
          'success': false,
          'error': 'Kunne ikke åbne email-klient',
        };
      }

      return {
        'success': true,
        'jobAnalysisId': jobAnalysisId,
        'appointmentId': (appointmentResult['appointment'] as AppointmentModel).id,
        'acceptanceToken': acceptanceToken,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  String generateQuoteEmail({
    required String customerEmail,
    required String customerName,
    required String jobDescription,
    required double totalEstimate,
    required String acceptanceToken,
  }) {
    // Generate accept/reject URLs (these would be your app's URLs)
    // For web, use current origin; for mobile, use configured base URL
    final baseUrl = kIsWeb
        ? html.window.location.origin
        : const String.fromEnvironment('APP_BASE_URL', defaultValue: 'https://developercatdk.com');
    final acceptUrl = '$baseUrl/quote/accept/$acceptanceToken';
    final rejectUrl = '$baseUrl/quote/reject/$acceptanceToken';

    final subject = Uri.encodeComponent('Tilbud: $jobDescription');
    final body = Uri.encodeComponent('''
Hej $customerName,

Tak for din henvendelse om $jobDescription.

Vi har udarbejdet et tilbud til dig:

Samlet pris: ${totalEstimate.toStringAsFixed(2)} DKK

Du kan acceptere eller afvise tilbuddet ved at klikke på et af nedenstående links:

✅ Acceptér tilbud: $acceptUrl

❌ Afvis tilbud: $rejectUrl

Hvis du har spørgsmål, er du velkommen til at kontakte os.

Med venlig hilsen
DeveloperCat DK
''');

    return 'mailto:$customerEmail?subject=$subject&body=$body';
  }

  @override
  Future<Map<String, dynamic>> acceptQuote(String token) async {
    try {
      // Find appointment by token
      final appointment = await getAppointmentByToken(token);
      if (appointment == null) {
        return {
          'success': false,
          'error': 'Tilbud ikke fundet',
        };
      }

      // Update quote status to 'accepted'
      final result = await _appointmentService.updateQuoteStatus(
        appointment.id!,
        'accepted',
      );

      if (result['success'] == true) {
        // Also update quote_accepted_at timestamp
        await _supabase
            .from('appointments')
            .update({
              'quote_accepted_at': DateTime.now().toIso8601String(),
            })
            .eq('id', appointment.id!);

        return {
          'success': true,
          'message': 'Tilbud accepteret! Vi kontakter dig snarest.',
          'appointment': result['appointment'],
        };
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> rejectQuote(String token) async {
    try {
      // Find appointment by token
      final appointment = await getAppointmentByToken(token);
      if (appointment == null) {
        return {
          'success': false,
          'error': 'Tilbud ikke fundet',
        };
      }

      // Update quote status to 'rejected'
      final result = await _appointmentService.updateQuoteStatus(
        appointment.id!,
        'rejected',
      );

      if (result['success'] == true) {
        return {
          'success': true,
          'message': 'Tilbud afvist. Tak for din besked.',
        };
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<AppointmentModel?> getAppointmentByToken(String token) async {
    try {
      final response = await _supabase
          .from('appointments')
          .select()
          .eq('acceptance_token', token)
          .maybeSingle();

      if (response == null) return null;

      return AppointmentModel.fromJson(response);
    } catch (e) {
      print('Error getting appointment by token: $e');
      return null;
    }
  }
}
