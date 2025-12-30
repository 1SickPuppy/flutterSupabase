// lib/presentation/components/dashboard_card.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? statusBadge;
  final String? metaInfo;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.statusBadge,
    this.metaInfo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(
            color: theme.dividerColor,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Icon(
              icon,
              size: 48,
              color: colorScheme.onSurface,
            ),
            const SizedBox(height: AppTheme.space2),

            // Title
            Text(
              title,
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: AppTheme.space1),

            // Description
            Text(
              description,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Status Footer
            Container(
              padding: const EdgeInsets.only(top: AppTheme.space2),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.surfaceContainerHighest,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (statusBadge != null) statusBadge!,
                  if (metaInfo != null)
                    Text(
                      metaInfo!,
                      style: theme.textTheme.labelSmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
