// Rehlah Design System v0.1 — full token set
// Source of truth: design_handoff_rehlah/README.md § "Design tokens — exact values"
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────

abstract final class RColors {
  // Sand neutrals — page bg and surfaces
  static const sand50  = Color(0xFFFAF8F4);  // page background
  static const sand100 = Color(0xFFF3F0EA);  // subtle surface
  static const sand200 = Color(0xFFE6E1D7);  // divider, chip bg
  static const sand300 = Color(0xFFD2CABE);
  static const sand400 = Color(0xFFA89E8E);
  static const sand500 = Color(0xFF7E7468);  // muted text
  static const sand700 = Color(0xFF4F473C);
  static const sand900 = Color(0xFF231E16);  // primary text
  static const sand950 = Color(0xFF14110B);

  // Teal — primary "journey" color
  static const teal50  = Color(0xFFE6F2F1);
  static const teal100 = Color(0xFFCEE6E4);
  static const teal200 = Color(0xFFA7D2CE);
  static const teal500 = Color(0xFF457A77);
  static const teal600 = Color(0xFF356561);
  static const teal700 = Color(0xFF275350);  // primary brand
  static const teal900 = Color(0xFF142E2C);

  // Saffron — "today" / "act now" accent
  static const saffron100 = Color(0xFFFAF1DE);
  static const saffron300 = Color(0xFFE9C997);
  static const saffron500 = Color(0xFFD4A258);  // FAB / accent
  static const saffron700 = Color(0xFF8B6328);

  // Sage — positive / taken / complete
  static const sage100 = Color(0xFFE8F1E5);
  static const sage300 = Color(0xFFB4D2A9);
  static const sage500 = Color(0xFF7CA773);
  static const sage700 = Color(0xFF466540);

  // Clay — alert / fever / missed
  static const clay100 = Color(0xFFFAEAE0);
  static const clay300 = Color(0xFFE9B79A);
  static const clay500 = Color(0xFFC76F47);
  static const clay700 = Color(0xFF8B4824);

  // Sky — informational
  static const sky100 = Color(0xFFE7EEF8);
  static const sky500 = Color(0xFF6D8FB8);

  // Plum — caregiver mode / journey
  static const plum100 = Color(0xFFEDE3EE);
  static const plum500 = Color(0xFF8967A0);
  static const plum700 = Color(0xFF5B4276);

  static const surface = Color(0xFFFFFFFF);

  // Semantic aliases
  static const pageBackground = sand50;
  static const primaryText    = sand900;
  static const mutedText      = sand500;
  static const divider        = sand200;
}

// ─── Spacing Scale (4 px base) ────────────────────────────────────────────────

abstract final class RSpace {
  static const s4  =  4.0;
  static const s8  =  8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s40 = 40.0;
  static const s56 = 56.0;
  static const s72 = 72.0;
}

// ─── Radii ────────────────────────────────────────────────────────────────────

abstract final class RRadius {
  static const xs   = Radius.circular(6);
  static const sm   = Radius.circular(10);
  static const md   = Radius.circular(14);   // inline rows, metric cards
  static const lg   = Radius.circular(20);   // surface cards
  static const xl   = Radius.circular(28);   // hero cards, sheets
  static const pill = Radius.circular(999);  // buttons, status pills

  static const xsBR   = BorderRadius.all(xs);
  static const smBR   = BorderRadius.all(sm);
  static const mdBR   = BorderRadius.all(md);
  static const lgBR   = BorderRadius.all(lg);
  static const xlBR   = BorderRadius.all(xl);
  static const pillBR = BorderRadius.all(pill);
}

// ─── Elevation / Shadows ─────────────────────────────────────────────────────
// shadow color: rgba(40, 30, 20, α) → Color(0x__281E14)
//   α=.03 → 0x07   α=.04 → 0x0A   α=.05 → 0x0D   α=.08 → 0x14

abstract final class RShadow {
  // shadow-1: resting card
  static const shadow1 = [
    BoxShadow(color: Color(0x0A281E14), blurRadius: 2,  offset: Offset(0, 1)),
    BoxShadow(color: Color(0x07281E14), blurRadius: 1,  offset: Offset(0, 1)),
  ];

  // shadow-2: surface card
  static const shadow2 = [
    BoxShadow(color: Color(0x0D281E14), blurRadius: 6,  offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0A281E14), blurRadius: 12, offset: Offset(0, 4)),
  ];

  // shadow-3: sheet, FAB, bottom nav
  static const shadow3 = [
    BoxShadow(color: Color(0x14281E14), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0A281E14), blurRadius: 6,  offset: Offset(0, 2)),
  ];
}

// ─── Motion ───────────────────────────────────────────────────────────────────

abstract final class RMotion {
  static const curve    = Cubic(0.2, 0.8, 0.2, 1.0);  // default easing
  static const duration = Duration(milliseconds: 180);  // default transition
  static const pageDuration = Duration(milliseconds: 240); // slide-up page transitions
}

// ─── Typography ───────────────────────────────────────────────────────────────
// Tajawal: Arabic + Latin (weights 300/400/500/700/900)
// Newsreader: editorial/serif moments only (weights 400/500, italic 400)
// Tabular figures on all numeric values.

abstract final class RText {
  // Display — Newsreader 400, 40–64 px, for welcome / success state headings
  static TextStyle get display => GoogleFonts.newsreader(
    fontSize: 40, fontWeight: FontWeight.w400,
    height: 1.0, letterSpacing: -0.8,  // -0.02em × 40px
    color: RColors.sand900,
  );

  static TextStyle get displayLg => GoogleFonts.newsreader(
    fontSize: 64, fontWeight: FontWeight.w400,
    height: 1.0, letterSpacing: -1.28,  // -0.02em × 64px
    color: RColors.sand900,
  );

  static TextStyle get displayItalic => display.copyWith(fontStyle: FontStyle.italic);

  // Numeric hero — Tajawal 700, 48–56 px, tabular
  static TextStyle get numericHero => GoogleFonts.tajawal(
    fontSize: 52, fontWeight: FontWeight.w700,
    height: 1.0, letterSpacing: -1.04,  // -0.02em × 52px
    color: RColors.sand900,
    fontFeatures: const [FontFeature('tnum')],
  );

  // H1 — Tajawal 700, 32 px
  static TextStyle get h1 => GoogleFonts.tajawal(
    fontSize: 32, fontWeight: FontWeight.w700,
    height: 36 / 32, letterSpacing: -0.32,  // -0.01em × 32px
    color: RColors.sand900,
  );

  // H2 — Tajawal 700, 22 px (card titles, hero labels)
  static TextStyle get h2 => GoogleFonts.tajawal(
    fontSize: 22, fontWeight: FontWeight.w700,
    height: 28 / 22, letterSpacing: -0.22,  // -0.01em × 22px
    color: RColors.sand900,
  );

  // H3 — Tajawal 500, 18 px (subheads)
  static TextStyle get h3 => GoogleFonts.tajawal(
    fontSize: 18, fontWeight: FontWeight.w500,
    height: 24 / 18, letterSpacing: 0,
    color: RColors.sand900,
  );

  // Body — Tajawal 400, 15 px
  static TextStyle get body => GoogleFonts.tajawal(
    fontSize: 15, fontWeight: FontWeight.w400,
    height: 23 / 15, letterSpacing: 0,
    color: RColors.sand900,
  );

  // Small — Tajawal 400, 13 px (metadata, captions)
  static TextStyle get small => GoogleFonts.tajawal(
    fontSize: 13, fontWeight: FontWeight.w400,
    height: 19 / 13, letterSpacing: 0,
    color: RColors.sand500,
  );

  // Eyebrow — Tajawal 500, 11 px UPPERCASE, wide tracking
  static TextStyle get eyebrow => GoogleFonts.tajawal(
    fontSize: 11, fontWeight: FontWeight.w500,
    height: 1.0, letterSpacing: 1.54,  // 0.14em × 11px
    color: RColors.sand500,
  );

  // Tabular variant of body — for any inline numeric value
  static TextStyle get bodyTabular => body.copyWith(
    fontFeatures: const [FontFeature('tnum')],
  );

  // Convenience: muted / on-surface-dark variants
  static TextStyle get bodyMuted    => body.copyWith(color: RColors.sand500);
  static TextStyle get smallMuted   => small.copyWith(color: RColors.sand400);
  static TextStyle get h2OnDark     => h2.copyWith(color: RColors.surface);
  static TextStyle get bodyOnDark   => body.copyWith(color: RColors.surface);
  static TextStyle get smallOnDark  => small.copyWith(color: RColors.teal100);
  static TextStyle get eyebrowOnDark => eyebrow.copyWith(color: RColors.teal200);
}

// ─── SeverityColors ThemeExtension ───────────────────────────────────────────
// Maps 5-point segmented control steps to fill colors.
// None → Mild → Moderate → Severe → Worst
// Stored as 0 / 2 / 5 / 7 / 10 in DB (kSegmentedToNrs).

@immutable
class SeverityColors extends ThemeExtension<SeverityColors> {
  const SeverityColors({
    required this.none,
    required this.mild,
    required this.moderate,
    required this.severe,
    required this.worst,
    required this.noneText,
    required this.mildText,
    required this.moderateText,
    required this.severeText,
    required this.worstText,
  });

  final Color none;
  final Color mild;
  final Color moderate;
  final Color severe;
  final Color worst;
  final Color noneText;
  final Color mildText;
  final Color moderateText;
  final Color severeText;
  final Color worstText;

  // The five segment colors in order (index == step 0–4).
  List<Color> get steps => [none, mild, moderate, severe, worst];
  List<Color> get textSteps => [noneText, mildText, moderateText, severeText, worstText];

  static const defaults = SeverityColors(
    none:         RColors.sand200,
    mild:         RColors.saffron100,
    moderate:     RColors.saffron300,
    severe:       RColors.clay300,
    worst:        RColors.clay500,
    noneText:     RColors.sand700,
    mildText:     RColors.saffron700,
    moderateText: RColors.saffron700,
    severeText:   RColors.clay700,
    worstText:    RColors.surface,
  );

  @override
  SeverityColors copyWith({
    Color? none, Color? mild, Color? moderate, Color? severe, Color? worst,
    Color? noneText, Color? mildText, Color? moderateText, Color? severeText, Color? worstText,
  }) => SeverityColors(
    none:         none         ?? this.none,
    mild:         mild         ?? this.mild,
    moderate:     moderate     ?? this.moderate,
    severe:       severe       ?? this.severe,
    worst:        worst        ?? this.worst,
    noneText:     noneText     ?? this.noneText,
    mildText:     mildText     ?? this.mildText,
    moderateText: moderateText ?? this.moderateText,
    severeText:   severeText   ?? this.severeText,
    worstText:    worstText    ?? this.worstText,
  );

  @override
  SeverityColors lerp(ThemeExtension<SeverityColors>? other, double t) {
    if (other is! SeverityColors) return this;
    return SeverityColors(
      none:         Color.lerp(none,         other.none,         t)!,
      mild:         Color.lerp(mild,         other.mild,         t)!,
      moderate:     Color.lerp(moderate,     other.moderate,     t)!,
      severe:       Color.lerp(severe,       other.severe,       t)!,
      worst:        Color.lerp(worst,        other.worst,        t)!,
      noneText:     Color.lerp(noneText,     other.noneText,     t)!,
      mildText:     Color.lerp(mildText,     other.mildText,     t)!,
      moderateText: Color.lerp(moderateText, other.moderateText, t)!,
      severeText:   Color.lerp(severeText,   other.severeText,   t)!,
      worstText:    Color.lerp(worstText,    other.worstText,    t)!,
    );
  }
}

// ─── Theme Builder ────────────────────────────────────────────────────────────

ThemeData buildRehlahTheme() {
  final base = ThemeData(useMaterial3: true);

  const colorScheme = ColorScheme(
    brightness:      Brightness.light,
    primary:         RColors.teal700,
    onPrimary:       RColors.surface,
    primaryContainer: RColors.teal100,
    onPrimaryContainer: RColors.teal900,
    secondary:       RColors.saffron500,
    onSecondary:     RColors.surface,
    secondaryContainer: RColors.saffron100,
    onSecondaryContainer: RColors.saffron700,
    tertiary:        RColors.sage500,
    onTertiary:      RColors.surface,
    tertiaryContainer: RColors.sage100,
    onTertiaryContainer: RColors.sage700,
    error:           RColors.clay500,
    onError:         RColors.surface,
    errorContainer:  RColors.clay100,
    onErrorContainer: RColors.clay700,
    surface:         RColors.surface,
    onSurface:       RColors.sand900,
    onSurfaceVariant: RColors.sand500,
    outline:         RColors.sand200,
    outlineVariant:  RColors.sand100,
    shadow:          RColors.sand900,
    scrim:           RColors.sand950,
    inverseSurface:  RColors.sand900,
    onInverseSurface: RColors.sand50,
    inversePrimary:  RColors.teal200,
  );

  final textTheme = GoogleFonts.tajawalTextTheme(base.textTheme).copyWith(
    displayLarge:   RText.displayLg,
    displayMedium:  RText.display,
    displaySmall:   RText.h1,
    headlineLarge:  RText.h1,
    headlineMedium: RText.h2,
    headlineSmall:  RText.h3,
    titleLarge:     RText.h2,
    titleMedium:    RText.h3,
    titleSmall:     GoogleFonts.tajawal(
      fontSize: 15, fontWeight: FontWeight.w500,
      color: RColors.sand900,
    ),
    bodyLarge:  RText.body,
    bodyMedium: RText.body,
    bodySmall:  RText.small,
    labelLarge: GoogleFonts.tajawal(
      fontSize: 15, fontWeight: FontWeight.w500, color: RColors.surface,
    ),
    labelMedium: RText.eyebrow,
    labelSmall:  RText.small,
  );

  return base.copyWith(
    colorScheme:             colorScheme,
    scaffoldBackgroundColor: RColors.sand50,
    textTheme:               textTheme,
    extensions: const [SeverityColors.defaults],

    appBarTheme: AppBarTheme(
      backgroundColor:          RColors.sand50,
      surfaceTintColor:         Colors.transparent,
      shadowColor:              Colors.transparent,
      elevation:                0,
      scrolledUnderElevation:   0,
      centerTitle:              false,
      titleTextStyle:           RText.h3,
      iconTheme: const IconThemeData(color: RColors.sand900, size: 24),
    ),

    cardTheme: const CardThemeData(
      color:        RColors.surface,
      elevation:    0,
      shape:        RoundedRectangleBorder(borderRadius: RRadius.lgBR),
      margin:       EdgeInsets.zero,
    ),

    dividerTheme: const DividerThemeData(
      color: RColors.sand200, thickness: 1, space: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:  RColors.teal700,
        foregroundColor:  RColors.surface,
        elevation:        0,
        shadowColor:      Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: RRadius.pillBR),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(double.infinity, 52),
        textStyle: GoogleFonts.tajawal(
          fontSize: 15, fontWeight: FontWeight.w500,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RColors.teal700,
        side: const BorderSide(color: RColors.teal700, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: RRadius.pillBR),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(double.infinity, 52),
        textStyle: GoogleFonts.tajawal(
          fontSize: 15, fontWeight: FontWeight.w500,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: RColors.teal700,
        shape: const RoundedRectangleBorder(borderRadius: RRadius.pillBR),
        textStyle: GoogleFonts.tajawal(
          fontSize: 15, fontWeight: FontWeight.w500,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor:  RColors.saffron500,
        foregroundColor:  RColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: RRadius.pillBR),
        minimumSize: const Size(double.infinity, 52),
        textStyle: GoogleFonts.tajawal(
          fontSize: 15, fontWeight: FontWeight.w500,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled:    true,
      fillColor: RColors.surface,
      border: const OutlineInputBorder(
        borderRadius: RRadius.mdBR,
        borderSide: BorderSide(color: RColors.sand200, width: 1),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: RRadius.mdBR,
        borderSide: BorderSide(color: RColors.sand200, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: RRadius.mdBR,
        borderSide: BorderSide(color: RColors.teal700, width: 1.5),
      ),
      hintStyle:       RText.body.copyWith(color: RColors.sand400),
      contentPadding:  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    chipTheme: ChipThemeData(
      backgroundColor:  RColors.sand100,
      selectedColor:    RColors.teal100,
      labelStyle:       RText.small.copyWith(color: RColors.sand700),
      shape: const RoundedRectangleBorder(borderRadius: RRadius.pillBR),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      side: const BorderSide(color: RColors.sand200, width: 1),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: RColors.saffron500,
      foregroundColor: RColors.surface,
      elevation:       4,
      shape: RoundedRectangleBorder(borderRadius: RRadius.pillBR),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:  Colors.transparent,
      elevation:        0,
      selectedItemColor:   RColors.teal700,
      unselectedItemColor: RColors.sand400,
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color:              RColors.teal700,
      linearTrackColor:   RColors.sand200,
      circularTrackColor: RColors.sand100,
    ),

    switchTheme: SwitchThemeData(
      thumbColor:  WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? RColors.teal700 : RColors.sand400),
      trackColor:  WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? RColors.teal200 : RColors.sand200),
    ),

    sliderTheme: const SliderThemeData(
      activeTrackColor:   RColors.teal700,
      inactiveTrackColor: RColors.sand200,
      thumbColor:         RColors.teal700,
      overlayColor:       Color(0x1A275350),  // teal700 @ 10%
    ),
  );
}
