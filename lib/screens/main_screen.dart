import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';
import 'today/today_screen.dart';
import 'journey/journey_screen.dart';
import 'care/care_screen.dart';
import 'community/community_screen.dart';
import 'yusr/yusr_overlay.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, provider, _) {
      final isArabic = provider.isArabic;
      final l = AppLocalizations(isArabic: isArabic);

      const tabScreens = [
        TodayScreen(),
        JourneyScreen(),
        CareScreen(),
        CommunityScreen(),
      ];

      return Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                Column(
                  children: [
                    if (provider.isDemoMode) _DemoBanner(l: l),
                    Expanded(
                      child: IndexedStack(
                        index: provider.currentTabIndex.clamp(0, 3),
                        children: tabScreens,
                      ),
                    ),
                    _BottomNav(
                      currentIndex: provider.currentTabIndex.clamp(0, 3),
                      l: l,
                    ),
                  ],
                ),
                // Floating Yusr button
                Positioned(
                  bottom: 96,
                  right: 16,
                  child: _FloatingYusrButton(),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Floating Yusr Button
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingYusrButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) => const YusrOverlay(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(
              opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryMid, AppColors.gradEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.chat_bubble_outline_rounded,
            color: Colors.white, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Demo Banner
// ─────────────────────────────────────────────────────────────────────────────
class _DemoBanner extends StatelessWidget {
  final AppLocalizations l;
  const _DemoBanner({required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFBEB),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 14, color: AppColors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.demoBanner,
              style: tsBodySm(c: AppColors.amberDark, w: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: () => context.read<AppProvider>().exitDemoMode(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(l.demoExit,
                  style: tsBodySm(c: AppColors.primary, w: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Bottom Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final AppLocalizations l;
  const _BottomNav({required this.currentIndex, required this.l});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _TabItem(icon: Icons.home_outlined,    activeIcon: Icons.home_rounded,        label: l.tabToday),
      _TabItem(icon: Icons.route_outlined,   activeIcon: Icons.route_rounded,       label: l.tabJourney),
      _TabItem(icon: Icons.favorite_outline, activeIcon: Icons.favorite_rounded,    label: l.tabCare),
      _TabItem(icon: Icons.people_outline,   activeIcon: Icons.people_alt_rounded,  label: l.tabConnect),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<AppProvider>().setTab(i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Active indicator dot
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 20 : 0,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Icon(
                          active ? tabs[i].activeIcon : tabs[i].icon,
                          color: active
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tabs[i].label,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: active
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem(
      {required this.icon, required this.activeIcon, required this.label});
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared Screen Header
// ─────────────────────────────────────────────────────────────────────────────
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showAvatar;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isArabic = provider.isArabic;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Brand wordmark pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: Text(
              isArabic ? 'رحلة' : 'Rehlah',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(subtitle!,
                      style: tsBodySm(c: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          if (showAvatar)
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: provider,
                    child: Directionality(
                      textDirection:
                          isArabic ? TextDirection.rtl : TextDirection.ltr,
                      child: const ProfileScreen(),
                    ),
                  ),
                ),
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryMid, AppColors.gradEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    provider.userName.isNotEmpty
                        ? provider.userName[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
