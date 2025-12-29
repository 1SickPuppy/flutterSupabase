// lib/models/customer_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class CustomerModel {
  final int? id;

  @JsonKey(name: 'customer_number')
  final String? customerNumber;

  final String name;
  final String? category; // 'Erhverv', 'Privat', 'Offentlig'

  // Kontakt information
  final String? address;
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  final String? city;
  final String? phone;
  final String? mobile;
  final String? email;

  // Firma information
  @JsonKey(name: 'cvr_number')
  final String? cvrNumber;

  // Faktura information
  @JsonKey(name: 'invoice_name')
  final String? invoiceName;
  @JsonKey(name: 'invoice_address')
  final String? invoiceAddress;
  @JsonKey(name: 'invoice_postal_code')
  final String? invoicePostalCode;
  @JsonKey(name: 'invoice_city')
  final String? invoiceCity;
  @JsonKey(name: 'invoice_email')
  final String? invoiceEmail;
  @JsonKey(name: 'invoice_phone')
  final String? invoicePhone;
  @JsonKey(name: 'payment_terms')
  final String? paymentTerms;

  // Kontaktperson
  @JsonKey(name: 'contact_person')
  final String? contactPerson;

  // Ekstra
  final String? notes;

  // Metadata
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  CustomerModel({
    this.id,
    this.customerNumber,
    required this.name,
    this.category,
    this.address,
    this.postalCode,
    this.city,
    this.phone,
    this.mobile,
    this.email,
    this.cvrNumber,
    this.invoiceName,
    this.invoiceAddress,
    this.invoicePostalCode,
    this.invoiceCity,
    this.invoiceEmail,
    this.invoicePhone,
    this.paymentTerms,
    this.contactPerson,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);

  // Helper method to get display name
  String get displayName => name;

  // Helper method to get full address
  String get fullAddress {
    final parts = [
      if (address != null && address!.isNotEmpty) address,
      if (postalCode != null && postalCode!.isNotEmpty) postalCode,
      if (city != null && city!.isNotEmpty) city,
    ];
    return parts.join(', ');
  }

  // Helper method to check if this is a business customer
  bool get isBusiness => category == 'Erhverv' || category == 'Offentlig';

  // Helper method to get primary contact method
  String? get primaryContact => mobile ?? phone ?? email;

  // Copy with method for easy updates
  CustomerModel copyWith({
    int? id,
    String? customerNumber,
    String? name,
    String? category,
    String? address,
    String? postalCode,
    String? city,
    String? phone,
    String? mobile,
    String? email,
    String? cvrNumber,
    String? invoiceName,
    String? invoiceAddress,
    String? invoicePostalCode,
    String? invoiceCity,
    String? invoiceEmail,
    String? invoicePhone,
    String? paymentTerms,
    String? contactPerson,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      customerNumber: customerNumber ?? this.customerNumber,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      cvrNumber: cvrNumber ?? this.cvrNumber,
      invoiceName: invoiceName ?? this.invoiceName,
      invoiceAddress: invoiceAddress ?? this.invoiceAddress,
      invoicePostalCode: invoicePostalCode ?? this.invoicePostalCode,
      invoiceCity: invoiceCity ?? this.invoiceCity,
      invoiceEmail: invoiceEmail ?? this.invoiceEmail,
      invoicePhone: invoicePhone ?? this.invoicePhone,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      contactPerson: contactPerson ?? this.contactPerson,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
