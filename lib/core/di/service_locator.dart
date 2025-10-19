// lib/core/di/service_locator.dart

import 'package:get_it/get_it.dart';
import '../../features/supabase_integration/domain/supabase_service.dart';
import '../../features/supabase_integration/data/supabase_service_impl.dart';
// You will add imports for ALL your services here...
// import '../security/secure_storage_service.dart';
// import '../../features/voice_input/domain/voice_input_service.dart';

final GetIt sl = GetIt.instance; // 'sl' stands for Service Locator

/// Registers all the services, repositories, and providers for the application.
Future<void> initDependencies() async {

  // -----------------------------------------------------
  // 1. Core Services (Singleton instances)
  // -----------------------------------------------------

  // Register the implementation of the Supabase Service
  sl.registerLazySingleton<SupabaseService>(
        () => SupabaseServiceImpl(),
  );

  // TODO: Register your Secure Storage Service here
  // sl.registerLazySingleton<SecureStorageService>(
  //   () => SecureStorageServiceImpl(encryptUtil: sl()), // Example of a dependency
  // );

  // -----------------------------------------------------
  // 2. Feature Services (Lazy Singletons or Factories)
  // -----------------------------------------------------

  // TODO: Register your Voice Input Service here
  // sl.registerLazySingleton<VoiceInputService>(
  //   () => VoiceInputServiceImpl(supabaseClient: sl()),
  // );

  // TODO: Continue with DataExtractionService and PdfGenerationService
  // ...


  // -----------------------------------------------------
  // 3. Providers/Notifiers (Factories for new instances per request)
  // -----------------------------------------------------

  // We often register our ChangeNotifiers as Factories
  // when we plan to use them with the Provider package's MultiProvider.
  // sl.registerFactory<AuthNotifier>(
  //   () => AuthNotifier(supabaseService: sl()),
  // );
}