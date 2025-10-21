// lib/models/job_analysis_model.dart

class PartNeeded {
  final String name;
  final String sku;
  final double price;

  PartNeeded({required this.name, required this.sku, required this.price});

  // En simpel factory til at konvertere Map til PartNeeded (til DataExtraction)
  factory PartNeeded.fromJson(Map<String, dynamic> json) {
    return PartNeeded(
      name: json['name'] as String,
      sku: json['sku'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }
}

class JobAnalysisModel {
  final String customerName;
  final String phone;
  final String email;
  final String address;
  final String job;
  final String assignment;
  final List<String> preferredDates;
  final List<PartNeeded> partsNeeded;
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

  // Factory constructor til at oprette modellen fra et JSON Map
  factory JobAnalysisModel.fromJson(Map<String, dynamic> json) {
    return JobAnalysisModel(
      customerName: json['customerName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      job: json['job'] as String,
      assignment: json['assignment'] as String,
      preferredDates: List<String>.from(json['preferredDates'] as List),

      partsNeeded: (json['partsNeeded'] as List)
          .map((item) => PartNeeded.fromJson(item as Map<String, dynamic>))
          .toList(),

      totalEstimate: (json['totalEstimate'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }
}