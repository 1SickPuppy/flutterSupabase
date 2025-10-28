// lib/models/job_analysis_model.dart

// Vigtigt: Du skal have 'json_annotation' i din pubspec.yaml
import 'package:json_annotation/json_annotation.dart';

part 'job_analysis_model.g.dart';

@JsonSerializable(explicitToJson: true)
class JobAnalysisModel {
  final String customerName;
  final String phone;
  final String email;
  final String address;
  final String job;
  final String assignment;
  final List<String> preferredDates;
  final List<PartItem> partsNeeded;
  final double totalEstimate;
  final String? notes;

  JobAnalysisModel({
    required this.customerName,
    required this.phone,
    required this.email,
    required this.address,
    required this.job,
    required this.assignment,
    required this.preferredDates,
    required this.partsNeeded,
    required this.totalEstimate,
    this.notes,
  });

  factory JobAnalysisModel.fromJson(Map<String, dynamic> json) => _$JobAnalysisModelFromJson(json);
  Map<String, dynamic> toJson() => _$JobAnalysisModelToJson(this);
}

@JsonSerializable()
class PartItem {
  final String name;
  final String sku;
  final double price;

  PartItem({
    required this.name,
    required this.sku,
    required this.price,
  });

  factory PartItem.fromJson(Map<String, dynamic> json) => _$PartItemFromJson(json);
  Map<String, dynamic> toJson() => _$PartItemToJson(this);
}