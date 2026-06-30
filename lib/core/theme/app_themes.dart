
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemePreset {
  final String name;
  final String displayName;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final Color background;
  final Color backgroundEnd;
  final Color surfaceDark;
  final Color surfaceLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color shadowDark;
  final Color shadowLight;
  final Color cellSelected;
  final Color cellSameNumber;

  const ThemePreset({
    required this.name,
    required this.displayName,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.background,
    required this.backgroundEnd,
    required this.surfaceDark,
    required this.surfaceLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.shadowDark,
    required this.shadowLight,
    required this.cellSelected,
    required this.cellSameNumber,
  });

  static const List<ThemePreset> presets = [
    // ── Indigo (default) ──
    ThemePreset(
      name: 'indigo',
      displayName: 'Indigo',
      primary: Color(0xFF5B6ABF),
      primaryLight: Color(0xFF8E99D9),
      primaryDark: Color(0xFF3D4999),
      accent: Color(0xFFFF6B6B),
      background: Color(0xFFE8ECF1),
      backgroundEnd: Color(0xFFDCE3F0),
      surfaceDark: Color(0xFFD1D9E6),
      surfaceLight: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF2D3142),
      textSecondary: Color(0xFF9BA3B5),
      shadowDark: Color(0xFFBEC8D9),
      shadowLight: Color(0xFFFFFFFF),
      cellSelected: Color(0xFFC5CBE8),
      cellSameNumber: Color(0xFFDCE0F0),
    ),
    // ── Teal ──
    ThemePreset(
      name: 'teal',
      displayName: 'Teal',
      primary: Color(0xFF0D9488),
      primaryLight: Color(0xFF5EEAD4),
      primaryDark: Color(0xFF0F766E),
      accent: Color(0xFFF97316),
      background: Color(0xFFE8F5F3),
      backgroundEnd: Color(0xFFD4EDE8),
      surfaceDark: Color(0xFFC5E0DA),
      surfaceLight: Color(0xFFFAFFFE),
      textPrimary: Color(0xFF134E4A),
      textSecondary: Color(0xFF5F8B87),
      shadowDark: Color(0xFFB2CCC6),
      shadowLight: Color(0xFFFFFFFF),
      cellSelected: Color(0xFFB8E0DA),
      cellSameNumber: Color(0xFFD5F0EB),
    ),
    // ── Amber ──
    ThemePreset(
      name: 'amber',
      displayName: 'Amber',
      primary: Color(0xFFD97706),
      primaryLight: Color(0xFFFBBF24),
      primaryDark: Color(0xFFB45309),
      accent: Color(0xFF7C3AED),
      background: Color(0xFFFEF7ED),
      backgroundEnd: Color(0xFFFDEAD0),
      surfaceDark: Color(0xFFF5DDB8),
      surfaceLight: Color(0xFFFEFCF7),
      textPrimary: Color(0xFF451A03),
      textSecondary: Color(0xFFA16207),
      shadowDark: Color(0xFFD9B99B),
      shadowLight: Color(0xFFFFFFFF),
      cellSelected: Color(0xFFFDE68A),
      cellSameNumber: Color(0xFFFEF3C7),
    ),
    // ── Rose ──
    ThemePreset(
      name: 'rose',
      displayName: 'Rose',
      primary: Color(0xFFE11D48),
      primaryLight: Color(0xFFFDA4AF),
      primaryDark: Color(0xFFBE123C),
      accent: Color(0xFF0EA5E9),
      background: Color(0xFFFDF2F4),
      backgroundEnd: Color(0xFFFCE4E8),
      surfaceDark: Color(0xFFF0CDD4),
      surfaceLight: Color(0xFFFEFAFB),
      textPrimary: Color(0xFF4C0519),
      textSecondary: Color(0xFF9F1239),
      shadowDark: Color(0xFFDBBCC4),
      shadowLight: Color(0xFFFFFFFF),
      cellSelected: Color(0xFFFDA4AF),
      cellSameNumber: Color(0xFFFECDD3),
    ),
    // ── Ocean (dark blue) ──
    ThemePreset(
      name: 'ocean',
      displayName: 'Ocean',
      primary: Color(0xFF2563EB),
      primaryLight: Color(0xFF60A5FA),
      primaryDark: Color(0xFF1D4ED8),
      accent: Color(0xFFF59E0B),
      background: Color(0xFFEEF2FF),
      backgroundEnd: Color(0xFFDBE4FF),
      surfaceDark: Color(0xFFC7D2FE),
      surfaceLight: Color(0xFFF8FAFF),
      textPrimary: Color(0xFF1E293B),
      textSecondary: Color(0xFF475569),
      shadowDark: Color(0xFFBAC8E0),
      shadowLight: Color(0xFFFFFFFF),
      cellSelected: Color(0xFFBFDBFE),
      cellSameNumber: Color(0xFFDBEAFE),
    ),
  ];

  static ThemePreset byName(String name) {
    return presets.firstWhere((p) => p.name == name,
        orElse: () => presets.first);
  }

  ThemeData toThemeData() {
    final textTheme = GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5),
      headlineMedium: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
      labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
    );

    return ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(primary: primary, secondary: accent, surface: background),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: primary),
      ),
    );
  }
}
