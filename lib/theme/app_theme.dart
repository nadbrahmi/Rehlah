import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design Tokens — Rehla Care  ─────────────────────────────────────────────
// Palette extracted from original approved design:
//   Background   #FCF7FC  blush-lilac page canvas
//   Card         #FFFFFF  pure white, r=24, purple-tinted shadow
//   Hero grad    #D894D3 → #C178BB → #BD6BB8  soft mauve-purple
//   Plum text    #3A2A3F  headings
//   Mauve text   #B68AB3  secondary / captions
//   Rose accent  #F75B9A  active highlights
//   Green done   #EAF8EC bg / #22C55E icon
//   Peach pend   #FFF1E4 bg / #FF7A00 button
//   Purple icon  #9B5DC4 → #D370C8 tiles / AI
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  // ── Page canvas ───────────────────────────────────────────────────────────
  static const Color background     = Color(0xFFFCF7FC); // blush-lilac page
  static const Color backgroundWarm = Color(0xFFF9F3F8); // slightly deeper blush
  static const Color surface        = Color(0xFFFFFFFF); // pure white cards
  static const Color surfaceElevated= Color(0xFFFFFBFF); // barely lifted
  static const Color surfaceGlass   = Color(0xF2FFFFFF); // 95% white glass
  static const Color cardSurface    = Color(0xFFFFFFFF);

  // ── Brand — soft mauve-purple ─────────────────────────────────────────────
  static const Color primary        = Color(0xFF9B5DC4); // purple icon / active
  static const Color primaryDark    = Color(0xFF7A3FAA); // darker purple
  static const Color primaryDeeper  = Color(0xFF5B2A85); // deepest purple
  static const Color primaryLight   = Color(0xFFD370C8); // mid purple-pink
  static const Color primarySurface = Color(0xFFEEE0F9); // pale purple wash
  static const Color primarySurface2= Color(0xFFE4D0F5); // slightly richer

  // ── Hero gradient stops ───────────────────────────────────────────────────
  static const Color heroTop    = Color(0xFFD894D3); // soft mauve
  static const Color heroMid    = Color(0xFFC178BB); // mid mauve-purple
  static const Color heroBottom = Color(0xFFBD6BB8); // deeper mauve

  // ── Rose accent ───────────────────────────────────────────────────────────
  static const Color accent      = Color(0xFFF75B9A); // rose pink (active tab, highlights)
  static const Color accentMid   = Color(0xFFFF6BAF); // brighter rose
  static const Color accentDark  = Color(0xFFD43F82); // deep rose
  static const Color accentLight = Color(0xFFFDE8F2); // pale rose wash
  static const Color accentSurface= Color(0xFFFFF0F6); // barely-there rose

  // ── Semantic — green (done / stable) ─────────────────────────────────────
  static const Color success      = Color(0xFF22C55E); // green check
  static const Color successDark  = Color(0xFF166534); // dark green text
  static const Color successLight = Color(0xFFEAF8EC); // mint bg
  static const Color successSurface = Color(0xFFF0FDF4);

  // ── Semantic — peach (pending / due) ─────────────────────────────────────
  static const Color warning      = Color(0xFFFF7A00); // orange action
  static const Color warningDark  = Color(0xFFCC5E00);
  static const Color warningLight = Color(0xFFFFF1E4); // peach bg
  static const Color warningMid   = Color(0xFFFFA040);

  // ── Semantic — danger / critical ─────────────────────────────────────────
  static const Color danger       = Color(0xFFDC2626);
  static const Color dangerLight  = Color(0xFFFEF2F2);
  static const Color critical     = Color(0xFF991B1B);

  // ── Info / calm ───────────────────────────────────────────────────────────
  static const Color info         = Color(0xFF2563EB);
  static const Color infoMid      = Color(0xFF3B82F6);
  static const Color infoLight    = Color(0xFFEFF6FF);
  static const Color calm         = Color(0xFF4F46E5);

  // ── Text — warm plum hierarchy ────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF3A2A3F); // dark plum headings
  static const Color textSecondary = Color(0xFF6B4F72); // body text
  static const Color textTertiary  = Color(0xFFB68AB3); // secondary / captions
  static const Color textMuted     = Color(0xFFCCA8CC); // muted / hints
  static const Color textOnDark    = Color(0xFFFFFFFF);
  static const Color textOnDarkMuted = Color(0xFFE8C8E8);

  // ── Dividers / borders ────────────────────────────────────────────────────
  static const Color divider      = Color(0xFFF3E8F5); // warm lilac divider
  static const Color border       = Color(0xFFEDD8F0); // card border
  static const Color borderStrong = Color(0xFFD9BEE0);

  // ── Symptom domain colors ─────────────────────────────────────────────────
  static const Color pain       = Color(0xFFDC2626);
  static const Color fatigue    = Color(0xFFFF7A00);
  static const Color nausea     = Color(0xFF2563EB);
  static const Color appetite   = Color(0xFF22C55E);
  static const Color sleep      = Color(0xFF9B5DC4);
  static const Color mood       = Color(0xFFF75B9A);

  // ── Phase / domain colors ─────────────────────────────────────────────────
  static const Color diagnosis    = Color(0xFF2563EB);
  static const Color chemo        = Color(0xFF9B5DC4);
  static const Color radiation    = Color(0xFFFF7A00);
  static const Color surgery      = Color(0xFFDC2626);
  static const Color recoveryCol  = Color(0xFF22C55E);
  static const Color immunotherapy= Color(0xFF4F46E5);

  // ── Community / avatar palette ────────────────────────────────────────────
  static const Color avatarViolet = Color(0xFF9B5DC4);
  static const Color avatarEmerald= Color(0xFF22C55E);
  static const Color avatarBlue   = Color(0xFF2563EB);
  static const Color avatarAmber  = Color(0xFFFF7A00);
  static const Color avatarRose   = Color(0xFFF75B9A);
  static const Color avatarIndigo = Color(0xFF4F46E5);
  static const Color avatarTeal   = Color(0xFF0D9488);

  // ── Legacy aliases (keep for backward compat) ─────────────────────────────
  static const Color primaryBackground   = background;
  static const Color secondaryBackground = primarySurface;

  // ── Gradients ─────────────────────────────────────────────────────────────
  /// Hero card gradient — soft mauve-purple (main brand)
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [heroTop, heroMid, heroBottom],
    stops: [0.0, 0.5, 1.0],
  );

  /// Softer hero (used in demo banner etc.)
  static const LinearGradient heroGradientSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC870C3), Color(0xFFB05AAF)],
  );

  /// Card gradient — purple icon tiles
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  /// Accent gradient — rose pink (active action tiles)
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentMid, accent],
  );

  /// Danger gradient
  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), danger],
  );

  /// Warning gradient
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warningMid, warning],
  );

  /// AI / info gradient — purple→rose
  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  /// Warm tint (section backgrounds, highlights)
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primarySurface, primarySurface2],
  );

  static const LinearGradient calmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A2060), Color(0xFF2A1050)],
  );

  static const LinearGradient sunriseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, info],
  );
}

// ─── Shadows — purple-tinted, purposeful ──────────────────────────────────────
class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: const Color(0xFF9B5DC4).withValues(alpha: 0.08),
      blurRadius: 20, offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.04),
      blurRadius: 6, offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get cardElevated => [
    BoxShadow(
      color: const Color(0xFF9B5DC4).withValues(alpha: 0.18),
      blurRadius: 28, offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.04),
      blurRadius: 6, offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get glass => [
    BoxShadow(
      color: const Color(0xFF9B5DC4).withValues(alpha: 0.08),
      blurRadius: 28, offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get fab => [
    BoxShadow(
      color: const Color(0xFFF75B9A).withValues(alpha: 0.40),
      blurRadius: 24, offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.06),
      blurRadius: 6, offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> get nav => [
    BoxShadow(
      color: const Color(0xFF9B5DC4).withValues(alpha: 0.08),
      blurRadius: 20, offset: const Offset(0, -3),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.04),
      blurRadius: 4, offset: const Offset(0, -1),
    ),
  ];

  static List<BoxShadow> get danger => [
    BoxShadow(
      color: const Color(0xFFDC2626).withValues(alpha: 0.28),
      blurRadius: 18, offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get accent => [
    BoxShadow(
      color: const Color(0xFFF75B9A).withValues(alpha: 0.32),
      blurRadius: 18, offset: const Offset(0, 6),
    ),
  ];
}

// ─── Spacing — strict 8-point grid ────────────────────────────────────────────
class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;

  static const double cardRadius   = 24;
  static const double heroRadius   = 24;
  static const double chipRadius   = 50;
  static const double buttonRadius = 14;
  static const double inputRadius  = 14;
  static const double iconRadius   = 14;

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
}

// ─── Text styles — Inter, warm plum hierarchy ─────────────────────────────────
class AppText {
  static TextStyle display([Color? color]) => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w700,
    color: color ?? AppColors.textPrimary, letterSpacing: -0.3, height: 1.2);

  static TextStyle headline([Color? color]) => GoogleFonts.inter(
    fontSize: 20, fontWeight: FontWeight.w700,
    color: color ?? AppColors.textPrimary, letterSpacing: -0.2, height: 1.3);

  static TextStyle title([Color? color]) => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: color ?? AppColors.textPrimary);

  static TextStyle subtitle([Color? color]) => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w500,
    color: color ?? AppColors.textSecondary);

  static TextStyle body([Color? color]) => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: color ?? AppColors.textSecondary, height: 1.55);

  static TextStyle bodySmall([Color? color]) => GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: color ?? AppColors.textTertiary, height: 1.5);

  static TextStyle caption([Color? color]) => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: color ?? AppColors.textMuted);

  static TextStyle label([Color? color]) => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w700,
    color: color ?? AppColors.textPrimary, letterSpacing: 0.3);

  static TextStyle overline([Color? color]) => GoogleFonts.inter(
    fontSize: 10, fontWeight: FontWeight.w700,
    color: color ?? AppColors.textMuted, letterSpacing: 1.0);

  // On-dark variants
  static TextStyle headlineDark() => GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: Colors.white, letterSpacing: -0.3);

  static TextStyle bodyDark() => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textOnDarkMuted, height: 1.55);

  static TextStyle captionDark() => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: Colors.white54);
}

// ─── Glassmorphism helpers ────────────────────────────────────────────────────
class GlassMorphism {
  static BoxDecoration light({double radius = 20, double borderOpacity = 0.22}) =>
    BoxDecoration(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: borderOpacity), width: 1),
    );

  static BoxDecoration card({double radius = 24}) => BoxDecoration(
    color: AppColors.surfaceGlass,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
    boxShadow: AppShadows.card,
  );

  static BoxDecoration dark({double radius = 20}) => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.07),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
  );
}

// ─── Shared decoration helpers ────────────────────────────────────────────────
class AppDecor {
  /// Standard white card
  static BoxDecoration card({double radius = 24, Color? borderColor}) =>
    BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.border, width: 1),
      boxShadow: AppShadows.card,
    );

  /// Tinted card for semantic states
  static BoxDecoration tinted(Color color, {double radius = 18}) =>
    BoxDecoration(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withValues(alpha: 0.20), width: 1),
    );

  /// Icon container
  static BoxDecoration icon(Color color, {double radius = 14}) =>
    BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(radius),
    );

  /// Hero gradient card
  static BoxDecoration hero({double radius = 24}) =>
    BoxDecoration(
      gradient: AppColors.heroGradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: AppShadows.cardElevated,
    );

  /// Warm surface
  static BoxDecoration warm({double radius = 24}) =>
    BoxDecoration(
      gradient: AppColors.warmGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
      boxShadow: AppShadows.card,
    );
}

// ─── Theme ────────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.3),
          displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.2),
          headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.2),
          headlineMedium:TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleLarge:    TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleMedium:   TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleSmall:    TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          bodyLarge:     TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w400, height: 1.6),
          bodyMedium:    TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w400, height: 1.55),
          bodySmall:     TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w400),
          labelLarge:    TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, letterSpacing: 0.3),
          labelMedium:   TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          labelSmall:    TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500, letterSpacing: 0.3),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, letterSpacing: -0.2),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundWarm,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primarySurface,
        labelStyle: const TextStyle(
          color: AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius)),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider, space: 0, thickness: 1),
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.05),
    );
  }
}
