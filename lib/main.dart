// lib/main.dart (OPDATERET)

import 'package:flutter/material.dart'; // Tilføj denne for Material
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_it/get_it.dart'; // Nødvendig for at hente services

// Tilføj stien til dine services og notifiers
import 'core/di/service_locator.dart';
import 'features/job_flow/job_flow_notifier.dart';
import 'features/voice_input/domain/voice_input_service.dart';
import 'features/data_extraction/domain/data_extraction_service.dart';
import 'features/pdf_generation/domain/pdf_generation_service.dart';
import 'core/security/secure_storage_service.dart'; // Hvis den er nødvendig her

// Du skal erstatte 'presentation/app.dart' med din MyApp (som indeholder VoiceInputWidget)
import 'presentation/app.dart'; // Vi antager, at dette er din MaterialApp wrapper
// import 'voice_input_widget.dart'; // Hvis App() ikke findes, skal denne bruges

final getIt = GetIt.instance; // Hent GetIt instansen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser service locator
  await setupServiceLocator(); // Skal være korrekt defineret i core/di/service_locator.dart

  // Initialiser Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(
    MultiProvider(
      providers: [
        // 1. JobFlowNotifier (DEN VIGTIGSTE)
        ChangeNotifierProvider<JobFlowNotifier>(
          // Opret JobFlowNotifier ved at hente services via GetIt
          create: (_) => JobFlowNotifier(
            getIt<VoiceInputService>(),
            getIt<DataExtractionService>(),
            getIt<PdfGenerationService>(),
            // getIt<SupabaseService>(), // Tilføj når den er implementeret
          ),
        ),

        // 2. Secure Storage Service
        Provider<SecureStorageService>(
          create: (_) => SecureStorageServiceImpl(
            const FlutterSecureStorage(),
          ),
        ),
        // Andre providers her
      ],
      // ⭐️ SIKR DIG, AT App() PEGER PÅ DIN VoiceInputWidget som 'home' ⭐️
      child: const App(),
    ),
  );
}