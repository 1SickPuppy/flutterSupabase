// lib/presentation/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// VIGTIGT: Importer service_locator for JobFlowNotifier
import '../core/di/service_locator.dart';
import '../features/job_flow/job_flow_notifier.dart';
import 'screens/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {

    // Sætter JobFlowNotifier op med de nødvendige afhængigheder hentet via getIt
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => JobFlowNotifier(
            // Henter de 3 services, som Notifieren skal bruge
            getIt(),
            getIt(),
            getIt(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Voice Business Assistant',

        // Standard tema for lyst mode
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),

        // Mørkt tema, der matcher dit design
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0f172a),
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),

        // Tvinger den mørke tilstand
        themeMode: ThemeMode.dark,

        // Sætter HomeScreen (som indeholder navigationen) som startside
        home: const HomeScreen(),
      ),
    );
  }
}