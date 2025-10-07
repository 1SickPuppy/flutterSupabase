import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/security/secure_storage_service.dart';
import 'presentation/app.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser service locator
  await setupServiceLocator();
  
  // Initialiser Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  
  runApp(
    MultiProvider(
      providers: [
        Provider<SecureStorageService>(
          create: (_) => SecureStorageServiceImpl(
            const FlutterSecureStorage(),
          ),
        ),
        // Andre providers her
      ],
      child: const App(),
    ),
  );
}