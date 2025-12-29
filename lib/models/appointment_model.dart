// lib/models/appointment_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'appointment_model.g.dart';

@JsonSerializable()
class AppointmentModel {
  final int? id;

  // Relations
  @JsonKey(name: 'job_analysis_id')
  final int? jobAnalysisId;

  @JsonKey(name: 'customer_id')
  final int? customerId;

  @JsonKey(name: 'user_email')
  final String userEmail;

  // Appointment detaljer
  final String title;
  final String? description;

  @JsonKey(name: 'start_time')
  final DateTime startTime;

  @JsonKey(name: 'end_time')
  final DateTime endTime;

  @JsonKey(name: 'estimated_duration_hours')
  final double? estimatedDurationHours;

  // Status tracking
  final String status; // 'planned', 'in_progress', 'awaiting_parts', 'completed', 'cancelled'

  // Quote/Tilbuds tracking
  @JsonKey(name: 'quote_status')
  final String quoteStatus; // 'draft', 'sent', 'accepted', 'rejected'

  @JsonKey(name: 'quote_sent_at')
  final DateTime? quoteSentAt;

  @JsonKey(name: 'quote_accepted_at')
  final DateTime? quoteAcceptedAt;

  @JsonKey(name: 'acceptance_token')
  final String? acceptanceToken;

  // Metadata
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  AppointmentModel({
    this.id,
    this.jobAnalysisId,
    this.customerId,
    required this.userEmail,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.estimatedDurationHours,
    this.status = 'planned',
    this.quoteStatus = 'draft',
    this.quoteSentAt,
    this.quoteAcceptedAt,
    this.acceptanceToken,
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentModelToJson(this);

  // Helper methods
  bool get isPlanned => status == 'planned';
  bool get isInProgress => status == 'in_progress';
  bool get isAwaitingParts => status == 'awaiting_parts';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  bool get isQuoteDraft => quoteStatus == 'draft';
  bool get isQuoteSent => quoteStatus == 'sent';
  bool get isQuoteAccepted => quoteStatus == 'accepted';
  bool get isQuoteRejected => quoteStatus == 'rejected';

  Duration get duration => endTime.difference(startTime);

  // Get status color for UI
  String get statusColor {
    switch (status) {
      case 'planned':
        return '#2196F3'; // Blue
      case 'in_progress':
        return '#FF9800'; // Orange
      case 'awaiting_parts':
        return '#FFC107'; // Yellow
      case 'completed':
        return '#4CAF50'; // Green
      case 'cancelled':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Get status display text (Danish)
  String get statusDisplay {
    switch (status) {
      case 'planned':
        return 'Planlagt';
      case 'in_progress':
        return 'I gang';
      case 'awaiting_parts':
        return 'Afventer dele';
      case 'completed':
        return 'Færdig';
      case 'cancelled':
        return 'Annulleret';
      default:
        return status;
    }
  }

  // Copy with method
  AppointmentModel copyWith({
    int? id,
    int? jobAnalysisId,
    int? customerId,
    String? userEmail,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    double? estimatedDurationHours,
    String? status,
    String? quoteStatus,
    DateTime? quoteSentAt,
    DateTime? quoteAcceptedAt,
    String? acceptanceToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      jobAnalysisId: jobAnalysisId ?? this.jobAnalysisId,
      customerId: customerId ?? this.customerId,
      userEmail: userEmail ?? this.userEmail,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      estimatedDurationHours: estimatedDurationHours ?? this.estimatedDurationHours,
      status: status ?? this.status,
      quoteStatus: quoteStatus ?? this.quoteStatus,
      quoteSentAt: quoteSentAt ?? this.quoteSentAt,
      quoteAcceptedAt: quoteAcceptedAt ?? this.quoteAcceptedAt,
      acceptanceToken: acceptanceToken ?? this.acceptanceToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
