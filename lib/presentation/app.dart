// lib/presentation/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// VIGTIGT: Importer service_locator for JobFlowNotifier
import '../core/di/service_locator.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_notifier.dart';
import '../features/job_flow/job_flow_notifier.dart';
import 'screens/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme management
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(),
        ),

        // Job flow management
        ChangeNotifierProvider(
          create: (_) => JobFlowNotifier(
            getIt(),
            getIt(),
            getIt(),
          ),
        ),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'DeveloperCat DK',
            debugShowCheckedModeBanner: false,

            // Industrial Scandinavian Dashboard themes
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.themeMode,

            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}