// Rehlah Design System v0.1 — new widget library
// Dependency order: StatusPill → PhaseBanner / PhaseSubheadPill →
//   AdherenceRing → Timeline → MetricCard → MoodLikert → SymptomSegmented →
//   AddSymptomDisclosure → TemperaturePromptCard → FeverRedFlagBanner →
//   Notes → SubmitFooter → TrendCard → LabRangeRow → AISummary →
//   CycleCalendar → CareTeamStrip → AskRehlahPrompt
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/rehlah_theme.dart';

// ─── StatusPill ───────────────────────────────────────────────────────────────
// 22 px tall pill with leading status dot. Used everywhere.

enum StatusPillVariant { warn, pos, alert, info, neutral }

class StatusPill extends StatelessWidget {
  final String label;
  final StatusPillVariant variant;

  const StatusPill(this.label, {super.key, this.variant = StatusPillVariant.neutral});

  @override
  Widget build(BuildContext context) {
    final (bg, dot, text) = switch (variant) {
      StatusPillVariant.warn    => (RColors.saffron100, RColors.saffron500, RColors.saffron700),
      StatusPillVariant.pos     => (RColors.sage100,    RColors.sage500,    RColors.sage700),
      StatusPillVariant.alert   => (RColors.clay100,    RColors.clay500,    RColors.clay700),
      StatusPillVariant.info    => (RColors.sky100,     RColors.sky500,     RColors.sand700),
      StatusPillVariant.neutral => (RColors.sand100,    RColors.sand400,    RColors.sand700),
    };

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: bg, borderRadius: RRadius.pillBR),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
        ),
        const SizedBox(width: 5),
        Text(label, style: RText.eyebrow.copyWith(
          color: text, letterSpacing: 0, fontSize: 11)),
      ]),
    );
  }
}

// ─── PhaseBanner ─────────────────────────────────────────────────────────────
// Gradient row: circle badge · eyebrow (warm) · title · subtitle · trailing pill.
// Variants: saffron (current/default) · clay (alert/nadir) · sage (complete)

enum PhaseBannerVariant { current, alert, complete }

class PhaseBanner extends StatelessWidget {
  final String eyebrow;      // e.g. "Cycle 2 of 6"
  final String title;        // e.g. "Recovery week · Day 7"
  final String subtitle;     // e.g. "Nadir window expected in 3 days"
  final String badge;        // shown inside circle — cycle number or glyph
  final PhaseBannerVariant variant;
  final Widget? trailingPill;

  const PhaseBanner({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.badge = '●',
    this.variant = PhaseBannerVariant.current,
    this.trailingPill,
  });

  @override
  Widget build(BuildContext context) {
    final (gradStart, border, badgeBg, badgeText, eyebrowColor) = switch (variant) {
      PhaseBannerVariant.current  => (RColors.saffron100, RColors.saffron300, RColors.saffron500, RColors.sand950,  RColors.saffron700),
      PhaseBannerVariant.alert    => (RColors.clay100,    RColors.clay300,    RColors.clay500,    RColors.surface,  RColors.clay700),
      PhaseBannerVariant.complete => (RColors.sage100,    RColors.sage300,    RColors.sage500,    RColors.surface,  RColors.sage700),
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-1, -0.3),
          end: Alignment.bottomRight,
          colors: [gradStart, RColors.sand100],
        ),
        borderRadius: RRadius.lgBR,
        border: Border.all(color: border, width: 1),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
          child: Center(
            child: Text(badge,
              style: TextStyle(color: badgeText, fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eyebrow.toUpperCase(),
              style: RText.eyebrow.copyWith(color: eyebrowColor)),
            const SizedBox(height: 2),
            Text(title,
              style: RText.body.copyWith(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 1),
            Text(subtitle,
              style: RText.small.copyWith(fontSize: 11, color: RColors.sand700)),
          ],
        )),
        if (trailingPill != null) ...[
          const SizedBox(width: 8),
          trailingPill!,
        ],
      ]),
    );
  }
}

// ─── PhaseSubheadPill ─────────────────────────────────────────────────────────
// Quiet flat pill under the greeting in check-in. Same 3 variants as PhaseBanner.

class PhaseSubheadPill extends StatelessWidget {
  final String label;
  final PhaseBannerVariant variant;

  const PhaseSubheadPill(this.label, {super.key, this.variant = PhaseBannerVariant.current});

  @override
  Widget build(BuildContext context) {
    final (bg, text) = switch (variant) {
      PhaseBannerVariant.current  => (RColors.saffron100, RColors.saffron700),
      PhaseBannerVariant.alert    => (RColors.clay100,    RColors.clay700),
      PhaseBannerVariant.complete => (RColors.sage100,    RColors.sage700),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: RRadius.pillBR),
      child: Text(label, style: RText.small.copyWith(color: text, fontWeight: FontWeight.w500)),
    );
  }
}

// ─── AdherenceRing ────────────────────────────────────────────────────────────
// 100 px SVG-style ring, 8 px stroke, color by percentage.

class AdherenceRing extends StatelessWidget {
  final double value; // 0.0–1.0
  final String label; // centre text, e.g. "87%"

  const AdherenceRing({super.key, required this.value, required this.label});

  Color get _ringColor {
    if (value >= 0.8) return RColors.sage500;
    if (value >= 0.5) return RColors.saffron500;
    return RColors.clay500;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100, height: 100,
      child: CustomPaint(
        painter: _RingPainter(value: value.clamp(0, 1), color: _ringColor),
        child: Center(
          child: Text(label, style: RText.h2.copyWith(
            fontFeatures: const [FontFeature('tnum')])),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  const _RingPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = (size.width - 8) / 2;
    const stroke = 8.0;

    // Track
    canvas.drawCircle(Offset(cx, cy), r, Paint()
      ..color = RColors.sand200
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke);

    if (value <= 0) return;

    // Arc — starts at top (-π/2), sweeps clockwise
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.color != color;
}

// ─── Timeline + TimelineItem ──────────────────────────────────────────────────

enum TimelineStatus { taken, missed, next, scheduled }

class TimelineItem {
  final String time;
  final String title;
  final String? subtitle;
  final TimelineStatus status;

  const TimelineItem({
    required this.time,
    required this.title,
    this.subtitle,
    this.status = TimelineStatus.scheduled,
  });
}

class Timeline extends StatelessWidget {
  final List<TimelineItem> items;

  const Timeline({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (int i = 0; i < items.length; i++)
        _TimelineRow(item: items[i], isLast: i == items.length - 1),
    ]);
  }
}

class _TimelineRow extends StatelessWidget {
  final TimelineItem item;
  final bool isLast;

  const _TimelineRow({required this.item, required this.isLast});

  Color get _dotColor => switch (item.status) {
    TimelineStatus.taken     => RColors.sage500,
    TimelineStatus.missed    => RColors.clay500,
    TimelineStatus.next      => RColors.saffron500,
    TimelineStatus.scheduled => RColors.sand300,
  };

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Time column
        SizedBox(
          width: 52,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(item.time, style: RText.small.copyWith(
              fontFeatures: const [FontFeature('tnum')])),
          ),
        ),
        // Thread + dot
        Column(children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _dotColor),
          ),
          if (!isLast)
            Expanded(child: Container(width: 1.5, color: RColors.sand200)),
        ]),
        const SizedBox(width: 12),
        // Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: item.status == TimelineStatus.next
                    ? RColors.saffron100
                    : RColors.surface,
                borderRadius: RRadius.mdBR,
                boxShadow: RShadow.shadow1,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.title, style: RText.body.copyWith(fontWeight: FontWeight.w500)),
                if (item.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(item.subtitle!, style: RText.small),
                ],
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── MetricCard ───────────────────────────────────────────────────────────────
// Compact: icon tile · label · big tabular value · "X ago" caption.

class MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final String? caption;

  const MetricCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        boxShadow: RShadow.shadow2,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: iconBg, borderRadius: RRadius.smBR),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: 8),
        Text(label, style: RText.eyebrow),
        const SizedBox(height: 4),
        Text(value, style: RText.numericHero.copyWith(
          fontSize: 28,
          fontFeatures: const [FontFeature('tnum')],
          color: RColors.sand900,
        )),
        if (caption != null) ...[
          const SizedBox(height: 2),
          Text(caption!, style: RText.small),
        ],
      ]),
    );
  }
}

// ─── MoodLikert ───────────────────────────────────────────────────────────────
// 5-cell row of abstract glyphs. Selected = teal ring + teal-100 fill.

class MoodLikert extends StatelessWidget {
  final int? selected; // 0–4 (None → Best)
  final ValueChanged<int> onSelect;

  const MoodLikert({super.key, this.selected, required this.onSelect});

  static const _glyphs  = ['◔', '◑', '●', '◐', '◕'];
  static const _anchors = ['Terrible', 'Bad', 'Okay', 'Good', 'Great'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (i) {
        final isSelected = selected == i;
        return GestureDetector(
          onTap: () => onSelect(i),
          child: Column(children: [
            AnimatedContainer(
              duration: RMotion.duration,
              curve: RMotion.curve,
              width: 52, height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? RColors.teal100 : RColors.sand100,
                border: Border.all(
                  color: isSelected ? RColors.teal700 : RColors.sand200,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  const BoxShadow(
                    color: Color(0x1A275350),
                    blurRadius: 8, offset: Offset(0, 2)),
                ] : null,
              ),
              child: Center(
                child: Text(_glyphs[i], style: TextStyle(
                  fontSize: 22,
                  color: isSelected ? RColors.teal700 : RColors.sand500,
                )),
              ),
            ),
            const SizedBox(height: 6),
            Text(_anchors[i], style: RText.small.copyWith(
              fontSize: 10,
              color: isSelected ? RColors.teal700 : RColors.sand400,
            )),
          ]),
        );
      }),
    );
  }
}

// ─── SymptomSegmented ─────────────────────────────────────────────────────────
// 5-step segmented control. Severity ramp from SeverityColors extension.
// Stored as 0/2/5/7/10 via kSegmentedToNrs.

const kSegmentedToNrs = [0, 2, 5, 7, 10];
const kSegmentedAnchors = ['None', 'Mild', 'Mod.', 'Severe', 'Worst'];

class SymptomSegmented extends StatelessWidget {
  final String label;
  final int? selectedIndex; // 0–4
  final ValueChanged<int> onSelect;

  const SymptomSegmented({
    super.key,
    required this.label,
    this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final severity = Theme.of(context).extension<SeverityColors>()
        ?? SeverityColors.defaults;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: RText.body.copyWith(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Row(children: List.generate(5, (i) {
        final isFilled = selectedIndex != null && i <= selectedIndex!;
        final isSelected = selectedIndex == i;
        final fillColor = isFilled ? severity.steps[selectedIndex!] : Colors.transparent;
        final textColor = isFilled ? severity.textSteps[selectedIndex!] : RColors.sand400;

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: RMotion.duration,
              curve: RMotion.curve,
              height: 40,
              margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
              decoration: BoxDecoration(
                color: isFilled ? fillColor : Colors.transparent,
                borderRadius: RRadius.smBR,
                border: Border.all(
                  color: isFilled
                      ? fillColor
                      : RColors.sand200,
                  width: isSelected ? 2 : 1,
                  style: isFilled ? BorderStyle.solid : BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Text(kSegmentedAnchors[i], style: RText.small.copyWith(
                  fontSize: 11,
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                )),
              ),
            ),
          ),
        );
      })),
    ]);
  }
}

// ─── AddSymptomDisclosure ─────────────────────────────────────────────────────
// Dashed-outline pill "＋ Add another symptom" → expands to extra symptoms.

class AddSymptomDisclosure extends StatefulWidget {
  final List<String> extraSymptoms;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const AddSymptomDisclosure({
    super.key,
    required this.extraSymptoms,
    required this.selected,
    required this.onToggle,
  });

  @override
  State<AddSymptomDisclosure> createState() => _AddSymptomDisclosureState();
}

class _AddSymptomDisclosureState extends State<AddSymptomDisclosure> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: RRadius.pillBR,
            border: Border.all(
              color: RColors.sand300,
              width: 1.5,
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(_expanded ? Icons.remove : Icons.add,
                size: 16, color: RColors.teal700),
            const SizedBox(width: 6),
            Text(
              _expanded ? 'Fewer symptoms' : '＋ Add another symptom',
              style: RText.small.copyWith(color: RColors.teal700, fontWeight: FontWeight.w500),
            ),
          ]),
        ),
      ),
      if (_expanded) ...[
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final s in widget.extraSymptoms)
            GestureDetector(
              onTap: () => widget.onToggle(s),
              child: AnimatedContainer(
                duration: RMotion.duration,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.selected.contains(s)
                      ? RColors.teal100
                      : RColors.sand100,
                  borderRadius: RRadius.pillBR,
                  border: Border.all(
                    color: widget.selected.contains(s)
                        ? RColors.teal700
                        : RColors.sand200,
                  ),
                ),
                child: Text(s, style: RText.small.copyWith(
                  color: widget.selected.contains(s)
                      ? RColors.teal700
                      : RColors.sand700,
                )),
              ),
            ),
        ]),
      ],
    ]);
  }
}

// ─── TemperaturePromptCard ────────────────────────────────────────────────────
// Nadir-only: last reading + "Log temperature now →" CTA routing to /vitals.

class TemperaturePromptCard extends StatelessWidget {
  final double? lastReading;   // null = not recorded today
  final VoidCallback onTap;

  const TemperaturePromptCard({
    super.key,
    this.lastReading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final caption = lastReading != null
        ? '${lastReading!.toStringAsFixed(1)} °C recorded today'
        : 'Not recorded today';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: RColors.clay100,
          borderRadius: RRadius.mdBR,
          boxShadow: RShadow.shadow1,
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(
              color: RColors.clay300,
              borderRadius: RRadius.smBR,
            ),
            child: const Icon(Icons.thermostat_rounded,
                color: RColors.clay700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Temperature', style: RText.body.copyWith(
                  fontWeight: FontWeight.w500, color: RColors.clay700)),
              Text(caption, style: RText.small),
            ],
          )),
          Text('Log now →', style: RText.small.copyWith(
              color: RColors.clay700, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

// ─── FeverRedFlagBanner ───────────────────────────────────────────────────────
// Pinned top-of-scroll clay card. NOT a modal — pushes form down.

class FeverRedFlagBanner extends StatelessWidget {
  final double temperature;
  final VoidCallback onCallCareTeam;
  final VoidCallback onContinue;

  const FeverRedFlagBanner({
    super.key,
    required this.temperature,
    required this.onCallCareTeam,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RColors.clay100,
        borderRadius: RRadius.lgBR,
        border: Border.all(color: RColors.clay300, width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.warning_amber_rounded,
              color: RColors.clay500, size: 20),
          const SizedBox(width: 8),
          Text('URGENT', style: RText.eyebrow.copyWith(color: RColors.clay700)),
        ]),
        const SizedBox(height: 8),
        Text(
          '${temperature.toStringAsFixed(1)} °C',
          style: RText.numericHero.copyWith(
            fontSize: 36,
            color: RColors.clay700,
            fontFeatures: const [FontFeature('tnum')],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your temperature is above 38°C during nadir. '
          'This may indicate infection — please contact your care team now.',
          style: RText.body.copyWith(color: RColors.clay700),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: onCallCareTeam,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: RColors.clay500,
                borderRadius: RRadius.pillBR,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.phone_rounded, color: RColors.surface, size: 16),
                const SizedBox(width: 8),
                Text('Call care team now',
                    style: RText.body.copyWith(
                        color: RColors.surface, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: GestureDetector(
            onTap: onContinue,
            child: Text('Continue check-in',
                style: RText.small.copyWith(
                    decoration: TextDecoration.underline,
                    color: RColors.clay700)),
          ),
        ),
      ]),
    );
  }
}

// ─── Notes ────────────────────────────────────────────────────────────────────
// Sand-tinted input with inline mic chip.

class Notes extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onMicTap;

  const Notes({super.key, required this.controller, this.onMicTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RColors.sand50,
        borderRadius: RRadius.lgBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Notes', style: RText.body.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          Text('optional', style: RText.small),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 4,
          style: RText.body,
          decoration: InputDecoration(
            hintText: 'How are you feeling today? Any concerns?',
            hintStyle: RText.body.copyWith(color: RColors.sand400),
            filled: true,
            fillColor: RColors.surface,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: RRadius.mdBR,
              borderSide: const BorderSide(color: RColors.sand200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: RRadius.mdBR,
              borderSide: const BorderSide(color: RColors.sand200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: RRadius.mdBR,
              borderSide: const BorderSide(color: RColors.teal700, width: 1.5),
            ),
            suffixIcon: onMicTap != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8, right: 8),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: onMicTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: RColors.sand100,
                            borderRadius: RRadius.pillBR,
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.mic_none_rounded,
                                size: 14, color: RColors.sand700),
                            const SizedBox(width: 4),
                            Text('Speak', style: RText.small.copyWith(
                                color: RColors.sand700)),
                          ]),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ]),
    );
  }
}

// ─── SubmitFooter ─────────────────────────────────────────────────────────────
// Sticky-bottom full-width primary button with sand-50 gradient fade-out.

class SubmitFooter extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const SubmitFooter({
    super.key,
    this.label = 'Send to care team',
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            RColors.sand50.withValues(alpha: 0),
            RColors.sand50,
          ],
          stops: const [0.0, 0.35],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          16, 20, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: RMotion.duration,
          height: 52,
          decoration: BoxDecoration(
            color: enabled ? RColors.teal700 : RColors.sand200,
            borderRadius: RRadius.pillBR,
          ),
          child: Center(
            child: Text(label, style: RText.body.copyWith(
              color: enabled ? RColors.surface : RColors.sand400,
              fontWeight: FontWeight.w500,
            )),
          ),
        ),
      ),
    );
  }
}

// ─── TrendCard ────────────────────────────────────────────────────────────────
// Today-vs-yesterday comparison for check-in success screen.

enum TrendDirection { better, same, worse }

class TrendRow {
  final String label;
  final TrendDirection direction;
  const TrendRow(this.label, this.direction);
}

class TrendCard extends StatelessWidget {
  final List<TrendRow> rows;

  const TrendCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.lgBR,
        boxShadow: RShadow.shadow2,
      ),
      child: Column(children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Expanded(child: Text(row.label, style: RText.body)),
              _TrendChip(row.direction),
            ]),
          ),
      ]),
    );
  }
}

class _TrendChip extends StatelessWidget {
  final TrendDirection direction;
  const _TrendChip(this.direction);

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (direction) {
      TrendDirection.better => (Icons.arrow_downward_rounded, 'better', RColors.sage700),
      TrendDirection.same   => (Icons.arrow_forward_rounded,  'same',   RColors.sand500),
      TrendDirection.worse  => (Icons.arrow_upward_rounded,   'worse',  RColors.clay700),
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(label, style: RText.small.copyWith(color: color, fontWeight: FontWeight.w500)),
    ]);
  }
}

// ─── LabRangeRow ──────────────────────────────────────────────────────────────
// Name · gradient range bar · current value marker · monospace value + unit.

class LabRangeRow extends StatelessWidget {
  final String name;
  final double value;
  final double min;
  final double max;
  final String unit;

  const LabRangeRow({
    super.key,
    required this.name,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final isInRange = value >= min && value <= max;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(name, style: RText.body)),
          Text('${value.toStringAsFixed(1)} $unit',
              style: RText.bodyTabular.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isInRange ? RColors.sand900 : RColors.clay700)),
        ]),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (_, constraints) {
          final w = constraints.maxWidth;
          return Stack(children: [
            // Gradient bar: clay → sage → clay
            Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: RRadius.pillBR,
                gradient: const LinearGradient(
                  colors: [RColors.clay300, RColors.sage300, RColors.clay300],
                ),
              ),
            ),
            // Current value marker
            Positioned(
              left: (fraction * w - 4).clamp(0, w - 8),
              top: -2,
              child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isInRange ? RColors.teal700 : RColors.clay500,
                  border: Border.all(color: RColors.surface, width: 2),
                ),
              ),
            ),
          ]);
        }),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${min.toStringAsFixed(1)}', style: RText.small),
          Text('${max.toStringAsFixed(1)} $unit', style: RText.small),
        ]),
      ]),
    );
  }
}

// ─── AISummary ────────────────────────────────────────────────────────────────
// Teal-tinted card with sparkle icon and AI-generated text.

class AISummary extends StatelessWidget {
  final String text;
  final bool isLoading;

  const AISummary({super.key, required this.text, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RColors.teal50,
        borderRadius: RRadius.lgBR,
        border: Border.all(color: RColors.teal100),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('✦', style: TextStyle(color: RColors.teal700, fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: isLoading
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _shimmerLine(0.9),
                  const SizedBox(height: 6),
                  _shimmerLine(0.7),
                  const SizedBox(height: 6),
                  _shimmerLine(0.5),
                ])
              : Text(text, style: RText.body.copyWith(color: RColors.teal900)),
        ),
      ]),
    );
  }

  Widget _shimmerLine(double widthFraction) => FractionallySizedBox(
    widthFactor: widthFraction,
    child: Container(
      height: 12,
      decoration: BoxDecoration(
        color: RColors.teal100,
        borderRadius: RRadius.pillBR,
      ),
    ),
  );
}

// ─── CycleCalendar ────────────────────────────────────────────────────────────
// 7-col grid: today = teal-700 · cycle days = saffron · nadir = clay · appt dots.

class CycleCalendarDay {
  final DateTime date;
  final bool isToday;
  final bool isCycleDay;
  final bool isNadirDay;
  final bool hasAppointment;

  const CycleCalendarDay({
    required this.date,
    this.isToday = false,
    this.isCycleDay = false,
    this.isNadirDay = false,
    this.hasAppointment = false,
  });
}

class CycleCalendar extends StatelessWidget {
  final List<CycleCalendarDay> days;
  final ValueChanged<CycleCalendarDay>? onDayTap;

  const CycleCalendar({super.key, required this.days, this.onDayTap});

  static const _weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Week header
      Row(children: [
        for (final d in _weekLabels)
          Expanded(child: Center(
            child: Text(d, style: RText.eyebrow.copyWith(letterSpacing: 0)),
          )),
      ]),
      const SizedBox(height: 8),
      // Day grid
      GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
        children: days.map((day) => _CalendarCell(
          day: day, onTap: onDayTap != null ? () => onDayTap!(day) : null,
        )).toList(),
      ),
    ]);
  }
}

class _CalendarCell extends StatelessWidget {
  final CycleCalendarDay day;
  final VoidCallback? onTap;

  const _CalendarCell({required this.day, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.transparent;
    Color textColor = RColors.sand900;

    if (day.isToday) {
      bg = RColors.teal700;
      textColor = RColors.surface;
    } else if (day.isNadirDay) {
      bg = RColors.clay100;
      textColor = RColors.clay700;
    } else if (day.isCycleDay) {
      bg = RColors.saffron100;
      textColor = RColors.saffron700;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
          child: Center(
            child: Text('${day.date.day}', style: RText.small.copyWith(
              color: textColor,
              fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w400,
              fontFeatures: const [FontFeature('tnum')],
            )),
          ),
        ),
        if (day.hasAppointment)
          Container(
            width: 4, height: 4, margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle, color: RColors.sky500),
          ),
      ]),
    );
  }
}

// ─── CareTeamStrip ────────────────────────────────────────────────────────────
// Horizontal row of 48 px avatars with role label below.

class CareTeamMember {
  final String name;
  final String role;
  final String? initial;

  const CareTeamMember({required this.name, required this.role, this.initial});
}

class CareTeamStrip extends StatelessWidget {
  final List<CareTeamMember> members;

  const CareTeamStrip({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: members.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final m = members[i];
          final initial = m.initial ?? (m.name.isNotEmpty ? m.name[0] : '?');
          return SizedBox(
            width: 56,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: RColors.teal100,
                  border: Border.all(color: RColors.teal200, width: 1.5),
                ),
                child: Center(
                  child: Text(initial, style: RText.h3.copyWith(
                      color: RColors.teal700, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 4),
              Text(m.role, style: RText.small.copyWith(
                  fontSize: 10, color: RColors.sand500),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center),
            ]),
          );
        },
      ),
    );
  }
}

// ─── AskRehlahPrompt ─────────────────────────────────────────────────────────
// Inline suggestion row: teal sparkle · question · chevron → AI Chat.

class AskRehlahPrompt extends StatelessWidget {
  final String question;
  final VoidCallback onTap;

  const AskRehlahPrompt({
    super.key,
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: RColors.teal50,
          borderRadius: RRadius.mdBR,
        ),
        child: Row(children: [
          const Text('✦', style: TextStyle(color: RColors.teal700, fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(question, style: RText.body.copyWith(color: RColors.teal900)),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: RColors.teal500),
        ]),
      ),
    );
  }
}
