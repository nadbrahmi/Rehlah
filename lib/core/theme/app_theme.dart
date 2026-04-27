import 'package:flutter/material.dart';

// ── Rehlah · Soft Dawn · Design Tokens ────────────────────────────────────────
abstract class AppColors {
  // Brand purple
  static const primary = Color(0xFF7B5CC4);
  static const primaryDark = Color(0xFF5B3A9C);
  static const primaryLight = Color(0xFFEDE8F8);
  static const primaryMid = Color(0x407B5CC4); // ~25% alpha

  // App backgrounds
  static const background = Color(0xFFF5F2FC); // lavender-white
  static const background2 = Color(0xFFEDE8F8);
  static const surface = Color(0xFFFFFFFF);

  // Semantic colours
  static const peach = Color(0xFFE09060);
  static const peachLight = Color(0xFFFEF2EA);
  static const teal = Color(0xFF3DB87A);
  static const tealLight = Color(0xFFEAF8F0);
  static const blue = Color(0xFF4A8EC0);
  static const blueLight = Color(0xFFE8F2F8);
  static const gold = Color(0xFFC49030);
  static const goldLight = Color(0xFFFBF4E0);
  static const rose = Color(0xFFC04060);
  static const roseLight = Color(0xFFFEF0F3);

  // Text
  static const text1 = Color(0xFF2A2040); // primary
  static const text2 = Color(0xFF6858A0); // secondary
  static const text3 = Color(0xFFB8A8D8); // tertiary / placeholder

  // Border
  static const border = Color(0x217B5CC4); // rgba(123,92,196,0.13)

  // Hero card gradient stops
  static const heroGrad1 = Color(0xFFDDD4F5);
  static const heroGrad2 = Color(0xFFCCC0EC);
  static const heroGrad3 = Color(0xFFD8CCEE);
  static const heroGrad4 = Color(0xFFE8D4E0);

  // Nadir / warning (orange left-border card)
  static const nadirBg = Color(0xFFFEF2EA);
  static const nadirBorder = Color(0xFFE09060);
}

// ── Text Styles ───────────────────────────────────────────────────────────────
abstract class AppText {
  static const _base = TextStyle(fontFamily: 'Inter', color: AppColors.text1);

  static final displayTitle = _base.copyWith(
    fontSize: 22, fontWeight: FontWeight.w300, letterSpacing: -0.4, height: 1.2,
  );
  static final displayTitleBold = displayTitle.copyWith(fontWeight: FontWeight.w700);

  static final sectionHeading = _base.copyWith(
    fontSize: 16, fontWeight: FontWeight.w500,
  );
  static final body = _base.copyWith(
    fontSize: 13, fontWeight: FontWeight.w300, height: 1.6,
  );
  static final bodySemibold = body.copyWith(fontWeight: FontWeight.w500);
  static final bodySecondary = body.copyWith(color: AppColors.text2);

  static final label = _base.copyWith(
    fontSize: 11, fontWeight: FontWeight.w600,
    letterSpacing: 0.07, color: AppColors.text3,
  );
  static final labelUppercase = label.copyWith(
    letterSpacing: 0.07,
    // Use .toUpperCase() on the string itself
  );

  static final caption = _base.copyWith(
    fontSize: 11, fontWeight: FontWeight.w300, color: AppColors.text3,
  );

  static final statNumber = _base.copyWith(
    fontSize: 30, fontWeight: FontWeight.w300, letterSpacing: -1,
  );

  // Arabic (Almarai font)
  static final arabicBody = _base.copyWith(
    fontFamily: 'Almarai', fontSize: 14, fontWeight: FontWeight.w300,
  );
  static final arabicTitle = _base.copyWith(
    fontFamily: 'Almarai', fontSize: 20, fontWeight: FontWeight.w700,
  );
}

// ── Radius ────────────────────────────────────────────────────────────────────
abstract class AppRadius {
  static const sm = Radius.circular(8);
  static const md = Radius.circular(13);
  static const lg = Radius.circular(18);
  static const xl = Radius.circular(24);
  static const full = Radius.circular(100);
  static const smBR = BorderRadius.all(sm);
  static const mdBR = BorderRadius.all(md);
  static const lgBR = BorderRadius.all(lg);
  static const xlBR = BorderRadius.all(xl);
  static const fullBR = BorderRadius.all(full);
}

// ── Shadows ───────────────────────────────────────────────────────────────────
abstract class AppShadows {
  static final card = BoxShadow(
    color: const Color(0xFF5A3CA0).withOpacity(0.10),
    blurRadius: 20,
    offset: const Offset(0, 6),
  );
  static final fab = BoxShadow(
    color: AppColors.primary.withOpacity(0.40),
    blurRadius: 14,
    offset: const Offset(0, 4),
  );
  static final fabTeal = BoxShadow(
    color: AppColors.teal.withOpacity(0.35),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );
  static final hero = BoxShadow(
    color: const Color(0xFF5A3CA0).withOpacity(0.14),
    blurRadius: 32,
    offset: const Offset(0, 10),
  );
}

// ── Theme ─────────────────────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.background,
      surface: AppColors.surface,
      primary: AppColors.primary,
      secondary: AppColors.teal,
      tertiary: AppColors.peach,
    ),
    fontFamily: 'Inter',
    textTheme: TextTheme(
      displayLarge: AppText.displayTitle,
      titleLarge: AppText.sectionHeading,
      bodyMedium: AppText.body,
      labelSmall: AppText.label,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter', fontSize: 17,
        fontWeight: FontWeight.w600, color: AppColors.text1,
      ),
      iconTheme: IconThemeData(color: AppColors.text1),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border, thickness: 0.5, space: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: AppRadius.mdBR,
        borderSide: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdBR,
        borderSide: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdBR,
        borderSide: const BorderSide(color: AppColors.primaryMid, width: 1),
      ),
      hintStyle: AppText.body.copyWith(color: AppColors.text3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.fullBR),
        textStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
  );
}
