// lib\features\supabase_integration\presentation\supabase_widget.dart

import 'package:flutter/material.dart';
import '../domain/supabase_service.dart';
import '../../../core/di/service_locator.dart'; // ⭐️ RETTELSE: Importerer GetIt

class SupabaseWidget extends StatelessWidget {
  // ⭐️ RETTELSE: Henter service via getIt<T>() ⭐️
  final SupabaseService _supabaseService = getIt<SupabaseService>();

  const SupabaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder UI
    return const Center(
      child: Text('Supabase Widget (Ready)'),
    );
  }
}