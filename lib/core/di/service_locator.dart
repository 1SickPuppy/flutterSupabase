import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../security/secure_storage_service.dart';
import '../../features/voice_input/domain/voice_input_service.dart';
import '../../features/voice_input/data/voice_input_service_impl.dart';
import '../../features/data_extraction/domain/data_extraction_service.dart';
import '../../features/data_extraction/data/data_extraction_service_impl.dart';
import '../../features/pdf_generation/domain/pdf_generation_service.dart';
import '../../features/pdf_generation/data/pdf_generation_service_impl.dart';
import '../../features/supabase_integration/domain/supabase_service.dart';
import '../../features/supabase_integration/data/supabase_service_impl.dart';

// Singleton instances
final secureStorageService = SecureStorageServiceImpl(const FlutterSecureStorage());
final voiceInputService = VoiceInputServiceImpl();
final dataExtractionService = DataExtractionServiceImpl();
final pdfGenerationService = PdfGenerationServiceImpl();
final supabaseService = SupabaseServiceImpl();

Future<void> setupServiceLocator() async {
  // Initialiser services her hvis nødvendigt
  await secureStorageService.init();
}