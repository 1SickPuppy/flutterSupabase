// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_notifier.dart';
import '../../features/job_flow/job_flow_notifier.dart';
import '../../features/voice_input/presentation/voice_input_widget.dart';
import '../../features/data_extraction/presentation/data_extraction_widget.dart';
import '../../features/pdf_generation/presentation/pdf_generation_widget.dart';
import '../../features/supabase_integration/presentation/supabase_widget.dart';
import '../../features/customer_management/presentation/customer_list_widget.dart';
import '../../features/calendar/presentation/calendar_widget.dart';
import '../components/dashboard_card.dart';
import '../components/status_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<JobFlowNotifier>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = Theme.of(context);
    final selectedIndex = notifier.selectedIndex;

    // If a specific feature is selected, show that page
    if (selectedIndex > 0) {
      return _buildFeaturePage(context, selectedIndex, notifier);
    }

    // Otherwise show dashboard
    return Scaffold(
      appBar: AppBar(
        title: Text('DEVELOPERCAT DK', style: theme.appBarTheme.titleTextStyle),
        actions: [
          // Theme toggle button
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.space2),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.dividerColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ThemeToggleButton(
                    icon: Icons.light_mode,
                    label: 'LYS',
                    isActive: !themeNotifier.isDarkMode,
                    onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                  ),
                  _ThemeToggleButton(
                    icon: Icons.dark_mode,
                    label: 'MØRK',
                    isActive: themeNotifier.isDarkMode,
                    onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats overview
            _buildStatsRow(context),
            const SizedBox(height: AppTheme.space4),

            // Dashboard cards grid
            _buildDashboardGrid(context, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePage(BuildContext context, int index, JobFlowNotifier notifier) {
    final pages = [
      const VoiceInputWidget(),
      const DataExtractionWidget(),
      const PdfGenerationWidget(),
      const SupabaseWidget(),
      const CustomerListWidget(),
      const CalendarWidget(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => notifier.setSelectedIndex(0), // Back to dashboard
        ),
        title: Text(_getPageTitle(index)),
      ),
      body: pages[index - 1], // Subtract 1 because dashboard is index 0
    );
  }

  String _getPageTitle(int index) {
    const titles = [
      'Dashboard',
      'Stemme Input',
      'Data Udtræk',
      'PDF Tilbud',
      'Supabase',
      'Kunder',
      'Kalender',
    ];
    return titles[index];
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '24',
            label: 'KUNDER',
            theme: theme,
          ),
        ),
        const SizedBox(width: AppTheme.space2),
        Expanded(
          child: _StatCard(
            value: '8',
            label: 'AFTALER',
            theme: theme,
          ),
        ),
        const SizedBox(width: AppTheme.space2),
        Expanded(
          child: _StatCard(
            value: '3',
            label: 'I DAG',
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid(BuildContext context, JobFlowNotifier notifier) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppTheme.space3,
      mainAxisSpacing: AppTheme.space3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.9,
      children: [
        DashboardCard(
          icon: Icons.mic,
          title: 'Stemme',
          description: 'Optag job med dansk talegenkendelse',
          statusBadge: const StatusBadge(
            type: StatusType.completed,
            customLabel: 'KLAR',
          ),
          metaInfo: '60s',
          onTap: () => notifier.setSelectedIndex(1),
        ),
        DashboardCard(
          icon: Icons.analytics,
          title: 'Data',
          description: 'AI-drevet job-analyse',
          statusBadge: const StatusBadge(
            type: StatusType.planned,
            customLabel: 'STANDBY',
          ),
          metaInfo: 'Gemini',
          onTap: () => notifier.setSelectedIndex(2),
        ),
        DashboardCard(
          icon: Icons.picture_as_pdf,
          title: 'PDF',
          description: 'Generer professionelle tilbud',
          statusBadge: const StatusBadge(
            type: StatusType.completed,
            customLabel: 'KLAR',
          ),
          metaInfo: 'A4',
          onTap: () => notifier.setSelectedIndex(3),
        ),
        DashboardCard(
          icon: Icons.cloud,
          title: 'Cloud',
          description: 'Database og autentificering',
          statusBadge: const StatusBadge(
            type: StatusType.completed,
            customLabel: 'TILSLUTTET',
          ),
          metaInfo: 'Supabase',
          onTap: () => notifier.setSelectedIndex(4),
        ),
        DashboardCard(
          icon: Icons.people,
          title: 'Kunder',
          description: 'Administrer kunder',
          statusBadge: const StatusBadge(
            type: StatusType.planned,
            customLabel: '24 AKTIVE',
          ),
          metaInfo: 'CSV',
          onTap: () => notifier.setSelectedIndex(5),
        ),
        DashboardCard(
          icon: Icons.calendar_today,
          title: 'Kalender',
          description: 'Aftaler og møder',
          statusBadge: const StatusBadge(
            type: StatusType.inProgress,
            customLabel: '3 I DAG',
          ),
          metaInfo: 'Uge',
          onTap: () => notifier.setSelectedIndex(6),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final ThemeData theme;

  const _StatCard({
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: theme.colorScheme.surfaceContainerHighest,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: AppTheme.space1),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ThemeToggleButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}