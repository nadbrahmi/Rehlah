import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../ai/lab_tracker_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../ai/lab_analyzer_screen.dart';
import '../checkin/voice_checkin_screen.dart';
import 'medication_tracker_screen.dart';
import 'appointment_tracker_screen.dart';

class CareHubScreen extends StatelessWidget {
  const CareHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Header ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.heroGradient),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Care Hub',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your health tools in one place',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: Container(
                color: const Color(0xFF150A30).withValues(alpha: 0.92),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Care Hub',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              titlePadding: EdgeInsets.zero,
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── MEDICATIONS & ADHERENCE ─────────────────────────────
                _HubLabel('MEDICATIONS & ADHERENCE',
                    action: 'Track', onAction: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MedicationTrackerScreen()))),
                const SizedBox(height: 12),
                const _MedicationsSummaryCard(),
                const SizedBox(height: 32),

                // ── APPOINTMENTS ─────────────────────────────────────────
                _HubLabel('APPOINTMENTS',
                    action: 'All', onAction: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AppointmentTrackerScreen()))),
                const SizedBox(height: 12),
                const _AppointmentsSummaryCard(),
                const SizedBox(height: 32),

                // ── EMOTIONAL WELLBEING ─────────────────────────────────
                _HubLabel('EMOTIONAL WELLBEING'),
                const SizedBox(height: 12),
                const _EmotionalCard(),
                const SizedBox(height: 32),

                // ── CARE TEAM ───────────────────────────────────────────
                _HubLabel('CARE TEAM'),
                const SizedBox(height: 12),
                const _CareTeamCard(),
                const SizedBox(height: 32),

                // ── CARE BINDER ─────────────────────────────────────────
                _HubLabel('CARE BINDER'),
                const SizedBox(height: 12),
                const _CareBinderCard(),
                const SizedBox(height: 32),

                // ── SUPPORT RESOURCES ───────────────────────────────────
                _HubLabel('SUPPORT RESOURCES'),
                const SizedBox(height: 12),
                const _ResourcesCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────
class _HubLabel extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onAction;
  const _HubLabel(this.text, {this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(text,
          style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
              letterSpacing: 1.3)),
      if (action != null) ...[
        const Spacer(),
        GestureDetector(
          onTap: onAction,
          child: Text(action!,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ),
      ],
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI TOOLS — 2×2 gradient grid
// ─────────────────────────────────────────────────────────────────────────────
class _AIToolsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tools = [
      _Tool(
        gradient: AppColors.aiGradient,
        icon: Icons.chat_bubble_rounded,
        title: 'Ask AI',
        desc: 'Health questions answered',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AIAssistantScreen())),
      ),
      _Tool(
        gradient: AppColors.cardGradient,
        icon: Icons.science_rounded,
        title: 'Lab Tracker',
        desc: 'Upload & analyse results',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LabTrackerScreen())),
      ),
      _Tool(
        gradient: AppColors.accentGradient,
        icon: Icons.mic_rounded,
        title: 'Voice Check-In',
        desc: 'Just talk, AI records',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const VoiceCheckInScreen())),
      ),
      _Tool(
        gradient: const LinearGradient(
          colors: [AppColors.calm, AppColors.info],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.document_scanner_rounded,
        title: 'Lab Analyzer',
        desc: 'Scan reports instantly',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LabAnalyzerScreen())),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemCount: tools.length,
      itemBuilder: (_, i) {
        final t = tools[i];
        return GestureDetector(
          onTap: t.onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: t.gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.glass,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(t.icon, color: Colors.white, size: 18),
                ),
                const Spacer(),
                Text(t.title,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(t.desc,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.72))),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Tool {
  final LinearGradient gradient;
  final IconData icon;
  final String title, desc;
  final VoidCallback onTap;
  const _Tool({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.desc,
    required this.onTap,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// EMOTIONAL WELLBEING — mood picker + support resources
// ─────────────────────────────────────────────────────────────────────────────
class _EmotionalCard extends StatefulWidget {
  const _EmotionalCard();

  @override
  State<_EmotionalCard> createState() => _EmotionalCardState();
}

class _EmotionalCardState extends State<_EmotionalCard> {
  int? _sel;

  static const _moods = [
    (emoji: '😔', label: 'Low',     color: AppColors.info),
    (emoji: '😐', label: 'Okay',    color: AppColors.warning),
    (emoji: '🙂', label: 'Good',    color: AppColors.accent),
    (emoji: '😊', label: 'Great',   color: AppColors.primary),
    (emoji: '😰', label: 'Anxious', color: AppColors.danger),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecor.card(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  gradient: AppColors.heroGradientSoft,
                  borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.self_improvement_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text('How are you feeling?', style: AppText.subtitle()),
          ]),
          const SizedBox(height: 18),

          // Mood buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _moods.asMap().entries.map((e) {
              final i = e.key;
              final m = e.value;
              final sel = _sel == i;
              return GestureDetector(
                onTap: () {
                  setState(() => _sel = i);
                  Future.delayed(const Duration(milliseconds: 240), () {
                    if (mounted) _onSelect(context, m);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel
                        ? m.color.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: sel
                            ? m.color
                            : Colors.transparent,
                        width: 1.5),
                  ),
                  child: Column(children: [
                    Text(m.emoji,
                        style: TextStyle(fontSize: sel ? 28 : 24)),
                    const SizedBox(height: 4),
                    Text(m.label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                sel ? FontWeight.w700 : FontWeight.w400,
                            color: sel ? m.color : AppColors.textMuted)),
                  ]),
                ),
              );
            }).toList(),
          ),

          if (_sel != null) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: _moods[_sel!].color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(children: [
                Icon(Icons.check_circle_rounded,
                    color: _moods[_sel!].color, size: 15),
                const SizedBox(width: 8),
                Text('Feeling ${_moods[_sel!].label.toLowerCase()} — noted',
                    style: TextStyle(
                        fontSize: 12,
                        color: _moods[_sel!].color,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Quick support chips
          Text('SUPPORT', style: AppText.label(AppColors.textMuted)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _SupportChip(
                icon: Icons.psychology_rounded,
                label: 'Talk to Someone',
                color: AppColors.primary,
                onTap: () => _showSheet(context, 'Support Resources', [
                  _ResItem('Cancer Support Community',
                      Icons.groups_rounded, AppColors.primary, '1-888-793-9355'),
                  _ResItem('CancerCare Helpline', Icons.phone_rounded,
                      AppColors.accent, '1-800-813-4673'),
                  _ResItem('Crisis Text Line', Icons.sms_rounded,
                      AppColors.info, 'Text HOME to 741741'),
                ]),
              ),
              const SizedBox(width: 10),
              _SupportChip(
                icon: Icons.spa_rounded,
                label: 'Mindfulness',
                color: AppColors.accent,
                onTap: () => _showSheet(context, 'Mindfulness Exercises', [
                  _ResItem('4-7-8 Breathing', Icons.air_rounded,
                      AppColors.primary, 'Inhale 4s · Hold 7s · Exhale 8s'),
                  _ResItem('5-4-3-2-1 Grounding', Icons.touch_app_rounded,
                      AppColors.accent, '5 things you see, 4 feel, 3 hear'),
                  _ResItem('Body Scan', Icons.accessibility_new_rounded,
                      AppColors.calm, 'Relax each body part, top to bottom'),
                  _ResItem('Gratitude Journal', Icons.edit_note_rounded,
                      AppColors.warning, 'Write 3 things you\'re grateful for'),
                ]),
              ),
              const SizedBox(width: 10),
              _SupportChip(
                icon: Icons.emergency_rounded,
                label: 'Crisis Line',
                color: AppColors.danger,
                onTap: () => _showSheet(context, 'Crisis Support', [
                  _ResItem('988 Crisis Lifeline', Icons.phone_rounded,
                      AppColors.danger, 'Call or text 988'),
                  _ResItem('Crisis Text Line', Icons.sms_rounded,
                      AppColors.info, 'Text HOME to 741741'),
                  _ResItem('Cancer Support Community',
                      Icons.groups_rounded, AppColors.primary,
                      '1-888-793-9355'),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _onSelect(BuildContext context, dynamic m) {
    final msg = switch (m.label as String) {
      'Anxious' || 'Low' =>
        "It's okay to feel this way. Support resources are just below.",
      'Okay' => 'Staying steady is an achievement. A mindfulness break can help.',
      _ => "Great to hear! Keep nurturing what's working.",
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: m.color as Color,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showSheet(
      BuildContext ctx, String title, List<_ResItem> items) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.35,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Center(
                child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2))),
              ),
              Text(title, style: AppText.headline()),
              const SizedBox(height: 16),
              ...items.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: AppDecor.card(),
                      child: Row(children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration:
                              AppDecor.icon(r.color, radius: 12),
                          child:
                              Icon(r.icon, color: r.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.name,
                                  style: AppText.subtitle()),
                              const SizedBox(height: 2),
                              Text(r.contact,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: r.color)),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResItem {
  final String name, contact;
  final IconData icon;
  final Color color;
  const _ResItem(this.name, this.icon, this.color, this.contact);
}

class _SupportChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SupportChip(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 7),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEDICATIONS CARD
// ─────────────────────────────────────────────────────────────────────────────
class _MedicationsCard extends StatelessWidget {
  const _MedicationsCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, app, _) {
      final meds = app.medications.where((m) => m.isActive).toList();
      if (meds.isEmpty) {
        return _EmptyTile(
          icon: Icons.medication_outlined,
          text: 'No medications added yet',
          action: 'Add',
          onTap: () {},
        );
      }
      return Container(
        decoration: AppDecor.card(),
        child: Column(
          children: meds.asMap().entries.map((e) {
            final i = e.key;
            final med = e.value;
            return Column(children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration:
                        AppDecor.icon(AppColors.primary, radius: 12),
                    child: const Icon(Icons.medication_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(med.name, style: AppText.subtitle()),
                        Text('${med.dosage} · ${med.frequency}',
                            style: AppText.caption()),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Active',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentDark)),
                  ),
                ]),
              ),
              if (i < meds.length - 1)
                const Divider(height: 1, indent: 14, endIndent: 14),
            ]);
          }).toList(),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARE TEAM CARD
// ─────────────────────────────────────────────────────────────────────────────
class _CareTeamCard extends StatelessWidget {
  const _CareTeamCard();

  static const _team = [
    (initials: 'SC', name: 'Dr. Sarah Chen', role: 'Oncologist',
     color: AppColors.avatarViolet),
    (initials: 'MR', name: 'Dr. Maria Rodriguez', role: 'Radiologist',
     color: AppColors.avatarEmerald),
    (initials: 'SJ', name: 'Sarah Johnson', role: 'Counselor',
     color: AppColors.avatarBlue),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecor.card(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ..._team.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: p.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(p.initials,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: p.color)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: AppText.subtitle()),
                        Text(p.role, style: AppText.caption()),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: AppDecor.icon(AppColors.primary, radius: 10),
                    child: const Icon(Icons.message_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                ]),
              )),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add_rounded, size: 15),
              label: const Text('Invite Care Team Member'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 42),
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARE BINDER — document categories, using AppColors tokens
// ─────────────────────────────────────────────────────────────────────────────
class _CareBinderCard extends StatelessWidget {
  const _CareBinderCard();

  static const _types = [
    (icon: Icons.science_rounded,            label: 'Lab Results',      color: AppColors.primary),
    (icon: Icons.medical_information_rounded, label: 'Diagnosis',        color: AppColors.danger),
    (icon: Icons.description_rounded,        label: 'Doctor Summaries', color: AppColors.info),
    (icon: Icons.image_search_rounded,       label: 'Scan Reports',     color: AppColors.accent),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecor.card(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types.map((t) => GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('${t.label} — coming soon'),
                          behavior: SnackBarBehavior.floating)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: t.color.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: t.color.withValues(alpha: 0.20)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(t.icon, color: t.color, size: 15),
                      const SizedBox(width: 6),
                      Text(t.label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: t.color)),
                    ]),
                  ),
                )).toList(),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _BinderAction(
                label: 'Upload Document',
                icon: Icons.upload_file_rounded,
                bgColor: AppColors.primarySurface,
                fgColor: AppColors.primary,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Document upload coming soon'),
                        behavior: SnackBarBehavior.floating)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BinderAction(
                label: 'Export PDF',
                icon: Icons.picture_as_pdf_rounded,
                bgColor: AppColors.accentLight,
                fgColor: AppColors.accentDark,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('PDF export coming soon'),
                        behavior: SnackBarBehavior.floating)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _BinderAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor, fgColor;
  final VoidCallback onTap;
  const _BinderAction({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.fgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fgColor, size: 17),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                    color: fgColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESOURCES CARD — using AppColors tokens throughout
// ─────────────────────────────────────────────────────────────────────────────
class _ResourcesCard extends StatelessWidget {
  const _ResourcesCard();

  static const _items = [
    (icon: Icons.groups_rounded, label: 'Cancer Support Community',
     sub: '1-888-793-9355',          color: AppColors.avatarViolet),
    (icon: Icons.phone_rounded, label: 'American Cancer Society',
     sub: '1-800-227-2345',          color: AppColors.danger),
    (icon: Icons.volunteer_activism_rounded, label: 'CancerCare Helpline',
     sub: '1-800-813-4673',          color: AppColors.accent),
    (icon: Icons.favorite_rounded, label: 'Livestrong Foundation',
     sub: '1-855-220-7777',          color: AppColors.warning),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecor.card(),
      child: Column(
        children: _items.asMap().entries.map((e) {
          final i = e.key;
          final r = e.value;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: AppDecor.icon(r.color, radius: 11),
                  child: Icon(r.icon, color: r.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.label, style: AppText.subtitle()),
                      Text(r.sub,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: r.color)),
                    ],
                  ),
                ),
                Icon(Icons.call_rounded,
                    color: AppColors.textMuted, size: 18),
              ]),
            ),
            if (i < _items.length - 1)
              const Divider(height: 1, indent: 14, endIndent: 14),
          ]);
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE TILE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? action;
  final VoidCallback? onTap;
  const _EmptyTile(
      {required this.icon, required this.text, this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecor.card(),
      child: Row(children: [
        Icon(icon, color: AppColors.textMuted, size: 24),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text, style: AppText.body(AppColors.textMuted))),
        if (action != null)
          GestureDetector(
            onTap: onTap,
            child: Text(action!, style: AppText.subtitle(AppColors.primary)),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEDICATIONS SUMMARY CARD (links to full MedicationTrackerScreen)
// ─────────────────────────────────────────────────────────────────────────────
class _MedicationsSummaryCard extends StatelessWidget {
  const _MedicationsSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, app, _) {
      final meds = app.medications.where((m) => m.isActive).toList();
      final todayTaken = meds.where((m) => app.isMedTakenToday(m.id)).length;
      final pct = meds.isEmpty ? 1.0 : todayTaken / meds.length;
      final rate7 = app.medAdherenceRate(days: 7);

      return GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MedicationTrackerScreen())),
        child: Container(
          decoration: AppDecor.card(),
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Header row
            Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medication_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Today\'s Medications', style: AppText.subtitle()),
                  Text('$todayTaken/${meds.isEmpty ? 0 : meds.length} taken today',
                      style: AppText.caption()),
                ]),
              ),
              Container(
                width: 46, height: 46,
                child: Stack(alignment: Alignment.center, children: [
                  CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 4,
                    backgroundColor: AppColors.primarySurface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        pct >= 1.0 ? AppColors.accent : AppColors.primary),
                  ),
                  Text('${(pct * 100).round()}%',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                ]),
              ),
            ]),
            if (meds.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),
              // Med rows (up to 3)
              ...meds.take(3).map((m) {
                final taken = app.isMedTakenToday(m.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: taken ? AppColors.accent : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('${m.name} · ${m.dosage}',
                          style: AppText.body()),
                    ),
                    Text(taken ? 'Taken ✓' : 'Pending',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: taken ? AppColors.accent : AppColors.warning)),
                  ]),
                );
              }),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(children: [
                      Text('7-day', style: AppText.caption()),
                      Text('${(rate7 * 100).round()}%',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                              color: rate7 >= 0.8 ? AppColors.accent : AppColors.warning)),
                      Text('adherence', style: AppText.caption()),
                    ]),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MedicationTrackerScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text('Track Doses →',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ]),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APPOINTMENTS SUMMARY CARD (links to full AppointmentTrackerScreen)
// ─────────────────────────────────────────────────────────────────────────────
class _AppointmentsSummaryCard extends StatelessWidget {
  const _AppointmentsSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, app, _) {
      final upcoming = app.appointments
          .where((a) => a.dateTime.isAfter(DateTime.now()) && !a.isCompleted)
          .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

      return GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AppointmentTrackerScreen())),
        child: Container(
          decoration: AppDecor.card(),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradientSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('My Appointments', style: AppText.subtitle()),
                  Text('${upcoming.length} upcoming',
                      style: AppText.caption()),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${upcoming.length} upcoming',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),
            ]),
            if (upcoming.isEmpty) ...[
              const SizedBox(height: 12),
              Text('No upcoming appointments. Tap to add one.',
                  style: AppText.body(AppColors.textMuted)),
            ] else ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),
              ...upcoming.take(2).map((a) {
                final days = a.dateTime.difference(DateTime.now()).inDays;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Text(days == 0 ? '!' : '$days',
                            style: TextStyle(
                                fontSize: days > 9 ? 14 : 18,
                                fontWeight: FontWeight.w900,
                                color: days <= 2 ? AppColors.warning : AppColors.primary)),
                        Text(days == 0 ? 'TODAY' : days == 1 ? 'DAY' : 'DAYS',
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700,
                                color: AppColors.textMuted, letterSpacing: 0.4)),
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(a.title, style: AppText.subtitle()),
                        Text('${a.doctorName}  ·  ${DateFormat("MMM d, h:mm a").format(a.dateTime)}',
                            style: AppText.caption()),
                      ]),
                    ),
                  ]),
                );
              }),
            ],
          ]),
        ),
      );
    });
  }
}
