// lib/service_locator.dart

import 'package:get_it/get_it.dart';
import 'features/voice_input/domain/voice_input_service.dart';
import 'features/voice_input/data/voice_input_service_impl.dart';
import 'features/data_extraction/domain/data_extraction_service.dart';
import 'features/data_extraction/data/data_extraction_service_impl.dart';
import 'features/pdf_generation/domain/pdf_generation_service.dart';
import 'features/pdf_generation/data/pdf_generation_service_impl.dart';
// Du skal oprette denne fil, SupabaseServiceImpl.dart, snart
// import 'features/supabase_integration/data/supabase_service_impl.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // --- Registrer Services (Enkelt instans) ---

  // Voice Input Feature
  getIt.registerLazySingleton<VoiceInputService>(
        () => VoiceInputServiceImpl(),
  );

  // Data Extraction Feature
  getIt.registerLazySingleton<DataExtractionService>(
        () => DataExtractionServiceImpl(),
  );

  // PDF Generation Feature
  getIt.registerLazySingleton<PdfGenerationService>(
        () => PdfGenerationServiceImpl(),
  );

  // Supabase/Database Feature
  // Midlertidig placeholder indtil implementering
  // getIt.registerLazySingleton<SupabaseService>(
  //   () => SupabaseServiceImpl(),
  // );

  // Du kan oprette notifiers, der bruger GetIt, i din main.dart
}