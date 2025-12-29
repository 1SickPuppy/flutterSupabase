// lib/core/di/service_locator.dart (KORREKT VERSION)

import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- Imports med Aliasser for at undgå navnekonflikter ---
// ⭐️ LØSNING: Sikrer at vi kan referere til dem entydigt ⭐️
import '../../features/data_extraction/data/data_extraction_service_impl.dart' as de;
import '../security/secure_storage_service_impl.dart' as ss;


// --- Domain Interfaces ---
import '../../features/voice_input/domain/voice_input_service.dart';
import '../../features/data_extraction/domain/data_extraction_service.dart';
import '../../features/data_extraction/domain/job_analysis_repository.dart';
import '../../features/pdf_generation/domain/pdf_generation_service.dart';
import '../../features/supabase_integration/domain/supabase_service.dart';
import '../../features/customer_management/domain/customer_service.dart';
import '../../features/calendar/domain/appointment_service.dart';
import '../../features/quote/domain/quote_service.dart';
import '../security/secure_storage_service.dart';

// --- Data Implementeringer (Impl) ---
// ❌ Fjernet de duplikerede IMPL imports herfra. De er nu kun importeret med alias ovenfor. ❌
import '../../features/voice_input/data/voice_input_service_impl.dart';
import '../../features/data_extraction/data/job_analysis_repository_impl.dart';
import '../../features/pdf_generation/data/pdf_generation_service_impl.dart';
import '../../features/supabase_integration/data/supabase_service_impl.dart';
import '../../features/customer_management/data/customer_service_impl.dart';
import '../../features/calendar/data/appointment_service_impl.dart';
import '../../features/quote/data/quote_service_impl.dart';


final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // --- 1. Register Core Services ---

  // Secure Storage Dependency
  getIt.registerLazySingleton<FlutterSecureStorage>(
        () => const FlutterSecureStorage(),
  );

  // ⭐️ BRUG ALIAS 'ss' HER ⭐️
  getIt.registerLazySingleton<SecureStorageService>(
        () => ss.SecureStorageServiceImpl(getIt()),
  );


  // --- 2. Register Application Feature Services ---

  // Voice Input (Impl)
  getIt.registerLazySingleton<VoiceInputService>(
        () => VoiceInputServiceImpl(),
  );

  // Data Extraction (Impl)
  // ⭐️ BRUG ALIAS 'de' HER ⭐️
  getIt.registerLazySingleton<DataExtractionService>(
        () => de.DataExtractionServiceImpl(),
  );

  // PDF Generation (Impl)
  getIt.registerLazySingleton<PdfGenerationService>(
        () => PdfGenerationServiceImpl(),
  );

  // Supabase Integration (Impl)
  getIt.registerLazySingleton<SupabaseService>(
        () => SupabaseServiceImpl(),
  );

  // Customer Management (Impl)
  getIt.registerLazySingleton<CustomerService>(
        () => CustomerServiceImpl(),
  );

  // Calendar/Appointment Management (Impl)
  getIt.registerLazySingleton<AppointmentService>(
        () => AppointmentServiceImpl(),
  );

  // Job Analysis Repository (Impl)
  getIt.registerLazySingleton<JobAnalysisRepository>(
        () => JobAnalysisRepositoryImpl(),
  );

  // Quote Service (Impl) - depends on JobAnalysisRepository and AppointmentService
  getIt.registerLazySingleton<QuoteService>(
        () => QuoteServiceImpl(getIt(), getIt()),
  );
}