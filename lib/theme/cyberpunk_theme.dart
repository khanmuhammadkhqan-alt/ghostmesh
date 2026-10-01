// lib/theme/cyberpunk_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CyberpunkTheme {
  // Cyberpunk Smoke & Flame Palette
  static const Color pitchBlack = Color(0xFF030407);
  static const Color darkCarbon = Color(0xFF0B0D14);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color flameOrange = Color(0xFFFF3300);
  static const Color ghostMagenta = Color(0xFFFF0055);
  static const Color techGrey = Color(0xFF626B82);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: pitchBlack,
      primaryColor: flameOrange,
      colorScheme: const ColorScheme.dark(
        primary: flameOrange,
        secondary: neonCyan,
        surface: darkCarbon,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          color: Colors.white,
          fontSize: 38,
          fontWeight: FontWeight.w900,
          letterSpacing: 6.0,
          shadows: [
            const Shadow(blurRadius: 12.0, color: neonCyan, offset: Offset(-2, 0)),
            const Shadow(blurRadius: 15.0, color: flameOrange, offset: Offset(2, 0)),
          ],
        ),
        bodyLarge: GoogleFonts.shareTechMono(
          color: techGrey,
          fontSize: 12,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}