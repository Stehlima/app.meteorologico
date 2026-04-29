import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Azul Oceano ──────────────────────────────────
  static const Color oceanBlue    = Color(0xFF0066AA);
  static const Color deepOcean    = Color(0xFF004A80);
  static const Color midOcean     = Color(0xFF0088CC);

  // ── Lilás / Lavanda ──────────────────────────────
  static const Color lilac        = Color(0xFFB07FD4);
  static const Color deepLilac    = Color(0xFF7C4FA0);
  static const Color lightLilac   = Color(0xFFD9AAFF);
  static const Color paleLilac    = Color(0xFFF0E6FF);

  // ── Neutros ──────────────────────────────────────
  static const Color white        = Color(0xFFFFFFFF);
  static const Color offWhite     = Color(0xFFF5F0FF);
  static const Color glassWhite   = Color(0x33FFFFFF);
  static const Color glassBorder  = Color(0x55FFFFFF);
  static const Color textLight    = Color(0xDDFFFFFF);

  // ── Gradientes ───────────────────────────────────
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [deepOcean, oceanBlue, deepLilac],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x44FFFFFF), Color(0x11FFFFFF)],
  );

  static const LinearGradient lilacAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lilac, deepLilac],
  );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: oceanBlue,
        primary: oceanBlue,
        secondary: lilac,
        tertiary: lightLilac,
        surface: white,
      ),
      textTheme: GoogleFonts.montserratTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: lightLilac, width: 2),
        ),
        hintStyle: TextStyle(color: white.withValues(alpha: 0.45)),
        prefixIconColor: lightLilac,
      ),
    );
  }
}
