// lib/features/calendar/data/appointment_service_impl.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/appointment_model.dart';
import '../domain/appointment_service.dart';

class AppointmentServiceImpl implements AppointmentService {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<AppointmentModel>> getAllAppointments() async {
    try {
      final userEmail = _supabase.auth.currentUser?.email;
      if (userEmail == null) return [];

      final response = await _supabase
          .from('appointments')
          .select('*')
          .eq('user_email', userEmail)
          .order('start_time', ascending: true);

      return (response as List)
          .map((json) => AppointmentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting all appointments: $e');
      return [];
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final userEmail = _supabase.auth.currentUser?.email;
      if (userEmail == null) return [];

      final response = await _supabase
          .from('appointments')
          .select('*')
          .eq('user_email', userEmail)
          .gte('start_time', startDate.toIso8601String())
          .lte('start_time', endDate.toIso8601String())
          .order('start_time', ascending: true);

      return (response as List)
          .map((json) => AppointmentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting appointments by date range: $e');
      return [];
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByCustomer(int customerId) async {
    try {
      final userEmail = _supabase.auth.currentUser?.email;
      if (userEmail == null) return [];

      final response = await _supabase
          .from('appointments')
          .select('*')
          .eq('user_email', userEmail)
          .eq('customer_id', customerId)
          .order('start_time', ascending: true);

      return (response as List)
          .map((json) => AppointmentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting appointments by customer: $e');
      return [];
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByJobAnalysis(int jobAnalysisId) async {
    try {
      final userEmail = _supabase.auth.currentUser?.email;
      if (userEmail == null) return [];

      final response = await _supabase
          .from('appointments')
          .select('*')
          .eq('user_email', userEmail)
          .eq('job_analysis_id', jobAnalysisId)
          .order('start_time', ascending: true);

      return (response as List)
          .map((json) => AppointmentModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting appointments by job analysis: $e');
      return [];
    }
  }

  @override
  Future<AppointmentModel?> getAppointmentById(int id) async {
    try {
      final response = await _supabase
          .from('appointments')
          .select('*')
          .eq('id', id)
          .single();

      return AppointmentModel.fromJson(response);
    } catch (e) {
      print('Error getting appointment by ID: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> createAppointment(AppointmentModel appointment) async {
    try {
      final userEmail = _supabase.auth.currentUser?.email;
      if (userEmail == null) {
        return {
          'success': false,
          'error': 'Bruger ikke logget ind',
        };
      }

      final data = appointment.toJson();
      // Remove id and timestamps, let database handle them
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');
      // Ensure user_email is set
      data['user_email'] = userEmail;

      final response = await _supabase
          .from('appointments')
          .insert(data)
          .select()
          .single();

      return {
        'success': true,
        'appointment': AppointmentModel.fromJson(response),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> updateAppointment(int id, AppointmentModel appointment) async {
    try {
      final data = appointment.toJson();
      // Remove id, timestamps, and user_email (don't allow changing user)
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');
      data.remove('user_email');

      final response = await _supabase
          .from('appointments')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return {
        'success': true,
        'appointment': AppointmentModel.fromJson(response),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> deleteAppointment(int id) async {
    try {
      await _supabase
          .from('appointments')
          .delete()
          .eq('id', id);

      return {
        'success': true,
        'message': 'Aftale slettet',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> updateAppointmentStatus(int id, String status) async {
    try {
      final response = await _supabase
          .from('appointments')
          .update({'status': status})
          .eq('id', id)
          .select()
          .single();

      return {
        'success': true,
        'appointment': AppointmentModel.fromJson(response),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> updateQuoteStatus(int id, String quoteStatus) async {
    try {
      final response = await _supabase
          .from('appointments')
          .update({'quote_status': quoteStatus})
          .eq('id', id)
          .select()
          .single();

      return {
        'success': true,
        'appointment': AppointmentModel.fromJson(response),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, int>> getAppointmentCountsByStatus() async {
    try {
      final userEmail = _supabase.auth.currentUser?.email;
      if (userEmail == null) return {};

      final appointments = await getAllAppointments();

      final Map<String, int> counts = {
        'planned': 0,
        'in_progress': 0,
        'awaiting_parts': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (final appointment in appointments) {
        final status = appointment.status;
        counts[status] = (counts[status] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      print('Error getting appointment counts by status: $e');
      return {};
    }
  }
}
