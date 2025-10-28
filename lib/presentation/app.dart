// lib/presentation/app.dart

import 'package:flutter/material.dart';
// ⭐️ VIGTIGT: Ret stien her, så den matcher din struktur!
// Hvis 'app.dart' er i 'lib/presentation', skal den gå tilbage to niveauer
import '../features/voice_input/presentation/voice_input_widget.dart';
// Du kan også importere ui_constants, hvis du vil bruge kColorSlate900 til baggrund
// import '../ui_constants.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Business Assistant',

      // Standard tema for lyst mode
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),

      // ⭐️ Mørkt tema, der matcher vores UI-design ⭐️
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // Sætter den mørke baggrundsfarve, som du har defineret i ui_constants
        scaffoldBackgroundColor: const Color(0xFF0f172a), // Kopi af kColorSlate900
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),

      // Vi tvinger den mørke tilstand, da hele din UI er designet til den mørke baggrund
      themeMode: ThemeMode.dark,

      // ⭐️ Sætter VoiceInputWidget som startside ⭐️
      home: const VoiceInputWidget(),
    );
  }
}