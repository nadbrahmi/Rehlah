// ── Care Hub (Screen 8) ───────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/shared_widgets.dart';
import '../../../../../core/utils/models.dart';

// ── Screen 8: Care Hub (entry point for Care tab) ────────────────────────────
// Note: The Care tab actually routes directly to LabResultsScreen.
// The Care Hub is a separate dedicated screen reached via navigation.

// ── Screen 9: Lab Results ─────────────────────────────────────────────────────
class LabResultsScreen extends StatelessWidget {
  const LabResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final latest = MockData.labs.first;
    final hasIssue = latest.metrics.any((m) => !m.isNormal);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/care'),
                    child: Row(children: [
                      Icon(Icons.arrow_back_ios_new_rounded, size: 15,
                        color: AppColors.text2.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Text('Care hub', style: AppText.caption.copyWith(
                        color: AppColors.text2, fontSize: 11)),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        RichText(text: TextSpan(
                          style: AppText.displayTitle,
                          children: const [
                            TextSpan(text: 'Lab '),
                            TextSpan(text: 'results',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        )),
                        Text('Last updated ${DateFormat('d MMM').format(latest.date)}',
                          style: AppText.bodySecondary),
                      ]),
                      GestureDetector(
                        onTap: () => context.push('/care/labs/add'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: AppRadius.fullBR,
                            border: Border.all(color: AppColors.primaryMid, width: 0.5),
                          ),
                          child: Text('+ Add', style: AppText.caption.copyWith(
                            color: AppColors.primary, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
            SliverToBoxAdapter(child: HeroCard(
              gradientColors: const [
                Color(0xFFD8E8F8), Color(0xFFCCC0EC), Color(0xFFD0E0F0)],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.peach.withOpacity(0.18),
                      borderRadius: AppRadius.fullBR,
                      border: Border.all(color: AppColors.peach.withOpacity(0.3), width: 0.5),
                    ),
                    child: Text(
                      hasIssue ? '⚠ Needs attention' : '✓ All normal',
                      style: AppText.caption.copyWith(
                        color: hasIssue ? const Color(0xFF804020) : AppColors.teal,
                        fontWeight: FontWeight.w500, fontSize: 11)),
                  ),
                  Text('${latest.panelName} · ${DateFormat('MMMM d, y').format(latest.date)}',
                    style: AppText.sectionHeading.copyWith(fontSize: 14)),
                  const SizedBox(height: 3),
                  Text('Hemoglobin is low — common during chemo. Your team is monitoring it.',
                    style: AppText.bodySecondary),
                  const SizedBox(height: 12),
                  Row(children: latest.metrics.map((m) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: m != latest.metrics.last ? 5 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: AppRadius.smBR,
                        border: Border.all(color: Colors.white.withOpacity(0.65), width: 0.5),
                      ),
                      child: Column(children: [
                        Text(m.value.toStringAsFixed(m.value.truncateToDouble() == m.value ? 0 : 1),
                          style: AppText.sectionHeading.copyWith(
                            fontSize: 16,
                            color: m.isNormal ? AppColors.teal : AppColors.peach)),
                        const SizedBox(height: 2),
                        Text(m.name.substring(0, m.name.length > 3 ? 3 : m.name.length).toUpperCase(),
                          style: AppText.caption.copyWith(fontSize: 9)),
                      ]),
                    ),
                  )).toList()),
                ],
              ),
            )),
            if (latest.aiSummary != null)
              SliverToBoxAdapter(child: InsightCard(
                title: 'AI summary',
                body: latest.aiSummary!,
              )),
            SliverToBoxAdapter(child: GestureDetector(
              onTap: () => context.push('/care/labs/history'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Text('View all lab history →',
                  style: AppText.bodySemibold.copyWith(
                    color: AppColors.primary, fontSize: 13)),
              ),
            )),
            ...latest.metrics.map((m) => SliverToBoxAdapter(
              child: _buildMetricCard(m))),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(LabMetric m) {
    final color = m.isNormal ? AppColors.teal : AppColors.peach;
    final normalPct = (m.normalMin / m.normalMax).clamp(0.0, 1.0);
    final valuePct = (m.value / m.normalMax).clamp(0.0, 1.0);

    return SurfaceCard(
      child: Column(
        children: [
          Row(children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: m.isNormal ? AppColors.tealLight : AppColors.peachLight,
                borderRadius: AppRadius.smBR,
              ),
              child: Icon(Icons.circle_rounded,
                size: 14, color: m.isNormal ? AppColors.teal : AppColors.peach),
            ),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.name, style: AppText.bodySemibold),
              Text('Normal: ${m.normalMin}–${m.normalMax} ${m.unit}',
                style: AppText.caption),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(m.value.toStringAsFixed(1),
                style: AppText.sectionHeading.copyWith(color: color, fontSize: 16)),
              Text(m.unit, style: AppText.caption),
              if (m.trend != null) Text(
                '${m.trend! >= 0 ? '↑' : '↓'} ${m.trend!.abs().toStringAsFixed(1)}',
                style: AppText.caption.copyWith(
                  color: color, fontWeight: FontWeight.w500, fontSize: 10)),
            ]),
          ]),
          const SizedBox(height: 10),
          // Simple sparkline placeholder
          Container(
            height: 28,
            decoration: BoxDecoration(
              color: m.isNormal
                  ? AppColors.teal.withOpacity(0.06)
                  : AppColors.peach.withOpacity(0.06),
              borderRadius: AppRadius.smBR,
            ),
            child: Center(child: Text('↗ Trend chart',
              style: AppText.caption.copyWith(fontSize: 10))),
          ),
          const SizedBox(height: 8),
          // Range bar
          Stack(children: [
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: AppRadius.fullBR,
              ),
            ),
            Positioned(
              left: normalPct * 200,
              right: 0,
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.14),
                  borderRadius: AppRadius.fullBR,
                ),
              ),
            ),
            Positioned(
              left: valuePct * 200 - 6,
              top: -3,
              child: Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2.5),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 5),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('0', style: AppText.caption.copyWith(fontSize: 9)),
            Text('You ↑', style: AppText.caption.copyWith(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
            Text('Normal', style: AppText.caption.copyWith(fontSize: 9)),
            Text('${m.normalMax}', style: AppText.caption.copyWith(fontSize: 9)),
          ]),
        ],
      ),
    );
  }
}

// ── Screen 10: Lab History ────────────────────────────────────────────────────
class LabHistoryScreen extends StatelessWidget {
  const LabHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lab history'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.go('/care/labs'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push('/care/labs/add'),
            child: const Text('+ Add'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
            child: Text('April 2026', style: AppText.label),
          ),
          ...MockData.labs.map((lab) => _buildLabHistoryRow(context, lab)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Text('March 2026', style: AppText.label),
          ),
          _buildStaticLabRow('CBC · Mar 23',
              'Hemoglobin 12.1 · WBC 6.8 · PLT 210', false),
          _buildStaticLabRow('CBC · Mar 9',
              'Hemoglobin 12.8 · WBC 7.2 · PLT 220', false),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLabHistoryRow(BuildContext context, LabResult lab) {
    final hasIssue = lab.metrics.any((m) => !m.isNormal);
    final summary = lab.metrics
        .map((m) => '${m.name.substring(0, 3)} ${m.value.toStringAsFixed(1)}')
        .join(' · ');
    return GestureDetector(
      onTap: () => context.go('/care/labs'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${lab.panelName} · ${DateFormat('MMM d').format(lab.date)}',
              style: AppText.bodySemibold),
            Text(summary, style: AppText.bodySecondary),
          ])),
          PillBadge(
            text: hasIssue ? 'Needs attention' : 'Normal',
            bg: hasIssue ? AppColors.peachLight : AppColors.tealLight,
            textColor: hasIssue ? AppColors.peach : AppColors.teal,
          ),
        ]),
      ),
    );
  }

  Widget _buildStaticLabRow(String title, String subtitle, bool hasIssue) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppText.bodySemibold),
          Text(subtitle, style: AppText.bodySecondary),
        ])),
        PillBadge(
          text: hasIssue ? 'Needs attention' : 'Normal',
          bg: hasIssue ? AppColors.peachLight : AppColors.tealLight,
          textColor: hasIssue ? AppColors.peach : AppColors.teal,
        ),
      ]),
    );
  }
}

// ── Screen 11: Lab Add Form ───────────────────────────────────────────────────
class LabAddScreen extends StatelessWidget {
  const LabAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add lab result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.go('/care/labs'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TEST TYPE', style: AppText.label),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: 'Complete Blood Count (CBC)',
              items: const [
                DropdownMenuItem(value: 'Complete Blood Count (CBC)',
                  child: Text('Complete Blood Count (CBC)')),
                DropdownMenuItem(value: 'Metabolic Panel',
                  child: Text('Metabolic Panel')),
                DropdownMenuItem(value: 'Tumour Markers',
                  child: Text('Tumour Markers')),
              ],
              onChanged: (_) {},
              decoration: const InputDecoration(),
            ),
            const SizedBox(height: 14),
            Text('VALUE', style: AppText.label),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '10.2'),
            ),
            const SizedBox(height: 14),
            Text('UNIT', style: AppText.label),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(hintText: 'g/dL'),
            ),
            const SizedBox(height: 14),
            Text('DATE', style: AppText.label),
            const SizedBox(height: 8),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: DateFormat('MMMM d, y').format(DateTime.now()),
                suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.05),
                borderRadius: AppRadius.smBR,
                border: Border.all(color: AppColors.teal.withOpacity(0.18), width: 0.5),
              ),
              child: Row(children: [
                const Text('🔒', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 7),
                Expanded(child: Text(
                  'Stored only on your device. Never shared.',
                  style: AppText.caption.copyWith(color: AppColors.teal, fontSize: 11))),
              ]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/care/labs'),
              child: const Text('Save result'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => context.go('/care/labs'),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
