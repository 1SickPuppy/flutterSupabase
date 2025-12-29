// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parts_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartsOrderModel _$PartsOrderModelFromJson(Map<String, dynamic> json) =>
    PartsOrderModel(
      id: (json['id'] as num?)?.toInt(),
      appointmentId: (json['appointment_id'] as num).toInt(),
      partName: json['part_name'] as String,
      partSku: json['part_sku'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble(),
      supplier: json['supplier'] as String?,
      status: json['status'] as String? ?? 'not_ordered',
      orderedAt: json['ordered_at'] == null
          ? null
          : DateTime.parse(json['ordered_at'] as String),
      arrivedAt: json['arrived_at'] == null
          ? null
          : DateTime.parse(json['arrived_at'] as String),
      installedAt: json['installed_at'] == null
          ? null
          : DateTime.parse(json['installed_at'] as String),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PartsOrderModelToJson(PartsOrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'appointment_id': instance.appointmentId,
      'part_name': instance.partName,
      'part_sku': instance.partSku,
      'quantity': instance.quantity,
      'price': instance.price,
      'supplier': instance.supplier,
      'status': instance.status,
      'ordered_at': instance.orderedAt?.toIso8601String(),
      'arrived_at': instance.arrivedAt?.toIso8601String(),
      'installed_at': instance.installedAt?.toIso8601String(),
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
