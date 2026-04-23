import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS  — clinical-premium palette (inspired by Epic, Hims, Noom)
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  // Brand
  static const primary       = Color(0xFF6D28D9);   // deep violet
  static const primaryMid    = Color(0xFF7C3AED);
  static const primaryLight  = Color(0xFFF5F3FF);
  static const primaryBorder = Color(0xFFDDD6FE);

  // Teal / success
  static const teal          = Color(0xFF0F766E);
  static const tealLight     = Color(0xFFF0FDFA);
  static const tealBorder    = Color(0xFF99F6E4);

  // Amber / warning
  static const amber         = Color(0xFFB45309);
  static const amberLight    = Color(0xFFFFFBEB);
  static const amberBorder   = Color(0xFFFDE68A);
  static const amberDark     = Color(0xFF78350F);

  // Red / emergency
  static const emergencyRed  = Color(0xFFB91C1C);
  static const redLight      = Color(0xFFFEF2F2);
  static const redBorder     = Color(0xFFFECACA);

  // Neutrals — warm white base (clinical feel)
  static const background    = Color(0xFFF8F7FA);   // off-white with slight lavender
  static const surface       = Color(0xFFFFFFFF);
  static const surfaceAlt    = Color(0xFFFAF9FC);
  static const border        = Color(0xFFEDE9F6);   // subtle purple tint
  static const borderLight   = Color(0xFFF3F0FA);

  // Text
  static const textPrimary   = Color(0xFF18181B);   // near-black
  static const textSecondary = Color(0xFF71717A);
  static const textTertiary  = Color(0xFFA1A1AA);

  // Gradient stops
  static const gradStart     = Color(0xFF6D28D9);
  static const gradEnd       = Color(0xFF4F46E5);   // indigo lean

  // Special
  static const cardShadow    = Color(0x0D6D28D9);   // purple-tinted shadow
}

// ─────────────────────────────────────────────────────────────────────────────
//  THEME
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      surface: AppColors.surface,
      brightness: Brightness.light,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHADOW SYSTEM
// ─────────────────────────────────────────────────────────────────────────────
List<BoxShadow> get shadowSm => const [
  BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x06000000), blurRadius: 2, offset: Offset(0, 0)),
];

List<BoxShadow> get shadowMd => const [
  BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4)),
  BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2)),
];

List<BoxShadow> get shadowLg => const [
  BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 8)),
  BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4)),
];

List<BoxShadow> shadowPurple({double opacity = 0.18}) => [
  BoxShadow(
    color: AppColors.primary.withValues(alpha: opacity),
    blurRadius: 16,
    offset: const Offset(0, 6),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
//  DECORATION HELPERS
// ─────────────────────────────────────────────────────────────────────────────
BoxDecoration cardDecoration({
  Color? color,
  double radius = 16,
  bool withBorder = true,
  List<BoxShadow>? shadows,
}) =>
    BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: withBorder ? Border.all(color: AppColors.border, width: 1) : null,
      boxShadow: shadows ?? shadowMd,
    );

BoxDecoration glassCard({double radius = 16}) => BoxDecoration(
  color: Colors.white.withValues(alpha: 0.85),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border),
  boxShadow: shadowMd,
);

BoxDecoration accentCard({
  required Color accent,
  Color? bg,
  double radius = 16,
  bool rtl = false,
}) =>
    BoxDecoration(
      color: bg ?? AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border(
        left: rtl ? BorderSide.none : BorderSide(color: accent, width: 3),
        right: rtl ? BorderSide(color: accent, width: 3) : BorderSide.none,
        top: Border.all(color: AppColors.border).top,
        bottom: Border.all(color: AppColors.border).bottom,
      ),
      boxShadow: shadowMd,
    );

// Gradient decoration
BoxDecoration gradientDecoration({
  double radius = 16,
  List<Color>? colors,
}) =>
    BoxDecoration(
      gradient: LinearGradient(
        colors: colors ?? [AppColors.gradStart, AppColors.gradEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
    );

// ─────────────────────────────────────────────────────────────────────────────
//  TEXT STYLES
// ─────────────────────────────────────────────────────────────────────────────
TextStyle tsDisplay({Color c = AppColors.textPrimary}) =>
    GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.5);

TextStyle tsH1({Color c = AppColors.textPrimary}) =>
    GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: c, letterSpacing: -0.3);

TextStyle tsH2({Color c = AppColors.textPrimary}) =>
    GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: c, letterSpacing: -0.2);

TextStyle tsH3({Color c = AppColors.textPrimary}) =>
    GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: c);

TextStyle tsBody({Color c = AppColors.textPrimary, FontWeight w = FontWeight.w400}) =>
    GoogleFonts.inter(fontSize: 15, fontWeight: w, color: c, height: 1.55);

TextStyle tsBodySm({Color c = AppColors.textSecondary, FontWeight w = FontWeight.w400}) =>
    GoogleFonts.inter(fontSize: 13, fontWeight: w, color: c, height: 1.5);

TextStyle tsLabel({Color c = AppColors.textSecondary}) =>
    GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: c, letterSpacing: 0.6);

TextStyle tsCaption({Color c = AppColors.textTertiary}) =>
    GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: c);

// Arabic headings use Almarai
TextStyle tsArabicH({double size = 22, Color c = AppColors.textPrimary}) =>
    GoogleFonts.almarai(fontSize: size, fontWeight: FontWeight.w700, color: c);
