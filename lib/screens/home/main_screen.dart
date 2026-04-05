import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import '../journey/journey_screen.dart';
import '../checkin/checkin_screen.dart';
import '../care/care_hub_screen.dart';
import '../community/community_screen.dart';
import '../profile/profile_screen.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static List<Widget> get _screens => [
        const HomeScreen(),
        const JourneyScreen(),
        const DailyCheckInScreen(),
        const CareHubScreen(),
        const CommunityScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final idx = provider.currentNavIndex;

        return Scaffold(
          backgroundColor: AppColors.background,
          endDrawer: const Drawer(
            backgroundColor: AppColors.background,
            child: ProfileScreen(),
          ),
          body: Column(
            children: [
              if (provider.isDemoMode)
                _DemoBanner(
                  onExit: () async {
                    await provider.exitDemoMode();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                ),
              Expanded(
                child: IndexedStack(
                  index: idx,
                  children: _screens,
                ),
              ),
            ],
          ),
          bottomNavigationBar: _BottomNav(
            currentIndex: idx,
            hasCheckedIn: provider.hasCheckedInToday,
            onTap: (i) => provider.setNavIndex(i),
            onProfile: () => Scaffold.of(context).openEndDrawer(),
          ),
        );
      },
    );
  }
}

// ─── Demo Banner ──────────────────────────────────────────────────────────────
class _DemoBanner extends StatelessWidget {
  final VoidCallback onExit;
  const _DemoBanner({required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.heroGradientSoft),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Demo Mode — Sarah's journey (sample data)",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: onExit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.30)),
                  ),
                  child: const Text('Exit',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final bool hasCheckedIn;
  final ValueChanged<int> onTap;
  final VoidCallback onProfile;

  const _BottomNav({
    required this.currentIndex,
    required this.hasCheckedIn,
    required this.onTap,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        boxShadow: AppShadows.nav,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.show_chart_rounded,
                label: 'Journey',
                index: 1,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              // Center FAB — Check-In
              _CheckInFAB(
                hasCheckedIn: hasCheckedIn,
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.local_hospital_rounded,
                label: 'Care',
                index: 3,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.people_rounded,
                label: 'Community',
                index: 4,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                icon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                fontFamily: GoogleFonts.inter().fontFamily,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckInFAB extends StatelessWidget {
  final bool hasCheckedIn, isActive;
  final VoidCallback onTap;

  const _CheckInFAB({
    required this.hasCheckedIn,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: hasCheckedIn
                  ? AppColors.accentGradient
                  : AppColors.cardGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (hasCheckedIn
                          ? AppColors.accent
                          : AppColors.primary)
                      .withValues(alpha: isActive ? 0.50 : 0.28),
                  blurRadius: isActive ? 22 : 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                hasCheckedIn
                    ? Icons.check_rounded
                    : Icons.edit_note_rounded,
                key: ValueKey(hasCheckedIn),
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Check-In',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
