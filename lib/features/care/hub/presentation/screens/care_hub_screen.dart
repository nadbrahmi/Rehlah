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
              subtitle: 'Your health tools, all in one place',
            )),
            SliverToBoxAdapter(child: const SectionLabel('AI-powered')),
            SliverToBoxAdapter(child: ToolRow(
              icon: const Icon(Icons.auto_awesome_rounded,
                size: 17, color: AppColors.primary),
              iconBg: AppColors.primaryLight,
              title: 'Ask AI assistant',
              subtitle: 'Symptoms, side effects, treatment',
              aiTinted: true,
              onTap: () => context.push('/ai-chat'),
            )),
            SliverToBoxAdapter(child: ToolRow(
              icon: const Icon(Icons.description_outlined,
                size: 17, color: AppColors.primary),
              iconBg: AppColors.primaryLight,
              title: 'AI lab analyzer',
              subtitle: 'Plain-language lab explanations',
              aiTinted: true,
              onTap: () => context.push('/care/labs'),
            )),
            SliverToBoxAdapter(child: const SectionLabel('Clinical tools')),
            SliverToBoxAdapter(child: ToolRow(
              icon: const Icon(Icons.biotech_outlined,
                size: 17, color: AppColors.blue),
              iconBg: AppColors.blueLight,
              title: 'Lab results',
              subtitle: 'CBC, metabolic, tumour markers',
              trailing: _buildLabsBadge(),
              onTap: () => context.push('/care/labs'),
            )),
            SliverToBoxAdapter(child: ToolRow(
              icon: const Icon(Icons.medication_rounded,
                size: 17, color: AppColors.teal),
              iconBg: AppColors.tealLight,
              title: 'Medications',
              subtitle: 'Daily doses, adherence, history',
              trailing: _MedBadge(),
              onTap: () => context.push('/care/medications'),
            )),
            SliverToBoxAdapter(child: ToolRow(
              icon: const Icon(Icons.calendar_month_rounded,
                size: 17, color: AppColors.peach),
              iconBg: AppColors.peachLight,
              title: 'Appointments',
              subtitle: 'Upcoming visits, prep notes',
              trailing: Builder(builder: (_) {
                final upcoming = MockData.appointments
                    .where((a) => !a.isPast).toList();
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
              }),
              onTap: () => context.push('/care/appointments'),
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
    final taken = UserSession().medsTakenTodayCount;
    final total = UserSession().medications.length;
    return PillBadge(
      text: taken == total && total > 0 ? 'All done ✓' : '$taken of $total',
      bg: taken == total && total > 0 ? AppColors.tealLight : AppColors.peachLight,
      textColor: taken == total && total > 0 ? AppColors.teal : AppColors.peach,
    );
  }
}
