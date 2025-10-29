// lib/features/supabase_integration/presentation/supabase_widget.dart

import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../domain/supabase_service.dart';

class SupabaseWidget extends StatefulWidget {
  const SupabaseWidget({super.key});

  @override
  State<SupabaseWidget> createState() => _SupabaseWidgetState();
}

class _SupabaseWidgetState extends State<SupabaseWidget> {
  // Initialiseret senere for at undgå 'const' fejl
  late final SupabaseService _supabaseService;

  @override
  void initState() {
    super.initState();
    // Henter servicen via getIt i initState
    _supabaseService = getIt<SupabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Supabase Widget (Under udvikling)', style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
    );
  }
}