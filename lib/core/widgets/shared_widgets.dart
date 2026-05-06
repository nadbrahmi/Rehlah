import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../utils/user_session.dart';

// ── App Header (used on all main screens) ────────────────────────────────────
class AppHeader extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final String? backLabel;
  final String backRoute;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.backLabel,
    this.backRoute = '/',
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  @override
  void initState() {
    super.initState();
    UserSession().addListener(_rebuild);
  }

  @override
  void dispose() {
    UserSession().removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    final initial = session.displayName.isNotEmpty
        ? session.displayName[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showBack)
            GestureDetector(
              onTap: () => context.go(widget.backRoute),
              child: Row(children: [
                Icon(Icons.arrow_back_ios_new_rounded, size: 15,
                  color: AppColors.text2.withOpacity(0.4)),
                const SizedBox(width: 4),
                Text(widget.backLabel ?? 'Back',
                  style: AppText.caption.copyWith(
                    color: AppColors.text2, fontSize: 11)),
              ]),
            ),
          if (widget.showBack) const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(text: TextSpan(
                      style: AppText.displayTitle,
                      children: widget.title.contains('|')
                          ? [
                              TextSpan(text: widget.title.split('|')[0]),
                              TextSpan(text: widget.title.split('|')[1],
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            ]
                          : [TextSpan(text: widget.title,
                              style: const TextStyle(fontWeight: FontWeight.w700))],
                    )),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(widget.subtitle!,
                        style: AppText.bodySecondary),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryMid, width: 0.5),
                  ),
                  child: Center(
                    child: Text(initial,
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      )),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class HeroCard extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;

  const HeroCard({super.key, required this.child, this.gradientColors, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-0.6, -0.8),
            end: const Alignment(1, 1),
            colors: gradientColors ?? const [
              AppColors.heroGrad1, AppColors.heroGrad2,
              AppColors.heroGrad3, AppColors.heroGrad4,
            ],
          ),
          borderRadius: AppRadius.lgBR,
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

// ── Surface Card ─────────────────────────────────────────────────────────────
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool aiTinted;

  const SurfaceCard({
    super.key, required this.child,
    this.margin, this.padding, this.onTap, this.aiTinted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.fromLTRB(14, 8, 14, 0),
        padding: padding ?? const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: aiTinted
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(
            color: aiTinted
                ? AppColors.primary.withOpacity(0.18)
                : AppColors.border,
            width: 0.5,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 6),
      child: Text(
        text.toUpperCase(),
        style: AppText.label.copyWith(
          fontSize: 10,
          letterSpacing: 0.8,
          color: AppColors.text3,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Pill Badge ────────────────────────────────────────────────────────────────
class PillBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color textColor;
  final Color? borderColor;

  const PillBadge({
    super.key, required this.text,
    required this.bg, required this.textColor, this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.fullBR,
        border: Border.all(
          color: borderColor ?? bg,
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: AppText.caption.copyWith(
          color: textColor, fontWeight: FontWeight.w500, fontSize: 10,
        ),
      ),
    );
  }
}

// ── Hero Pill (inside gradient card) ─────────────────────────────────────────
class HeroPill extends StatelessWidget {
  final String text;
  final bool hasLeadingDot;

  const HeroPill(this.text, {super.key, this.hasLeadingDot = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: AppRadius.fullBR,
        border: Border.all(color: Colors.white.withOpacity(0.7), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasLeadingDot) ...[
            Container(
              width: 5, height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(text,
            style: AppText.caption.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w500, fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tool Row (Care Hub rows) ──────────────────────────────────────────────────
class ToolRow extends StatelessWidget {
  final Widget icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool aiTinted;
  final bool alertTinted;
  final bool successTinted;

  const ToolRow({
    super.key,
    required this.icon, required this.iconBg,
    required this.title, required this.subtitle,
    this.trailing, this.onTap,
    this.aiTinted = false,
    this.alertTinted = false,
    this.successTinted = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = alertTinted
        ? AppColors.peach.withOpacity(0.05)
        : successTinted
            ? AppColors.teal.withOpacity(0.04)
            : aiTinted
                ? AppColors.primary.withOpacity(0.05)
                : AppColors.surface;
    final borderColor = alertTinted
        ? AppColors.peach.withOpacity(0.22)
        : successTinted
            ? AppColors.teal.withOpacity(0.18)
            : aiTinted
                ? AppColors.primary.withOpacity(0.18)
                : AppColors.border;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: AppRadius.smBR),
              child: Center(child: icon),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: AppText.bodySemibold.copyWith(
                      color: alertTinted
                          ? AppColors.peach
                          : aiTinted ? AppColors.primary : AppColors.text1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.bodySecondary),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8), trailing!,
            ],
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.text1.withOpacity(0.18)),
          ],
        ),
      ),
    );
  }
}

// ── Nadir Warning Card ────────────────────────────────────────────────────────
class NadirCard extends StatelessWidget {
  final String title;
  final String body;

  const NadirCard({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 9, 14, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.peachLight,
        borderRadius: AppRadius.mdBR,
        border: const Border(left: BorderSide(color: AppColors.peach, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: AppText.bodySemibold.copyWith(color: AppColors.peach)),
          const SizedBox(height: 3),
          Text(body, style: AppText.bodySecondary),
        ],
      ),
    );
  }
}

// ── Encouragement / Green Note Card ──────────────────────────────────────────
class EncouragementCard extends StatelessWidget {
  final String text;
  final String emoji;

  const EncouragementCard({super.key, required this.text, this.emoji = '🌿'});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.06),
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.teal.withOpacity(0.18), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
              style: AppText.body.copyWith(color: AppColors.teal)),
          ),
        ],
      ),
    );
  }
}

// ── AI Insight Card ──────────────────────────────────────────────────────────
class InsightCard extends StatelessWidget {
  final String title;
  final String body;

  const InsightCard({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: AppRadius.mdBR,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.13), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✦', style: TextStyle(color: AppColors.primary, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: AppText.bodySemibold.copyWith(color: AppColors.primary)),
                const SizedBox(height: 3),
                Text(body, style: AppText.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress Bar ─────────────────────────────────────────────────────────────
class AppProgressBar extends StatelessWidget {
  final double value; // 0.0–1.0
  final Color? foreground;
  final double height;

  const AppProgressBar({
    super.key, required this.value,
    this.foreground, this.height = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.fullBR,
      child: LinearProgressIndicator(
        value: value,
        minHeight: height,
        backgroundColor: AppColors.primaryLight,
        valueColor: AlwaysStoppedAnimation(foreground ?? AppColors.primary),
      ),
    );
  }
}

// ── Bottom Nav ───────────────────────────────────────────────────────────────
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool checkInDone;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.checkInDone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.97),
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom / 2),
        child: Row(
          children: [
            _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded,
              label: 'Home', active: currentIndex == 0, onTap: () => onTap(0)),
            _NavItem(icon: Icons.monitor_heart_outlined, activeIcon: Icons.monitor_heart_rounded,
              label: 'My Health', active: currentIndex == 1, onTap: () => onTap(1)),
            // FAB slot
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => onTap(5),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: checkInDone
                            ? [const Color(0xFF3DB87A), const Color(0xFF2A9060)]
                            : [const Color(0xFF9B70E0), AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2.5),
                      boxShadow: [
                        checkInDone ? AppShadows.fabTeal : AppShadows.fab,
                      ],
                    ),
                    child: Icon(
                      checkInDone ? Icons.check_rounded : Icons.add_rounded,
                      color: Colors.white, size: 20,
                    ),
                  ),
                ),
              ),
            ),
            _NavItem(icon: Icons.local_hospital_outlined, activeIcon: Icons.local_hospital_rounded,
              label: 'Care', active: currentIndex == 2, onTap: () => onTap(2)),
            _NavItem(icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded,
              label: 'Connect', active: currentIndex == 3, onTap: () => onTap(3)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.activeIcon,
    required this.label, required this.active, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              size: 22,
              color: active ? AppColors.primary : AppColors.text1.withOpacity(0.18),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppText.caption.copyWith(
                fontSize: 9, fontWeight: FontWeight.w500,
                color: active ? AppColors.primary : AppColors.text3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
