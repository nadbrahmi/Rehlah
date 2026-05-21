class DemoAlert {
  final String symptom;
  final String detail;
  final String level; // HIGH / MODERATE / STABLE

  const DemoAlert({
    required this.symptom,
    required this.detail,
    required this.level,
  });
}

class DemoMedication {
  final String name;
  final int takenDays;
  final int totalDays;
  final List<String> missedDates;
  final String missedReason;
  final String? refillAlert;

  const DemoMedication({
    required this.name,
    required this.takenDays,
    required this.totalDays,
    required this.missedDates,
    required this.missedReason,
    this.refillAlert,
  });
}

class DemoLab {
  final String testName;
  final String uploadDate;
  final String value;
  final String normalRange;
  final String status; // LOW / NORMAL / HIGH
  final String clinicalNote;

  const DemoLab({
    required this.testName,
    required this.uploadDate,
    required this.value,
    required this.normalRange,
    required this.status,
    required this.clinicalNote,
  });
}

class DemoTalkingPoint {
  final String english;
  final String arabic;
  final String checklistItem;
  final String flagLevel; // HIGH / MODERATE / STABLE
  final bool patientWordsUsed;

  const DemoTalkingPoint({
    required this.english,
    required this.arabic,
    required this.checklistItem,
    required this.flagLevel,
    required this.patientWordsUsed,
  });
}

class DemoReport {
  final String code;
  final String patientName;
  final String diagnosis;
  final String protocol;
  final String cycleLabel;
  final String phaseEnglish;
  final String phaseArabic;
  final int daysSinceInfusion;
  final bool nadirActive;
  final String nadirWindow;
  final int checkinsCompleted;
  final int checkinsTotalDays;
  final String appointmentLabel;
  // Section 1 — Protocol Adherence Context
  final String protocolContext;
  final String protocolContextArabic;
  // Section 2 — Phase-Specific Symptom Summary
  final String symptomSummary;
  final String symptomSummaryArabic;
  // Section 3 — Threshold Alerts
  final List<DemoAlert> alerts;
  // Section 4 — Medication Adherence
  final List<DemoMedication> medications;
  // Section 5 — Lab Correlation
  final List<DemoLab> labs;
  // Section 6 — Talking Points
  final List<DemoTalkingPoint> talkingPoints;

  const DemoReport({
    required this.code,
    required this.patientName,
    required this.diagnosis,
    required this.protocol,
    required this.cycleLabel,
    required this.phaseEnglish,
    required this.phaseArabic,
    required this.daysSinceInfusion,
    required this.nadirActive,
    required this.nadirWindow,
    required this.checkinsCompleted,
    required this.checkinsTotalDays,
    required this.appointmentLabel,
    required this.protocolContext,
    required this.protocolContextArabic,
    required this.symptomSummary,
    required this.symptomSummaryArabic,
    required this.alerts,
    required this.medications,
    required this.labs,
    required this.talkingPoints,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Demo reports
// ─────────────────────────────────────────────────────────────────────────────

const List<DemoReport> demoReports = [

  // ── Report 1 — REHLAH-ACT-003 · Nadia ──────────────────────────────────────
  DemoReport(
    code: 'REHLAH-ACT-003',
    patientName: 'Nadia',
    diagnosis: 'Breast cancer · Grade II · ER+/PR+',
    protocol: 'AC-T Taxol',
    cycleLabel: 'Cycle 5 of 8',
    phaseEnglish: 'Taxol — Joint pain peak',
    phaseArabic: 'ذروة آلام المفاصل — مرحلة تاكسول',
    daysSinceInfusion: 4,
    nadirActive: false,
    nadirWindow: 'Days 6–14',
    checkinsCompleted: 13,
    checkinsTotalDays: 14,
    appointmentLabel: 'Consultation oncologie · in 2 days',
    protocolContext:
        'Patient is at Day 4 of Cycle 5 (Taxol phase). Nadir window is Days 6–14 — not yet active. Check-in completion: 13 of 14 days (93%). Taxol phase typically presents with arthralgia and myalgia peak Days 2–5, and cumulative peripheral neuropathy from Cycle 5 onward.',
    protocolContextArabic:
        'المريضة في اليوم الرابع من الدورة الخامسة — مرحلة تاكسول. فترة انخفاض المناعة من اليوم السادس إلى الرابع عشر، لم تبدأ بعد. معدل المتابعة اليومية: 13 من 14 يوماً (93%). تتميز مرحلة تاكسول بذروة آلام المفاصل والعضلات في الأيام 2-5، والاعتلال العصبي التراكمي اعتباراً من الدورة الخامسة.',
    symptomSummary:
        'Joint pain 7-8/10 persisting 5 consecutive days — expected for Taxol Day 4 but severity above threshold. Neuropathy 6-7/10 persisting since Cycle 5 and NOT resolving between cycles — this is the clinically unexpected finding. Fatigue 4-5/10 — within expected range for this phase. No fever or infection signs — appropriate for pre-nadir day.',
    symptomSummaryArabic:
        'آلام المفاصل 7-8 من 10 منذ خمسة أيام متتالية — متوقعة في اليوم الرابع من تاكسول لكن الشدة تتجاوز العتبة. اعتلال الأعصاب 6-7 من 10 مستمر منذ الدورة الخامسة ولا يختفي بين الدورات — هذا هو النتيجة السريرية غير المتوقعة. الإرهاق 4-5 من 10 ضمن النطاق المتوقع لهذه المرحلة. لا حمى ولا أعراض عدوى.',
    alerts: [
      DemoAlert(
        symptom: 'Peripheral Neuropathy',
        level: 'HIGH',
        detail:
            'Score 6-7/10 · Persistent >5 days · Not resolving between cycles since Cycle 5 · Threshold for dose review exceeded',
      ),
      DemoAlert(
        symptom: 'Joint Pain',
        level: 'MODERATE',
        detail:
            'Score 7-8/10 · Expected for Taxol Day 4 · Above yellow threshold · Interference with daily activities reported 4 of 5 days',
      ),
      DemoAlert(
        symptom: 'Analgesic Adherence',
        level: 'MODERATE',
        detail:
            '64% adherence · Missed: side effects ×2, forgot ×3 · Under-treatment may be amplifying neuropathy perception',
      ),
    ],
    medications: [
      DemoMedication(
        name: 'Ondansétron 8mg',
        takenDays: 13,
        totalDays: 14,
        missedDates: ['Day 8'],
        missedReason: 'Forgot',
      ),
      DemoMedication(
        name: 'Taxol Premedication',
        takenDays: 14,
        totalDays: 14,
        missedDates: [],
        missedReason: '',
      ),
      DemoMedication(
        name: 'Analgesic (Ibuprofen 400mg)',
        takenDays: 9,
        totalDays: 14,
        missedDates: ['Day 3', 'Day 5', 'Day 9', 'Day 11', 'Day 13'],
        missedReason: 'Side effects ×2 · Forgot ×3',
        refillAlert: 'Refill needed in 5 days',
      ),
    ],
    labs: [
      DemoLab(
        testName: 'CBC — Hemoglobin',
        uploadDate: 'Day 2 of Cycle 5',
        value: '10.8 g/dL',
        normalRange: '12.0–16.0',
        status: 'LOW',
        clinicalNote:
            'Mild anaemia consistent with cumulative AC-T toxicity. Monitor — not yet requiring intervention.',
      ),
      DemoLab(
        testName: 'CBC — WBC',
        uploadDate: 'Day 2 of Cycle 5',
        value: '6.2 × 10⁹/L',
        normalRange: '4.0–11.0',
        status: 'NORMAL',
        clinicalNote: 'WBC recovered — safe for Cycle 5 Taxol infusion.',
      ),
      DemoLab(
        testName: 'Platelets',
        uploadDate: 'Day 2 of Cycle 5',
        value: '198 × 10⁹/L',
        normalRange: '150–400',
        status: 'NORMAL',
        clinicalNote: 'Within normal range.',
      ),
    ],
    talkingPoints: [
      DemoTalkingPoint(
        english:
            'Neuropathy at 7/10 has persisted for 5 consecutive days and is not resolving between cycles — Nadia\'s own words: \'My fingers are numb constantly since Cycle 5 and the numbness did not disappear between the two cycles this time.\' This cumulative pattern exceeds the threshold for dose review per Taxol protocol. Formal peripheral neuropathy grading and discussion of dose modification before Cycle 6 is warranted.',
        arabic:
            'اعتلال الأعصاب عند 7 من 10 منذ خمسة أيام متتالية ولا يختفي بين الدورات. وبكلمات ناديا الخاصة: أصابعها تتنمل باستمرار منذ الدورة الخامسة ولم يختفِ التنميل بين الدورتين. هذا النمط التراكمي يتجاوز عتبة مراجعة الجرعة وفق بروتوكول تاكسول. تقييم رسمي ومناقشة تعديل الجرعة قبل الدورة السادسة مطلوبان.',
        checklistItem:
            'Formal peripheral neuropathy grading — consider dose modification before Cycle 6',
        flagLevel: 'HIGH',
        patientWordsUsed: true,
      ),
      DemoTalkingPoint(
        english:
            'Analgesic adherence is 64% — patient is under-treating joint pain due to ibuprofen side effects and forgetting. Under-treatment of pain during the Taxol joint pain peak may be directly amplifying neuropathy perception and reducing daily function. A brief discussion on analgesic timing, alternative formulations, or prophylactic dosing strategy could reduce symptom burden in Cycle 6.',
        arabic:
            'الالتزام بالمسكن 64% — المريضة لا تعالج آلام المفاصل بشكل كافٍ بسبب آثار الإيبوبروفين الجانبية والنسيان. قد يؤدي ضعف علاج الألم في ذروة آلام مفاصل تاكسول إلى تضخيم الأعراض العصبية وتقليل القدرة الوظيفية. مراجعة استراتيجية إدارة الألم قد تخفف العبء في الدورة السادسة.',
        checklistItem:
            'Review analgesic strategy — timing, alternative formulation, or prophylactic dosing for Cycle 6',
        flagLevel: 'HIGH',
        patientWordsUsed: false,
      ),
      DemoTalkingPoint(
        english:
            'Hemoglobin at 10.8 g/dL is mildly below normal — consistent with cumulative AC-T haematological toxicity and likely contributing to the fatigue pattern. Not yet at intervention threshold but trending. Acknowledge to patient that her fatigue has a measurable physiological basis — this often reduces anxiety about symptom severity.',
        arabic:
            'الهيموغلوبين عند 10.8 جم/ديسيلتر أقل من المعدل الطبيعي — متوافق مع السمية الدموية التراكمية لـ AC-T ويساهم على الأرجح في نمط الإرهاق. لم يصل بعد إلى عتبة التدخل لكنه في تراجع. إبلاغ المريضة بأن لإرهاقها أساساً فسيولوجياً قابلاً للقياس يخفف عادةً من القلق حول شدة الأعراض.',
        checklistItem:
            'Inform patient of haematological basis for fatigue — discuss monitoring plan for Cycle 6',
        flagLevel: 'MODERATE',
        patientWordsUsed: false,
      ),
    ],
  ),

  // ── Report 2 — REHLAH-CMF-001 · Layla ──────────────────────────────────────
  DemoReport(
    code: 'REHLAH-CMF-001',
    patientName: 'Layla',
    diagnosis: 'Breast cancer · Grade II · Triple negative',
    protocol: 'CMF',
    cycleLabel: 'Cycle 1 of 6',
    phaseEnglish: 'Post-infusion — Mucositis window',
    phaseArabic: 'مرحلة ما بعد الحقن — نافذة التهاب الفم',
    daysSinceInfusion: 3,
    nadirActive: false,
    nadirWindow: 'Days 10–18',
    checkinsCompleted: 11,
    checkinsTotalDays: 14,
    appointmentLabel: 'Consultation oncologie · in 2 days',
    protocolContext:
        'Patient is at Day 3 of Cycle 1 (CMF). Nadir window is Days 10–18 — not yet active. Check-in completion: 11 of 14 days (79%). Note: 3 missing check-ins correlate with Days 1–3 post-Day 1 infusion — the peak mucositis and nausea window, suggesting symptom burden prevented check-in.',
    protocolContextArabic:
        'المريضة في اليوم الثالث من الدورة الأولى — بروتوكول CMF. فترة انخفاض المناعة من اليوم العاشر إلى الثامن عشر، لم تبدأ بعد. معدل المتابعة: 11 من 14 يوماً (79%). ملاحظة: الأيام الثلاثة الغائبة تتزامن مع ذروة التهاب الفم والغثيان، مما يشير إلى أن ثقل الأعراض منع المتابعة.',
    symptomSummary:
        'Mouth sores 5/10 Days 2-3 with inability to eat and pain on drinking — clinically unexpected severity for Cycle 1 Day 3. Nausea 6/10 and appetite loss 6/10 — within expected CMF post-infusion range. Mouth rinse adherence critically low at 57% — vicious cycle pattern identified. No fever, infection signs, or bladder irritation at this stage.',
    symptomSummaryArabic:
        'تقرّحات الفم 5 من 10 في اليومين الثاني والثالث مع عجز عن الأكل وألم عند الشرب — شدة غير متوقعة سريرياً في اليوم الثالث من الدورة الأولى. الغثيان 6 من 10 وفقدان الشهية 6 من 10 ضمن النطاق المتوقع. الالتزام ببروتوكول الفم منخفض بشكل حرج عند 57% — نمط حلقة مفرغة تم تحديده.',
    alerts: [
      DemoAlert(
        symptom: 'Mouth Sores / Mucositis',
        level: 'HIGH',
        detail:
            'Score 5/10 · Days 2-3 · Unable to eat · Pain on drinking · Patient words: \'Even drinking is painful\' · Possible Grade II-III — formal grading required · Grade III = 20% MTX/5-FU dose reduction per ASWCS10 BR016',
      ),
      DemoAlert(
        symptom: 'Mouth Rinse Adherence',
        level: 'HIGH',
        detail:
            '57% adherence · Too sick to use ×2 · Forgot ×2 · Non-adherence perpetuating mucositis cycle',
      ),
      DemoAlert(
        symptom: 'Nausea',
        level: 'MODERATE',
        detail:
            'Score 6/10 · Expected for CMF Day 3 · Ondansétron adherence 86% · Optimise timing relative to meals',
      ),
    ],
    medications: [
      DemoMedication(
        name: 'Ondansétron 8mg',
        takenDays: 12,
        totalDays: 14,
        missedDates: ['Day 1', 'Day 2'],
        missedReason: 'Too sick',
      ),
      DemoMedication(
        name: 'Mouth Rinse (prescribed)',
        takenDays: 8,
        totalDays: 14,
        missedDates: ['Day 2', 'Day 3', 'Day 8', 'Day 9', 'Day 12', 'Day 13'],
        missedReason: 'Too sick ×2 · Forgot ×4',
        refillAlert: 'Refill needed in 7 days',
      ),
      DemoMedication(
        name: 'Leucovorin',
        takenDays: 13,
        totalDays: 14,
        missedDates: ['Day 6'],
        missedReason: 'Forgot',
      ),
    ],
    labs: [
      DemoLab(
        testName: 'CBC — WBC',
        uploadDate: 'Pre-Cycle 1',
        value: '7.1 × 10⁹/L',
        normalRange: '4.0–11.0',
        status: 'NORMAL',
        clinicalNote: 'Baseline WBC normal — monitor at nadir Day 10-18.',
      ),
      DemoLab(
        testName: 'CBC — Hemoglobin',
        uploadDate: 'Pre-Cycle 1',
        value: '11.9 g/dL',
        normalRange: '12.0–16.0',
        status: 'LOW',
        clinicalNote:
            'Borderline low at baseline. Monitor — CMF may cause further reduction.',
      ),
      DemoLab(
        testName: 'Renal function (Creatinine)',
        uploadDate: 'Pre-Cycle 1',
        value: '72 μmol/L',
        normalRange: '44–97',
        status: 'NORMAL',
        clinicalNote: 'Normal — methotrexate clearance not compromised.',
      ),
    ],
    talkingPoints: [
      DemoTalkingPoint(
        english:
            'Layla reports mouth sores at 5/10 on Days 2-3 with complete inability to eat and pain on drinking — her own words: \'Even drinking is painful.\' This severity in Cycle 1 Day 3 is clinically unexpected and consistent with Grade II-III stomatitis. Per ASWCS10 BR016 protocol, Grade III mandates 20% dose reduction of methotrexate and 5-FU at Cycle 2. Formal grading at this consultation is required before Cycle 2 authorisation.',
        arabic:
            'تُبلّغ ليلى عن تقرّحات في الفم بدرجة 5 من 10 في اليومين الثاني والثالث مع عجز تام عن الأكل وألم عند الشرب. وبكلماتها: حتى الشرب مؤلم. هذه الشدة في اليوم الثالث من الدورة الأولى غير متوقعة سريرياً وتتوافق مع التهاب فم من الدرجة الثانية أو الثالثة. وفق ASWCS10 BR016 تستوجب الدرجة الثالثة تخفيض جرعة MTX/5-FU بنسبة 20% في الدورة الثانية.',
        checklistItem:
            'Grade mucositis formally — if Grade III apply 20% MTX/5-FU dose reduction at Cycle 2',
        flagLevel: 'HIGH',
        patientWordsUsed: true,
      ),
      DemoTalkingPoint(
        english:
            'Mouth rinse adherence is only 57% — patient was too sick to use it on 2 days and forgot on 4 others. This creates a vicious cycle where mucositis severity prevents the treatment that would reduce it. Before Cycle 2, discuss whether a simpler administration protocol, a different formulation, or caregiver assistance can break this cycle — because the Day 8 second infusion will re-peak mucositis.',
        arabic:
            'الالتزام ببروتوكول الفم 57% فقط — كانت المريضة مريضة جداً يومين ونسيت أربعة أيام أخرى. هذا يخلق حلقة مفرغة حيث شدة التهاب الفم تمنع العلاج الذي سيخففه. قبل الدورة الثانية ناقشي تبسيط البروتوكول أو تغيير التركيبة أو إشراك مقدّم رعاية — لأن الحقن الثاني في اليوم الثامن سيعيد ذروة الالتهاب.',
        checklistItem:
            'Redesign mouth rinse protocol before Cycle 2 — simplify or arrange caregiver assistance',
        flagLevel: 'HIGH',
        patientWordsUsed: false,
      ),
      DemoTalkingPoint(
        english:
            'Baseline hemoglobin is borderline low at 11.9 g/dL — combined with CMF-related myelosuppression this may decline further during nadir Days 10-18. The nausea and appetite loss pattern in Days 1-3 is consistent with CMF profile but Ondansétron timing relative to meals should be optimised to protect nutritional intake before the nadir window.',
        arabic:
            'الهيموغلوبين الأساسي منخفض على الحدود عند 11.9 جم/ديسيلتر — بالاقتران مع كبت النخاع المرتبط بـ CMF قد ينخفض أكثر خلال فترة الناضير من اليوم العاشر إلى الثامن عشر. نمط الغثيان وفقدان الشهية في الأيام 1-3 متوافق مع CMF لكن توقيت الأوندانسيترون بالنسبة للوجبات يجب تحسينه لحماية التغذية قبل فترة الناضير.',
        checklistItem:
            'Optimise Ondansétron timing before nadir — protect nutritional status in Days 10-18',
        flagLevel: 'MODERATE',
        patientWordsUsed: false,
      ),
    ],
  ),

  // ── Report 3 — REHLAH-REC-001 · Amira ──────────────────────────────────────
  DemoReport(
    code: 'REHLAH-REC-001',
    patientName: 'Amira',
    diagnosis: 'Breast cancer · Grade II · ER+/PR+',
    protocol: 'AC-T',
    cycleLabel: 'Cycle 4 of 8',
    phaseEnglish: 'Recovery week — Pre-Cycle 5',
    phaseArabic: 'مرحلة التعافي — ما قبل الدورة الخامسة',
    daysSinceInfusion: 18,
    nadirActive: false,
    nadirWindow: 'Days 6–14 · Passed',
    checkinsCompleted: 12,
    checkinsTotalDays: 14,
    appointmentLabel: 'Consultation oncologie · in 2 days',
    protocolContext:
        'Patient is at Day 18 of Cycle 4 (AC). Nadir window Days 6-14 has passed. Check-in completion: 12 of 14 days (86%). Recovery phase — functional trajectory monitored for Cycle 5 authorisation. Patient on Tamoxifen long-term — adherence tracked continuously.',
    protocolContextArabic:
        'المريضة في اليوم الثامن عشر من الدورة الرابعة — AC. فترة انخفاض المناعة من اليوم السادس إلى الرابع عشر قد انتهت. معدل المتابعة: 12 من 14 يوماً (86%). مرحلة التعافي — مراقبة المسار الوظيفي للموافقة على الدورة الخامسة. المريضة على التاموكسيفين طويل الأمد — الالتزام تحت المراقبة المستمرة.',
    symptomSummary:
        'Physical recovery on track — fatigue declining from 6 to 4, energy improving from 3 to 5 over 14 days. Interference with daily activities negative for past 5 consecutive days. Clinically unexpected finding: anxiety persisting at 4/10 despite physical recovery — not resolving with physical improvement. Patient anticipatory anxiety about Cycle 5 documented in own words.',
    symptomSummaryArabic:
        'التعافي الجسدي يسير وفق المتوقع — تراجع الإرهاق من 6 إلى 4 وتحسّنت الطاقة من 3 إلى 5 خلال 14 يوماً. انعدم تأثير الأعراض على الأنشطة اليومية خلال الخمسة أيام الأخيرة. النتيجة غير المتوقعة: القلق مستمر عند 4 من 10 رغم التعافي الجسدي — لا يتراجع مع التحسن الجسدي. توثيق القلق الاستباقي للدورة الخامسة بكلمات المريضة.',
    alerts: [
      DemoAlert(
        symptom: 'Anxiety — Persistent',
        level: 'MODERATE',
        detail:
            'Score 4/10 · 14 consecutive days · Not resolving with physical recovery · Anticipatory anxiety about Cycle 5 documented · Patient words: \'Very worried about the next cycle\'',
      ),
      DemoAlert(
        symptom: 'Fatigue — Residual',
        level: 'STABLE',
        detail:
            'Score 4/10 · Improving trajectory · Was 6/10 at Day 5 · Within recovery range · Interference flag negative 5 consecutive days',
      ),
      DemoAlert(
        symptom: 'Tamoxifen Adherence',
        level: 'STABLE',
        detail:
            '93% adherence · 18-day consecutive streak · Strong long-term behavior established',
      ),
    ],
    medications: [
      DemoMedication(
        name: 'Tamoxifen 20mg',
        takenDays: 19,
        totalDays: 21,
        missedDates: ['Day 7', 'Day 14'],
        missedReason: 'Forgot ×2',
        refillAlert: 'Refill needed in 12 days',
      ),
      DemoMedication(
        name: 'Ondansétron 8mg (as needed)',
        takenDays: 4,
        totalDays: 21,
        missedDates: [],
        missedReason: 'PRN — taken only when needed',
      ),
    ],
    labs: [
      DemoLab(
        testName: 'CBC — Hemoglobin',
        uploadDate: 'Day 15 of Cycle 4',
        value: '11.2 g/dL',
        normalRange: '12.0–16.0',
        status: 'LOW',
        clinicalNote:
            'Recovering from nadir — mild anaemia persisting. Consistent with fatigue pattern. Not yet at intervention threshold.',
      ),
      DemoLab(
        testName: 'CBC — WBC',
        uploadDate: 'Day 15 of Cycle 4',
        value: '5.8 × 10⁹/L',
        normalRange: '4.0–11.0',
        status: 'NORMAL',
        clinicalNote:
            'WBC recovered to safe range — supports Cycle 5 authorisation.',
      ),
      DemoLab(
        testName: 'CA 15-3 Tumour Marker',
        uploadDate: 'Day 15 of Cycle 4',
        value: '18.2 U/mL',
        normalRange: '<25 U/mL',
        status: 'NORMAL',
        clinicalNote:
            'Trending down 18% since Cycle 2 (from 22.1 to 18.2) — positive treatment response signal worth acknowledging to patient.',
      ),
    ],
    talkingPoints: [
      DemoTalkingPoint(
        english:
            'Amira reports persistent anxiety at 4/10 for 14 consecutive days despite physical recovery — her own words: \'I am getting better but I am very worried about the next cycle and what symptoms it will bring.\' This anticipatory anxiety is not resolving with physical improvement, suggesting a psychosocial need that physical recovery alone will not address. A brief psycho-oncology referral discussion before Cycle 5 is warranted.',
        arabic:
            'تُبلّغ أميرة عن قلق مستمر بدرجة 4 من 10 لمدة 14 يوماً متتالية رغم التعافي الجسدي. وبكلماتها: تبدأ بالتحسن لكنها قلقة جداً من الدورة القادمة وما ستحمله من أعراض. هذا القلق الاستباقي لا يتراجع مع التحسن الجسدي، مما يشير إلى احتياج نفسي-اجتماعي لا يعالجه التعافي الجسدي وحده. مناقشة إحالة نفسية-أورامية موجزة قبل الدورة الخامسة مستحسنة.',
        checklistItem:
            'Discuss psycho-oncology referral — anticipatory anxiety not resolving with physical recovery',
        flagLevel: 'MODERATE',
        patientWordsUsed: true,
      ),
      DemoTalkingPoint(
        english:
            'CA 15-3 tumour marker trending down 18% since Cycle 2 — from 22.1 to 18.2 U/mL — a positive treatment response signal. Acknowledging this explicitly to Amira during the consultation could directly address her anxiety about treatment efficacy and provide meaningful reassurance at a psychologically vulnerable moment before Cycle 5.',
        arabic:
            'مؤشر الورم CA 15-3 في تراجع بنسبة 18% منذ الدورة الثانية — من 22.1 إلى 18.2 وحدة/مل — إشارة إيجابية على استجابة العلاج. الإعلان عن هذا الأمر صراحةً لأميرة خلال الاستشارة قد يعالج مباشرةً قلقها حول فاعلية العلاج ويوفر طمأنينة حقيقية في لحظة نفسية حساسة قبل الدورة الخامسة.',
        checklistItem:
            'Share CA 15-3 downward trend with patient — use as positive reinforcement before Cycle 5',
        flagLevel: 'STABLE',
        patientWordsUsed: false,
      ),
      DemoTalkingPoint(
        english:
            'Physical recovery supports Cycle 5 authorisation — WBC 5.8, fatigue improving, interference flag negative 5 consecutive days. Hemoglobin at 11.2 is mildly below normal but recovering and not at intervention threshold. Tamoxifen adherence 93% with 18-day streak — acknowledge this explicitly to reinforce long-term adherence behavior at a moment when patient motivation needs support.',
        arabic:
            'التعافي الجسدي يدعم الموافقة على الدورة الخامسة — WBC 5.8، الإرهاق في تحسن، انعدام التأثير على الأنشطة 5 أيام متتالية. الهيموغلوبين 11.2 أقل من المعدل قليلاً لكن في تحسن وليس عند عتبة التدخل. الالتزام بالتاموكسيفين 93% مع سلسلة 18 يوماً — الاعتراف به صراحةً يعزز سلوك الالتزام طويل الأمد في لحظة تحتاج فيها المريضة إلى الدعم.',
        checklistItem:
            'Confirm Cycle 5 authorisation — acknowledge Tamoxifen streak to reinforce long-term adherence',
        flagLevel: 'STABLE',
        patientWordsUsed: false,
      ),
    ],
  ),
];
