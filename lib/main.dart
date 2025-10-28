// lib/main.dart (KORREKT VERSION)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_it/get_it.dart';

// --- Core Services & Notifiers ---
import 'core/di/service_locator.dart';
import 'features/job_flow/job_flow_notifier.dart';

// --- Interfaces (Brugt i GetIt kald) ---
import 'features/voice_input/domain/voice_input_service.dart';
import 'features/data_extraction/domain/data_extraction_service.dart';
import 'features/pdf_generation/domain/pdf_generation_service.dart';

// --- App Wrapper ---
import 'presentation/app.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupServiceLocator();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(
    MultiProvider(
      providers: [
        // 1. JobFlowNotifier (DEN VIGTIGSTE)
        ChangeNotifierProvider<JobFlowNotifier>(
          create: (_) => JobFlowNotifier(
            getIt<VoiceInputService>(),
            getIt<DataExtractionService>(),
            getIt<PdfGenerationService>(),
            // getIt<SupabaseService>(), // Tilføj når den er implementeret
          ),
        ),

        // ❌ Secure Storage Provider ER FJERNET HER ❌
        // Den skal KUN hentes via GetIt, da den er en Core/Data service.

        // Andre providers her (f.eks. AuthenticationNotifier)
      ],
      child: const App(),
    ),
  );
}