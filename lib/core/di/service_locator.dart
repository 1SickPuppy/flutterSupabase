// lib/core/di/service_locator.dart (KORREKT VERSION)

import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- Domain Interfaces ---
import '../../features/voice_input/domain/voice_input_service.dart';
import '../../features/data_extraction/domain/data_extraction_service.dart';
import '../../features/pdf_generation/domain/pdf_generation_service.dart';
import '../../features/supabase_integration/domain/supabase_service.dart';
import '../security/secure_storage_service.dart';

// --- Data Implementeringer (Impl) ---
import '../../features/voice_input/data/voice_input_service_impl.dart';
import '../../features/data_extraction/data/data_extraction_service_impl.dart';
import '../../features/pdf_generation/data/pdf_generation_service_impl.dart';
import '../../features/supabase_integration/data/supabase_service_impl.dart';
import '../security/secure_storage_service_impl.dart';


final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // --- 1. Register Core Services ---

  // Secure Storage (Nødvendig for Supabase)
  getIt.registerLazySingleton<FlutterSecureStorage>(
        () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<SecureStorageService>(
        () => SecureStorageServiceImpl(getIt()),
  );
  // (Bemærk: Vi initialiserer ikke secureStorageService.init() her, da det klares af Supabase eller andre services senere)


  // --- 2. Register Application Feature Services ---

  // Voice Input (Impl)
  getIt.registerLazySingleton<VoiceInputService>(
        () => VoiceInputServiceImpl(),
  );

  // Data Extraction (Impl)
  getIt.registerLazySingleton<DataExtractionService>(
        () => DataExtractionServiceImpl(),
  );

  // PDF Generation (Impl)
  getIt.registerLazySingleton<PdfGenerationService>(
        () => PdfGenerationServiceImpl(),
  );

  // Supabase Integration (Impl) - Hvis den er implementeret
  getIt.registerLazySingleton<SupabaseService>(
        () => SupabaseServiceImpl(),
  );

  // Vi venter med at initialisere services, indtil de faktisk bruges (LazySingleton)
}