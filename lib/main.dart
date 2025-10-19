import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/security/secure_storage_service.dart';
import 'features/voice_input/domain/voice_input_service.dart';
import 'features/voice_input/data/voice_input_service_impl.dart';
import 'features/data_extraction/domain/data_extraction_service.dart';
import 'features/data_extraction/data/data_extraction_service_impl.dart';
import 'features/pdf_generation/domain/pdf_generation_service.dart';
import 'features/pdf_generation/data/pdf_generation_service_impl.dart';
import 'features/supabase_integration/domain/supabase_service.dart';
import 'features/supabase_integration/data/supabase_service_impl.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  final secureStorage = const FlutterSecureStorage();
  final secureStorageService = SecureStorageServiceImpl(secureStorage);
  await secureStorageService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<SecureStorageService>(
          create: (_) => secureStorageService,
        ),
        Provider<VoiceInputService>(
          create: (_) => VoiceInputServiceImpl(),
        ),
        Provider<DataExtractionService>(
          create: (_) => DataExtractionServiceImpl(),
        ),
        Provider<PdfGenerationService>(
          create: (_) => PdfGenerationServiceImpl(),
        ),
        Provider<SupabaseService>(
          create: (_) => SupabaseServiceImpl(),
        ),
      ],
      child: const App(),
    ),
  );
}