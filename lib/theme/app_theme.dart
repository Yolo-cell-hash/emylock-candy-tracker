import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary: #810055 and its shades
  static const Color primaryMaroon = Color(0xFF810055);
  static const Color darkMaroon = Color(0xFF5C003D);
  static const Color lightMaroon = Color(0xFFA33078);
  static const Color accentRose = Color(0xFFB8508F);

  // Secondary: #f2f1e6 and its shades
  static const Color backgroundPeach = Color(0xFFF2F1E6);
  static const Color backgroundCard = Color(0xFFE8E7DB);
  static const Color cardWhite = Color(0xFFFAF9F2);

  // Text: standard black / white / grey
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMedium = Color(0xFF555555);
  static const Color textLight = Color(0xFF999999);

  // Functional colors
  static const Color greenOnline = Color(0xFF27AE60);
  static const Color orangeStatus = Color(0xFFE67E22);
  static const Color ringGrey = Color(0xFFDDDCD2);
  static const Color dangerRed = Color(0xFFC0392B);
}

class AppTheme {
  static ThemeData get theme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundPeach,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryMaroon,
        primary: AppColors.primaryMaroon,
        secondary: AppColors.accentRose,
        surface: AppColors.cardWhite,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 28,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.textMedium,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.textMedium,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textLight,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: AppColors.cardWhite,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundPeach,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryMaroon,
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryMaroon),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryMaroon,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
