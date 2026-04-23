import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design Tokens v2 — Rehlah Brand Refresh ─────────────────────────────────
// Background:       #FCF7FC
// Primary purple:   #7C3AED  (ONE element per screen)
// Cards:            #FFFFFF  shadow: 0 2px 12px rgba(0,0,0,0.06)
// Amber accent:     #D97706  (warnings only)
// Teal success:     #0D9488  (milestone celebrations only)
// Body text:        #1C1917
// Secondary text:   #78716C
// Body:             18sp min / heading: 26sp min / line-height: 1.7
// Buttons:          52px min height / tap target 48px
// Screen padding:   24px sides, 32px top
// Card padding:     20px all
// Section spacing:  24px min
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  // ── Page canvas ──────────────────────────────────────────────────────────
  static const Color background      = Color(0xFFFCF7FC);
  static const Color backgroundWarm  = Color(0xFFF9F4F9);
  static const Color surface         = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFBFF);
  static const Color surfaceGlass    = Color(0xF2FFFFFF);
  static const Color cardSurface     = Color(0xFFFFFFFF);

  // ── Brand — primary purple (use ONE element per screen) ──────────────────
  static const Color primary         = Color(0xFF7C3AED); // NEW: #7C3AED
  static const Color primaryDark     = Color(0xFF6D28D9);
  static const Color primaryDeeper   = Color(0xFF4C1D95);
  static const Color primaryLight    = Color(0xFFA78BFA);
  static const Color primarySurface  = Color(0xFFEDE9FE);
  static const Color primarySurface2 = Color(0xFFDDD6FE);

  // ── Hero gradient (welcome/journey screens only) ─────────────────────────
  static const Color heroTop    = Color(0xFFD894D3);
  static const Color heroMid    = Color(0xFFC178BB);
  static const Color heroBottom = Color(0xFFBD6BB8);

  // ── Amber accent (warnings only — never red for missed actions) ──────────
  static const Color amber       = Color(0xFFD97706); // NEW: #D97706
  static const Color amberLight  = Color(0xFFFEF3C7);
  static const Color amberMedium = Color(0xFFF59E0B);

  // ── Teal success (milestone celebrations only) ───────────────────────────
  static const Color teal        = Color(0xFF0D9488); // NEW: #0D9488
  static const Color tealLight   = Color(0xFFCCFBF1);
  static const Color tealSurface = Color(0xFFF0FDFA);

  // ── Legacy accent (kept for backward compat) ─────────────────────────────
  static const Color accent       = Color(0xFF7C3AED);
  static const Color accentMid    = Color(0xFFA78BFA);
  static const Color accentDark   = Color(0xFF6D28D9);
  static const Color accentLight  = Color(0xFFEDE9FE);
  static const Color accentSurface = Color(0xFFF5F3FF);

  // ── Yusr chat bubble ─────────────────────────────────────────────────────
  static const Color yusrBubble  = Color(0xFFF5F3FF); // #F5F3FF per spec

  // ── Semantic — green (done / stable) ────────────────────────────────────
  static const Color success      = Color(0xFF22C55E);
  static const Color successDark  = Color(0xFF166534);
  static const Color successLight = Color(0xFFEAF8EC);
  static const Color successSurface = Color(0xFFF0FDF4);

  // ── Semantic — orange/amber (pending, missed — NOT red) ──────────────────
  static const Color warning      = Color(0xFFD97706);
  static const Color warningDark  = Color(0xFFB45309);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningMid   = Color(0xFFF59E0B);

  // ── Semantic — danger (critical lab alerts only) ─────────────────────────
  static const Color danger       = Color(0xFFDC2626);
  static const Color dangerLight  = Color(0xFFFEF2F2);
  static const Color critical     = Color(0xFF991B1B);

  // ── Info ─────────────────────────────────────────────────────────────────
  static const Color info         = Color(0xFF2563EB);
  static const Color infoMid      = Color(0xFF3B82F6);
  static const Color infoLight    = Color(0xFFEFF6FF);
  static const Color calm         = Color(0xFF4F46E5);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1C1917); // NEW: #1C1917
  static const Color textSecondary = Color(0xFF78716C); // NEW: #78716C
  static const Color textTertiary  = Color(0xFFA8A29E);
  static const Color textMuted     = Color(0xFFD6D3D1);
  static const Color textOnDark    = Color(0xFFFFFFFF);
  static const Color textOnDarkMuted = Color(0xFFE8C8E8);

  // ── Dividers / borders ───────────────────────────────────────────────────
  static const Color divider      = Color(0xFFF3E8F5);
  static const Color border       = Color(0xFFEDD8F0);
  static const Color borderStrong = Color(0xFFD9BEE0);

  // ── Symptom domain colors ────────────────────────────────────────────────
  static const Color pain       = Color(0xFFDC2626);
  static const Color fatigue    = Color(0xFFD97706);
  static const Color nausea     = Color(0xFF2563EB);
  static const Color appetite   = Color(0xFF22C55E);
  static const Color sleep      = Color(0xFF7C3AED);
  static const Color mood       = Color(0xFF0D9488);

  // ── Phase / domain colors ────────────────────────────────────────────────
  static const Color diagnosis    = Color(0xFF2563EB);
  static const Color chemo        = Color(0xFF7C3AED);
  static const Color radiation    = Color(0xFFD97706);
  static const Color surgery      = Color(0xFFDC2626);
  static const Color recoveryCol  = Color(0xFF22C55E);
  static const Color immunotherapy= Color(0xFF0D9488);

  // ── Community / avatar palette ───────────────────────────────────────────
  static const Color avatarViolet = Color(0xFF7C3AED);
  static const Color avatarEmerald= Color(0xFF22C55E);
  static const Color avatarBlue   = Color(0xFF2563EB);
  static const Color avatarAmber  = Color(0xFFD97706);
  static const Color avatarRose   = Color(0xFFF43F5E);
  static const Color avatarIndigo = Color(0xFF4F46E5);
  static const Color avatarTeal   = Color(0xFF0D9488);

  // ── Legacy aliases ───────────────────────────────────────────────────────
  static const Color primaryBackground   = background;
  static const Color secondaryBackground = primarySurface;

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [heroTop, heroMid, heroBottom],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient heroGradientSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC870C3), Color(0xFFB05AAF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), danger],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amberMedium, amber],
  );

  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

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

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, Color(0xFF0F766E)],
  );
}

// ─── Shadows ─────────────────────────────────────────────────────────────────
class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.06),
      blurRadius: 12, offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get cardElevated => [
    BoxShadow(
      color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
      blurRadius: 20, offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.04),
      blurRadius: 4, offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get glass => [
    BoxShadow(
      color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
      blurRadius: 28, offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get fab => [
    BoxShadow(
      color: const Color(0xFF7C3AED).withValues(alpha: 0.36),
      blurRadius: 20, offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.06),
      blurRadius: 6, offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> get nav => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.06),
      blurRadius: 16, offset: const Offset(0, -2),
    ),
  ];

  static List<BoxShadow> get danger => [
    BoxShadow(
      color: const Color(0xFFDC2626).withValues(alpha: 0.22),
      blurRadius: 14, offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get accent => [
    BoxShadow(
      color: const Color(0xFF7C3AED).withValues(alpha: 0.28),
      blurRadius: 14, offset: const Offset(0, 4),
    ),
  ];
}

// ─── Spacing ─────────────────────────────────────────────────────────────────
class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;  // minimum section spacing
  static const double xl  = 32;  // screen top padding
  static const double xxl = 48;

  static const double cardRadius   = 16;
  static const double heroRadius   = 20;
  static const double chipRadius   = 50;
  static const double buttonRadius = 14;
  static const double inputRadius  = 14;
  static const double iconRadius   = 12;

  // Per spec: 24px sides, 32px top, 20px card padding
  static const EdgeInsets pagePadding    = EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets pageTopPadding = EdgeInsets.fromLTRB(24, 32, 24, 0);
  static const EdgeInsets cardPadding    = EdgeInsets.all(20);
  static const SizedBox sectionGap       = SizedBox(height: 24);
}

// ─── Text styles ─────────────────────────────────────────────────────────────
class AppText {
  // heading: 26sp min, body: 18sp min, line-height: 1.7

  static TextStyle display([Color? color]) => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w700,
    color: color ?? AppColors.textPrimary, letterSpacing: -0.3, height: 1.4);

  static TextStyle headline([Color? color]) => GoogleFonts.inter(
    fontSize: 26, fontWeight: FontWeight.w700,
    color: color ?? AppColors.textPrimary, letterSpacing: -0.2, height: 1.4);

  static TextStyle title([Color? color]) => GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w600,
    color: color ?? AppColors.textPrimary, height: 1.4);

  static TextStyle subtitle([Color? color]) => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w500,
    color: color ?? AppColors.textSecondary, height: 1.7);

  static TextStyle body([Color? color]) => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w400,
    color: color ?? AppColors.textSecondary, height: 1.7);

  static TextStyle bodySmall([Color? color]) => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: color ?? AppColors.textSecondary, height: 1.7);

  static TextStyle caption([Color? color]) => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w500,
    color: color ?? AppColors.textTertiary, height: 1.5);

  static TextStyle captionSmall([Color? color]) => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: color ?? AppColors.textSecondary,
    fontStyle: FontStyle.italic, height: 1.4);

  static TextStyle label([Color? color]) => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: color ?? AppColors.textPrimary);

  static TextStyle overline([Color? color]) => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w700,
    color: color ?? AppColors.textMuted, letterSpacing: 0.8);

  // On-dark variants
  static TextStyle headlineDark() => GoogleFonts.inter(
    fontSize: 26, fontWeight: FontWeight.w700,
    color: Colors.white, letterSpacing: -0.3, height: 1.4);

  static TextStyle bodyDark() => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w400,
    color: AppColors.textOnDarkMuted, height: 1.7);

  static TextStyle captionDark() => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w500,
    color: Colors.white70, height: 1.5);
}

// ─── Glassmorphism helpers ────────────────────────────────────────────────────
class GlassMorphism {
  static BoxDecoration light({double radius = 20, double borderOpacity = 0.22}) =>
    BoxDecoration(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: borderOpacity), width: 1),
    );

  static BoxDecoration card({double radius = 16}) => BoxDecoration(
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
  /// Standard white card — shadow: 0 2px 12px rgba(0,0,0,0.06)
  static BoxDecoration card({double radius = 16, Color? borderColor}) =>
    BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.border.withValues(alpha: 0.5), width: 1),
      boxShadow: AppShadows.card,
    );

  /// Tinted card for semantic states
  static BoxDecoration tinted(Color color, {double radius = 16}) =>
    BoxDecoration(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withValues(alpha: 0.20), width: 1),
    );

  /// Icon container
  static BoxDecoration icon(Color color, {double radius = 12}) =>
    BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(radius),
    );

  /// Hero gradient card
  static BoxDecoration hero({double radius = 20}) =>
    BoxDecoration(
      gradient: AppColors.heroGradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: AppShadows.cardElevated,
    );

  /// Warm surface
  static BoxDecoration warm({double radius = 16}) =>
    BoxDecoration(
      gradient: AppColors.warmGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
      boxShadow: AppShadows.card,
    );

  /// Card with amber left border (Yusr tip / warnings)
  static BoxDecoration amberBorder({double radius = 16}) => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border(
      left: const BorderSide(color: AppColors.amber, width: 4),
      top: BorderSide(color: AppColors.border.withValues(alpha: 0.4), width: 1),
      right: BorderSide(color: AppColors.border.withValues(alpha: 0.4), width: 1),
      bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.4), width: 1),
    ),
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
        secondary: AppColors.teal,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge:   TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 32),
          displayMedium:  TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 28),
          headlineLarge:  TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 26, height: 1.4),
          headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 22),
          headlineSmall:  TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
          titleLarge:     TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 22),
          titleMedium:    TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
          titleSmall:     TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 16),
          bodyLarge:      TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w400, fontSize: 18, height: 1.7),
          bodyMedium:     TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w400, fontSize: 18, height: 1.7),
          bodySmall:      TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w400, fontSize: 16, height: 1.7),
          labelLarge:     TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
          labelMedium:    TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 16),
          labelSmall:     TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22, fontWeight: FontWeight.w700,
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
          textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
          textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundWarm,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 18),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primarySurface,
        labelStyle: const TextStyle(
          color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius)),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider, space: 0, thickness: 1),
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),
    );
  }
}
