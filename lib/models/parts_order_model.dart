// lib/models/parts_order_model.dart

import 'package:json_annotation/json_annotation.dart';

part 'parts_order_model.g.dart';

@JsonSerializable()
class PartsOrderModel {
  final int? id;

  // Relation
  @JsonKey(name: 'appointment_id')
  final int appointmentId;

  // Part detaljer
  @JsonKey(name: 'part_name')
  final String partName;

  @JsonKey(name: 'part_sku')
  final String? partSku;

  final int quantity;
  final double? price;
  final String? supplier;

  // Status tracking
  final String status; // 'not_ordered', 'ordered', 'arrived', 'installed'

  @JsonKey(name: 'ordered_at')
  final DateTime? orderedAt;

  @JsonKey(name: 'arrived_at')
  final DateTime? arrivedAt;

  @JsonKey(name: 'installed_at')
  final DateTime? installedAt;

  // Ekstra
  final String? notes;

  // Metadata
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  PartsOrderModel({
    this.id,
    required this.appointmentId,
    required this.partName,
    this.partSku,
    this.quantity = 1,
    this.price,
    this.supplier,
    this.status = 'not_ordered',
    this.orderedAt,
    this.arrivedAt,
    this.installedAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory PartsOrderModel.fromJson(Map<String, dynamic> json) =>
      _$PartsOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$PartsOrderModelToJson(this);

  // Helper methods
  bool get isNotOrdered => status == 'not_ordered';
  bool get isOrdered => status == 'ordered';
  bool get isArrived => status == 'arrived';
  bool get isInstalled => status == 'installed';

  // Calculate total price
  double get totalPrice => (price ?? 0) * quantity;

  // Get status color for UI
  String get statusColor {
    switch (status) {
      case 'not_ordered':
        return '#9E9E9E'; // Grey
      case 'ordered':
        return '#FFC107'; // Yellow
      case 'arrived':
        return '#4CAF50'; // Green
      case 'installed':
        return '#2196F3'; // Blue
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Get status icon
  String get statusIcon {
    switch (status) {
      case 'not_ordered':
        return '⚪'; // White circle
      case 'ordered':
        return '🟡'; // Yellow circle
      case 'arrived':
        return '🟢'; // Green circle
      case 'installed':
        return '✅'; // Check mark
      default:
        return '⚪';
    }
  }

  // Get status display text (Danish)
  String get statusDisplay {
    switch (status) {
      case 'not_ordered':
        return 'Ikke bestilt';
      case 'ordered':
        return 'Bestilt';
      case 'arrived':
        return 'Ankommet';
      case 'installed':
        return 'Installeret';
      default:
        return status;
    }
  }

  // Copy with method
  PartsOrderModel copyWith({
    int? id,
    int? appointmentId,
    String? partName,
    String? partSku,
    int? quantity,
    double? price,
    String? supplier,
    String? status,
    DateTime? orderedAt,
    DateTime? arrivedAt,
    DateTime? installedAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartsOrderModel(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      partName: partName ?? this.partName,
      partSku: partSku ?? this.partSku,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      supplier: supplier ?? this.supplier,
      status: status ?? this.status,
      orderedAt: orderedAt ?? this.orderedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      installedAt: installedAt ?? this.installedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
