// lib/features/voice_input/presentation/voice_input_widget.dart (KORREKT RECAP)

// ...
return Scaffold(
// ⭐️ BRUG KOLON (:) til navngivne parametre ⭐️
appBar = AppBar( /* ... Header ... */ ),
// ...
body = Container(
decoration: kMainBackgroundGradient, // Fra ui_constants.dart
child: SafeArea(
child: Center(
child: SingleChildScrollView(
padding: const EdgeInsets.all(16.0),
child: currentScreen, // Dette skifter mellem de 3 widgets
),
),
),
),
);
// ...