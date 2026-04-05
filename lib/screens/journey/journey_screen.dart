import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';

// ─── Phase Data Model ─────────────────────────────────────────────────────────
class PhaseInfo {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final Color lightColor;
  final String overview;
  final String duration;
  final List<String> whatToExpect;
  final List<PhaseMilestone> milestones;
  final List<GuidanceVideo> videos;
  final List<String> tips;

  const PhaseInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.lightColor,
    required this.overview,
    required this.duration,
    required this.whatToExpect,
    required this.milestones,
    required this.videos,
    required this.tips,
  });
}

class PhaseMilestone {
  final String title;
  final String description;
  final IconData icon;
  const PhaseMilestone({required this.title, required this.description, required this.icon});
}

class GuidanceVideo {
  final String title;
  final String channel;
  final String duration;
  final String thumbnail;
  final String url;
  final String description;
  const GuidanceVideo({
    required this.title,
    required this.channel,
    required this.duration,
    required this.thumbnail,
    required this.url,
    required this.description,
  });
}

// ─── Phase Content Database ───────────────────────────────────────────────────
const List<PhaseInfo> _phases = [
  PhaseInfo(
    id: 'diagnosis',
    name: 'Diagnosis & Planning',
    icon: '🔬',
    color: AppColors.diagnosis,
    lightColor: AppColors.infoLight,
    duration: '2–4 weeks',
    overview:
        "This phase involves confirming your diagnosis, staging your cancer, and working with your care team to build a personalized treatment plan. It can feel overwhelming, but it's also when you gain clarity about the path ahead.",
    whatToExpect: [
      'Multiple specialist appointments (oncologist, surgeon, radiologist)',
      'Biopsy results and pathology reports',
      'Imaging scans (MRI, CT, PET)',
      'Genetic testing and hormone receptor testing (for some cancers)',
      'Multidisciplinary team meetings to finalize your plan',
      'Discussions about fertility preservation if relevant',
    ],
    milestones: [
      PhaseMilestone(
        title: 'Biopsy & Pathology Confirmed',
        description: 'Tissue analysis confirms diagnosis and cancer type',
        icon: Icons.biotech_rounded,
      ),
      PhaseMilestone(
        title: 'Staging Complete',
        description: 'Scans determine how far the cancer has spread',
        icon: Icons.search_rounded,
      ),
      PhaseMilestone(
        title: 'Oncologist Consultation',
        description: 'Review results and discuss treatment options',
        icon: Icons.medical_services_rounded,
      ),
      PhaseMilestone(
        title: 'Treatment Plan Approved',
        description: 'Your care team finalizes a personalized treatment plan',
        icon: Icons.assignment_turned_in_rounded,
      ),
    ],
    videos: [
      GuidanceVideo(
        title: 'Understanding Your Cancer Diagnosis',
        channel: 'Cancer Research UK',
        duration: '8:42',
        thumbnail: 'https://img.youtube.com/vi/iNRgQ_e3IDk/mqdefault.jpg',
        url: 'https://www.youtube.com/watch?v=iNRgQ_e3IDk',
        description: 'What your diagnosis means and how to process it',
      ),
      GuidanceVideo(
        title: 'Questions to Ask Your Oncologist',
        channel: 'American Cancer Society',
        duration: '6:15',
        thumbnail: 'https://img.youtube.com/vi/placeholder/mqdefault.jpg',
        url: 'https://www.youtube.com/results?search_query=questions+ask+oncologist+cancer',
        description: 'How to prepare for your first oncology appointment',
      ),
    ],
    tips: [
      'Bring a trusted person to all appointments to help remember information',
      'Write down all your questions before each visit',
      'Ask for copies of all your test results and reports',
      'Consider getting a second opinion — your care team expects this',
      'Don\'t make major life decisions in the first few weeks',
    ],
  ),
  PhaseInfo(
    id: 'preTreatment',
    name: 'Pre-Treatment (Planning)',
    icon: '📋',
    color: AppColors.warning,
    lightColor: AppColors.warningLight,
    duration: '1–3 weeks',
    overview:
        'Before treatment begins, your body and life need preparation. This phase includes port placement, baseline tests, dental checks, and emotional preparation. A little preparation now makes treatment much smoother.',
    whatToExpect: [
      'Port or PICC line placement for chemotherapy delivery',
      'Baseline blood work, heart function tests (echocardiogram)',
      'Dental clearance before certain treatments',
      'Fertility preservation procedures if desired',
      'Meeting with a nutritionist and social worker',
      'Reviewing insurance and financial assistance options',
    ],
    milestones: [
      PhaseMilestone(
        title: 'Port/PICC Line Placed',
        description: 'Access device installed for safe medication delivery',
        icon: Icons.link_rounded,
      ),
      PhaseMilestone(
        title: 'Baseline Tests Complete',
        description: 'Heart, blood, and organ function recorded',
        icon: Icons.favorite_rounded,
      ),
      PhaseMilestone(
        title: 'Support Team Assembled',
        description: 'Caregivers, social worker, and nutritionist identified',
        icon: Icons.people_rounded,
      ),
      PhaseMilestone(
        title: 'Ready to Begin Treatment',
        description: 'All pre-checks complete — treatment starts soon',
        icon: Icons.check_circle_rounded,
      ),
    ],
    videos: [
      GuidanceVideo(
        title: 'How to Prepare for Chemotherapy',
        channel: 'Mayo Clinic',
        duration: '7:30',
        thumbnail: 'https://img.youtube.com/vi/placeholder2/mqdefault.jpg',
        url: 'https://www.youtube.com/results?search_query=prepare+for+chemotherapy+patient+guide',
        description: 'Practical steps to get ready for your first chemo session',
      ),
      GuidanceVideo(
        title: 'Port Placement: What to Expect',
        channel: 'MD Anderson Cancer Center',
        duration: '4:50',
        thumbnail: 'https://img.youtube.com/vi/placeholder3/mqdefault.jpg',
        url: 'https://www.youtube.com/results?search_query=chemo+port+placement+what+to+expect',
        description: 'Understanding the port procedure and recovery',
      ),
    ],
    tips: [
      'Stock your home with easy-to-prepare meals and comfort items',
      'Arrange transportation for treatment days in advance',
      'Set up an online grocery delivery subscription',
      'Prepare mentally — journaling and counseling can help',
      'Get all dental work done before treatment starts',
    ],
  ),
  PhaseInfo(
    id: 'chemo',
    name: 'Chemotherapy',
    icon: '💊',
    color: AppColors.chemo,
    lightColor: AppColors.primarySurface,
    duration: '3–6 months (varies)',
    overview:
        'Chemotherapy uses powerful medications to kill cancer cells or stop them from growing. Treatment is given in cycles with rest periods in between, allowing your body to recover. Side effects are manageable with the right support.',
    whatToExpect: [
      'Infusion sessions lasting 2–8 hours, every 1–3 weeks',
      'Fatigue that builds over the course of treatment',
      'Nausea and vomiting (anti-nausea meds help greatly)',
      'Hair loss (usually begins 2–4 weeks after first treatment)',
      'Increased infection risk due to lower white blood cell counts',
      'Regular blood tests to monitor your counts and organ function',
      'Possible mouth sores and changes in taste',
    ],
    milestones: [
      PhaseMilestone(
        title: 'First Chemotherapy Session',
        description: 'Your first infusion — a major milestone',
        icon: Icons.water_drop_rounded,
      ),
      PhaseMilestone(
        title: 'Halfway Point',
        description: 'Mid-treatment scan to assess response',
        icon: Icons.flag_rounded,
      ),
      PhaseMilestone(
        title: 'Final Chemo Cycle',
        description: 'Last scheduled chemotherapy infusion',
        icon: Icons.celebration_rounded,
      ),
      PhaseMilestone(
        title: 'Post-Chemo Assessment',
        description: 'Scans and labs to evaluate treatment effectiveness',
        icon: Icons.monitor_heart_rounded,
      ),
    ],
    videos: [
      GuidanceVideo(
        title: 'What Happens During Chemotherapy',
        channel: 'Cancer Research UK',
        duration: '9:15',
        thumbnail: 'https://img.youtube.com/vi/placeholder4/mqdefault.jpg',
        url: 'https://www.youtube.com/results?search_query=what+happens+during+chemotherapy+explained',
        description: 'A step-by-step look at your chemo session experience',
      ),
      GuidanceVideo(
        title: 'Managing Chemo Side Effects',
        channel: 'Memorial Sloan Kettering',
        duration: '12:00',
        thumbnail: 'https://img.youtube.com/vi/placeholder5/mqdefault.jpg',
        url: 'https://www.youtube.com/results?search_query=managing+chemotherapy+side+effects+tips',
        description: 'Practical strategies for nausea, fatigue, and hair loss',
      ),
      GuidanceVideo(
        title: 'Nutrition During Chemotherapy',
        channel: 'UCSF Health',
        duration: '8:30',
        thumbnail: 'https://img.youtube.com/vi/placeholder6/mqdefault.jpg',
        url: 'https://www.youtube.com/results?search_query=nutrition+diet+during+chemotherapy',
        description: 'What to eat (and avoid) to keep your strength up',
      ),
    ],
    tips: [
      'Take anti-nausea medication as prescribed — don\'t wait until you feel sick',
      'Rest when you need to, but gentle walking helps with fatigue',
      'Use a soft toothbrush and rinse your mouth regularly',
      'Avoid raw meat, eggs, and unwashed produce to prevent infection',
      'Stay hydrated — at least 8 glasses of water daily',
      'Keep a symptom journal and report anything unusual to your team',
    ],
  ),
  PhaseInfo(
    id: 'radiation',
    name: 'Radiation Therapy',
    icon: '☢️',
    color: Color(0xFFFF6B6B),
    lightColor: Color(0xFFFFEBEB),
    duration: '3–8 weeks (5 days/week)',
    overview:
        'Radiation therapy uses high-energy rays to destroy cancer cells in a specific area. It is usually painless and very precise. Side effects are generally localized to the treated area and tend to build up gradually over the course of treatment.',
    whatToExpect: [
      'Short daily sessions (10–30 minutes) Monday through Friday',
      'Treatment planning session with simulation and mapping',
      'Skin redness, irritation, or peeling in the treatment area',
      'Fatigue that accumulates over weeks of treatment',
      'Possible swelling in the treatment area',
      'Specific side effects depend on the area being treated',
    ],
    milestones: [
      PhaseMilestone(
        title: 'Radiation Planning (Simulation)',
        description: 'CT scan and body markings to map the treatment area',
        icon: Icons.adjust_rounded,
      ),
      PhaseMilestone(
        title: 'First Radiation Session',
        description: 'Treatment begins — you\'re on your way',
        icon: Icons.bolt_rounded,
      ),
      PhaseMilestone(
        title: 'Halfway Through',
        description: 'Mid-point check-in with your radiation oncologist',
        icon: Icons.compare_arrows_rounded,
      ),
      PhaseMilestone(
        title: 'Final Radiation Session',
        description: 'Ring the bell — you\'ve completed radiation!',
        icon: Icons.notifications_active_rounded,
      ),
    ],
    videos: [
      GuidanceVideo(
        title: 'What is Radiation Therapy?',
        channel: 'American Cancer Society',
        duration: '7:20',
        thumbnail: 'https://img.youtube.com/vi/placeholder7/mqdefault.jpg',
        url: 'https://www.youtube.com/results?search_query=what+is+radiation+therapy+cancer+explained',
        description: 'How radiation works and what to expect during treatment',
      ),
      GuidanceVideo(
        title: 'Skin Care During Radiation',
        channel: 'Mayo Clinic',
        duration: '5:40',
        thumbnail: 'https://img.youtube.com/vi/placeholder8/mqdefault.jpg',
        url: 'https://www.youtube.com/results?search_query=skin+care+radiation+therapy+tips',
        description: 'Protecting and soothing irradiated skin',
      ),
    ],
    tips: [
      'Keep the treated area clean and moisturized with recommended products',
      'Avoid sun exposure on the treatment area during and after radiation',
      'Wear loose, soft clothing over the treatment site',
      'Continue gentle exercise if you feel up to it — it fights fatigue',
      'The fatigue often peaks 1–2 weeks after treatment ends, then improves',
    ],
  ),
  PhaseInfo(
    id: 'surgery',
    name: 'Surgery',
    icon: '🏥',
    color: AppColors.recoveryCol,
    lightColor: AppColors.accentLight,
    duration: '1 day + 2–6 weeks recovery',
    overview:
        'Surgery removes the tumor and may remove nearby lymph nodes or tissue. It can be the primary treatment or part of a combination approach. Your surgical team will guide you through pre-op preparations and recovery.',
    whatToExpect: [
      'Pre-operative tests and assessments',
      'Fasting the night before surgery',
      'General or regional anesthesia during the procedure',
      'Hospital stay ranging from same-day to several days',
      'Drains or dressings at the incision site',
      'Physical therapy or rehabilitation after certain surgeries',
      'Pathology report from removed tissue (3–10 days post-surgery)',
    ],
    milestones: [
      PhaseMilestone(
        title: 'Pre-Op Assessment Complete',
        description: 'Cleared for surgery with all tests done',
        icon: Icons.playlist_add_check_rounded,
      ),
      PhaseMilestone(
        title: 'Surgery Day',
        description: 'The procedure is complete — a huge step forward',
        icon: Icons.local_hospital_rounded,
      ),
      PhaseMilestone(
        title: 'Pathology Results Received',
        description: 'Lab analysis of removed tissue confirms next steps',
        icon: Icons.science_rounded,
      ),
      PhaseMilestone(
        title: 'Surgical Recovery Complete',
        description: 'Wounds healed and cleared for next treatment phase',
        icon: Icons.healing_rounded,
      ),
    ],
    videos: [
      GuidanceVideo(
        title: 'Preparing for Cancer Surgery',
        channel: 'MD Anderson Cancer Center',
        duration: '10:05',
        thumbnail: 'https://img.youtube.com/vi/placeholder9/mqdefault.jpg',
        url: 'https://www.youtube.com/results?search_query=preparing+for+cancer+surgery+patient+guide',
        description: 'What to do before, during, and after your surgery',
      ),
      GuidanceVideo(
        title: 'Post-Surgery Recovery Tips',
        channel: 'Memorial Sloan Kettering',
        duration: '6:55',
        thumbnail: 'https://img.youtube.com/vi/placeholder10/mqdefault.jpg',
        url: 'https://www.youtube.com/results?search_query=post+surgery+cancer+recovery+tips',
        description: 'Managing pain, wounds, and regaining strength',
      ),
    ],
    tips: [
      'Arrange for someone to help at home for at least 2 weeks post-surgery',
      'Follow all wound care instructions precisely',
      'Report any signs of infection (redness, warmth, unusual discharge) immediately',
      'Gentle walking helps prevent blood clots after surgery',
      'Attend all follow-up appointments even if you feel well',
    ],
  ),
  PhaseInfo(
    id: 'recovery',
    name: 'Recovery',
    icon: '🌱',
    color: AppColors.recoveryCol,
    lightColor: AppColors.accentLight,
    duration: '3–12 months',
    overview:
        'Recovery is a time of physical and emotional healing. Your body is recovering from treatment, and your energy will gradually return. Regular follow-up appointments monitor for recurrence and address any lasting side effects.',
    whatToExpect: [
      'Gradual improvement in energy levels over months',
      'Follow-up appointments every 3–6 months initially',
      'Management of long-term or late side effects',
      'Potential hormone therapy or targeted therapy continuing',
      'Emotional processing — anxiety and grief are normal',
      'Rebuilding physical strength and fitness',
      'Return-to-work planning when you feel ready',
    ],
    milestones: [
      PhaseMilestone(
        title: 'Active Treatment Completed',
        description: 'Primary treatment (chemo/radiation/surgery) is done',
        icon: Icons.emoji_events_rounded,
      ),
      PhaseMilestone(
        title: 'First Follow-Up Scan Clear',
        description: 'Scans show no signs of recurrence',
        icon: Icons.verified_rounded,
      ),
      PhaseMilestone(
        title: 'Energy Levels Restored',
        description: 'Back to most daily activities',
        icon: Icons.bolt_rounded,
      ),
      PhaseMilestone(
        title: 'Survivorship Plan Created',
        description: 'Long-term health plan established with care team',
        icon: Icons.star_rounded,
      ),
    ],
    videos: [
      GuidanceVideo(
        title: 'Life After Cancer Treatment',
        channel: 'Cancer Research UK',
        duration: '11:20',
        thumbnail: 'https://img.youtube.com/vi/placeholder11/mqdefault.jpg',
        url: 'https://www.youtube.com/results?search_query=life+after+cancer+treatment+recovery',
        description: 'What to expect as you enter the recovery phase',
      ),
      GuidanceVideo(
        title: 'Managing Post-Treatment Fatigue',
        channel: 'Macmillan Cancer Support',
        duration: '8:45',
        thumbnail: 'https://img.youtube.com/vi/placeholder12/mqdefault.jpg',
        url: 'https://www.youtube.com/results?search_query=cancer+related+fatigue+management+recovery',
        description: 'Strategies for regaining energy after treatment',
      ),
    ],
    tips: [
      'Be patient with yourself — recovery takes longer than expected',
      'Exercise, even gently, has strong evidence for reducing recurrence risk',
      'Talk openly to your doctor about lingering side effects',
      'Consider joining a cancer survivor support group',
      'Attend every follow-up appointment — early detection matters',
    ],
  ),
  PhaseInfo(
    id: 'survivorship',
    name: 'Survivorship',
    icon: '🌟',
    color: AppColors.warning,
    lightColor: AppColors.warningLight,
    duration: 'Lifelong',
    overview:
        'Survivorship begins when active treatment ends and continues for the rest of your life. It focuses on long-term wellness, monitoring for recurrence, managing late effects, and living as fully as possible after cancer.',
    whatToExpect: [
      'Annual check-ups and imaging scans for recurrence monitoring',
      'Possible ongoing hormone therapy (e.g., tamoxifen) for years',
      'Risk of late effects from treatment (heart, bone, nerve issues)',
      'Emotional journey — "scanxiety" before follow-up appointments',
      'Possible changes in relationships, career, and life priorities',
      'Greater focus on healthy lifestyle: diet, exercise, no smoking',
    ],
    milestones: [
      PhaseMilestone(
        title: '1 Year NED (No Evidence of Disease)',
        description: 'One full year since end of active treatment',
        icon: Icons.looks_one_rounded,
      ),
      PhaseMilestone(
        title: '5 Year Survival Milestone',
        description: 'A major statistical and personal milestone',
        icon: Icons.stars_rounded,
      ),
      PhaseMilestone(
        title: 'Return to Full Life',
        description: 'Back to work, hobbies, relationships, and dreams',
        icon: Icons.favorite_rounded,
      ),
    ],
    videos: [
      GuidanceVideo(
        title: 'Cancer Survivorship: What Comes Next',
        channel: 'American Cancer Society',
        duration: '9:30',
        thumbnail: 'https://img.youtube.com/vi/placeholder13/mqdefault.jpg',
        url: 'https://www.youtube.com/results?search_query=cancer+survivorship+what+comes+next',
        description: 'Long-term health and wellness after cancer',
      ),
      GuidanceVideo(
        title: 'The Emotional Side of Survivorship',
        channel: 'Macmillan Cancer Support',
        duration: '7:15',
        thumbnail: 'https://img.youtube.com/vi/placeholder14/mqdefault.jpg',
        url: 'https://www.youtube.com/results?search_query=emotional+cancer+survivorship+anxiety+fear',
        description: 'Navigating fear, anxiety, and identity after cancer',
      ),
    ],
    tips: [
      'Build a "survivorship care plan" with your oncologist',
      'Share your medical history with all future healthcare providers',
      'Regular exercise may reduce the risk of cancer coming back',
      'Watch for late effects from treatment and report new symptoms promptly',
      'Your mental health matters as much as your physical health',
    ],
  ),
];

// Helper to find the current phase
PhaseInfo _getPhaseInfo(String treatmentPhase) {
  if (treatmentPhase.toLowerCase().contains('chemo')) {
    return _phases.firstWhere((p) => p.id == 'chemo');
  } else if (treatmentPhase.toLowerCase().contains('radiation')) {
    return _phases.firstWhere((p) => p.id == 'radiation');
  } else if (treatmentPhase.toLowerCase().contains('surgery')) {
    return _phases.firstWhere((p) => p.id == 'surgery');
  } else if (treatmentPhase.toLowerCase().contains('recovery')) {
    return _phases.firstWhere((p) => p.id == 'recovery');
  } else if (treatmentPhase.toLowerCase().contains('survivor')) {
    return _phases.firstWhere((p) => p.id == 'survivorship');
  } else if (treatmentPhase.toLowerCase().contains('pre')) {
    return _phases.firstWhere((p) => p.id == 'preTreatment');
  } else {
    return _phases.firstWhere((p) => p.id == 'diagnosis');
  }
}

// ─── Main Journey Screen ───────────────────────────────────────────────────────
class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final journey = provider.journey;
        if (journey == null) {
          return const EmptyStateWidget(
            icon: Icons.timeline_rounded,
            title: 'No journey set up',
            subtitle: 'Set up your journey to track progress',
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 160,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: AppColors.heroTop,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.heroGradient,
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your Journey',
                                  style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(
                                '${journey.cancerType} · ${journey.stage}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.8)),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on_rounded,
                                        color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Current: ${journey.treatmentPhase}',
                                      style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Container(
                      color: AppColors.heroTop,
                      child: TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withValues(alpha: 0.55),
                        indicatorColor: Colors.white,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorWeight: 3,
                        labelStyle: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600),
                        tabs: const [
                          Tab(text: 'Overview'),
                          Tab(text: 'Phases'),
                          Tab(text: 'Analytics'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  _OverviewTab(provider: provider),
                  _PhasesTab(provider: provider),
                  _AnalyticsTab(provider: provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final AppProvider provider;
  const _OverviewTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final journey = provider.journey!;
    final currentPhaseInfo = _getPhaseInfo(journey.treatmentPhase);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Phase Hero Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  currentPhaseInfo.color,
                  currentPhaseInfo.color.withValues(alpha: 0.75),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: currentPhaseInfo.color.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(currentPhaseInfo.icon,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('You are currently in',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white70)),
                          Text(
                            currentPhaseInfo.name,
                            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentPhaseInfo.duration,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  currentPhaseInfo.overview,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats Row
          Row(
            children: [
              _StatCard(
                label: 'Day Streak',
                value: '${provider.checkInStreak}',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.warning,
              ),
              const SizedBox(width: 10),
              _StatCard(
                label: 'Check-ins',
                value: '${provider.checkIns.length}',
                icon: Icons.check_circle_rounded,
                color: AppColors.accent,
              ),
              const SizedBox(width: 10),
              _StatCard(
                label: 'Adherence',
                value: '${(provider.checkInRate * 100).round()}%',
                icon: Icons.medication_rounded,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // What to Expect
          _SectionTitle(title: 'What to Expect', icon: Icons.info_outline_rounded),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: currentPhaseInfo.whatToExpect.asMap().entries.map((e) {
                final isLast = e.key == currentPhaseInfo.whatToExpect.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: currentPhaseInfo.lightColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: currentPhaseInfo.color),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.value,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                          height: 1,
                          indent: 46,
                          color: AppColors.divider),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Weekly Task List
          _SectionTitle(title: 'This Week\'s Tasks', icon: Icons.checklist_rounded),
          const SizedBox(height: 12),
          _PhaseWeeklyTasks(phase: currentPhaseInfo),
          const SizedBox(height: 20),

          // Tips for this phase
          _SectionTitle(title: 'Tips for This Phase', icon: Icons.lightbulb_outline_rounded),
          const SizedBox(height: 12),
          ...currentPhaseInfo.tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: currentPhaseInfo.lightColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: currentPhaseInfo.color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tips_and_updates_rounded,
                          color: currentPhaseInfo.color, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(tip,
                            style: TextStyle(
                                fontSize: 13,
                                color: currentPhaseInfo.color
                                    .withValues(alpha: 0.85),
                                height: 1.45)),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 20),

          // Upcoming Appointments
          const _SectionTitle(
              title: 'Upcoming Appointments',
              icon: Icons.calendar_today_rounded),
          const SizedBox(height: 12),
          if (provider.appointments
              .where((a) =>
                  !a.isCompleted && a.dateTime.isAfter(DateTime.now()))
              .isEmpty)
            const EmptyStateWidget(
              icon: Icons.calendar_month_rounded,
              title: 'No upcoming appointments',
              subtitle: 'Add appointments in the Care Hub',
            )
          else
            ...provider.appointments
                .where(
                    (a) => !a.isCompleted && a.dateTime.isAfter(DateTime.now()))
                .take(3)
                .map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.card,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(DateFormat('d').format(a.dateTime),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary)),
                                  Text(DateFormat('MMM').format(a.dateTime),
                                      style: const TextStyle(
                                          fontSize: 9,
                                          color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.title,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary)),
                                  Text(a.doctorName,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    )),
        ],
      ),
    );
  }
}

// ─── Phases Tab ───────────────────────────────────────────────────────────────
class _PhasesTab extends StatefulWidget {
  final AppProvider provider;
  const _PhasesTab({required this.provider});

  @override
  State<_PhasesTab> createState() => _PhasesTabState();
}

class _PhasesTabState extends State<_PhasesTab> {
  String? _expandedPhaseId;

  @override
  void initState() {
    super.initState();
    // Auto-expand the current phase
    final journey = widget.provider.journey;
    if (journey != null) {
      _expandedPhaseId = _getPhaseInfo(journey.treatmentPhase).id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final journey = widget.provider.journey!;
    final currentPhaseInfo = _getPhaseInfo(journey.treatmentPhase);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tap any phase to explore key milestones, guidance videos, and what to expect.',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // All phases list
          ..._phases.asMap().entries.map((entry) {
            final idx = entry.key;
            final phase = entry.value;
            final isCurrent = phase.id == currentPhaseInfo.id;
            final isExpanded = _expandedPhaseId == phase.id;
            // Simple completed logic: phases before current are done
            final currentIdx =
                _phases.indexWhere((p) => p.id == currentPhaseInfo.id);
            final isCompleted = idx < currentIdx;

            return _PhaseAccordion(
              phase: phase,
              isCurrent: isCurrent,
              isCompleted: isCompleted,
              isExpanded: isExpanded,
              onTap: () {
                setState(() {
                  _expandedPhaseId = isExpanded ? null : phase.id;
                });
              },
            );
          }),
        ],
      ),
    );
  }
}

class _PhaseAccordion extends StatelessWidget {
  final PhaseInfo phase;
  final bool isCurrent;
  final bool isCompleted;
  final bool isExpanded;
  final VoidCallback onTap;

  const _PhaseAccordion({
    required this.phase,
    required this.isCurrent,
    required this.isCompleted,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isCompleted
        ? AppColors.accent
        : isCurrent
            ? phase.color
            : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCurrent ? phase.color.withValues(alpha: 0.5) : AppColors.border,
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: isCurrent ? AppShadows.card : [],
        ),
        child: Column(
          children: [
            // Header row
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Phase icon bubble
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.accentLight
                            : isCurrent
                                ? phase.lightColor
                                : AppColors.divider.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_rounded,
                                color: AppColors.accent, size: 22)
                            : Text(phase.icon,
                                style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  phase.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: isCurrent
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isCompleted || isCurrent
                                        ? AppColors.textPrimary
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: phase.color,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text('YOU ARE HERE',
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.5)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(phase.duration,
                                  style: TextStyle(
                                      fontSize: 12, color: statusColor)),
                              const SizedBox(width: 10),
                              Icon(Icons.ondemand_video_rounded,
                                  size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text('${phase.videos.length} videos',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            if (isExpanded) ...[
              Divider(
                  height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
              _PhaseDetailContent(phase: phase),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhaseDetailContent extends StatelessWidget {
  final PhaseInfo phase;
  const _PhaseDetailContent({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview
          Text(
            phase.overview,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 18),

          // Key Milestones
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: phase.lightColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flag_rounded, color: phase.color, size: 14),
                    const SizedBox(width: 5),
                    Text('Key Milestones',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: phase.color)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...phase.milestones.asMap().entries.map((e) {
            final isLast = e.key == phase.milestones.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: phase.lightColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: phase.color.withValues(alpha: 0.4)),
                      ),
                      child: Icon(e.value.icon, color: phase.color, size: 16),
                    ),
                    if (!isLast)
                      Container(
                        width: 1.5,
                        height: 36,
                        color: phase.color.withValues(alpha: 0.2),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.value.title,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(e.value.description,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 6),

          // Guidance Videos
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: phase.lightColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.play_circle_rounded, color: phase.color, size: 14),
                    const SizedBox(width: 5),
                    Text('Guidance Videos',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: phase.color)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...phase.videos.map((video) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => _openVideo(context, video),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        // Thumbnail placeholder
                        Container(
                          width: 72,
                          height: 48,
                          decoration: BoxDecoration(
                            color: phase.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(Icons.play_circle_filled_rounded,
                                color: phase.color, size: 28),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(video.channel,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: phase.lightColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(video.duration,
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: phase.color)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.open_in_new_rounded,
                            color: AppColors.textMuted, size: 16),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _openVideo(BuildContext context, GuidanceVideo video) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: phase.lightColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.play_circle_filled_rounded,
                      color: phase.color, size: 32),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(video.title,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(video.channel,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(video.description,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(video.duration,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [phase.color, phase.color.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: phase.color.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening: ${video.title}'),
                        backgroundColor: phase.color,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        action: SnackBarAction(
                          label: 'Watch',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text('Watch on YouTube',
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Analytics Tab ────────────────────────────────────────────────────────────
class _AnalyticsTab extends StatelessWidget {
  final AppProvider provider;
  const _AnalyticsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final checkIns = provider.recentCheckIns;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
              title: 'Symptom Trends (14 Days)',
              icon: Icons.bar_chart_rounded),
          const SizedBox(height: 16),
          if (checkIns.isEmpty)
            const EmptyStateWidget(
              icon: Icons.bar_chart_rounded,
              title: 'No data yet',
              subtitle: 'Complete daily check-ins to see your trends',
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                children: [
                  _TrendRow(
                    label: 'Mood',
                    value: checkIns
                            .map((c) => c.moodScore)
                            .reduce((a, b) => a + b) /
                        checkIns.length,
                    maxValue: 5,
                    color: AppColors.primary,
                    icon: Icons.sentiment_satisfied_alt_rounded,
                  ),
                  const SizedBox(height: 16),
                  _TrendRow(
                    label: 'Pain',
                    value: checkIns
                            .map((c) => c.painScore)
                            .reduce((a, b) => a + b) /
                        checkIns.length,
                    maxValue: 5,
                    color: AppColors.danger,
                    icon: Icons.healing_rounded,
                  ),
                  const SizedBox(height: 16),
                  _TrendRow(
                    label: 'Fatigue',
                    value: checkIns
                            .map((c) => c.fatigueScore)
                            .reduce((a, b) => a + b) /
                        checkIns.length,
                    maxValue: 5,
                    color: const Color(0xFFFF6B9D),
                    icon: Icons.battery_charging_full_rounded,
                  ),
                  const SizedBox(height: 16),
                  _TrendRow(
                    label: 'Sleep',
                    value: checkIns
                            .map((c) => c.sleepScore)
                            .reduce((a, b) => a + b) /
                        checkIns.length,
                    maxValue: 5,
                    color: AppColors.info,
                    icon: Icons.bedtime_rounded,
                  ),
                  const SizedBox(height: 16),
                  _TrendRow(
                    label: 'Appetite',
                    value: checkIns
                            .map((c) => c.appetiteScore)
                            .reduce((a, b) => a + b) /
                        checkIns.length,
                    maxValue: 5,
                    color: AppColors.accent,
                    icon: Icons.restaurant_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SectionTitle(
                title: 'This Week', icon: Icons.calendar_view_week_rounded),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _WeekStat(
                          label: 'Check-ins',
                          value:
                              '${checkIns.where((c) => c.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))).length}/7',
                          color: AppColors.primary,
                          icon: Icons.check_circle_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _WeekStat(
                          label: 'Meds Taken',
                          value:
                              '${checkIns.where((c) => c.medicationsTaken).length}/${checkIns.length}',
                          color: AppColors.accent,
                          icon: Icons.medication_rounded,
                        ),
                      ),
                    ],
                  ),
                  if (checkIns.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Mild fatigue reported consistently. Consider discussing with your care team.',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Phase Weekly Task List ───────────────────────────────────────────────────
class _PhaseWeeklyTasks extends StatefulWidget {
  final PhaseInfo phase;
  const _PhaseWeeklyTasks({required this.phase});

  @override
  State<_PhaseWeeklyTasks> createState() => _PhaseWeeklyTasksState();
}

class _PhaseWeeklyTasksState extends State<_PhaseWeeklyTasks> {
  late Set<int> _checked;

  @override
  void initState() {
    super.initState();
    _checked = {};
  }

  List<String> _getTasks(String phaseId) {
    switch (phaseId) {
      case 'diagnosis':
        return [
          'Attend oncologist consultation',
          'Collect and file all pathology reports',
          'Write down questions for care team',
          'Research your cancer type (trusted sources only)',
          'Identify a support person to attend appointments',
          'Look into patient navigation services',
        ];
      case 'preTreatment':
        return [
          'Confirm port/PICC line procedure date',
          'Complete dental clearance appointment',
          'Stock home with easy-to-prepare meals',
          'Arrange transportation for treatment days',
          'Meet with social worker about support options',
          'Set up online grocery/delivery subscription',
        ];
      case 'chemo':
        return [
          'Take anti-nausea medication as prescribed',
          'Drink at least 8 glasses of water',
          'Log today\'s symptoms in daily check-in',
          'Take a gentle 10-min walk if energy allows',
          'Avoid raw meat and unwashed produce',
          'Check in with your support person',
        ];
      case 'radiation':
        return [
          'Attend all scheduled radiation sessions',
          'Moisturize treatment area (approved products only)',
          'Wear loose, soft clothing over treated area',
          'Avoid sun exposure on treatment site',
          'Rest after sessions as needed',
          'Note any new skin changes to report',
        ];
      case 'surgery':
        return [
          'Complete all pre-op tests and assessments',
          'Review fasting and pre-op instructions',
          'Arrange home care for post-surgery period',
          'Prepare medications and wound care supplies',
          'Plan gentle walks to aid recovery',
          'Attend follow-up wound check appointment',
        ];
      case 'recovery':
        return [
          'Attend scheduled follow-up appointment',
          'Track energy levels daily',
          'Do at least 20 minutes of gentle exercise',
          'Connect with a survivor support group',
          'Report any new or unusual symptoms promptly',
          'Review long-term medication plan with doctor',
        ];
      case 'survivorship':
        return [
          'Schedule annual oncology check-up',
          'Review survivorship care plan with team',
          'Maintain healthy diet and exercise routine',
          'Practice stress management (meditation, yoga)',
          'Check in with mental health professional',
          'Share medical history with new providers',
        ];
      default:
        return [
          'Attend all scheduled appointments',
          'Complete daily check-in',
          'Take all medications as prescribed',
          'Stay hydrated — 8 glasses per day',
          'Rest when your body needs it',
          'Ask your care team about any concerns',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _getTasks(widget.phase.id);
    final completedCount = _checked.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          // Progress header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: tasks.isEmpty ? 0 : completedCount / tasks.length,
                      backgroundColor: widget.phase.lightColor,
                      color: widget.phase.color,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$completedCount/${tasks.length}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: widget.phase.color),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...tasks.asMap().entries.map((e) {
            final i = e.key;
            final task = e.value;
            final isDone = _checked.contains(i);
            return Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    if (isDone) {
                      _checked.remove(i);
                    } else {
                      _checked.add(i);
                    }
                  }),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isDone ? widget.phase.color : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDone ? widget.phase.color : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: isDone
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            task,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < tasks.length - 1)
                  const Divider(height: 1, indent: 50, color: AppColors.divider),
              ],
            );
          }),
          if (completedCount == tasks.length && tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.celebration_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'All tasks complete this week! 🎉',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 7),
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;
  final IconData icon;
  const _TrendRow(
      {required this.label,
      required this.value,
      required this.maxValue,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Text('${value.toStringAsFixed(1)}/5',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value / maxValue,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeekStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _WeekStat(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
