// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) =>
    AppointmentModel(
      id: (json['id'] as num?)?.toInt(),
      jobAnalysisId: (json['job_analysis_id'] as num?)?.toInt(),
      customerId: (json['customer_id'] as num?)?.toInt(),
      userEmail: json['user_email'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      estimatedDurationHours:
          (json['estimated_duration_hours'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'planned',
      quoteStatus: json['quote_status'] as String? ?? 'draft',
      quoteSentAt: json['quote_sent_at'] == null
          ? null
          : DateTime.parse(json['quote_sent_at'] as String),
      quoteAcceptedAt: json['quote_accepted_at'] == null
          ? null
          : DateTime.parse(json['quote_accepted_at'] as String),
      acceptanceToken: json['acceptance_token'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AppointmentModelToJson(AppointmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'job_analysis_id': instance.jobAnalysisId,
      'customer_id': instance.customerId,
      'user_email': instance.userEmail,
      'title': instance.title,
      'description': instance.description,
      'location': instance.location,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'estimated_duration_hours': instance.estimatedDurationHours,
      'status': instance.status,
      'quote_status': instance.quoteStatus,
      'quote_sent_at': instance.quoteSentAt?.toIso8601String(),
      'quote_accepted_at': instance.quoteAcceptedAt?.toIso8601String(),
      'acceptance_token': instance.acceptanceToken,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
