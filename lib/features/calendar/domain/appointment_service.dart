// lib/features/calendar/domain/appointment_service.dart

import '../../../models/appointment_model.dart';

abstract class AppointmentService {
  /// Get all appointments for the authenticated user
  Future<List<AppointmentModel>> getAllAppointments();

  /// Get appointments for a specific date range
  Future<List<AppointmentModel>> getAppointmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get appointments for a specific customer
  Future<List<AppointmentModel>> getAppointmentsByCustomer(int customerId);

  /// Get appointments for a specific job analysis
  Future<List<AppointmentModel>> getAppointmentsByJobAnalysis(int jobAnalysisId);

  /// Get appointment by ID
  Future<AppointmentModel?> getAppointmentById(int id);

  /// Create a new appointment
  Future<Map<String, dynamic>> createAppointment(AppointmentModel appointment);

  /// Update an existing appointment
  Future<Map<String, dynamic>> updateAppointment(int id, AppointmentModel appointment);

  /// Delete an appointment
  Future<Map<String, dynamic>> deleteAppointment(int id);

  /// Update appointment status
  Future<Map<String, dynamic>> updateAppointmentStatus(int id, String status);

  /// Update quote status
  Future<Map<String, dynamic>> updateQuoteStatus(int id, String quoteStatus);

  /// Get appointments count by status
  Future<Map<String, int>> getAppointmentCountsByStatus();
}
