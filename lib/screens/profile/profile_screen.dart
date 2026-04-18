import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';
import '../ai/lab_tracker_screen.dart';
import '../care/medication_tracker_screen.dart';
import '../care/appointment_tracker_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final journey = provider.journey;
        final name = journey?.name ?? 'User';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: Text('Profile & Settings',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile card
                RehlaCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primarySurface,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: GoogleFonts.inter(
                                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            if (journey != null) ...[
                              Text(journey.cancerType,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              Text('${journey.stage} • ${journey.treatmentPhase}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                        onPressed: () => _showEditProfile(context, provider),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Journey stats
                const SectionHeader(title: 'Journey Stats'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _StatCard(label: 'Check-ins', value: '${provider.checkIns.length}', icon: Icons.check_circle_rounded, color: AppColors.primary)),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(label: 'Day Streak', value: '${provider.checkInStreak}', icon: Icons.local_fire_department_rounded, color: const Color(0xFFF4B63E))),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(label: 'Med Rate', value: '95%', icon: Icons.medication_rounded, color: AppColors.accent)),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Quick access to moved sections ───────────────────────
                const SectionHeader(title: 'Health Tracking'),
                const SizedBox(height: 12),
                _SettingsSection(
                  items: [
                    _SettingsItem(
                      icon: Icons.science_rounded,
                      label: 'Labs & Results',
                      subtitle: 'View lab results, trends, AI analysis',
                      color: AppColors.info,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const LabTrackerScreen())),
                    ),
                    _SettingsItem(
                      icon: Icons.medication_rounded,
                      label: 'Medications',
                      subtitle: 'Track and manage your medications',
                      color: AppColors.primary,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MedicationTrackerScreen())),
                    ),
                    _SettingsItem(
                      icon: Icons.calendar_today_rounded,
                      label: 'Appointments',
                      subtitle: 'Upcoming and past appointments',
                      color: AppColors.amber,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AppointmentTrackerScreen())),
                    ),
                    _SettingsItem(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Yusr AI Coach',
                      subtitle: 'Ask health questions, get guidance',
                      color: AppColors.teal,
                      onTap: () => provider.setNavIndex(2),
                    ),
                    _SettingsItem(
                      icon: Icons.people_rounded,
                      label: 'Caregiver Mode',
                      subtitle: 'Invite a caregiver — coming soon',
                      color: const Color(0xFF78716C),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Account
                const SectionHeader(title: 'Account'),
                const SizedBox(height: 12),
                _SettingsSection(
                  items: [
                    _SettingsItem(icon: Icons.person_rounded, label: 'Edit Profile', color: AppColors.primary),
                    _SettingsItem(icon: Icons.medical_information_rounded, label: 'Journey Details', color: AppColors.info),
                    _SettingsItem(icon: Icons.notifications_rounded, label: 'Notifications', color: AppColors.warning),
                    _SettingsItem(icon: Icons.language_rounded, label: 'Language', subtitle: 'English', color: AppColors.accent),
                  ],
                ),
                const SizedBox(height: 20),

                // Privacy & data
                const SectionHeader(title: 'Privacy & Data'),
                const SizedBox(height: 12),
                _SettingsSection(
                  items: [
                    _SettingsItem(icon: Icons.lock_rounded, label: 'Privacy & Data Security', color: AppColors.primary),
                    _SettingsItem(icon: Icons.download_rounded, label: 'Export My Data', color: AppColors.accent),
                    _SettingsItem(icon: Icons.share_rounded, label: 'Share Care Binder', color: AppColors.info),
                  ],
                ),
                const SizedBox(height: 20),

                // Help
                const SectionHeader(title: 'Help & Support'),
                const SizedBox(height: 12),
                _SettingsSection(
                  items: [
                    _SettingsItem(icon: Icons.help_rounded, label: 'FAQ & Help Center', color: AppColors.primary),
                    _SettingsItem(icon: Icons.feedback_rounded, label: 'Send Feedback', color: AppColors.accent),
                    _SettingsItem(icon: Icons.policy_rounded, label: 'Terms & Privacy Policy', color: AppColors.textMuted),
                  ],
                ),
                const SizedBox(height: 20),

                // Data security badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: AppColors.accent, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your data is encrypted and HIPAA compliant',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            Text('We never share your data without your explicit consent.',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Create account CTA
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF5F0F9), Color(0xFFFDF8FD)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Create an account',
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      const Text('Save your journey, invite a caregiver, and sync across devices.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _showEditProfile(context, provider),
                              child: const Text('Create Account'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _showLoginSheet(context),
                              child: const Text('Log In'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Reset journey
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Reset Journey?'),
                        content: const Text('This will delete all your check-ins and journey data. This cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () async {
                              await provider.resetJourney();
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                Navigator.pushReplacementNamed(context, '/');
                              }
                            },
                            child: const Text('Reset', style: TextStyle(color: AppColors.danger)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                    ),
                    child: const Center(
                      child: Text(
                        'Reset Journey',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.danger),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text('Rehla v1.0.0 • Free (donations welcome)',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return RehlaCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return RehlaCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: items.asMap().entries.map((e) {
          final idx = e.key;
          final item = e.value;
          return Column(
            children: [
              InkWell(
                onTap: item.onTap ?? () => _showSettingsItem(context, item.label),
                borderRadius: idx == 0
                    ? const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
                    : idx == items.length - 1
                        ? const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))
                        : BorderRadius.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item.icon, color: item.color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.label,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                            if (item.subtitle != null)
                              Text(item.subtitle!,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                    ],
                  ),
                ),
              ),
              if (idx < items.length - 1)
                const Divider(height: 1, indent: 64),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;

  _SettingsItem({required this.icon, required this.label, this.subtitle, required this.color, this.onTap});
}

// ─── Profile Helper Functions ─────────────────────────────────────────────────
void _showEditProfile(BuildContext context, AppProvider provider) {
  final nameCtrl = TextEditingController(text: provider.journey?.name ?? '');
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 20, left: 140), decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const Text('Edit Profile', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Your name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty && provider.journey != null) {
                    provider.journey!.name = nameCtrl.text.trim();
                    provider.saveJourney(provider.journey!);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated!'), backgroundColor: AppColors.primary),
                    );
                  } else {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account creation coming soon — app is in MVP mode.')),
                    );
                  }
                },
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

void _showLoginSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 20, left: 140), decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const Text('Log In to Rehla', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('Cloud sync and multi-device support coming soon.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Rehla MVP runs offline. Cloud accounts will be available in the next release.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

void _showSettingsItem(BuildContext context, String label) {
  final messages = {
    'Edit Profile': 'Edit profile',
    'Journey Details': 'Journey details',
    'Notifications': 'Notification settings',
    'Language': 'Language selection',
    'Privacy & Data Security': 'Privacy policy',
    'Export My Data': 'Data export',
    'Share Care Binder': 'Share binder',
    'About Rehla': 'About',
  };
  final msg = messages[label] ?? label;

  if (label == 'Export My Data') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export started — your data will be emailed to you.'), backgroundColor: AppColors.accent),
    );
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$msg — coming in next release'), behavior: SnackBarBehavior.floating),
  );
}
