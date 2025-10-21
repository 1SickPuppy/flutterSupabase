// lib/ui_constants.dart

import 'package:flutter/material.dart';

// --- Baggrundsfarver ---
const Color kColorSlate900 = Color(0xFF0f172a); // Bagrgrund (0f172a)
const Color kColorSlate800 = Color(0xFF1e293b); // Lettere Slate (1e293b)
const Color kColorSlate700 = Color(0xFF334155); // Bruges til border/dividers

// --- Gradianter & Farver ---
const Color kColorRed500 = Color(0xFFef4444);
const Color kColorRed800 = Color(0xFFb91c1c);
const Color kColorBlue500 = Color(0xFF3b82f6);
const Color kColorBlue700 = Color(0xFF1d4ed8);
const Color kColorGreen500 = Color(0xFF10b981);
const Color kColorGreen600 = Color(0xFF059669);
const Color kColorPurple500 = Color(0xFFa855f7);
const Color kColorPink700 = Color(0xFFdb2777);

// Skygge, der matcher din .tsx specifikation
const BoxShadow kButtonShadow = BoxShadow(
  color: Colors.black,
  blurRadius: 20,
  spreadRadius: 5,
);

// Hovedbaggrundsgradient
const BoxDecoration kMainBackgroundGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [kColorSlate900, kColorSlate800, kColorSlate900],
  ),
);