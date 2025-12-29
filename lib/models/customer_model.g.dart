// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) =>
    CustomerModel(
      id: (json['id'] as num?)?.toInt(),
      customerNumber: json['customer_number'] as String?,
      name: json['name'] as String,
      category: json['category'] as String?,
      address: json['address'] as String?,
      postalCode: json['postal_code'] as String?,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      cvrNumber: json['cvr_number'] as String?,
      invoiceName: json['invoice_name'] as String?,
      invoiceAddress: json['invoice_address'] as String?,
      invoicePostalCode: json['invoice_postal_code'] as String?,
      invoiceCity: json['invoice_city'] as String?,
      invoiceEmail: json['invoice_email'] as String?,
      invoicePhone: json['invoice_phone'] as String?,
      paymentTerms: json['payment_terms'] as String?,
      contactPerson: json['contact_person'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CustomerModelToJson(CustomerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_number': instance.customerNumber,
      'name': instance.name,
      'category': instance.category,
      'address': instance.address,
      'postal_code': instance.postalCode,
      'city': instance.city,
      'phone': instance.phone,
      'mobile': instance.mobile,
      'email': instance.email,
      'cvr_number': instance.cvrNumber,
      'invoice_name': instance.invoiceName,
      'invoice_address': instance.invoiceAddress,
      'invoice_postal_code': instance.invoicePostalCode,
      'invoice_city': instance.invoiceCity,
      'invoice_email': instance.invoiceEmail,
      'invoice_phone': instance.invoicePhone,
      'payment_terms': instance.paymentTerms,
      'contact_person': instance.contactPerson,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
