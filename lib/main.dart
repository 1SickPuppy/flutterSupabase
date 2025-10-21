// lib/main.dart (OPDATERET)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service_locator.dart'; // Importer den nye fil
import 'features/job_flow/job_flow_notifier.dart';
import 'features/voice_input/presentation/voice_input_widget.dart'; // Din UI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐️ TRIN 1: Initialiser GetIt ⭐️
  setupLocator();

  // Her skal Supabase initialiseres, når du er klar til det
  // await Supabase.initialize(...);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ⭐️ TRIN 2: Opret JobFlowNotifier ved hjælp af GetIt ⭐️
        ChangeNotifierProvider(
          create: (context) => JobFlowNotifier(
            getIt<VoiceInputService>(),
            getIt<DataExtractionService>(),
            getIt<PdfGenerationService>(),
            // getIt<SupabaseService>(), // Tilføj denne, når den er implementeret
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Voice Business Assistant',
        theme: ThemeData(
          // Vi bruger dark theme, men baggrunden styres af VoiceInputWidget
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0f172a),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0f172a), // Helt mørk i header
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
          useMaterial3: true,
        ),
        // Vi bruger VoiceInputWidget som den primære skærm
        home: const VoiceInputWidget(),
      ),
    );
  }
}