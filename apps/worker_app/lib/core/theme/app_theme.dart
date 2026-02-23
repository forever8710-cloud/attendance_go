import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary brand
  static const primary = Color(0xFF8D99AE); // Lavender Grey
  static const primaryDark = Color(0xFF2B2D42); // Space Indigo

  // Action colors
  static const checkIn = Color(0xFF059669); // Emerald 600
  static const checkInLight = Color(0xFF34D399);
  static const checkOut = Color(0xFF2563EB); // Blue 600
  static const checkOutLight = Color(0xFF60A5FA);
  static const earlyLeave = Color(0xFFEA580C); // Orange 600
  static const earlyLeaveLight = Color(0xFFFB923C);

  // Surface
  static const surface = Color(0xFFF8F9FA);
  static const card = Colors.white;
  static const disabled = Color(0xFFE2E8F0);
  static const disabledText = Color(0xFF94A3B8);

  // Text
  static const textPrimary = Color(0xFF2B2D42);
  static const textSecondary = Color(0xFF64748B);
  static const textHint = Color(0xFF94A3B8);
}

class AppTheme {
  static ThemeData get light {
    final baseTextTheme = GoogleFonts.notoSansKrTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSansKr(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Noto Sans KR ExtraBold for brand text "WorkFlow"
  static TextStyle get brandTitle => GoogleFonts.notoSansKr(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.primary,
      );

  /// Noto Sans KR bold numbers (for time display, stats)
  static TextStyle get numberLarge => GoogleFonts.notoSansKr(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get numberMedium => GoogleFonts.notoSansKr(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
}
