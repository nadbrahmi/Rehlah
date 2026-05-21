import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/rehlah_theme.dart';
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
                  color: RColors.sand700.withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Text(widget.backLabel ?? 'Back',
                  style: RText.small.copyWith(
                    color: RColors.sand700, fontSize: 11)),
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
                      style: RText.display,
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
                        style: RText.bodyMuted),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: RColors.teal50,
                    shape: BoxShape.circle,
                    border: Border.all(color: RColors.teal100, width: 0.5),
                  ),
                  child: Center(
                    child: Text(initial,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: RColors.teal700,
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


enum HeroVariant { teal, plum, sage }

class HeroCard extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;
  final HeroVariant variant;

  const HeroCard({
    super.key,
    required this.child,
    this.gradientColors,
    this.onTap,
    this.variant = HeroVariant.teal,
  });

  List<Color> _gradient() {
    if (gradientColors != null) return gradientColors!;
    return switch (variant) {
      HeroVariant.teal => const [RColors.teal700, RColors.teal600],
      HeroVariant.plum => const [RColors.plum700, RColors.plum500],
      HeroVariant.sage => const [RColors.sage700, RColors.sage500],
    };
  }

  static const _radius = BorderRadius.all(Radius.circular(24));

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradient(),
          ),
          borderRadius: _radius,
        ),
        child: ClipRRect(
          borderRadius: _radius,
          child: Stack(
            children: [
              // Saffron decorative bloom — top-end corner, mirrors in RTL
              Positioned(
                top: -28,
                right: isRtl ? null : -20,
                left: isRtl ? -20 : null,
                child: Container(
                  width: 112, height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        RColors.saffron300.withValues(alpha: 0.28),
                        RColors.saffron300.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                child: child,
              ),
            ],
          ),
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
        margin: margin ?? const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: aiTinted ? RColors.teal50 : RColors.surface,
          borderRadius: RRadius.lgBR,
          border: aiTinted
              ? Border.all(color: RColors.teal100, width: 1)
              : null,
          boxShadow: RShadow.shadow2,
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
        style: RText.eyebrow.copyWith(
          fontSize: 10,
          letterSpacing: 0.8,
          color: RColors.sand400,
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
        borderRadius: RRadius.pillBR,
        border: Border.all(
          color: borderColor ?? bg,
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: RText.small.copyWith(
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
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: RRadius.pillBR,
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasLeadingDot) ...[
            Container(
              width: 5, height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle, color: RColors.teal700,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(text,
            style: RText.small.copyWith(
              color: RColors.teal900,
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
    final Color bg;
    if (alertTinted) {
      bg = RColors.clay100;
    } else if (successTinted) {
      bg = RColors.sage100;
    } else if (aiTinted) {
      bg = RColors.teal50;
    } else {
      bg = RColors.surface;
    }

    final Color titleColor;
    if (alertTinted) {
      titleColor = RColors.clay700;
    } else if (aiTinted) {
      titleColor = RColors.teal700;
    } else {
      titleColor = RColors.sand900;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: RRadius.mdBR,
          boxShadow: RShadow.shadow1,
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: RRadius.smBR,
              ),
              child: Center(child: icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: RText.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                    style: RText.small.copyWith(
                      fontSize: 11,
                      color: RColors.sand500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ] else ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                size: 18, color: RColors.sand300),
            ],
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
      decoration: const BoxDecoration(
        color: RColors.clay100,
        borderRadius: RRadius.mdBR,
        border: Border(left: BorderSide(color: RColors.clay500, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: RText.body.copyWith(fontWeight: FontWeight.w500).copyWith(color: RColors.clay500)),
          const SizedBox(height: 3),
          Text(body, style: RText.bodyMuted),
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
        color: RColors.teal600.withValues(alpha: 0.06),
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.teal600.withValues(alpha: 0.18), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
              style: RText.body.copyWith(color: RColors.teal600)),
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
        color: RColors.teal700.withValues(alpha: 0.05),
        borderRadius: RRadius.mdBR,
        border: Border.all(
          color: RColors.teal700.withValues(alpha: 0.13), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✦', style: TextStyle(color: RColors.teal700, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: RText.body.copyWith(fontWeight: FontWeight.w500).copyWith(color: RColors.teal700)),
                const SizedBox(height: 3),
                Text(body, style: RText.bodyMuted),
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
      borderRadius: RRadius.pillBR,
      child: LinearProgressIndicator(
        value: value,
        minHeight: height,
        backgroundColor: RColors.teal50,
        valueColor: AlwaysStoppedAnimation(foreground ?? RColors.teal700),
      ),
    );
  }
}

// ── Bottom Nav ───────────────────────────────────────────────────────────────
class AppBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final checkInDone = UserSession().checkedInToday;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 38 + bottomPadding),
      child: SizedBox(
        height: 86, // 64 nav + 22 FAB overhang
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Nav pill
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 64,
                decoration: const BoxDecoration(
                  color: RColors.surface,
                  borderRadius: RRadius.xlBR,
                  boxShadow: RShadow.shadow3,
                ),
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Today',
                      active: widget.currentIndex == 0,
                      onTap: () => widget.onTap(0),
                    ),
                    _NavItem(
                      icon: Icons.favorite_border_rounded,
                      activeIcon: Icons.favorite_rounded,
                      label: 'Care',
                      active: widget.currentIndex == 1,
                      onTap: () => widget.onTap(1),
                    ),
                    const Expanded(child: SizedBox()), // FAB spacer
                    _NavItem(
                      icon: Icons.people_outline_rounded,
                      activeIcon: Icons.people_rounded,
                      label: 'Connect',
                      active: widget.currentIndex == 3,
                      onTap: () => widget.onTap(3),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      active: widget.currentIndex == 4,
                      onTap: () => widget.onTap(4),
                    ),
                  ],
                ),
              ),
            ),
            // FAB — floats above nav bar centre
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () => widget.onTap(5),
                child: Container(
                  width: 60, height: 60,
                  decoration: const BoxDecoration(
                    color: RColors.sand50, // 4 px border ring
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: checkInDone ? RColors.sage500 : RColors.saffron500,
                        shape: BoxShape.circle,
                        boxShadow: RShadow.shadow3,
                      ),
                      child: Icon(
                        checkInDone ? Icons.check_rounded : Icons.add_rounded,
                        color: RColors.surface,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? RColors.teal700 : RColors.sand400;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? activeIcon : icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: RText.eyebrow.copyWith(
                fontSize: 10,
                letterSpacing: 0,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
