import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import '../checkin/checkin_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../profile/profile_screen.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN — 4-Tab Navigation
// Tab 0: Home     Tab 1: Check-In     Tab 2: Yusr (AI)     Tab 3: Profile
// Labs, Meds, Appointments moved into Profile as sections
// ═══════════════════════════════════════════════════════════════════════════════

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static List<Widget> get _screens => const [
    HomeScreen(),          // 0 — Home
    DailyCheckInScreen(),  // 1 — Check-In
    AIAssistantScreen(),   // 2 — Yusr AI
    ProfileScreen(),       // 3 — Profile (contains Labs, Meds, Appointments)
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final idx = provider.currentNavIndex;

        return Scaffold(
          backgroundColor: AppColors.background,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Demo Mode — Sarah's journey (sample data)",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: onExit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                  ),
                  child: const Text('Exit',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
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

// ─── Bottom Navigation — 4 tabs ───────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final bool hasCheckedIn;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.hasCheckedIn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        boxShadow: AppShadows.nav,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Tab 0: Home
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              // Tab 1: Check-In (styled as prominent FAB-style)
              _CheckInTab(
                hasCheckedIn: hasCheckedIn,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              // Tab 2: Yusr AI
              _NavItem(
                icon: Icons.auto_awesome_rounded,
                label: 'Yusr',
                index: 2,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
              // Tab 3: Profile
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                index: 3,
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

// ─── Standard nav item ────────────────────────────────────────────────────────
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
      child: Container(
        constraints: const BoxConstraints(minWidth: 64, minHeight: 52),
        padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 14 : 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Check-In tab (center, visually prominent) ────────────────────────────────
class _CheckInTab extends StatelessWidget {
  final bool hasCheckedIn, isActive;
  final VoidCallback onTap;

  const _CheckInTab({
    required this.hasCheckedIn,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 72, minHeight: 52),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: hasCheckedIn
                    ? AppColors.teal
                    : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (hasCheckedIn ? AppColors.teal : AppColors.primary)
                        .withValues(alpha: isActive ? 0.45 : 0.22),
                    blurRadius: isActive ? 18 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  hasCheckedIn
                      ? Icons.check_rounded
                      : Icons.edit_note_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Check-In',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive
                    ? (hasCheckedIn ? AppColors.teal : AppColors.primary)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
