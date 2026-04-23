import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFFFCF7FC);
  static const primary = Color(0xFF7C3AED);
  static const teal = Color(0xFF0D9488);
  static const amber = Color(0xFFD97706);
  static const emergencyRed = Color(0xFFDC2626);
  static const textPrimary = Color(0xFF1C1917);
  static const textSecondary = Color(0xFF78716C);
  static const border = Color(0xFFE7E5E4);
  static const surface = Color(0xFFFFFFFF);
  static const primaryLight = Color(0xFFF5F3FF);
  static const tealLight = Color(0xFFF0FDF4);
  static const amberLight = Color(0xFFFEF3C7);
  static const amberDark = Color(0xFF92400E);
  static const redLight = Color(0xFFFEF2F2);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}

// Text style helpers
TextStyle almaiDisplay({Color color = AppColors.textPrimary}) =>
    GoogleFonts.almarai(fontSize: 32, fontWeight: FontWeight.bold, color: color);

TextStyle almaiHeading({Color color = AppColors.textPrimary}) =>
    GoogleFonts.almarai(fontSize: 26, fontWeight: FontWeight.bold, color: color);

TextStyle almaiSubheading({Color color = AppColors.textPrimary}) =>
    GoogleFonts.almarai(fontSize: 20, fontWeight: FontWeight.w600, color: color);

TextStyle almaiTitle({double size = 24, Color color = AppColors.textPrimary}) =>
    GoogleFonts.almarai(fontSize: size, fontWeight: FontWeight.bold, color: color);

TextStyle interBody({Color color = AppColors.textPrimary, FontWeight weight = FontWeight.normal}) =>
    GoogleFonts.inter(fontSize: 16, fontWeight: weight, color: color);

TextStyle interSmall({Color color = AppColors.textSecondary, FontWeight weight = FontWeight.normal}) =>
    GoogleFonts.inter(fontSize: 13, fontWeight: weight, color: color);

TextStyle interCaption({Color color = AppColors.textSecondary}) =>
    GoogleFonts.inter(fontSize: 12, color: color);

BoxDecoration cardDecoration({
  Color? color,
  double radius = 16,
  bool withBorder = false,
}) =>
    BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: withBorder ? Border.all(color: AppColors.border) : null,
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
