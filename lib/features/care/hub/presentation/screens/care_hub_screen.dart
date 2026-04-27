import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/shared_widgets.dart';

class CareHubScreen extends StatelessWidget {
  const CareHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(text: TextSpan(
                  style: AppText.displayTitle,
                  children: const [
                    TextSpan(text: 'Care ',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                    TextSpan(text: 'hub'),
                  ],
                )),
                Text('Your health tools, all in one place',
                  style: AppText.bodySecondary),
              ]),
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
              trailing: PillBadge(
                text: '2 of 3',
                bg: AppColors.tealLight,
                textColor: AppColors.teal,
              ),
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
            SliverToBoxAdapter(child: const SectionLabel('Support')),
            SliverToBoxAdapter(child: ToolRow(
              icon: const Icon(Icons.people_outline_rounded,
                size: 17, color: AppColors.rose),
              iconBg: AppColors.roseLight,
              title: 'Community',
              subtitle: 'Connect with others on your journey',
              onTap: () => context.go('/connect'),
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
