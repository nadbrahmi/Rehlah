import 'package:flutter/material.dart';
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

      // Tab index mapping: 0=Home, 1=Journey, 2=Care, 3=Community
      const tabScreens = [
        TodayScreen(),
        JourneyScreen(),
        CareScreen(),
        CommunityScreen(),
      ];

      return Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
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
                  _BottomNav(currentIndex: provider.currentTabIndex.clamp(0, 3), l: l),
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
      );
    });
  }
}

// ── Floating Yusr Button ──────────────────────────────────────────────────────
class _FloatingYusrButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => const YusrOverlay(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          ),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
      ),
    );
  }
}

// ── Demo Banner ───────────────────────────────────────────────────────────────
class _DemoBanner extends StatelessWidget {
  final AppLocalizations l;
  const _DemoBanner({required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.amberLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l.demoBanner,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.amberDark, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTap: () => context.read<AppProvider>().exitDemoMode(),
            child: Text(l.demoExit,
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final AppLocalizations l;
  const _BottomNav({required this.currentIndex, required this.l});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _TabItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: l.tabToday),
      _TabItem(icon: Icons.route_outlined, activeIcon: Icons.route, label: l.tabJourney),
      _TabItem(icon: Icons.add_circle_outline, activeIcon: Icons.add_circle, label: l.tabCare),
      _TabItem(icon: Icons.people_outline, activeIcon: Icons.people, label: l.tabConnect),
    ];

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.read<AppProvider>().setTab(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    active ? tabs[i].activeIcon : tabs[i].icon,
                    color: active ? AppColors.primary : AppColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tabs[i].label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: active ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem({required this.icon, required this.activeIcon, required this.label});
}

// ── Shared screen header ──────────────────────────────────────────────────────
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'رحلة' : 'Rehlah',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(title,
                  style: GoogleFonts.almarai(
                      fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              if (subtitle != null)
                Text(subtitle!,
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          if (showAvatar)
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: provider,
                    child: Directionality(
                      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                      child: const ProfileScreen(),
                    ),
                  ),
                ),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : 'S',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
