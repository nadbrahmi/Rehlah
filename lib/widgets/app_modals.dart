import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Central hub for all bottom sheet modals across the app.
/// Every previously-dead link calls one of these.
class AppModals {
  // ─── Generic "Coming Soon" ───────────────────────────────────────────────
  static void showComingSoon(BuildContext context, String feature) {
    _show(context, child: _ComingSoonSheet(feature: feature));
  }

  // ─── Notifications ───────────────────────────────────────────────────────
  static void showNotifications(BuildContext context) {
    _show(context, child: const _NotificationsSheet());
  }

  // ─── Edit Profile ────────────────────────────────────────────────────────
  static void showEditProfile(BuildContext context, String currentName) {
    _show(context, child: _EditProfileSheet(currentName: currentName));
  }

  // ─── Message Care Team ───────────────────────────────────────────────────
  static void showMessageCareTeam(BuildContext context, String doctorName) {
    _show(context, child: _MessageSheet(doctorName: doctorName));
  }

  // ─── Add Medication ──────────────────────────────────────────────────────
  static void showAddMedication(BuildContext context) {
    _show(context, child: const _AddMedicationSheet());
  }

  // ─── Invite Care Team ────────────────────────────────────────────────────
  static void showInviteCareTeam(BuildContext context) {
    _show(context, child: const _InviteCareTeamSheet());
  }

  // ─── Upload Document ─────────────────────────────────────────────────────
  static void showUploadDocument(BuildContext context) {
    _show(context, child: const _UploadDocumentSheet());
  }

  // ─── Download PDF Report ─────────────────────────────────────────────────
  static void showDownloadReport(BuildContext context) {
    _show(context, child: const _DownloadReportSheet());
  }

  // ─── Share Care Binder ───────────────────────────────────────────────────
  static void showShareBinder(BuildContext context) {
    _show(context, child: const _ShareBinderSheet());
  }

  // ─── Book Wellness Session ───────────────────────────────────────────────
  static void showBookSession(BuildContext context, String serviceName) {
    _show(context, child: _BookSessionSheet(serviceName: serviceName));
  }

  // ─── Connect Mentor ──────────────────────────────────────────────────────
  static void showConnectMentor(BuildContext context, String mentorName) {
    _show(context, child: _ConnectMentorSheet(mentorName: mentorName));
  }

  // ─── Share Post ──────────────────────────────────────────────────────────
  static void showSharePost(BuildContext context) {
    _show(context, child: const _SharePostSheet());
  }

  // ─── Like / React ────────────────────────────────────────────────────────
  static void showReactions(BuildContext context) {
    _show(context, child: const _ReactionsSheet());
  }

  // ─── Resource Detail ─────────────────────────────────────────────────────
  static void showResourceDetail(BuildContext context, String title, String tag) {
    _show(context, child: _ResourceDetailSheet(title: title, tag: tag));
  }

  // ─── Add Appointment ─────────────────────────────────────────────────────
  static void showAddAppointment(BuildContext context) {
    _show(context, child: const _AddAppointmentSheet());
  }

  // ─── Create Account ──────────────────────────────────────────────────────
  static void showCreateAccount(BuildContext context) {
    _show(context, child: const _CreateAccountSheet());
  }

  // ─── Settings Item ───────────────────────────────────────────────────────
  static void showSettingsItem(BuildContext context, String title, String body) {
    _show(context, child: _GenericInfoSheet(title: title, body: body));
  }

  // ─── Export Data ─────────────────────────────────────────────────────────
  static void showExportData(BuildContext context) {
    _show(context, child: const _ExportDataSheet());
  }

  // ─── Journey Details Edit ────────────────────────────────────────────────
  static void showJourneyDetails(BuildContext context) {
    _show(context, child: const _JourneyDetailsSheet());
  }

  // ─── Scan Lab Results ────────────────────────────────────────────────────
  static void showScanLabs(BuildContext context) {
    _show(context, child: const _ScanLabsSheet());
  }

  // ─── Doctor Report ───────────────────────────────────────────────────────
  static void showDoctorReport(BuildContext context) {
    _show(context, child: const _DoctorReportSheet());
  }

  // ─── New Post ────────────────────────────────────────────────────────────
  static void showNewPost(BuildContext context) {
    _show(context, child: const _NewPostSheet());
  }

  // ─── Helper ──────────────────────────────────────────────────────────────
  static void _show(BuildContext context, {required Widget child}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Shared shell
// ═══════════════════════════════════════════════════════════════════
class _ModalShell extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;

  const _ModalShell({required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Individual sheets
// ═══════════════════════════════════════════════════════════════════

class _ComingSoonSheet extends StatelessWidget {
  final String feature;
  const _ComingSoonSheet({required this.feature});
  @override
  Widget build(BuildContext context) {
    return _ModalShell(
      title: feature,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.construction_rounded, color: AppColors.primary, size: 32),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Coming soon!', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('This feature is being built. Stay tuned for updates.',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
        _ModalButton(label: 'Got it', onTap: () => Navigator.pop(context)),
      ]),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();
  @override
  Widget build(BuildContext context) {
    final notifications = [
      _Notif(icon: Icons.edit_note_rounded, color: AppColors.primary,
          title: 'Daily Check-In Reminder', body: 'Time for your 6:00 PM check-in', time: 'Just now'),
      _Notif(icon: Icons.calendar_today_rounded, color: AppColors.info,
          title: 'Appointment Tomorrow', body: 'Oncologist Visit at 2:00 PM', time: '2h ago'),
      _Notif(icon: Icons.medication_rounded, color: AppColors.accent,
          title: 'Morning Medications', body: 'Don\'t forget Tamoxifen 20mg', time: '8h ago'),
      _Notif(icon: Icons.insights_rounded, color: const Color(0xFFF4B63E),
          title: 'New AI Insight', body: 'Your mood improved 15% this week!', time: '1d ago'),
    ];
    return _ModalShell(
      title: 'Notifications',
      child: Column(children: notifications.map((n) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          Container(width: 40, height: 40,
              decoration: BoxDecoration(color: n.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(n.icon, color: n.color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(n.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text(n.body, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          Text(n.time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ]),
      )).toList()),
    );
  }
}

class _Notif { final IconData icon; final Color color; final String title, body, time;
  const _Notif({required this.icon, required this.color, required this.title, required this.body, required this.time}); }

class _EditProfileSheet extends StatefulWidget {
  final String currentName;
  const _EditProfileSheet({required this.currentName});
  @override State<_EditProfileSheet> createState() => _EditProfileSheetState();
}
class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _ctrl;
  @override void initState() { super.initState(); _ctrl = TextEditingController(text: widget.currentName); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Edit Profile',
    child: Column(children: [
      TextField(controller: _ctrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_rounded))),
      const SizedBox(height: 12),
      const TextField(decoration: InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_rounded))),
      const SizedBox(height: 20),
      _ModalButton(label: 'Save Changes', onTap: () { Navigator.pop(context); _showSnack(context, 'Profile updated!'); }),
    ]),
  );
}

class _MessageSheet extends StatefulWidget {
  final String doctorName;
  const _MessageSheet({required this.doctorName});
  @override State<_MessageSheet> createState() => _MessageSheetState();
}
class _MessageSheetState extends State<_MessageSheet> {
  final _ctrl = TextEditingController();
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Message ${widget.doctorName}',
    child: Column(children: [
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
          child: const Row(children: [
            Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 14),
            SizedBox(width: 8),
            Text('Secure message — visible only to your care team', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ])),
      const SizedBox(height: 12),
      TextField(controller: _ctrl, maxLines: 4,
          decoration: const InputDecoration(hintText: 'Write your message...', alignLabelWithHint: true)),
      const SizedBox(height: 16),
      _ModalButton(label: 'Send Message', icon: Icons.send_rounded,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Message sent to ${widget.doctorName}'); }),
    ]),
  );
}

class _AddMedicationSheet extends StatefulWidget {
  const _AddMedicationSheet();
  @override State<_AddMedicationSheet> createState() => _AddMedicationSheetState();
}
class _AddMedicationSheetState extends State<_AddMedicationSheet> {
  final _name = TextEditingController();
  final _dosage = TextEditingController();
  String _frequency = 'Daily Morning';
  static const _freqs = ['Daily Morning', 'Daily Evening', 'Twice Daily', 'Weekly', 'As needed'];
  @override void dispose() { _name.dispose(); _dosage.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Add Medication',
    child: Column(children: [
      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Medication Name', prefixIcon: Icon(Icons.medication_rounded))),
      const SizedBox(height: 12),
      TextField(controller: _dosage, decoration: const InputDecoration(labelText: 'Dosage (e.g. 20mg)', prefixIcon: Icon(Icons.scale_rounded))),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: _frequency,
        decoration: const InputDecoration(labelText: 'Frequency', prefixIcon: Icon(Icons.schedule_rounded)),
        items: _freqs.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
        onChanged: (v) => setState(() => _frequency = v!),
      ),
      const SizedBox(height: 20),
      _ModalButton(label: 'Add Medication', icon: Icons.add_rounded,
          onTap: () { Navigator.pop(context); _showSnack(context, '${_name.text.isEmpty ? "Medication" : _name.text} added!'); }),
    ]),
  );
}

class _InviteCareTeamSheet extends StatefulWidget {
  const _InviteCareTeamSheet();
  @override State<_InviteCareTeamSheet> createState() => _InviteCareTeamSheetState();
}
class _InviteCareTeamSheetState extends State<_InviteCareTeamSheet> {
  final _email = TextEditingController();
  String _role = 'Oncologist';
  static const _roles = ['Oncologist', 'Nurse', 'Counselor', 'Caregiver', 'Other'];
  @override void dispose() { _email.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Invite Care Team Member',
    child: Column(children: [
      TextField(controller: _email, keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_rounded))),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: _role,
        decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.badge_rounded)),
        items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
        onChanged: (v) => setState(() => _role = v!),
      ),
      const SizedBox(height: 20),
      _ModalButton(label: 'Send Invite', icon: Icons.send_rounded,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Invite sent!'); }),
    ]),
  );
}

class _UploadDocumentSheet extends StatelessWidget {
  const _UploadDocumentSheet();
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Upload Document',
    child: Column(children: [
      _UploadOption(icon: Icons.camera_alt_rounded, label: 'Take a Photo', sub: 'Capture document with camera', color: AppColors.primary,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Camera opened (demo)'); }),
      const SizedBox(height: 10),
      _UploadOption(icon: Icons.photo_library_rounded, label: 'Choose from Gallery', sub: 'Select an image from your photos', color: AppColors.accent,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Gallery opened (demo)'); }),
      const SizedBox(height: 10),
      _UploadOption(icon: Icons.picture_as_pdf_rounded, label: 'Upload PDF', sub: 'Select a PDF file', color: AppColors.info,
          onTap: () { Navigator.pop(context); _showSnack(context, 'File picker opened (demo)'); }),
      const SizedBox(height: 12),
      Text('Supported: PDF, JPG, PNG (max 10MB)',
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted), textAlign: TextAlign.center),
    ]),
  );
}

class _UploadOption extends StatelessWidget {
  final IconData icon; final String label, sub; final Color color; final VoidCallback onTap;
  const _UploadOption({required this.icon, required this.label, required this.sub, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        Icon(Icons.chevron_right_rounded, color: color, size: 20),
      ]),
    ),
  );
}

class _DownloadReportSheet extends StatelessWidget {
  const _DownloadReportSheet();
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Doctor-Ready Report',
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Your report includes:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            ..._reportItems.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 14),
                const SizedBox(width: 8),
                Text(r, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            )),
          ])),
      const SizedBox(height: 16),
      _ModalButton(label: 'Download PDF', icon: Icons.download_rounded, color: AppColors.primary,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Report downloaded (demo)'); }),
      const SizedBox(height: 10),
      _ModalButton(label: 'Email to Doctor', icon: Icons.email_rounded, color: AppColors.accent, outlined: true,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Email sent (demo)'); }),
    ]),
  );
  static const _reportItems = [
    '14-day symptom summary', 'Mood & energy trends',
    'Medication adherence', 'Upcoming appointments', 'AI insights summary',
  ];
}

class _ShareBinderSheet extends StatelessWidget {
  const _ShareBinderSheet();
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Share Care Binder',
    child: Column(children: [
      const Text('Share your care binder securely with your care team or caregiver.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(height: 16),
      _ModalButton(label: 'Send via Email', icon: Icons.email_rounded,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Binder shared via email (demo)'); }),
      const SizedBox(height: 10),
      _ModalButton(label: 'Copy Share Link', icon: Icons.link_rounded, outlined: true,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Link copied!'); }),
    ]),
  );
}

class _BookSessionSheet extends StatelessWidget {
  final String serviceName;
  const _BookSessionSheet({required this.serviceName});
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Book: $serviceName',
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Select a date and time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: ['Mon Mar 11', 'Tue Mar 12', 'Wed Mar 13', 'Thu Mar 14', 'Fri Mar 15']
          .map((d) => _DateChip(label: d)).toList()),
      const SizedBox(height: 16),
      const Text('Available times', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: ['9:00 AM', '10:30 AM', '12:00 PM', '2:00 PM', '3:30 PM']
          .map((t) => _DateChip(label: t)).toList()),
      const SizedBox(height: 20),
      _ModalButton(label: 'Confirm Booking', icon: Icons.check_rounded,
          onTap: () { Navigator.pop(context); _showSnack(context, '$serviceName booked! (demo)'); }),
    ]),
  );
}

class _DateChip extends StatefulWidget { final String label; const _DateChip({required this.label}); @override State<_DateChip> createState() => _DateChipState(); }
class _DateChipState extends State<_DateChip> {
  bool _selected = false;
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => _selected = !_selected),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _selected ? AppColors.primary : AppColors.primarySurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _selected ? AppColors.primary : AppColors.divider),
      ),
      child: Text(widget.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: _selected ? Colors.white : AppColors.textPrimary)),
    ),
  );
}

class _ConnectMentorSheet extends StatelessWidget {
  final String mentorName;
  const _ConnectMentorSheet({required this.mentorName});
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Connect with $mentorName',
    child: Column(children: [
      Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(12)),
          child: const Row(children: [
            Icon(Icons.people_rounded, color: AppColors.accent, size: 18),
            SizedBox(width: 10),
            Expanded(child: Text('Peer mentors share lived experience, not medical advice.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          ])),
      const SizedBox(height: 16),
      _ModalButton(label: 'Send Connection Request', icon: Icons.person_add_rounded,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Request sent to $mentorName!'); }),
      const SizedBox(height: 10),
      _ModalButton(label: 'Send a Message First', icon: Icons.chat_bubble_rounded, outlined: true,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Message sent to $mentorName (demo)'); }),
    ]),
  );
}

class _SharePostSheet extends StatelessWidget {
  const _SharePostSheet();
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Share Post',
    child: Column(children: [
      _ShareOption(icon: Icons.link_rounded, label: 'Copy Link', color: AppColors.primary,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Link copied!'); }),
      const SizedBox(height: 10),
      _ShareOption(icon: Icons.email_rounded, label: 'Share via Email', color: AppColors.accent,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Shared via email (demo)'); }),
      const SizedBox(height: 10),
      _ShareOption(icon: Icons.message_rounded, label: 'Share via Message', color: AppColors.info,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Shared via message (demo)'); }),
    ]),
  );
}

class _ShareOption extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ShareOption({required this.icon, required this.label, required this.color, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ]),
    ),
  );
}

class _ReactionsSheet extends StatelessWidget {
  const _ReactionsSheet();
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'React',
    child: Wrap(spacing: 12, children: [
      '❤️ Love', '💪 Strong', '🙏 Thank you', '💜 Support', '✨ Inspiring'
    ].map((r) => GestureDetector(
      onTap: () { Navigator.pop(context); _showSnack(context, 'Reacted with ${r.split(' ').first}'); },
      child: Chip(label: Text(r, style: const TextStyle(fontSize: 14))),
    )).toList()),
  );
}

class _ResourceDetailSheet extends StatelessWidget {
  final String title, tag;
  const _ResourceDetailSheet({required this.title, required this.tag});
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: title,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(6)),
        child: Text(tag, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
      ),
      const SizedBox(height: 14),
      Text(_getSampleBody(tag), style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
      const SizedBox(height: 20),
      _ModalButton(label: 'Mark as Helpful', icon: Icons.thumb_up_rounded,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Marked as helpful!'); }),
      const SizedBox(height: 10),
      _ModalButton(label: 'Save to Binder', icon: Icons.bookmark_rounded, outlined: true,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Saved to your Care Binder!'); }),
    ]),
  );
  static String _getSampleBody(String tag) {
    switch (tag) {
      case 'skin care': return 'During radiation therapy, your skin may become sensitive and red. Keep the area moisturised with unscented lotion, avoid sun exposure, and wear loose clothing. Always check with your care team before applying any new products.';
      case 'nutrition': return 'Eating well during treatment helps your body heal. Focus on protein-rich foods, stay hydrated, and eat small frequent meals if nausea is an issue. Avoid raw or undercooked foods if your immune system is suppressed.';
      default: return 'Evidence-based information reviewed by medical specialists to support you through your cancer journey. Always consult your care team for personalised advice.';
    }
  }
}

class _AddAppointmentSheet extends StatefulWidget {
  const _AddAppointmentSheet();
  @override State<_AddAppointmentSheet> createState() => _AddAppointmentSheetState();
}
class _AddAppointmentSheetState extends State<_AddAppointmentSheet> {
  final _title = TextEditingController();
  final _doctor = TextEditingController();
  @override void dispose() { _title.dispose(); _doctor.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Add Appointment',
    child: Column(children: [
      TextField(controller: _title, decoration: const InputDecoration(labelText: 'Appointment Title', prefixIcon: Icon(Icons.event_rounded))),
      const SizedBox(height: 12),
      TextField(controller: _doctor, decoration: const InputDecoration(labelText: 'Doctor / Location', prefixIcon: Icon(Icons.local_hospital_rounded))),
      const SizedBox(height: 20),
      _ModalButton(label: 'Save Appointment', icon: Icons.check_rounded,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Appointment saved!'); }),
    ]),
  );
}

class _CreateAccountSheet extends StatelessWidget {
  const _CreateAccountSheet();
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Create Your Account',
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Save your journey, sync across devices, and invite your caregiver.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(height: 16),
      const TextField(decoration: InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_rounded))),
      const SizedBox(height: 12),
      const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Create Password', prefixIcon: Icon(Icons.lock_rounded))),
      const SizedBox(height: 20),
      _ModalButton(label: 'Create Account', icon: Icons.person_add_rounded,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Account created! (demo)'); }),
      const SizedBox(height: 10),
      _ModalButton(label: 'Log In Instead', outlined: true,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Logged in (demo)'); }),
    ]),
  );
}

class _GenericInfoSheet extends StatelessWidget {
  final String title, body;
  const _GenericInfoSheet({required this.title, required this.body});
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: title,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(body, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
      const SizedBox(height: 20),
      _ModalButton(label: 'Close', outlined: true, onTap: () => Navigator.pop(context)),
    ]),
  );
}

class _ExportDataSheet extends StatelessWidget {
  const _ExportDataSheet();
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Export My Data',
    child: Column(children: [
      Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(12)),
          child: const Row(children: [
            Icon(Icons.verified_user_rounded, color: AppColors.accent, size: 18),
            SizedBox(width: 10),
            Expanded(child: Text('Your data is encrypted. Export includes all check-ins, medications and journey info.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          ])),
      const SizedBox(height: 16),
      _ModalButton(label: 'Export as PDF', icon: Icons.picture_as_pdf_rounded,
          onTap: () { Navigator.pop(context); _showSnack(context, 'PDF export started (demo)'); }),
      const SizedBox(height: 10),
      _ModalButton(label: 'Export as CSV', icon: Icons.table_chart_rounded, outlined: true,
          onTap: () { Navigator.pop(context); _showSnack(context, 'CSV export started (demo)'); }),
    ]),
  );
}

class _JourneyDetailsSheet extends StatelessWidget {
  const _JourneyDetailsSheet();
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Journey Details',
    child: Column(children: [
      const Text('Update your cancer type, stage or current treatment phase.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(height: 16),
      _ModalButton(label: 'Update Journey Details',
          onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/onboarding'); }),
    ]),
  );
}

class _ScanLabsSheet extends StatelessWidget {
  const _ScanLabsSheet();
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Scan Lab Results',
    child: Column(children: [
      Container(height: 120, decoration: BoxDecoration(
          color: AppColors.primarySurface, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider, width: 2, style: BorderStyle.solid)),
          child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.document_scanner_rounded, color: AppColors.primary, size: 36),
            SizedBox(height: 8),
            Text('Tap to scan or upload', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ]))),
      const SizedBox(height: 16),
      _ModalButton(label: 'Scan with Camera', icon: Icons.camera_alt_rounded,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Camera opened (demo)'); }),
      const SizedBox(height: 10),
      _ModalButton(label: 'Upload from Files', icon: Icons.upload_file_rounded, outlined: true,
          onTap: () { Navigator.pop(context); _showSnack(context, 'File picker opened (demo)'); }),
    ]),
  );
}

class _DoctorReportSheet extends StatelessWidget {
  const _DoctorReportSheet();
  @override
  Widget build(BuildContext context) => _DownloadReportSheet().build(context);
}

class _NewPostSheet extends StatefulWidget {
  const _NewPostSheet();
  @override State<_NewPostSheet> createState() => _NewPostSheetState();
}
class _NewPostSheetState extends State<_NewPostSheet> {
  final _ctrl = TextEditingController();
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => _ModalShell(
    title: 'Share with Community',
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(controller: _ctrl, maxLines: 4,
          decoration: const InputDecoration(hintText: 'Share your experience, tip or encouragement...')),
      const SizedBox(height: 8),
      const Text('Community & coach suggestions, not medical advice.',
          style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      const SizedBox(height: 16),
      _ModalButton(label: 'Post', icon: Icons.send_rounded,
          onTap: () { Navigator.pop(context); _showSnack(context, 'Post shared with community! (demo)'); }),
    ]),
  );
}

// ─── Shared helpers ────────────────────────────────────────────────────────
class _ModalButton extends StatelessWidget {
  final String label; final IconData? icon; final VoidCallback onTap;
  final bool outlined; final Color color;
  const _ModalButton({required this.label, this.icon, required this.onTap,
      this.outlined = false, this.color = AppColors.primary});
  @override
  Widget build(BuildContext context) {
    final child = Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 17, color: outlined ? color : Colors.white), const SizedBox(width: 8)],
      Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: outlined ? color : Colors.white)),
    ]);
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: onTap,
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: color, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: child)
          : ElevatedButton(onPressed: onTap,
              style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: child),
    );
  }
}

void _showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: Colors.white)),
    backgroundColor: AppColors.primary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 2),
  ));
}
