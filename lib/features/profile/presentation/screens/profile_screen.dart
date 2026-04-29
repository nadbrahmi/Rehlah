// ── Screen 16: Profile ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/utils/user_session.dart';
import '../../../../core/utils/protocols.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserSession _session;

  @override
  void initState() {
    super.initState();
    _session = UserSession();
  }

  // Max days per cycle depending on protocol
  int get _maxDay {
    switch (_session.protocol) {
      case BreastProtocol.cmf: return 28;
      default: return 21;
    }
  }

  int get _maxCycle => _session.totalCycles;

  void _showDayPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _DayPickerSheet(
        currentDay: _session.dayInCycle,
        maxDay: _maxDay,
        protocol: _session.protocol,
        onSelected: (day) {
          setState(() => _session.dayInCycle = day);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCyclePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CyclePickerSheet(
        currentCycle: _session.currentCycle,
        maxCycle: _maxCycle,
        onSelected: (cycle) {
          setState(() => _session.currentCycle = cycle);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showProtocolPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ProtocolPickerSheet(
        current: _session.protocol,
        isTaxolPhase: _session.isTaxolPhase,
        onSelected: (protocol, isTaxol) {
          setState(() {
            _session.protocol = protocol;
            _session.isTaxolPhase = isTaxol;
            // Reset day to 1 if it exceeds new max
            if (_session.dayInCycle > _maxDay) _session.dayInCycle = 1;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phase = _session.currentPhase;
    final isNadir = _session.isNadirWindow;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Row(children: [
                        Icon(Icons.arrow_back_ios_new_rounded, size: 15,
                          color: AppColors.text2.withOpacity(0.4)),
                        const SizedBox(width: 4),
                        Text('Home', style: AppText.caption.copyWith(
                          color: AppColors.text2, fontSize: 11)),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    RichText(text: TextSpan(
                      style: AppText.displayTitle,
                      children: const [
                        TextSpan(text: 'Your '),
                        TextSpan(text: 'profile',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    )),
                  ],
                ),
              ),

              // Current phase card
              Container(
                margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isNadir
                      ? AppColors.peach.withOpacity(0.06)
                      : AppColors.primary.withOpacity(0.05),
                  borderRadius: AppRadius.mdBR,
                  border: Border.all(
                    color: isNadir
                        ? AppColors.peach.withOpacity(0.25)
                        : AppColors.primaryMid,
                    width: 0.5),
                ),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: isNadir
                          ? AppColors.peachLight
                          : AppColors.primaryLight,
                      borderRadius: AppRadius.smBR),
                    child: Center(child: Text(
                      isNadir ? '⚠' : '💊',
                      style: const TextStyle(fontSize: 16)))),
                  const SizedBox(width: 11),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_session.protocol.name} · Cycle ${_session.currentCycle} of ${_session.totalCycles} · Day ${_session.dayInCycle}',
                        style: AppText.bodySemibold.copyWith(
                          color: isNadir ? AppColors.peach : AppColors.primary,
                          fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(phase.name,
                        style: AppText.bodySecondary.copyWith(fontSize: 12)),
                    ],
                  )),
                ]),
              ),

              // ── Personal info ─────────────────────────────────────────
              const SectionLabel('Personal info'),
              _infoRow('Name', _session.displayName),
              _infoRow('Cancer type', _session.cancerType),

              // ── Treatment — editable ──────────────────────────────────
              const SectionLabel('Treatment journey'),
              _infoRow('Treatment phase', _session.treatmentPhase),

              // Protocol — tappable
              _editableRow(
                label: 'Protocol',
                value: '${_session.protocol.name}${_session.isTaxolPhase ? ' (Taxol phase)' : ''}',
                subtitle: _session.protocol.fullName,
                onTap: _showProtocolPicker,
                color: AppColors.primary,
              ),

              // Cycle — tappable
              _editableRow(
                label: 'Current cycle',
                value: 'Cycle ${_session.currentCycle} of ${_session.totalCycles}',
                subtitle: 'Tap to update',
                onTap: _showCyclePicker,
                color: AppColors.blue,
              ),

              // Day in cycle — tappable (most important)
              _editableRow(
                label: 'Day in cycle',
                value: 'Day ${_session.dayInCycle} of $_maxDay',
                subtitle: phase.name,
                onTap: _showDayPicker,
                color: isNadir ? AppColors.peach : AppColors.teal,
                highlight: true,
              ),

              // ── Settings ──────────────────────────────────────────────
              const SectionLabel('Settings'),
              _actionRow(Icons.notifications_outlined,
                  'Notifications', '2 of 3 enabled', null),
              _actionRow(Icons.shield_outlined,
                  'Privacy & data', 'View', '/profile/privacy'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 7),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.bodySecondary),
          Text(value, style: AppText.bodySemibold.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _editableRow({
    required String label,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool highlight = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 7),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: highlight
              ? color.withOpacity(0.05)
              : AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(
            color: highlight ? color.withOpacity(0.25) : AppColors.border,
            width: 0.5)),
        child: Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.bodySecondary),
              const SizedBox(height: 2),
              Text(value, style: AppText.bodySemibold.copyWith(
                color: color, fontSize: 14)),
              Text(subtitle, style: AppText.caption.copyWith(
                fontSize: 11, color: AppColors.text3)),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.09),
              borderRadius: AppRadius.fullBR,
              border: Border.all(color: color.withOpacity(0.2), width: 0.5)),
            child: Text('Update',
              style: AppText.caption.copyWith(
                color: color, fontWeight: FontWeight.w600, fontSize: 11)),
          ),
        ]),
      ),
    );
  }

  Widget _actionRow(IconData icon, String label, String value, String? route) {
    return GestureDetector(
      onTap: route != null ? () => context.push(route) : null,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 7),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.border, width: 0.5)),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.text2),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppText.bodySemibold)),
          Text(value, style: AppText.bodySecondary.copyWith(
            color: route != null ? AppColors.primary : AppColors.text2,
            fontWeight: FontWeight.w500)),
          if (route != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 16,
              color: AppColors.text1.withOpacity(0.18)),
          ],
        ]),
      ),
    );
  }
}

// ── Day Picker Sheet ──────────────────────────────────────────────────────────
class _DayPickerSheet extends StatelessWidget {
  final int currentDay, maxDay;
  final BreastProtocol protocol;
  final ValueChanged<int> onSelected;

  const _DayPickerSheet({
    required this.currentDay, required this.maxDay,
    required this.protocol, required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('SELECT TODAY\'S DAY',
            style: AppText.label.copyWith(fontSize: 10)),
          const SizedBox(height: 4),
          Text('Day in your current cycle (1–$maxDay)',
            style: AppText.bodySecondary),
          const SizedBox(height: 16),
          // Day grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1,
            ),
            itemCount: maxDay,
            itemBuilder: (_, i) {
              final day = i + 1;
              final isCurrent = day == currentDay;
              final phase = ProtocolResolver.resolve(protocol, day);
              final isNadir = phase.isNadir;

              Color bgColor;
              Color textColor;
              if (isCurrent) {
                bgColor = AppColors.primary;
                textColor = Colors.white;
              } else if (isNadir) {
                bgColor = AppColors.peachLight;
                textColor = AppColors.peach;
              } else {
                bgColor = AppColors.background2;
                textColor = AppColors.text2;
              }

              return GestureDetector(
                onTap: () => onSelected(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.primary
                          : isNadir
                              ? AppColors.peach.withOpacity(0.3)
                              : AppColors.border,
                      width: 0.5)),
                  child: Center(child: Text('$day',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 12,
                      fontWeight: isCurrent
                          ? FontWeight.w700 : FontWeight.w400,
                      color: textColor))),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Legend
          Row(children: [
            _dot(AppColors.primary, 'Today'),
            const SizedBox(width: 16),
            _dot(AppColors.peach, 'Nadir days'),
            const SizedBox(width: 16),
            _dot(AppColors.background2, 'Normal'),
          ]),
        ],
      ),
    );
  }

  Widget _dot(Color color, String label) => Row(children: [
    Container(width: 8, height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(label, style: AppText.caption.copyWith(fontSize: 10)),
  ]);
}

// ── Cycle Picker Sheet ────────────────────────────────────────────────────────
class _CyclePickerSheet extends StatelessWidget {
  final int currentCycle, maxCycle;
  final ValueChanged<int> onSelected;

  const _CyclePickerSheet({
    required this.currentCycle, required this.maxCycle,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('SELECT CURRENT CYCLE',
            style: AppText.label.copyWith(fontSize: 10)),
          const SizedBox(height: 4),
          Text('Which cycle are you on?',
            style: AppText.bodySecondary),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: List.generate(maxCycle, (i) {
              final cycle = i + 1;
              final isCurrent = cycle == currentCycle;
              return GestureDetector(
                onTap: () => onSelected(cycle),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primary
                        : AppColors.background2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.primary
                          : AppColors.border,
                      width: 0.5)),
                  child: Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$cycle',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isCurrent
                              ? Colors.white : AppColors.text2)),
                    ],
                  )),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Protocol Picker Sheet ─────────────────────────────────────────────────────
class _ProtocolPickerSheet extends StatefulWidget {
  final BreastProtocol current;
  final bool isTaxolPhase;
  final Function(BreastProtocol, bool) onSelected;

  const _ProtocolPickerSheet({
    required this.current, required this.isTaxolPhase,
    required this.onSelected,
  });

  @override
  State<_ProtocolPickerSheet> createState() => _ProtocolPickerSheetState();
}

class _ProtocolPickerSheetState extends State<_ProtocolPickerSheet> {
  late BreastProtocol _selected;
  late bool _isTaxol;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
    _isTaxol = widget.isTaxolPhase;
  }

  @override
  Widget build(BuildContext context) {
    final protocols = [
      (BreastProtocol.act, '💊', AppColors.primary, AppColors.primaryLight,
          'AC-T', 'Adriamycin + Cyclophosphamide → Taxol'),
      (BreastProtocol.tc, '🔵', AppColors.blue, AppColors.blueLight,
          'TC', 'Docetaxel + Cyclophosphamide'),
      (BreastProtocol.cmf, '🟢', AppColors.teal, AppColors.tealLight,
          'CMF', 'Cyclophosphamide + Methotrexate + 5-FU'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('UPDATE PROTOCOL',
            style: AppText.label.copyWith(fontSize: 10)),
          const SizedBox(height: 4),
          Text('Select your chemotherapy protocol',
            style: AppText.bodySecondary),
          const SizedBox(height: 16),
          ...protocols.map((p) {
            final sel = _selected == p.$1;
            return GestureDetector(
              onTap: () => setState(() {
                _selected = p.$1;
                if (p.$1 != BreastProtocol.act) _isTaxol = false;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 130),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: sel ? p.$4 : AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: sel ? p.$3.withOpacity(0.35) : AppColors.border,
                    width: 0.5)),
                child: Row(children: [
                  Text(p.$2, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.$5, style: TextStyle(fontFamily: 'Inter',
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: sel ? p.$3 : AppColors.text1)),
                      Text(p.$6, style: const TextStyle(fontFamily: 'Inter',
                        fontSize: 11, color: AppColors.text2,
                        fontWeight: FontWeight.w300)),
                    ],
                  )),
                  Container(width: 18, height: 18,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      color: sel ? p.$3 : Colors.transparent,
                      border: Border.all(
                        color: sel ? p.$3 : AppColors.border, width: 1.5)),
                    child: sel ? const Icon(Icons.check_rounded,
                      size: 10, color: Colors.white) : null),
                ]),
              ),
            );
          }),
          // Taxol toggle for AC-T
          if (_selected == BreastProtocol.act) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() => _isTaxol = !_isTaxol),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: AppColors.border, width: 0.5)),
                child: Row(children: [
                  const SizedBox(width: 30),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Currently in Taxol phase',
                        style: AppText.bodySemibold.copyWith(fontSize: 13)),
                      Text('Tick if you\'ve completed AC and started Taxol',
                        style: AppText.caption.copyWith(fontSize: 11)),
                    ],
                  )),
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: _isTaxol ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _isTaxol ? AppColors.primary : AppColors.border,
                        width: 1.5)),
                    child: _isTaxol ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white) : null),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => widget.onSelected(_selected, _isTaxol),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10, offset: const Offset(0, 3))]),
              child: const Center(child: Text('Save changes',
                style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                  fontWeight: FontWeight.w500, color: Colors.white))),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Screen 17: Privacy ────────────────────────────────────────────────────────
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy & data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text('Your health data belongs to you',
                style: AppText.sectionHeading),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.05),
                borderRadius: AppRadius.mdBR,
                border: Border.all(
                  color: AppColors.teal.withOpacity(0.18), width: 0.5)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    'Everything is stored only on your device. Rehlah never sells, shares, or uploads your personal health data.',
                    style: AppText.bodySecondary.copyWith(color: AppColors.teal))),
                ],
              ),
            ),
            const SectionLabel('Your data'),
            _buildDataAction(context, Icons.download_rounded,
                'Export my data', 'Download all records', AppColors.blue),
            _buildDataAction(context, Icons.delete_outline_rounded,
                'Delete my account', 'Removes all data permanently', AppColors.rose),
            _buildDataAction(context, Icons.refresh_rounded,
                'Reset the app', 'Start over from scratch', AppColors.peach),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
              child: Text(
                'These actions are permanent and cannot be undone.',
                style: AppText.caption.copyWith(
                  fontStyle: FontStyle.italic, fontSize: 11),
                textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataAction(BuildContext context, IconData icon,
      String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: AppRadius.smBR),
          child: Icon(icon, size: 18, color: color)),
        const SizedBox(width: 11),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.bodySemibold.copyWith(color: color)),
            Text(subtitle, style: AppText.bodySecondary),
          ],
        )),
        Icon(Icons.chevron_right_rounded, size: 16,
          color: AppColors.text1.withOpacity(0.18)),
      ]),
    );
  }
}
