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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Rebuild every time we come back to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
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
              trailing: PillBadge(
                text: 'Caution',
                bg: AppColors.peachLight,
                textColor: AppColors.peach,
              ),
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
              trailing: PillBadge(
                text: '4 days',
                bg: AppColors.peachLight,
                textColor: AppColors.peach,
              ),
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
    final total = MockData.medications.length;
    return PillBadge(
      text: taken == total && total > 0 ? 'All done ✓' : '$taken of $total',
      bg: taken == total && total > 0 ? AppColors.tealLight : AppColors.peachLight,
      textColor: taken == total && total > 0 ? AppColors.teal : AppColors.peach,
    );
  }
}
