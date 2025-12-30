// lib/presentation/components/status_badge.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum StatusType {
  planned,    // Planlagt
  inProgress, // I gang
  awaitingParts, // Afventer dele
  completed,  // Færdig
  cancelled,  // Aflyst
}

class StatusBadge extends StatelessWidget {
  final StatusType type;
  final String? customLabel;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.type,
    this.customLabel,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get colors and label based on status type
    final (bgColor, textColor, label) = _getStatusStyle(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space2,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            customLabel ?? label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }

  (Color, Color, String) _getStatusStyle(bool isDark) {
    switch (type) {
      case StatusType.planned:
        return (
          isDark
              ? AppTheme.statusInfoDarkBg
              : AppTheme.statusInfoLightBg,
          AppTheme.statusInfo,
          'PLANLAGT'
        );
      case StatusType.inProgress:
        return (
          isDark
              ? AppTheme.statusWarningDarkBg
              : AppTheme.statusWarningLightBg,
          AppTheme.statusWarning,
          'I GANG'
        );
      case StatusType.awaitingParts:
        return (
          isDark
              ? AppTheme.statusPurpleDarkBg
              : AppTheme.statusPurpleLightBg,
          AppTheme.statusPurple,
          'AFVENTER DELE'
        );
      case StatusType.completed:
        return (
          isDark
              ? AppTheme.statusSuccessDarkBg
              : AppTheme.statusSuccessLightBg,
          AppTheme.statusSuccess,
          'FÆRDIG'
        );
      case StatusType.cancelled:
        return (
          isDark
              ? AppTheme.statusErrorDarkBg
              : AppTheme.statusErrorLightBg,
          AppTheme.statusError,
          'AFLYST'
        );
    }
  }

  /// Helper to convert string status to StatusType
  static StatusType fromString(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
      case 'planlagt':
        return StatusType.planned;
      case 'in_progress':
      case 'i gang':
        return StatusType.inProgress;
      case 'awaiting_parts':
      case 'afventer dele':
      case 'afventer_dele':
        return StatusType.awaitingParts;
      case 'completed':
      case 'færdig':
        return StatusType.completed;
      case 'cancelled':
      case 'aflyst':
        return StatusType.cancelled;
      default:
        return StatusType.planned;
    }
  }
}
