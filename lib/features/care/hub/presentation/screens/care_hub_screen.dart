import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/shared_widgets.dart';
import '../../../../../core/utils/models.dart';
import '../../../../../core/utils/user_session.dart';

class CareHubScreen extends StatefulWidget {
  const CareHubScreen({super.key});
  @override
  State<CareHubScreen> createState() => _CareHubScreenState();
}

class _CareHubScreenState extends State<CareHubScreen> {
  final _session = UserSession();

  @override
  void initState() {
    super.initState();
    _session.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Widget _buildAppointmentsBadge() {
    _session.initDefaultAppointments();
    final upcoming = _session.upcomingAppointments;
    if (upcoming.isEmpty) return const SizedBox.shrink();
    final days = upcoming.first.daysUntil;
    final label = days < 0 ? 'Overdue'
        : days == 0 ? 'Today!'
        : days == 1 ? 'Tomorrow'
        : '$days days';
    final color = days <= 1 ? AppColors.rose
        : days <= 3 ? AppColors.peach
        : AppColors.text2;
    return PillBadge(
      text: label,
      bg: color.withOpacity(0.10),
      textColor: color,
      borderColor: color.withOpacity(0.2));
  }

  Widget _buildLabsBadge() {
    final labs = _session.labs;
    if (labs.isEmpty) {
      return PillBadge(
        text: 'Add first',
        bg: AppColors.background2,
        textColor: AppColors.text3);
    }
    final abnormal = labs.first.metrics.where((m) => !m.isNormal).length;
    final color = abnormal > 0 ? AppColors.peach : AppColors.teal;
    return PillBadge(
      text: abnormal > 0 ? '$abnormal abnormal' : 'All normal ✓',
      bg: color.withOpacity(0.10),
      textColor: color,
      borderColor: color.withOpacity(0.2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: AppHeader(
              title: 'Care |hub',
              subtitle: 'Your health tools',
            )),
            SliverToBoxAdapter(child: const SectionLabel('Daily')),
            SliverToBoxAdapter(child: ToolRow(
              icon: Icon(Icons.medication_rounded, size: 17,
                color: _session.hasRefillAlert ? AppColors.peach : AppColors.teal),
              iconBg: _session.hasRefillAlert
                  ? AppColors.peachLight : AppColors.tealLight,
              title: 'Medications',
              subtitle: 'Daily doses, adherence, supply',
              trailing: _MedBadge(),
              alertTinted: _session.hasRefillAlert,
              successTinted: !_session.hasRefillAlert &&
                  _session.medications.isNotEmpty &&
                  _session.medsTakenTodayCount == _session.medications.length,
              onTap: () => context.push('/care/medications'),
            )),
            SliverToBoxAdapter(child: ToolRow(
              icon: const Icon(Icons.calendar_month_rounded,
                size: 17, color: AppColors.peach),
              iconBg: AppColors.peachLight,
              title: 'Appointments',
              subtitle: 'Upcoming visits, prep notes',
              trailing: _buildAppointmentsBadge(),
              onTap: () => context.push('/care/appointments'),
            )),
            SliverToBoxAdapter(child: const SectionLabel('Clinical')),
            SliverToBoxAdapter(child: ToolRow(
              icon: Icon(Icons.biotech_outlined, size: 17,
                color: () {
                  final labs = _session.labs;
                  if (labs.isEmpty) return AppColors.blue;
                  final abnormal = labs.first.metrics
                      .where((m) => !m.isNormal).length;
                  return abnormal > 0 ? AppColors.peach : AppColors.blue;
                }()),
              iconBg: () {
                final labs = _session.labs;
                if (labs.isEmpty) return AppColors.blueLight;
                final abnormal = labs.first.metrics
                    .where((m) => !m.isNormal).length;
                return abnormal > 0 ? AppColors.peachLight : AppColors.blueLight;
              }(),
              title: 'Lab results',
              subtitle: 'CBC, metabolic, tumour markers',
              trailing: _buildLabsBadge(),
              alertTinted: _session.labs.isNotEmpty &&
                  _session.labs.first.metrics.any((m) => !m.isNormal),
              onTap: () => context.push('/care/labs'),
            )),
            SliverToBoxAdapter(child: const SectionLabel('AI assistant')),
            SliverToBoxAdapter(child: ToolRow(
              icon: const Icon(Icons.auto_awesome_rounded,
                size: 17, color: AppColors.primary),
              iconBg: AppColors.primaryLight,
              title: 'Ask AI',
              subtitle: 'Symptoms, side effects, any question',
              aiTinted: true,
              onTap: () => context.push('/ai-chat'),
            )),
            SliverToBoxAdapter(child: ToolRow(
              icon: const Icon(Icons.biotech_outlined,
                size: 17, color: AppColors.primary),
              iconBg: AppColors.primaryLight,
              title: 'AI lab analyzer',
              subtitle: 'Plain-language explanations of your results',
              aiTinted: true,
              trailing: PillBadge(
                text: 'Coming soon',
                bg: AppColors.primaryLight,
                textColor: AppColors.primary.withOpacity(0.6)),
              onTap: () => context.push('/care/labs'),
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _MedBadge extends StatefulWidget {
  @override
  State<_MedBadge> createState() => _MedBadgeState();
}

class _MedBadgeState extends State<_MedBadge> {
  @override
  void initState() {
    super.initState();
    UserSession().addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    UserSession().removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    final taken = session.medsTakenTodayCount;
    final total = session.medications.length;

    // Refill alert takes priority
    if (session.hasRefillAlert) {
      return PillBadge(
        text: '⚠ Refill needed',
        bg: AppColors.peachLight,
        textColor: AppColors.peach,
        borderColor: AppColors.peach.withOpacity(0.2));
    }
    if (total == 0) {
      return PillBadge(
        text: 'Add first',
        bg: AppColors.background2,
        textColor: AppColors.text3);
    }
    return PillBadge(
      text: taken == total ? 'All done ✓' : '$taken of $total',
      bg: taken == total ? AppColors.tealLight : AppColors.peachLight,
      textColor: taken == total ? AppColors.teal : AppColors.peach,
    );
  }
}
