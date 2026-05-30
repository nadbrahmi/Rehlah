import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../theme/rehlah_theme.dart';
import '../../../../core/utils/user_session.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class _DataPoint {
  final DateTime time;
  final double value;
  final VitalFlag flag;
  const _DataPoint(this.time, this.value, this.flag);
}

class _Threshold {
  final double value;
  final Color color;
  final String label;
  const _Threshold(this.value, this.color, this.label);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class VitalsHistoryScreen extends StatelessWidget {
  const VitalsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vitals = UserSession().vitals.toList(); // oldest → newest
    final reversed = vitals.reversed.toList();    // newest first (for list)

    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        child: Column(children: [
          _topbar(context, vitals.length),
          Expanded(
            child: vitals.isEmpty
                ? _empty()
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._chartCards(vitals),
                        const SizedBox(height: 28),
                        Text('ALL READINGS', style: RText.eyebrow),
                        const SizedBox(height: 8),
                        _fullList(reversed, vitals),
                      ],
                    ),
                  ),
          ),
        ]),
      ),
    );
  }

  // ── Top bar ─────────────────────────────────────────────────────────────────
  Widget _topbar(BuildContext context, int count) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    child: Row(children: [
      GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: RColors.surface, shape: BoxShape.circle,
            border: Border.all(color: RColors.sand200)),
          child: const Icon(Icons.chevron_left_rounded,
              color: RColors.sand700, size: 22),
        ),
      ),
      const Expanded(child: Center(
        child: Text('Trends & History',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              letterSpacing: -0.2)),
      )),
      Container(
        height: 36, alignment: Alignment.center,
        child: Text('$count readings',
          style: const TextStyle(fontSize: 11, color: RColors.sand500)),
      ),
    ]),
  );

  // ── Empty state ──────────────────────────────────────────────────────────────
  Widget _empty() => const Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('📈', style: TextStyle(fontSize: 44)),
      SizedBox(height: 12),
      Text('No readings yet',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
            color: RColors.sand700)),
      SizedBox(height: 6),
      Text('Log your first vital to see trends here',
        style: TextStyle(fontSize: 13, color: RColors.sand400)),
    ]),
  );

  // ── Chart cards ──────────────────────────────────────────────────────────────
  List<Widget> _chartCards(List<VitalRecord> vitals) {
    final cards = <Widget>[];

    // Temperature
    final temps = _extract(vitals, (v) => v.temperatureCelsius, (v) => v.tempFlag);
    if (temps.isNotEmpty) {
      cards.add(_ChartCard(
        title: 'Temperature', unit: '°C', icon: Icons.thermostat_rounded,
        lineColor: RColors.clay500,
        points: temps,
        thresholds: const [
          _Threshold(37.5, RColors.saffron500, '37.5'),
          _Threshold(38.0, RColors.clay500, '38.0'),
        ],
        decimals: 1,
      ));
      cards.add(const SizedBox(height: 12));
    }

    // Blood pressure — systolic + diastolic on same chart
    final sys = _extract(vitals,
        (v) => v.systolicBp?.toDouble(),
        (v) => v.bpFlag,
        requirePair: true);
    final dia = _extract(vitals,
        (v) => v.diastolicBp?.toDouble(),
        (v) => v.bpFlag,
        requirePair: true);
    if (sys.isNotEmpty) {
      cards.add(_ChartCard(
        title: 'Blood pressure', unit: 'mmHg', icon: Icons.favorite_border_rounded,
        lineColor: RColors.teal700,
        points: sys,
        secondaryPoints: dia,
        secondaryColor: RColors.plum500,
        thresholds: const [
          _Threshold(140, RColors.saffron500, '140'),
          _Threshold(160, RColors.clay500, '160'),
        ],
        decimals: 0,
        legendLabels: ('Systolic', 'Diastolic'),
      ));
      cards.add(const SizedBox(height: 12));
    }

    // Heart rate
    final hrs = _extract(vitals, (v) => v.heartRateBpm?.toDouble(), (v) => v.hrFlag);
    if (hrs.isNotEmpty) {
      cards.add(_ChartCard(
        title: 'Heart rate', unit: 'bpm', icon: Icons.monitor_heart_outlined,
        lineColor: RColors.clay300,
        points: hrs,
        thresholds: const [
          _Threshold(50, RColors.clay500, '50'),
          _Threshold(100, RColors.clay500, '100'),
        ],
        decimals: 0,
      ));
      cards.add(const SizedBox(height: 12));
    }

    // SpO₂
    final o2s = _extract(vitals, (v) => v.spo2Pct?.toDouble(), (v) => v.spo2Flag);
    if (o2s.isNotEmpty) {
      cards.add(_ChartCard(
        title: 'Oxygen saturation', unit: '%', icon: Icons.air_rounded,
        lineColor: RColors.sky500,
        points: o2s,
        thresholds: const [
          _Threshold(94, RColors.clay500, '94%'),
          _Threshold(96, RColors.sage500, '96%'),
        ],
        decimals: 0,
        invertAlertDirection: true,
      ));
      cards.add(const SizedBox(height: 12));
    }

    // Blood glucose
    final glus = _extract(vitals, (v) => v.glucoseMmol, (v) => v.glucoseFlag);
    if (glus.isNotEmpty) {
      cards.add(_ChartCard(
        title: 'Blood glucose', unit: 'mmol/L', icon: Icons.water_drop_outlined,
        lineColor: RColors.saffron500,
        points: glus,
        thresholds: const [
          _Threshold(3.9, RColors.clay500, '3.9'),
          _Threshold(8.0, RColors.saffron500, '8.0'),
          _Threshold(11.0, RColors.clay500, '11.0'),
        ],
        decimals: 1,
      ));
      cards.add(const SizedBox(height: 12));
    }

    // Weight
    final wts = _extract(vitals, (v) => v.weightKg, (v) => VitalFlag.normal);
    if (wts.isNotEmpty) {
      cards.add(_ChartCard(
        title: 'Weight', unit: 'kg', icon: Icons.monitor_weight_outlined,
        lineColor: RColors.sage500,
        points: wts,
        thresholds: const [],
        decimals: 1,
        showDeltaInstead: true,
      ));
      cards.add(const SizedBox(height: 12));
    }

    return cards;
  }

  // ── Extract typed series from vitals ────────────────────────────────────────
  List<_DataPoint> _extract(
    List<VitalRecord> vitals,
    double? Function(VitalRecord) getValue,
    VitalFlag Function(VitalRecord) getFlag, {
    bool requirePair = false,
  }) {
    return vitals
        .where((v) => getValue(v) != null &&
            (!requirePair ||
                (v.systolicBp != null && v.diastolicBp != null)))
        .map((v) => _DataPoint(v.recordedAt, getValue(v)!, getFlag(v)))
        .toList();
  }

  // ── Full readings list ───────────────────────────────────────────────────────
  Widget _fullList(List<VitalRecord> reversed, List<VitalRecord> all) {
    return Container(
      decoration: const BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        boxShadow: RShadow.shadow1),
      child: Column(children: reversed.asMap().entries.map((e) {
        final isLast = e.key == reversed.length - 1;
        final v = e.value;
        final flag = v.worstFlag;
        final dotColor = flag == VitalFlag.high   ? RColors.clay500
            : flag == VitalFlag.moderate ? RColors.saffron500
            : RColors.sage500;

        return Container(
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
          decoration: isLast ? null : const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: RColors.sand200, width: 0.5))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(DateFormat('d MMM').format(v.recordedAt),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: RColors.sand700)),
              Text(DateFormat('HH:mm').format(v.recordedAt),
                style: const TextStyle(fontSize: 10, color: RColors.sand400)),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Wrap(spacing: 10, runSpacing: 3, children: [
              if (v.temperatureCelsius != null)
                _chip('${v.temperatureCelsius!.toStringAsFixed(1)}°C', v.tempFlag),
              if (v.systolicBp != null && v.diastolicBp != null)
                _chip('${v.systolicBp}/${v.diastolicBp}', v.bpFlag),
              if (v.heartRateBpm != null)
                _chip('${v.heartRateBpm} bpm', v.hrFlag),
              if (v.spo2Pct != null)
                _chip('${v.spo2Pct}% O₂', v.spo2Flag),
              if (v.glucoseMmol != null)
                _chip('${v.glucoseMmol!.toStringAsFixed(1)} mmol/L', v.glucoseFlag),
              if (v.weightKg != null)
                _chip('${v.weightKg!.toStringAsFixed(1)} kg', VitalFlag.normal),
            ])),
            Container(
              width: 8, height: 8,
              margin: const EdgeInsets.only(top: 3),
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          ]),
        );
      }).toList()),
    );
  }

  Widget _chip(String value, VitalFlag flag) {
    final c = flag == VitalFlag.high   ? RColors.clay500
        : flag == VitalFlag.moderate   ? RColors.saffron500
        : RColors.sand700;
    return Text(value,
      style: TextStyle(
        fontSize: 12, color: c,
        fontWeight: flag != VitalFlag.normal ? FontWeight.w600 : FontWeight.w400,
        fontFeatures: const [FontFeature('tnum')]));
  }
}

// ── Chart card widget ─────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final String unit;
  final IconData icon;
  final Color lineColor;
  final List<_DataPoint> points;
  final List<_DataPoint>? secondaryPoints;
  final Color? secondaryColor;
  final List<_Threshold> thresholds;
  final int decimals;
  final bool invertAlertDirection;
  final bool showDeltaInstead;
  final (String, String)? legendLabels;

  const _ChartCard({
    required this.title, required this.unit, required this.icon,
    required this.lineColor, required this.points,
    this.secondaryPoints, this.secondaryColor,
    required this.thresholds, required this.decimals,
    this.invertAlertDirection = false,
    this.showDeltaInstead = false,
    this.legendLabels,
  });

  // ── Stats ──────────────────────────────────────────────────────────────────
  double get _min => points.map((p) => p.value).reduce(math.min);
  double get _max => points.map((p) => p.value).reduce(math.max);
  double get _avg => points.map((p) => p.value).reduce((a, b) => a + b) / points.length;
  double get _latest => points.last.value;

  String _fmt(double v) => decimals > 0
      ? v.toStringAsFixed(decimals)
      : v.round().toString();

  // Trend: compare last vs previous. Returns 1 (up), -1 (down), 0 (flat)
  int get _trend {
    if (points.length < 2) return 0;
    final diff = points.last.value - points[points.length - 2].value;
    final threshold = (_max - _min) * 0.05; // 5% of range = "flat"
    if (diff.abs() < threshold) return 0;
    return diff > 0 ? 1 : -1;
  }

  // ── Y range for chart ──────────────────────────────────────────────────────
  (double, double) get _yRange {
    double lo = _min;
    double hi = _max;
    // Include secondary series
    if (secondaryPoints != null && secondaryPoints!.isNotEmpty) {
      lo = math.min(lo, secondaryPoints!.map((p) => p.value).reduce(math.min));
      hi = math.max(hi, secondaryPoints!.map((p) => p.value).reduce(math.max));
    }
    // Include thresholds that are "near" the data (within 30% of range)
    final range = math.max(hi - lo, 1.0);
    for (final t in thresholds) {
      if (t.value > lo - range * 0.5 && t.value < hi + range * 0.5) {
        lo = math.min(lo, t.value);
        hi = math.max(hi, t.value);
      }
    }
    // Add 10% padding
    final pad = math.max((hi - lo) * 0.15, 0.5);
    return (lo - pad, hi + pad);
  }

  @override
  Widget build(BuildContext context) {
    final (yMin, yMax) = _yRange;
    final trend = _trend;
    final trendIcon = trend == 1 ? '↑' : trend == -1 ? '↓' : '→';
    final trendColor = trend == 0 ? RColors.sand500 : lineColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: const BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.lgBR,
        boxShadow: RShadow.shadow2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ────────────────────────────────────────────────────────
        Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: lineColor.withValues(alpha: 0.12),
              borderRadius: RRadius.smBR),
            child: Icon(icon, size: 14, color: lineColor)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(title,
              style: RText.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          Text(
            '${_fmt(_latest)} $unit  $trendIcon',
            style: RText.body.copyWith(
              fontSize: 13, fontWeight: FontWeight.w600, color: trendColor,
              fontFeatures: const [FontFeature('tnum')])),
        ]),

        // ── Legend (for dual-series BP) ───────────────────────────────────
        if (legendLabels != null) ...[
          const SizedBox(height: 6),
          Row(children: [
            _legendDot(lineColor), const SizedBox(width: 4),
            Text(legendLabels!.$1, style: RText.small.copyWith(fontSize: 10)),
            const SizedBox(width: 12),
            _legendDot(secondaryColor ?? RColors.sand400), const SizedBox(width: 4),
            Text(legendLabels!.$2, style: RText.small.copyWith(fontSize: 10)),
          ]),
        ],

        const SizedBox(height: 12),

        // ── Chart ─────────────────────────────────────────────────────────
        SizedBox(
          height: 130,
          child: CustomPaint(
            size: const Size(double.infinity, 130),
            painter: _LinePainter(
              primary: points,
              secondary: secondaryPoints,
              secondaryColor: secondaryColor,
              lineColor: lineColor,
              thresholds: thresholds,
              yMin: yMin, yMax: yMax,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ── Stats row ─────────────────────────────────────────────────────
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _stat('MIN', _fmt(_min)),
          _divider(),
          _stat('AVG', _fmt(_avg)),
          _divider(),
          _stat('MAX', _fmt(_max)),
          if (showDeltaInstead && points.length >= 2) ...[
            _divider(),
            _stat('ΔLAST',
              '${points.last.value - points[points.length - 2].value > 0 ? "+" : ""}'
              '${(points.last.value - points[points.length - 2].value).toStringAsFixed(1)} kg',
            ),
          ],
          _divider(),
          _stat('READINGS', '${points.length}'),
        ]),
      ]),
    );
  }

  Widget _legendDot(Color c) => Container(
    width: 8, height: 8,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _stat(String label, String value) => Column(children: [
    Text(label,
      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
          color: RColors.sand400, letterSpacing: 0.5)),
    const SizedBox(height: 2),
    Text(value,
      style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600, color: RColors.sand900,
        fontFeatures: [FontFeature('tnum')])),
  ]);

  Widget _divider() => Container(
    width: 0.5, height: 28, color: RColors.sand200);
}

// ── Line chart painter ────────────────────────────────────────────────────────

class _LinePainter extends CustomPainter {
  final List<_DataPoint> primary;
  final List<_DataPoint>? secondary;
  final Color? secondaryColor;
  final Color lineColor;
  final List<_Threshold> thresholds;
  final double yMin;
  final double yMax;

  const _LinePainter({
    required this.primary,
    required this.lineColor,
    required this.thresholds,
    required this.yMin,
    required this.yMax,
    this.secondary,
    this.secondaryColor,
  });

  // Layout constants
  static const _lp = 36.0; // left pad (y-labels)
  static const _rp = 8.0;
  static const _tp = 8.0;
  static const _bp = 24.0; // bottom pad (x-labels)

  double _cx(int i, int n, double w) {
    if (n <= 1) return _lp + (w - _lp - _rp) / 2;
    return _lp + i * (w - _lp - _rp) / (n - 1);
  }

  double _cy(double v, double h) {
    final range = math.max(yMax - yMin, 0.001);
    return _tp + (h - _tp - _bp) * (1.0 - (v - yMin) / range);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final chartH = h - _tp - _bp;
    final n = primary.length;

    if (n == 0) return;

    // ── Background grid lines ──────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = RColors.sand200.withValues(alpha: 0.6)
      ..strokeWidth = 0.5;
    for (int r = 0; r <= 4; r++) {
      final y = _tp + chartH * r / 4;
      canvas.drawLine(Offset(_lp, y), Offset(w - _rp, y), gridPaint);
    }

    // ── Y-axis value labels ────────────────────────────────────────────────
    _paintYLabels(canvas, h);

    // ── Threshold lines (dashed) ───────────────────────────────────────────
    for (final t in thresholds) {
      final ty = _cy(t.value, h);
      if (ty < _tp - 2 || ty > h - _bp + 2) continue;
      _drawDashed(canvas, Offset(_lp, ty), Offset(w - _rp, ty),
        Paint()..color = t.color.withValues(alpha: 0.7)..strokeWidth = 1);
      // Label
      _paintText(canvas, t.label, Offset(_lp + 4, ty - 9),
        fontSize: 8, color: t.color);
    }

    // ── Primary series ─────────────────────────────────────────────────────
    _drawSeries(canvas, primary, lineColor, n, w, h);

    // ── Secondary series (BP diastolic) ───────────────────────────────────
    if (secondary != null && secondary!.isNotEmpty && secondaryColor != null) {
      _drawSeries(canvas, secondary!, secondaryColor!, secondary!.length, w, h,
          dashed: true);
    }

    // ── X-axis date labels ─────────────────────────────────────────────────
    _paintXLabels(canvas, primary, n, w, h);
  }

  void _drawSeries(Canvas canvas, List<_DataPoint> pts, Color color,
      int n, double w, double h, {bool dashed = false}) {
    if (pts.isEmpty) return;

    final xs = List.generate(pts.length, (i) => _cx(i, pts.length, w));
    final ys = List.generate(pts.length, (i) => _cy(pts[i].value, h));

    // ── Gradient fill under line ─────────────────────────────────────────
    if (pts.length >= 2 && !dashed) {
      final fillPath = Path();
      fillPath.moveTo(xs[0], ys[0]);
      for (int i = 1; i < pts.length; i++) {
        _addSmooth(fillPath, xs[i - 1], ys[i - 1], xs[i], ys[i]);
      }
      fillPath.lineTo(xs.last, h - _bp);
      fillPath.lineTo(xs[0], h - _bp);
      fillPath.close();

      final gradient = ui.Gradient.linear(
        Offset(0, _tp),
        Offset(0, h - _bp),
        [color.withValues(alpha: 0.18), color.withValues(alpha: 0.0)],
      );
      canvas.drawPath(fillPath,
        Paint()..shader = gradient..style = PaintingStyle.fill);
    }

    // ── Line ───────────────────────────────────────────────────────────────
    if (pts.length >= 2) {
      final linePath = Path();
      linePath.moveTo(xs[0], ys[0]);
      for (int i = 1; i < pts.length; i++) {
        _addSmooth(linePath, xs[i - 1], ys[i - 1], xs[i], ys[i]);
      }
      if (dashed) {
        _drawDashedPath(canvas, linePath,
          Paint()..color = color..strokeWidth = 1.5
              ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
      } else {
        canvas.drawPath(linePath,
          Paint()..color = color..strokeWidth = 2
              ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round);
      }
    }

    // ── Dots ───────────────────────────────────────────────────────────────
    for (int i = 0; i < pts.length; i++) {
      final dotColor = pts[i].flag == VitalFlag.high   ? RColors.clay500
          : pts[i].flag == VitalFlag.moderate ? RColors.saffron500
          : color;
      canvas.drawCircle(Offset(xs[i], ys[i]), 5,
        Paint()..color = Colors.white);
      canvas.drawCircle(Offset(xs[i], ys[i]), 3.5,
        Paint()..color = dotColor);
    }
  }

  // Smooth bezier segment between two points
  void _addSmooth(Path path, double x1, double y1, double x2, double y2) {
    final cpX = (x1 + x2) / 2;
    path.cubicTo(cpX, y1, cpX, y2, x2, y2);
  }

  // Y-axis: 3 labels (min, mid, max of chart range)
  void _paintYLabels(Canvas canvas, double h) {
    final labels = [yMax, (yMin + yMax) / 2, yMin];
    for (int i = 0; i < labels.length; i++) {
      final y = _cy(labels[i], h);
      final text = _fmtAxis(labels[i]);
      _paintText(canvas, text, Offset(0, y - 6),
        fontSize: 8.5, color: RColors.sand400);
    }
  }

  // X-axis: show date labels spaced nicely
  void _paintXLabels(Canvas canvas, List<_DataPoint> pts, int n, double w, double h) {
    if (n == 0) return;
    final maxLabels = math.min(n, 5);
    final step = math.max((n - 1) / (maxLabels - 1), 1).round();
    final shown = <int>{0};
    for (int i = step; i < n - 1; i += step) shown.add(i);
    shown.add(n - 1);

    for (final i in shown) {
      final x = _cx(i, n, w);
      final label = _fmtDate(pts[i].time, pts, i);
      _paintText(canvas, label, Offset(x - 12, h - _bp + 5),
        fontSize: 8, color: RColors.sand400);
    }
  }

  String _fmtDate(DateTime t, List<_DataPoint> all, int i) {
    if (i > 0 && DateFormat('dMMM').format(all[i - 1].time) ==
        DateFormat('dMMM').format(t)) {
      return DateFormat('HH:mm').format(t);
    }
    return DateFormat('d MMM').format(t);
  }

  String _fmtAxis(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(1);
  }

  // Draw a dashed horizontal line
  void _drawDashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dash = 4.0, gap = 3.0;
    double x = from.dx;
    while (x < to.dx) {
      canvas.drawLine(Offset(x, from.dy),
        Offset(math.min(x + dash, to.dx), to.dy), paint);
      x += dash + gap;
    }
  }

  // Draw a dashed path
  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dash = 5.0, gap = 3.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double dist = 0;
      bool drawing = true;
      while (dist < metric.length) {
        final len = drawing ? dash : gap;
        if (drawing) {
          canvas.drawPath(
            metric.extractPath(dist, math.min(dist + len, metric.length)),
            paint);
        }
        dist += len;
        drawing = !drawing;
      }
    }
  }

  // Paint a text string at position
  void _paintText(Canvas canvas, String text, Offset offset,
      {required double fontSize, required Color color}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, color: color,
            fontWeight: FontWeight.w500),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.primary != primary || old.yMin != yMin || old.yMax != yMax;
}
