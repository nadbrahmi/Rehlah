// ─────────────────────────────────────────────────────────────────────────────
// Rehlah · Breast Cancer Protocol Database
// 3 most common protocols: AC-T, TC, CMF
// Each protocol defines per-day symptom priority + nadir windows + warnings
// ─────────────────────────────────────────────────────────────────────────────

enum BreastProtocol { act, tc, cmf }

extension ProtocolLabel on BreastProtocol {
  String get name {
    switch (this) {
      case BreastProtocol.act: return 'AC-T';
      case BreastProtocol.tc:  return 'TC';
      case BreastProtocol.cmf: return 'CMF';
    }
  }
  String get fullName {
    switch (this) {
      case BreastProtocol.act:
        return 'Adriamycin + Cyclophosphamide → Taxol';
      case BreastProtocol.tc:
        return 'Docetaxel + Cyclophosphamide';
      case BreastProtocol.cmf:
        return 'Cyclophosphamide + Methotrexate + Fluorouracil';
    }
  }
  String get cycleLength {
    switch (this) {
      case BreastProtocol.act: return '21 days per cycle (AC), then weekly Taxol';
      case BreastProtocol.tc:  return '21 days per cycle';
      case BreastProtocol.cmf: return '28 days per cycle';
    }
  }
}

// ── Symptom definition ────────────────────────────────────────────────────────
class ProtocolSymptom {
  final String key;
  final String label;
  final String arabicLabel;
  final String emoji;
  final bool isUrgent;
  final double urgentThreshold;
  final String? urgentMessage;
  final String? tip;
  final bool isInverted;
  final String? interferenceQuestion;

  const ProtocolSymptom({
    required this.key,
    required this.label,
    required this.arabicLabel,
    required this.emoji,
    this.isUrgent = false,
    this.urgentThreshold = 4,
    this.urgentMessage,
    this.tip,
    this.isInverted = false,
    this.interferenceQuestion,
  });
}

// ── Master symptom library ────────────────────────────────────────────────────
class SymptomLibrary {
  static const nausea = ProtocolSymptom(
    key: 'nausea', label: 'Nausea', arabicLabel: 'غثيان', emoji: '🌊',
    tip: 'Small frequent meals every 2–3 hours. Cold or room-temperature foods are easier to tolerate.',
    interferenceQuestion: 'Does nausea affect eating or drinking?',
  );
  static const vomiting = ProtocolSymptom(
    key: 'vomiting', label: 'Vomiting', arabicLabel: 'قيء', emoji: '🤢',
    isUrgent: true, urgentThreshold: 5,
    urgentMessage: 'More than 2–3 episodes — contact your care team. You may need anti-nausea medication adjustment.',
    tip: 'Take your anti-nausea medication as prescribed. Small sips of clear fluids help prevent dehydration.',
    interferenceQuestion: 'How many episodes today?',
  );
  static const fatigue = ProtocolSymptom(
    key: 'fatigue', label: 'Fatigue', arabicLabel: 'إرهاق', emoji: '🌙',
    tip: 'Rest when your body asks. Short 20-minute rests are better than long naps.',
    interferenceQuestion: 'Does fatigue stop normal activities?',
  );
  static const fever = ProtocolSymptom(
    key: 'fever', label: 'Fever / Temperature', arabicLabel: 'حمى / حرارة', emoji: '🌡️',
    isUrgent: true, urgentThreshold: 3,
    urgentMessage: 'Fever above 38°C (100.4°F) during chemotherapy — call your care team immediately, day or night. Do not wait.',
  );
  static const pain = ProtocolSymptom(
    key: 'pain', label: 'Pain', arabicLabel: 'ألم', emoji: '⚡',
    tip: 'Note where the pain is. Your care team needs the location and type (sharp, dull, constant).',
    interferenceQuestion: 'Does pain stop normal activities?',
  );
  static const mouthSores = ProtocolSymptom(
    key: 'mouth_sores', label: 'Mouth sores', arabicLabel: 'تقرحات الفم', emoji: '👄',
    tip: 'Rinse with salt water 4–6 times daily. Avoid spicy, acidic, or rough-textured foods.',
    isUrgent: true, urgentThreshold: 6,
    urgentMessage: 'Severe mouth sores can make it hard to eat or drink. Contact your team if you cannot swallow.',
    interferenceQuestion: 'Do mouth sores affect eating or speaking?',
  );
  static const appetite = ProtocolSymptom(
    key: 'appetite', label: 'Poor appetite', arabicLabel: 'فقدان الشهية', emoji: '🍽️',
    tip: 'Eat whatever you can tolerate. Calories matter more than nutrition right now.',
    interferenceQuestion: 'Is poor appetite affecting your nutrition?',
  );
  static const constipation = ProtocolSymptom(
    key: 'constipation', label: 'Constipation', arabicLabel: 'إمساك', emoji: '🌿',
    tip: 'Stay hydrated. Gentle movement helps. Tell your team if no bowel movement for 3+ days.',
    interferenceQuestion: 'Has this lasted more than 2 days?',
  );
  static const diarrhea = ProtocolSymptom(
    key: 'diarrhea', label: 'Diarrhoea', arabicLabel: 'إسهال', emoji: '💧',
    isUrgent: true, urgentThreshold: 6,
    urgentMessage: 'More than 4–6 loose stools per day — contact your team. Risk of dehydration.',
    interferenceQuestion: 'How many episodes today?',
  );
  static const hairLoss = ProtocolSymptom(
    key: 'hair_loss', label: 'Hair loss', arabicLabel: 'تساقط الشعر', emoji: '💇',
    tip: 'This is temporary. Gentle shampoo and a soft pillow cover can reduce scalp discomfort.',
    interferenceQuestion: 'Is hair loss affecting your confidence or comfort?',
  );
  static const neuropathy = ProtocolSymptom(
    key: 'neuropathy', label: 'Tingling / numbness', arabicLabel: 'تنميل', emoji: '🤲',
    tip: 'Hands and feet tingling is common with Taxol. Tell your team — dose adjustment may help.',
    isUrgent: true, urgentThreshold: 7,
    urgentMessage: 'Severe tingling or numbness — report to your care team at next visit or call if it affects walking.',
    interferenceQuestion: 'Does tingling affect your hands or feet daily tasks?',
  );
  static const jointPain = ProtocolSymptom(
    key: 'joint_pain', label: 'Joint / muscle pain', arabicLabel: 'آلام المفاصل', emoji: '🦴',
    tip: 'Peaks 2–4 days after Taxol. Gentle warm compresses and light movement can help.',
    interferenceQuestion: 'Does joint pain stop you moving normally?',
  );
  static const swelling = ProtocolSymptom(
    key: 'swelling', label: 'Swelling / fluid', arabicLabel: 'تورم', emoji: '💧',
    tip: 'Elevate legs when resting. Avoid tight shoes. Report significant swelling.',
    interferenceQuestion: 'Does swelling affect walking or wearing shoes?',
  );
  static const skinNails = ProtocolSymptom(
    key: 'skin_nails', label: 'Skin / nail changes', arabicLabel: 'تغيرات الجلد والأظافر', emoji: '💅',
    tip: 'Keep nails clean and short. Moisturise hands daily. Avoid cutting cuticles.',
    interferenceQuestion: 'Are skin or nail changes causing discomfort?',
  );
  static const breathlessness = ProtocolSymptom(
    key: 'breathlessness', label: 'Breathlessness', arabicLabel: 'ضيق التنفس', emoji: '🫁',
    isUrgent: true, urgentThreshold: 4,
    urgentMessage: 'Breathlessness at rest or with light activity — contact your care team today.',
  );
  static const mood = ProtocolSymptom(
    key: 'mood', label: 'Mood / anxiety', arabicLabel: 'المزاج / القلق', emoji: '💜',
    tip: 'What you\'re feeling is a normal response to treatment. Talking about it helps.',
    isInverted: true,
    interferenceQuestion: 'Is your mood affecting daily life or sleep?',
  );
  static const sleep = ProtocolSymptom(
    key: 'sleep', label: 'Sleep quality', arabicLabel: 'جودة النوم', emoji: '😴',
    tip: 'A consistent bedtime routine helps. Avoid screens 30 minutes before sleep.',
    interferenceQuestion: 'Is poor sleep affecting your energy during the day?',
  );
  static const fluidRetention = ProtocolSymptom(
    key: 'fluid_retention', label: 'Fluid retention', arabicLabel: 'احتباس السوائل', emoji: '⚖️',
    tip: 'Weigh yourself daily at the same time. Report a gain of 2kg+ in 48 hours.',
    interferenceQuestion: 'Have you gained more than 1kg since yesterday?',
  );
  static const infection = ProtocolSymptom(
    key: 'infection', label: 'Signs of infection', arabicLabel: 'علامات العدوى', emoji: '🔴',
    isUrgent: true, urgentThreshold: 2,
    urgentMessage: 'Redness, swelling, warmth around any wound or IV site — contact your team today.',
  );
  static const heartPalpitations = ProtocolSymptom(
    key: 'palpitations', label: 'Heart palpitations', arabicLabel: 'خفقان القلب', emoji: '❤️',
    isUrgent: true, urgentThreshold: 3,
    urgentMessage: 'Irregular heartbeat or chest discomfort — contact your care team immediately.',
  );
}

// ── Phase definition ──────────────────────────────────────────────────────────
class ChemoPhase {
  final String name;
  final String description;
  final int cycleDay;
  final int cycleDayEnd;
  final bool isNadir;
  final bool isNadirApproaching;
  final List<ProtocolSymptom> primarySymptoms;
  final List<ProtocolSymptom> watchSymptoms;
  final String phaseNote;
  final String caregiverNote; // plain language for caregiver view

  const ChemoPhase({
    required this.name,
    required this.description,
    required this.cycleDay,
    required this.cycleDayEnd,
    this.isNadir = false,
    this.isNadirApproaching = false,
    required this.primarySymptoms,
    required this.watchSymptoms,
    required this.phaseNote,
    this.caregiverNote = '',
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PROTOCOL 1: AC-T
// AC phase: 4 cycles × 21 days
// T (Taxol) phase: 4 cycles × 21 days (or weekly × 12)
// ─────────────────────────────────────────────────────────────────────────────
class ACTProtocol {
  static const String name = 'AC-T';

  // AC sub-phase phases (days 1–21)
  static List<ChemoPhase> acPhases = [
    ChemoPhase(
      name: 'Infusion day',
      description: 'AC · Infusion day',
      cycleDay: 1, cycleDayEnd: 2,
      phaseNote: 'AC infusion day. Nausea often starts within a few hours — take your anti-nausea medication as prescribed.',
      primarySymptoms: [
        SymptomLibrary.nausea,
        SymptomLibrary.fatigue,
        SymptomLibrary.vomiting,
        SymptomLibrary.appetite,
        SymptomLibrary.mood,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.heartPalpitations,
      ],
    ),
    ChemoPhase(
      name: 'Peak nausea window',
      description: 'AC · Days 2–7',
      cycleDay: 3, cycleDayEnd: 7,
      phaseNote: 'Nausea and fatigue typically peak this week. Small frequent meals, rest, and staying hydrated are your main tools.',
      primarySymptoms: [
        SymptomLibrary.nausea,
        SymptomLibrary.fatigue,
        SymptomLibrary.vomiting,
        SymptomLibrary.appetite,
        SymptomLibrary.constipation,
        SymptomLibrary.mouthSores,
        SymptomLibrary.mood,
        SymptomLibrary.sleep,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.breathlessness,
      ],
    ),
    ChemoPhase(
      name: 'Nadir window',
      description: 'AC · Nadir days 8–14',
      cycleDay: 8, cycleDayEnd: 14,
      isNadir: true,
      phaseNote: 'Your white blood cell count is at its lowest. Avoid crowds, wash hands frequently, and monitor your temperature twice daily.',
      primarySymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.infection,
        SymptomLibrary.breathlessness,
        SymptomLibrary.fatigue,
        SymptomLibrary.mouthSores,
        SymptomLibrary.appetite,
        SymptomLibrary.mood,
        SymptomLibrary.sleep,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.infection,
        SymptomLibrary.breathlessness,
      ],
    ),
    ChemoPhase(
      name: 'Recovery week',
      description: 'AC · Recovery days 15–21',
      cycleDay: 15, cycleDayEnd: 21,
      phaseNote: 'Your counts are recovering. Energy usually improves this week. Hair loss may begin or intensify.',
      primarySymptoms: [
        SymptomLibrary.fatigue,
        SymptomLibrary.hairLoss,
        SymptomLibrary.mood,
        SymptomLibrary.appetite,
        SymptomLibrary.mouthSores,
        SymptomLibrary.sleep,
        SymptomLibrary.nausea,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
      ],
    ),
  ];

  // Taxol sub-phase phases (days 1–21)
  static List<ChemoPhase> taxolPhases = [
    ChemoPhase(
      name: 'Taxol infusion',
      description: 'Taxol · Infusion day',
      cycleDay: 1, cycleDayEnd: 2,
      phaseNote: 'Taxol infusion day. Joint and muscle pain usually starts 2–4 days after. Watch for any allergic reaction during infusion.',
      primarySymptoms: [
        SymptomLibrary.fatigue,
        SymptomLibrary.nausea,
        SymptomLibrary.neuropathy,
        SymptomLibrary.mood,
        SymptomLibrary.appetite,
        SymptomLibrary.sleep,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.breathlessness,
      ],
    ),
    ChemoPhase(
      name: 'Joint pain peak',
      description: 'Taxol · Days 2–7',
      cycleDay: 3, cycleDayEnd: 7,
      phaseNote: 'Joint and muscle pain typically peaks days 2–4 after Taxol. Gentle movement and warm compresses can help.',
      primarySymptoms: [
        SymptomLibrary.jointPain,
        SymptomLibrary.fatigue,
        SymptomLibrary.neuropathy,
        SymptomLibrary.nausea,
        SymptomLibrary.mood,
        SymptomLibrary.sleep,
        SymptomLibrary.appetite,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.neuropathy,
      ],
    ),
    ChemoPhase(
      name: 'Nadir window',
      description: 'Taxol · Nadir days 8–14',
      cycleDay: 8, cycleDayEnd: 14,
      isNadir: true,
      phaseNote: 'Immune system at its lowest. Temperature monitoring is essential. Neuropathy symptoms may linger.',
      primarySymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.infection,
        SymptomLibrary.breathlessness,
        SymptomLibrary.fatigue,
        SymptomLibrary.neuropathy,
        SymptomLibrary.swelling,
        SymptomLibrary.skinNails,
        SymptomLibrary.mood,
        SymptomLibrary.sleep,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.infection,
        SymptomLibrary.neuropathy,
      ],
    ),
    ChemoPhase(
      name: 'Recovery week',
      description: 'Taxol · Recovery days 15–21',
      cycleDay: 15, cycleDayEnd: 21,
      phaseNote: 'Energy returns. Neuropathy may linger — track it carefully. Nail changes can appear.',
      primarySymptoms: [
        SymptomLibrary.fatigue,
        SymptomLibrary.neuropathy,
        SymptomLibrary.skinNails,
        SymptomLibrary.hairLoss,
        SymptomLibrary.mood,
        SymptomLibrary.sleep,
        SymptomLibrary.appetite,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.neuropathy,
      ],
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// PROTOCOL 2: TC (Docetaxel + Cyclophosphamide)
// 4–6 cycles × 21 days
// ─────────────────────────────────────────────────────────────────────────────
class TCProtocol {
  static const String name = 'TC';

  static List<ChemoPhase> phases = [
    ChemoPhase(
      name: 'Infusion day',
      description: 'TC · Infusion day',
      cycleDay: 1, cycleDayEnd: 2,
      phaseNote: 'TC infusion day. Fluid retention and joint pain often develop over the next few days.',
      primarySymptoms: [
        SymptomLibrary.fatigue,
        SymptomLibrary.nausea,
        SymptomLibrary.mood,
        SymptomLibrary.appetite,
        SymptomLibrary.sleep,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.breathlessness,
      ],
    ),
    ChemoPhase(
      name: 'Fluid & pain window',
      description: 'TC · Days 3–7',
      cycleDay: 3, cycleDayEnd: 7,
      phaseNote: 'Joint pain and fluid retention peak this week. Weigh yourself daily — report a 2kg+ gain.',
      primarySymptoms: [
        SymptomLibrary.jointPain,
        SymptomLibrary.fatigue,
        SymptomLibrary.fluidRetention,
        SymptomLibrary.nausea,
        SymptomLibrary.diarrhea,
        SymptomLibrary.mouthSores,
        SymptomLibrary.mood,
        SymptomLibrary.appetite,
        SymptomLibrary.sleep,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.diarrhea,
        SymptomLibrary.fluidRetention,
      ],
    ),
    ChemoPhase(
      name: 'Nadir window',
      description: 'TC · Nadir days 7–14',
      cycleDay: 7, cycleDayEnd: 14,
      isNadir: true,
      phaseNote: 'WBC at lowest point. Infection risk is highest now. Take temperature morning and evening.',
      primarySymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.infection,
        SymptomLibrary.breathlessness,
        SymptomLibrary.fatigue,
        SymptomLibrary.fluidRetention,
        SymptomLibrary.mouthSores,
        SymptomLibrary.neuropathy,
        SymptomLibrary.mood,
        SymptomLibrary.sleep,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.infection,
        SymptomLibrary.breathlessness,
      ],
    ),
    ChemoPhase(
      name: 'Recovery week',
      description: 'TC · Recovery days 15–21',
      cycleDay: 15, cycleDayEnd: 21,
      phaseNote: 'Counts recovering. Fluid retention usually starts to reduce. Energy improves.',
      primarySymptoms: [
        SymptomLibrary.fatigue,
        SymptomLibrary.fluidRetention,
        SymptomLibrary.hairLoss,
        SymptomLibrary.neuropathy,
        SymptomLibrary.skinNails,
        SymptomLibrary.mood,
        SymptomLibrary.sleep,
        SymptomLibrary.appetite,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.neuropathy,
      ],
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// PROTOCOL 3: CMF (Cyclophosphamide + Methotrexate + 5-Fluorouracil)
// 6 cycles × 28 days
// ─────────────────────────────────────────────────────────────────────────────
class CMFProtocol {
  static const String name = 'CMF';

  static List<ChemoPhase> phases = [
    ChemoPhase(
      name: 'Infusion days',
      description: 'CMF · Days 1 & 8 (infusion)',
      cycleDay: 1, cycleDayEnd: 3,
      phaseNote: 'CMF is given on days 1 and 8. Nausea is usually milder than AC. Mouth sores and fatigue are the main side effects.',
      primarySymptoms: [
        SymptomLibrary.nausea,
        SymptomLibrary.fatigue,
        SymptomLibrary.appetite,
        SymptomLibrary.mouthSores,
        SymptomLibrary.mood,
        SymptomLibrary.sleep,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.breathlessness,
      ],
    ),
    ChemoPhase(
      name: 'Post-infusion week',
      description: 'CMF · Days 4–7',
      cycleDay: 4, cycleDayEnd: 7,
      phaseNote: 'Fatigue and mouth sores are most noticeable this week. Good oral hygiene reduces mouth sore severity.',
      primarySymptoms: [
        SymptomLibrary.fatigue,
        SymptomLibrary.mouthSores,
        SymptomLibrary.nausea,
        SymptomLibrary.appetite,
        SymptomLibrary.constipation,
        SymptomLibrary.mood,
        SymptomLibrary.sleep,
        SymptomLibrary.hairLoss,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.mouthSores,
      ],
    ),
    ChemoPhase(
      name: 'Second infusion',
      description: 'CMF · Day 8 infusion',
      cycleDay: 8, cycleDayEnd: 10,
      phaseNote: 'Second CMF infusion of the cycle. Same patterns as day 1 — nausea and fatigue in the following days.',
      primarySymptoms: [
        SymptomLibrary.nausea,
        SymptomLibrary.fatigue,
        SymptomLibrary.mouthSores,
        SymptomLibrary.appetite,
        SymptomLibrary.mood,
        SymptomLibrary.sleep,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
      ],
    ),
    ChemoPhase(
      name: 'Nadir window',
      description: 'CMF · Nadir days 10–18',
      cycleDay: 10, cycleDayEnd: 18,
      isNadir: true,
      phaseNote: 'WBC at lowest point after day 8 infusion. Nadir is usually milder than AC but still requires temperature monitoring.',
      primarySymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.infection,
        SymptomLibrary.breathlessness,
        SymptomLibrary.fatigue,
        SymptomLibrary.mouthSores,
        SymptomLibrary.appetite,
        SymptomLibrary.mood,
        SymptomLibrary.sleep,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
        SymptomLibrary.infection,
      ],
    ),
    ChemoPhase(
      name: 'Recovery / rest week',
      description: 'CMF · Recovery days 19–28',
      cycleDay: 19, cycleDayEnd: 28,
      phaseNote: 'Long recovery window — 10 days before next cycle. Energy returns. Good time to rebuild appetite.',
      primarySymptoms: [
        SymptomLibrary.fatigue,
        SymptomLibrary.appetite,
        SymptomLibrary.hairLoss,
        SymptomLibrary.mouthSores,
        SymptomLibrary.mood,
        SymptomLibrary.sleep,
        SymptomLibrary.nausea,
      ],
      watchSymptoms: [
        SymptomLibrary.fever,
      ],
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Protocol resolver — given a protocol + cycle day, returns the right phase
// ─────────────────────────────────────────────────────────────────────────────
class ProtocolResolver {

  static ChemoPhase resolve(BreastProtocol protocol, int cycleDay,
      {bool isTaxolPhase = false}) {
    List<ChemoPhase> phases;
    switch (protocol) {
      case BreastProtocol.act:
        phases = isTaxolPhase ? ACTProtocol.taxolPhases : ACTProtocol.acPhases;
        break;
      case BreastProtocol.tc:
        phases = TCProtocol.phases;
        break;
      case BreastProtocol.cmf:
        phases = CMFProtocol.phases;
        break;
    }
    // Find matching phase by day range
    for (final phase in phases) {
      if (cycleDay >= phase.cycleDay && cycleDay <= phase.cycleDayEnd) {
        return phase;
      }
    }
    // Fallback to last phase
    return phases.last;
  }

  static bool isNadirDay(BreastProtocol protocol, int cycleDay,
      {bool isTaxolPhase = false}) {
    return resolve(protocol, cycleDay,
        isTaxolPhase: isTaxolPhase).isNadir;
  }

  static String protocolSummary(BreastProtocol protocol, int currentCycle,
      int totalCycles, int cycleDay, {bool isTaxolPhase = false}) {
    final phase = resolve(protocol, cycleDay, isTaxolPhase: isTaxolPhase);
    return '${protocol.name} · Cycle $currentCycle of $totalCycles · ${phase.description}';
  }
}

// ── Monitoring & Surveillance symptom library ─────────────────────────────────
class MonitoringSymptomLibrary {
  static const anxiety = ProtocolSymptom(
    key: 'anxiety', label: 'Anxiety / scanxiety', arabicLabel: 'قلق', emoji: '💜',
    tip: 'Scanxiety is normal and valid. Mindfulness, talking to someone who understands, and limiting scan-related searches can help.',
    interferenceQuestion: 'Is anxiety affecting your sleep or daily life?',
    isInverted: true,
  );
  static const fatigue = ProtocolSymptom(
    key: 'fatigue', label: 'Fatigue', arabicLabel: 'إرهاق', emoji: '🌙',
    tip: 'Post-treatment fatigue can last months. Gentle daily movement and good sleep hygiene help more than rest alone.',
    interferenceQuestion: 'Does fatigue stop you doing normal activities?',
  );
  static const jointPain = ProtocolSymptom(
    key: 'joint_pain', label: 'Joint / muscle pain', arabicLabel: 'آلام المفاصل', emoji: '🦴',
    tip: 'Common with aromatase inhibitors. Gentle movement, warm baths, and anti-inflammatory foods can help. Tell your team if severe.',
    interferenceQuestion: 'Does joint pain limit your movement?',
  );
  static const hotFlashes = ProtocolSymptom(
    key: 'hot_flashes', label: 'Hot flashes', arabicLabel: 'هبات حرارية', emoji: '🌡️',
    tip: 'Triggered by hormone therapy. Layering clothing, cooling sprays, and avoiding triggers (caffeine, spicy food) can reduce frequency.',
    interferenceQuestion: 'How many hot flashes per day?',
  );
  static const nightSweats = ProtocolSymptom(
    key: 'night_sweats', label: 'Night sweats', arabicLabel: 'تعرق ليلي', emoji: '🌙',
    tip: 'Light breathable bedding and keeping the room cool helps. If severe, ask about management options.',
    interferenceQuestion: 'Do night sweats disrupt your sleep?',
  );
  static const cognitiveFog = ProtocolSymptom(
    key: 'cognitive_fog', label: 'Cognitive fog', arabicLabel: 'ضباب ذهني', emoji: '🧠',
    tip: 'Chemo brain is real. Mental exercises, good sleep, and reduced stress all help. It usually improves over time.',
    interferenceQuestion: 'Does brain fog affect your work or daily tasks?',
  );
  static const sleep = ProtocolSymptom(
    key: 'sleep', label: 'Sleep quality', arabicLabel: 'جودة النوم', emoji: '😴',
    tip: 'Consistent sleep schedule and avoiding screens before bed helps. Anxiety and hot flashes often disturb sleep.',
    interferenceQuestion: 'How many hours of sleep are you getting?',
  );
  static const mood = ProtocolSymptom(
    key: 'mood', label: 'Mood / depression', arabicLabel: 'المزاج', emoji: '💙',
    tip: 'Post-treatment emotional challenges are common and valid. Support groups, therapy, and talking to survivors all help.',
    isInverted: true,
    interferenceQuestion: 'Is your mood affecting relationships or daily life?',
  );
  static const vaginalDiscomfort = ProtocolSymptom(
    key: 'vaginal_discomfort', label: 'Vaginal dryness / discomfort', arabicLabel: 'جفاف مهبلي', emoji: '🌸',
    tip: 'Very common with hormone therapy. Non-hormonal lubricants and moisturisers help. Ask your gynaecologist.',
    interferenceQuestion: 'Is this affecting your quality of life?',
  );
  static const weightChanges = ProtocolSymptom(
    key: 'weight', label: 'Weight changes', arabicLabel: 'تغيرات الوزن', emoji: '⚖️',
    tip: 'Common after treatment. A dietitian can help with strategies for hormone therapy-related weight changes.',
    interferenceQuestion: 'Has weight changed more than 2kg recently?',
  );
  static const bodyImage = ProtocolSymptom(
    key: 'body_image', label: 'Body image / confidence', arabicLabel: 'صورة الجسم', emoji: '🪞',
    tip: 'Feeling differently about your body after treatment is common. Support groups and counselling can help process these feelings.',
    isInverted: true,
    interferenceQuestion: 'Is body image affecting your confidence or relationships?',
  );

  static const List<ProtocolSymptom> allSymptoms = [
    anxiety, fatigue, jointPain, hotFlashes, nightSweats,
    cognitiveFog, sleep, mood, vaginalDiscomfort, weightChanges, bodyImage,
  ];

  // Scanxiety period — scan within 14 days
  static const List<ProtocolSymptom> scanxietySymptoms = [
    anxiety, sleep, mood, fatigue,
    hotFlashes, nightSweats, cognitiveFog,
  ];

  // Standard monitoring check-in
  static const List<ProtocolSymptom> standardSymptoms = [
    fatigue, jointPain, hotFlashes, nightSweats,
    cognitiveFog, sleep, mood, vaginalDiscomfort,
  ];
}
