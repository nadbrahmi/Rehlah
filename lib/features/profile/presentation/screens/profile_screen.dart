// ── Screen 16: Profile ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/utils/models.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = MockData.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(text: TextSpan(
                      style: AppText.displayTitle,
                      children: const [
                        TextSpan(text: 'Your '),
                        TextSpan(text: 'profile',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    )),
                    const SizedBox(height: 12),
                    // Completion bar
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.mdBR,
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Profile complete',
                                style: AppText.bodySemibold),
                              Text('67%',
                                style: AppText.bodySemibold.copyWith(
                                  color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AppProgressBar(value: 0.67),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SectionLabel('Personal info'),
              _buildInfoRow('Name', profile.name),
              _buildInfoRow('Cancer type', profile.cancerType),
              _buildInfoRow('Stage', profile.stage.isEmpty
                  ? 'Tap to add →' : profile.stage,
                  isAdd: profile.stage.isEmpty),
              const SectionLabel('Treatment journey'),
              _buildInfoRow('Treatment phase', profile.treatmentPhase),
              _buildInfoRow('Treatment started', 'March 4, 2026'),
              _buildInfoRow('Current cycle',
                  'Cycle ${profile.currentCycle} · Day ${profile.currentDayInCycle}'),
              const SectionLabel('Settings'),
              _buildActionRow(context, Icons.notifications_outlined,
                  'Notifications', '2 of 3 enabled', null),
              _buildActionRow(context, Icons.shield_outlined,
                  'Privacy & data', 'View', '/profile/privacy'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAdd = false}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 7),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.bodySecondary),
          Text(value,
            style: AppText.bodySemibold.copyWith(
              color: isAdd ? AppColors.primary : AppColors.text1,
              fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, IconData icon,
      String label, String value, String? route) {
    return GestureDetector(
      onTap: route != null ? () => context.push(route) : null,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 7),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.text2),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppText.bodySemibold)),
          Text(value,
            style: AppText.bodySecondary.copyWith(
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
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text(
                'Your health data belongs to you',
                style: AppText.sectionHeading,
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.05),
                borderRadius: AppRadius.mdBR,
                border: Border.all(
                  color: AppColors.teal.withOpacity(0.18), width: 0.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Everything is stored only on your device. Rehlah never sells, shares, or uploads your personal health data.',
                      style: AppText.bodySecondary.copyWith(color: AppColors.teal),
                    ),
                  ),
                ],
              ),
            ),
            const SectionLabel('Your data'),
            _buildDataAction(context, Icons.download_rounded,
                'Export my data', 'Download all records', AppColors.blue),
            _buildDataAction(context, Icons.delete_outline_rounded,
                'Delete my account', 'Removes all data permanently',
                AppColors.rose),
            _buildDataAction(context, Icons.refresh_rounded,
                'Reset the app', 'Start over from scratch', AppColors.peach),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
              child: Text(
                'These actions are permanent and cannot be undone.',
                style: AppText.caption.copyWith(
                  fontStyle: FontStyle.italic, fontSize: 11),
                textAlign: TextAlign.center,
              ),
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
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: AppRadius.smBR,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
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
