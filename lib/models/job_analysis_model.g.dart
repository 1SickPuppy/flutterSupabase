// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_analysis_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobAnalysisModel _$JobAnalysisModelFromJson(Map<String, dynamic> json) =>
    JobAnalysisModel(
      customerName: json['customerName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      job: json['job'] as String,
      assignment: json['assignment'] as String,
      preferredDates: (json['preferredDates'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      partsNeeded: (json['partsNeeded'] as List<dynamic>)
          .map((e) => PartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalEstimate: (json['totalEstimate'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$JobAnalysisModelToJson(JobAnalysisModel instance) =>
    <String, dynamic>{
      'customerName': instance.customerName,
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'job': instance.job,
      'assignment': instance.assignment,
      'preferredDates': instance.preferredDates,
      'partsNeeded': instance.partsNeeded.map((e) => e.toJson()).toList(),
      'totalEstimate': instance.totalEstimate,
      'notes': instance.notes,
    };

PartItem _$PartItemFromJson(Map<String, dynamic> json) => PartItem(
      name: json['name'] as String,
      sku: json['sku'] as String,
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$PartItemToJson(PartItem instance) => <String, dynamic>{
      'name': instance.name,
      'sku': instance.sku,
      'price': instance.price,
    };
