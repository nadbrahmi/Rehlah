// ── Screen 16: Profile ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/rehlah_theme.dart';
import '../../../../core/utils/models.dart';
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

  int get _maxDay {
    switch (_session.protocol) {
      case BreastProtocol.cmf: return 28;
      default: return 21;
    }
  }

  int get _maxCycle => _session.totalCycles;

  int get _profilePct {
    var filled = 0;
    if (_session.name.isNotEmpty) filled++;
    if (_session.cancerType.isNotEmpty) filled++;
    if (_session.treatmentPhase.isNotEmpty) filled++;
    if (_session.isMonitoring
        ? _session.menstrualStatus != 'unknown'
        : _session.cycleDaySetByUser) { filled++; }
    if (_session.checkedInToday) { filled++; }
    return ((filled / 5) * 100).round();
  }

  // ── Bottom sheet helpers ───────────────────────────────────────────────────

  Widget _sheetHandle() => Center(child: Container(
    width: 36, height: 4,
    decoration: BoxDecoration(
      color: RColors.sand200, borderRadius: BorderRadius.circular(2))));

  void _showPhasePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: RRadius.xl)),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sheetHandle(),
          const SizedBox(height: 14),
          Text('TREATMENT PHASE', style: RText.eyebrow),
          const SizedBox(height: 10),
          ...AppConfig.treatmentPhases.map((p) => GestureDetector(
            onTap: () {
              setState(() => _session.treatmentPhase = p.$1);
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _session.treatmentPhase == p.$1
                    ? RColors.teal50 : RColors.surface,
                borderRadius: RRadius.mdBR,
                border: Border.all(
                  color: _session.treatmentPhase == p.$1
                      ? RColors.teal200 : RColors.sand200,
                  width: 0.5)),
              child: Row(children: [
                Text(p.$2, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(child: Text(p.$1,
                  style: RText.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _session.treatmentPhase == p.$1
                        ? RColors.teal700 : RColors.sand900,
                    fontSize: 13))),
                if (_session.treatmentPhase == p.$1)
                  const Icon(Icons.check_rounded, size: 16, color: RColors.teal700),
              ]),
            ),
          )),
        ]),
      ),
    );
  }

  void _showNameEditor() {
    final controller = TextEditingController(text: _session.name);
    showModalBottomSheet(
      context: context,
      backgroundColor: RColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: RRadius.xl)),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20,
            MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sheetHandle(),
            const SizedBox(height: 16),
            Text('UPDATE NAME', style: RText.eyebrow),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: RText.body.copyWith(color: RColors.sand900),
              decoration: InputDecoration(
                hintText: 'Your first name',
                hintStyle: RText.body.copyWith(color: RColors.sand400),
                filled: true, fillColor: RColors.sand50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: RColors.sand200, width: 0.5)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: RColors.sand200, width: 0.5)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: RColors.teal500, width: 1.5))),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) setState(() => _session.name = name);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: const BoxDecoration(
                  color: RColors.teal700,
                  borderRadius: RRadius.mdBR,
                  boxShadow: RShadow.shadow2),
                child: Center(child: Text('Save name',
                  style: RText.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: RColors.surface, fontSize: 15)))),
            ),
          ],
        ),
      ),
    );
  }

  void _showDayPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: RRadius.xl)),
      builder: (_) => _DayPickerSheet(
        currentDay: _session.dayInCycle,
        maxDay: _maxDay,
        protocol: _session.protocol,
        onSelected: (day) {
          setState(() {
            _session.dayInCycle = day;
            _session.cycleDaySetByUser = true;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCyclePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: RRadius.xl)),
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
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: RRadius.xl)),
      builder: (_) => _ProtocolPickerSheet(
        current: _session.protocol,
        isTaxolPhase: _session.isTaxolPhase,
        onSelected: (protocol, isTaxol) {
          setState(() {
            _session.protocol = protocol;
            _session.isTaxolPhase = isTaxol;
            if (_session.dayInCycle > _maxDay) _session.dayInCycle = 1;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  String _menstrualStatusLabel(String status) {
    const labels = {
      'regular': '🔄 Regular cycles',
      'irregular': '〰️ Irregular cycles',
      'amenorrhea': '⏸️ No period yet',
      'menopause': '🍂 Menopause',
      'unknown': 'Not set',
    };
    return labels[status] ?? status;
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: RRadius.xl)),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sheetHandle(),
          const SizedBox(height: 14),
          Text('LANGUAGE', style: RText.eyebrow),
          const SizedBox(height: 12),
          ...[('en', 'English', 'English'), ('ar', 'العربية', 'Arabic')]
              .map((opt) => GestureDetector(
            onTap: () {
              setState(() => _session.language = opt.$1);
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: _session.language == opt.$1
                    ? RColors.teal50 : RColors.surface,
                borderRadius: RRadius.mdBR,
                border: Border.all(
                  color: _session.language == opt.$1
                      ? RColors.teal200 : RColors.sand200,
                  width: 0.5)),
              child: Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opt.$2,
                      style: RText.body.copyWith(
                        fontWeight: FontWeight.w600, fontSize: 14,
                        color: _session.language == opt.$1
                            ? RColors.teal700 : RColors.sand900)),
                    Text(opt.$3,
                      style: RText.small.copyWith(color: RColors.sand500)),
                  ])),
                if (_session.language == opt.$1)
                  const Icon(Icons.check_rounded,
                      size: 16, color: RColors.teal700),
              ]),
            ),
          )),
        ]),
      ),
    );
  }

  void _showMenstrualStatusPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: RRadius.xl)),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sheetHandle(),
          const SizedBox(height: 16),
          Text('MENSTRUAL STATUS', style: RText.eyebrow),
          const SizedBox(height: 12),
          ...[
            ('regular', '🔄', 'Regular cycles'),
            ('irregular', '〰️', 'Irregular cycles'),
            ('amenorrhea', '⏸️', 'No period yet'),
            ('menopause', '🍂', 'Menopause confirmed'),
          ].map((opt) => GestureDetector(
            onTap: () {
              setState(() => _session.menstrualStatus = opt.$1);
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _session.menstrualStatus == opt.$1
                    ? RColors.teal50 : RColors.surface,
                borderRadius: RRadius.mdBR,
                border: Border.all(
                  color: _session.menstrualStatus == opt.$1
                      ? RColors.teal200 : RColors.sand200,
                  width: 0.5)),
              child: Row(children: [
                Text(opt.$2, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Text(opt.$3, style: RText.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _session.menstrualStatus == opt.$1
                      ? RColors.teal700 : RColors.sand900)),
                if (_session.menstrualStatus == opt.$1) ...[
                  const Spacer(),
                  const Icon(Icons.check_rounded, size: 16, color: RColors.teal700)],
              ]),
            ),
          )),
        ]),
      ),
    );
  }

  void _showCycleLengthPicker() {
    int length = _session.cycleLength;
    showModalBottomSheet(
      context: context,
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: RRadius.xl)),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sheetHandle(),
            const SizedBox(height: 16),
            Text('CYCLE LENGTH', style: RText.eyebrow),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                onTap: () => setS(() => length = (length - 1).clamp(21, 45)),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: RColors.teal50, shape: BoxShape.circle),
                  child: const Icon(Icons.remove_rounded,
                    size: 20, color: RColors.teal700))),
              const SizedBox(width: 24),
              Text('$length days',
                style: RText.h2.copyWith(
                  color: RColors.teal700,
                  fontFeatures: const [FontFeature('tnum')])),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () => setS(() => length = (length + 1).clamp(21, 45)),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: RColors.teal50, shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded,
                    size: 20, color: RColors.teal700))),
            ]),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() => _session.cycleLength = length);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: const BoxDecoration(
                  color: RColors.teal700, borderRadius: RRadius.pillBR),
                child: Center(child: Text('Save',
                  style: RText.body.copyWith(
                    fontWeight: FontWeight.w600, color: RColors.surface, fontSize: 15))))),
          ]),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isMonitoring = _session.isMonitoring;
    final isInChemo = _session.treatmentPhase == 'In chemotherapy';
    final pct = _profilePct;

    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _topbar(),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              _hero(pct, isMonitoring, isInChemo),
              _sectionHead('Personal'),
              const SizedBox(height: 8),
              _toolRow(
                icon: Icons.favorite_border_rounded,
                iconBg: RColors.clay100,
                iconFg: RColors.clay700,
                title: 'Cancer type',
                subtitle: _session.cancerType.isNotEmpty
                    ? _session.cancerType : 'Not set',
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: RColors.sand300, size: 20),
                onTap: () {},
              ),
              _toolRow(
                icon: Icons.language_rounded,
                iconBg: RColors.sky100,
                iconFg: RColors.sky500,
                title: 'Language',
                subtitle: _session.language == 'ar' ? 'العربية' : 'English',
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: RColors.sand300, size: 20),
                onTap: _showLanguagePicker,
              ),
              _sectionHead('Treatment'),
              const SizedBox(height: 8),
              _toolRow(
                icon: Icons.medication_rounded,
                iconBg: RColors.sage100,
                iconFg: RColors.sage700,
                title: 'Protocol',
                subtitle: isInChemo
                    ? '${_session.protocol.name}${_session.isTaxolPhase ? ' · Taxol phase' : ''}'
                    : _session.treatmentPhase,
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: RColors.sand300, size: 20),
                onTap: isInChemo ? _showProtocolPicker : _showPhasePicker,
              ),
              if (isInChemo) ...[
                _toolRow(
                  icon: Icons.loop_rounded,
                  iconBg: RColors.teal100,
                  iconFg: RColors.teal700,
                  title: 'Current cycle',
                  subtitle: 'Cycle ${_session.currentCycle} of ${_session.totalCycles}',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: RColors.sand300, size: 20),
                  onTap: _showCyclePicker,
                ),
                _toolRow(
                  icon: Icons.today_rounded,
                  iconBg: RColors.saffron100,
                  iconFg: RColors.saffron700,
                  title: 'Day in cycle',
                  subtitle: 'Day ${_session.dayInCycle} of $_maxDay',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: RColors.sand300, size: 20),
                  onTap: _showDayPicker,
                ),
              ],
              if (isMonitoring) ...[
                _toolRow(
                  icon: Icons.water_drop_outlined,
                  iconBg: RColors.plum100,
                  iconFg: RColors.plum500,
                  title: 'Menstrual status',
                  subtitle: _menstrualStatusLabel(_session.menstrualStatus),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: RColors.sand300, size: 20),
                  onTap: _showMenstrualStatusPicker,
                ),
                if (_session.menstrualStatus == 'regular')
                  _toolRow(
                    icon: Icons.date_range_rounded,
                    iconBg: RColors.sage100,
                    iconFg: RColors.sage700,
                    title: 'Cycle length',
                    subtitle: '${_session.cycleLength} days average',
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: RColors.sand300, size: 20),
                    onTap: _showCycleLengthPicker,
                  ),
              ],
              if (_session.history.isNotEmpty) ...[
                _sectionHead('Recent check-ins'),
                const SizedBox(height: 8),
                ..._session.history.take(3).map(_checkinRow),
              ],
              _sectionHead('Settings'),
              const SizedBox(height: 8),
              _toolRow(
                icon: Icons.notifications_outlined,
                iconBg: RColors.sand100,
                iconFg: RColors.sand500,
                title: 'Notifications',
                subtitle: '2 of 3 enabled',
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: RColors.sand300, size: 20),
                onTap: () {},
              ),
              _toolRow(
                icon: Icons.shield_outlined,
                iconBg: RColors.teal100,
                iconFg: RColors.teal700,
                title: 'Privacy & data',
                subtitle: 'Your data, your control',
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: RColors.sand300, size: 20),
                onTap: () => context.push('/profile/privacy'),
              ),
              const SizedBox(height: 24),
            ]),
          )),
        ]),
      ),
    );
  }

  // ── Topbar ────────────────────────────────────────────────────────────────

  Widget _topbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        const SizedBox(width: 36),
        const Expanded(child: Center(child: Text('Profile',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              letterSpacing: -0.2)))),
        GestureDetector(
          onTap: _showNameEditor,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: RColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: RColors.sand200),
            ),
            child: const Icon(Icons.edit_outlined,
                color: RColors.sand700, size: 18),
          ),
        ),
      ]),
    );
  }

  // ── Profile hero ──────────────────────────────────────────────────────────

  Widget _hero(int pct, bool isMonitoring, bool isInChemo) {
    final initial = _session.displayName.isNotEmpty
        ? _session.displayName[0].toUpperCase()
        : 'S';
    final sub = isMonitoring
        ? '${_session.daysCancerFree} days cancer-free'
        : isInChemo
            ? 'Cycle ${_session.currentCycle} of ${_session.totalCycles} · ${_session.cancerType}'
            : '${_session.treatmentPhase} · ${_session.cancerType}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RColors.teal700, RColors.teal600],
        ),
        borderRadius: RRadius.xlBR,
      ),
      child: Stack(children: [
        Positioned(
          top: -70, right: -70,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(initial,
                style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: Colors.white))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_session.displayName,
                style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: Colors.white, letterSpacing: -0.2)),
              const SizedBox(height: 3),
              Text(sub,
                style: TextStyle(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.78),
                  height: 1.4)),
            ])),
          ]),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text('Profile complete · $pct%',
            style: TextStyle(
              fontSize: 11, color: Colors.white.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }

  // ── Section head ──────────────────────────────────────────────────────────

  Widget _sectionHead(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5, letterSpacing: 1.4,
          fontWeight: FontWeight.w500, color: RColors.sand500)),
    );
  }

  // ── Tool row ──────────────────────────────────────────────────────────────

  Widget _toolRow({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: RColors.surface,
          borderRadius: RRadius.mdBR,
          border: Border.all(color: RColors.sand200),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: RRadius.smBR),
            child: Icon(icon, color: iconFg, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: RColors.sand950)),
            const SizedBox(height: 2),
            Text(subtitle,
              style: const TextStyle(fontSize: 11, color: RColors.sand500,
                  height: 1.3)),
          ])),
          const SizedBox(width: 8),
          trailing,
        ]),
      ),
    );
  }

  // ── Check-in row ──────────────────────────────────────────────────────────

  Widget _checkinRow(CheckInRecord r) {
    final days = DateTime.now().difference(r.date).inDays;
    final when = days == 0
        ? 'Today'
        : days == 1 ? 'Yesterday' : '${days}d ago';
    final topSymptoms = (r.symptomScores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .where((e) => e.value > 0)
        .take(2)
        .map((e) => e.key.replaceAll('_', ' '))
        .toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(
              color: RColors.saffron100, borderRadius: RRadius.smBR),
          child: Center(child: Text(r.moodEmoji,
            style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(when,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: RColors.sand950)),
          if (topSymptoms.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(topSymptoms.join(' · '),
              style: const TextStyle(fontSize: 11, color: RColors.sand500,
                  height: 1.3)),
          ],
        ])),
      ]),
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
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 4,
          decoration: BoxDecoration(color: RColors.sand200, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Text('SELECT TODAY\'S DAY', style: RText.eyebrow),
        const SizedBox(height: 4),
        Text('Day in your current cycle (1–$maxDay)', style: RText.bodyMuted),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, mainAxisSpacing: 6,
            crossAxisSpacing: 6, childAspectRatio: 1),
          itemCount: maxDay,
          itemBuilder: (_, i) {
            final day = i + 1;
            final isCurrent = day == currentDay;
            final phase = ProtocolResolver.resolve(protocol, day);
            final isNadir = phase.isNadir;

            final bgColor = isCurrent ? RColors.teal700
                : isNadir ? RColors.clay100 : RColors.sand100;
            final textColor = isCurrent ? RColors.surface
                : isNadir ? RColors.clay700 : RColors.sand700;

            return GestureDetector(
              onTap: () => onSelected(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrent ? RColors.teal700
                        : isNadir ? RColors.clay300.withValues(alpha: 0.4)
                        : RColors.sand200,
                    width: 0.5)),
                child: Center(child: Text('$day',
                  style: RText.small.copyWith(
                    fontSize: 12,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                    color: textColor,
                    fontFeatures: const [FontFeature('tnum')]))),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(children: [
          _dot(RColors.teal700, 'Today'),
          const SizedBox(width: 16),
          _dot(RColors.clay500, 'Nadir days'),
          const SizedBox(width: 16),
          _dot(RColors.sand300, 'Normal'),
        ]),
      ]),
    );
  }

  Widget _dot(Color color, String label) => Row(children: [
    Container(width: 8, height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(label, style: RText.small.copyWith(fontSize: 10)),
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
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 4,
          decoration: BoxDecoration(color: RColors.sand200, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Text('SELECT CURRENT CYCLE', style: RText.eyebrow),
        const SizedBox(height: 4),
        Text('Which cycle are you on?', style: RText.bodyMuted),
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
                  color: isCurrent ? RColors.teal700 : RColors.sand100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent ? RColors.teal700 : RColors.sand200,
                    width: 0.5)),
                child: Center(child: Text('$cycle',
                  style: RText.body.copyWith(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: isCurrent ? RColors.surface : RColors.sand700,
                    fontFeatures: const [FontFeature('tnum')]))),
              ),
            );
          }),
        ),
      ]),
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
      (BreastProtocol.act, '💊', RColors.teal700, RColors.teal50,
          'AC-T', 'Adriamycin + Cyclophosphamide → Taxol'),
      (BreastProtocol.tc, '🔵', RColors.sky500, RColors.sky100,
          'TC', 'Docetaxel + Cyclophosphamide'),
      (BreastProtocol.cmf, '🟢', RColors.sage500, RColors.sage100,
          'CMF', 'Cyclophosphamide + Methotrexate + 5-FU'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 4,
          decoration: BoxDecoration(color: RColors.sand200, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Text('UPDATE PROTOCOL', style: RText.eyebrow),
        const SizedBox(height: 4),
        Text('Select your chemotherapy protocol', style: RText.bodyMuted),
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
                color: sel ? p.$4 : RColors.surface,
                borderRadius: RRadius.mdBR,
                border: Border.all(
                  color: sel ? p.$3.withValues(alpha: 0.35) : RColors.sand200,
                  width: 0.5)),
              child: Row(children: [
                Text(p.$2, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.$5, style: RText.body.copyWith(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: sel ? p.$3 : RColors.sand900)),
                  Text(p.$6, style: RText.small.copyWith(fontWeight: FontWeight.w300)),
                ])),
                Container(width: 18, height: 18,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    color: sel ? p.$3 : Colors.transparent,
                    border: Border.all(
                      color: sel ? p.$3 : RColors.sand200, width: 1.5)),
                  child: sel ? const Icon(Icons.check_rounded, size: 10, color: RColors.surface) : null),
              ]),
            ),
          );
        }),
        if (_selected == BreastProtocol.act) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _isTaxol = !_isTaxol),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: RColors.surface,
                borderRadius: RRadius.mdBR,
                border: Border.all(color: RColors.sand200, width: 0.5)),
              child: Row(children: [
                const SizedBox(width: 30),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Currently in Taxol phase',
                    style: RText.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('Tick if you\'ve completed AC and started Taxol',
                    style: RText.small),
                ])),
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: _isTaxol ? RColors.teal700 : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _isTaxol ? RColors.teal700 : RColors.sand200, width: 1.5)),
                  child: _isTaxol ? const Icon(Icons.check_rounded,
                    size: 14, color: RColors.surface) : null),
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
            decoration: const BoxDecoration(
              color: RColors.teal700, borderRadius: RRadius.mdBR,
              boxShadow: RShadow.shadow2),
            child: Center(child: Text('Save changes',
              style: RText.body.copyWith(
                fontWeight: FontWeight.w600, color: RColors.surface, fontSize: 15))),
          ),
        ),
      ]),
    );
  }
}

// ── Screen 17: Privacy ────────────────────────────────────────────────────────
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});
  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _shareDoctor = true;
  bool _shareNurse = true;
  bool _shareFatima = true;
  bool _privateJournal = true;
  bool _helpImproveAI = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _topbar(context),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              _hero(),
              _sectionHead('Who can see'),
              const SizedBox(height: 8),
              _toggleRow('Dr. Aisha', 'Oncologist · Shared reports',
                'A', RColors.teal100, RColors.teal700,
                _shareDoctor, (v) => setState(() => _shareDoctor = v)),
              _toggleRow('Nurse Nour', 'Care nurse · Vitals alerts',
                'N', RColors.sage100, RColors.sage700,
                _shareNurse, (v) => setState(() => _shareNurse = v)),
              _toggleRow('Fatima', 'Sister · Check-in updates',
                'F', RColors.saffron100, RColors.saffron700,
                _shareFatima, (v) => setState(() => _shareFatima = v)),
              _sectionHead('Controls'),
              const SizedBox(height: 8),
              _toggleRow('Private journal', 'Only you can read check-ins',
                null, RColors.sand100, RColors.sand500,
                _privateJournal, (v) => setState(() => _privateJournal = v)),
              _toggleRow('Help improve AI', 'Share anonymised data with Rehlah',
                null, RColors.sand100, RColors.sand500,
                _helpImproveAI, (v) => setState(() => _helpImproveAI = v)),
              _sectionHead('Your data'),
              const SizedBox(height: 8),
              _dataRow(Icons.download_rounded, 'Download my data',
                'Export all records as PDF', RColors.sand100, RColors.sand700),
              _dataRow(Icons.delete_outline_rounded, 'Delete account',
                'Removes everything permanently', RColors.clay100, RColors.clay700),
              const SizedBox(height: 24),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _topbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.canPop() ? context.pop() : context.go('/'),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: RColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: RColors.sand200),
            ),
            child: const Icon(Icons.chevron_left_rounded,
                color: RColors.sand700, size: 22),
          ),
        ),
        const Expanded(child: Center(child: Text('Privacy & data',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              letterSpacing: -0.2)))),
        const SizedBox(width: 36),
      ]),
    );
  }

  Widget _hero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RColors.teal700, RColors.teal600],
        ),
        borderRadius: RRadius.xlBR,
      ),
      child: Stack(children: [
        Positioned(
          top: -70, right: -70,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('YOUR DATA',
            style: TextStyle(
              fontSize: 10.5, letterSpacing: 1.4, fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 4),
          const Text('Yours. Always.',
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: Colors.white, letterSpacing: -0.2, height: 1.2)),
          const SizedBox(height: 8),
          Text(
            'Everything lives on your device. We never sell or share your personal health data.',
            style: TextStyle(
              fontSize: 12.5, color: Colors.white.withValues(alpha: 0.78),
              height: 1.5)),
        ]),
      ]),
    );
  }

  Widget _sectionHead(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5, letterSpacing: 1.4,
          fontWeight: FontWeight.w500, color: RColors.sand500)),
    );
  }

  Widget _toggleRow(
    String name,
    String sub,
    String? initial,
    Color avatarBg,
    Color avatarFg,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
          child: initial != null
              ? Center(child: Text(initial,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: avatarFg)))
              : Icon(Icons.lock_outline_rounded, color: avatarFg, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: RColors.sand950)),
          const SizedBox(height: 2),
          Text(sub,
            style: const TextStyle(fontSize: 11, color: RColors.sand500,
                height: 1.3)),
        ])),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: RColors.teal700,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ]),
    );
  }

  Widget _dataRow(IconData icon, String title, String sub, Color bg, Color fg) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: bg, borderRadius: RRadius.smBR),
          child: Icon(icon, color: fg, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
          const SizedBox(height: 2),
          Text(sub,
            style: const TextStyle(fontSize: 11, color: RColors.sand500,
                height: 1.3)),
        ])),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right_rounded, color: RColors.sand300, size: 20),
      ]),
    );
  }
}
