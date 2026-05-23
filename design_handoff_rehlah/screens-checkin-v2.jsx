// Rehlah · Check-in v2 — phase-aware single-screen flow
// Implements the IA from Rehlah_Checkin_Redesign_v1.0.md using the v0.1 design system.

function _IcoCV({ d, size = 20, sw = 1.8 }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">{d}</svg>;
}
const CVI = {
  back: <path d="M15 18l-6-6 6-6"/>,
  forward: <path d="M9 18l6-6-6-6"/>,
  plus: <><path d="M12 5v14M5 12h14"/></>,
  mic: <><rect x="9" y="3" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0014 0M12 18v3M8 21h8"/></>,
  thermo: <><path d="M14 4a2 2 0 10-4 0v10a4 4 0 104 0z"/></>,
  phone: <path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45 12.84 12.84 0 002.81.7A2 2 0 0122 16.92z"/>,
  warning: <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0zM12 9v4M12 17h.01"/>,
  arrow: <path d="M5 12h14M13 6l6 6-6 6"/>,
  arrowDown: <path d="M12 5v14M19 12l-7 7-7-7"/>,
  arrowUp: <path d="M12 19V5M5 12l7-7 7 7"/>,
  arrowRight: <path d="M5 12h14M13 6l6 6-6 6"/>,
  check: <path d="M5 12l5 5 9-11"/>,
  close: <><path d="M6 6l12 12M18 6l-12 12"/></>,
  more: <><circle cx="5" cy="12" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="19" cy="12" r="1.5"/></>,
  home: <path d="M3 11l9-7 9 7v9a1 1 0 01-1 1h-5v-6h-6v6H4a1 1 0 01-1-1z"/>,
  heart: <path d="M12 21s-7-4.5-7-10a4 4 0 017-2.6A4 4 0 0119 11c0 5.5-7 10-7 10z"/>,
  users: <><path d="M17 21v-2a4 4 0 00-4-4H7a4 4 0 00-4 4v2"/><circle cx="10" cy="7" r="4"/></>,
  user: <><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0116 0"/></>,
};

// 5 mood faces from clinical-leaning abstract glyphs (◐ ◑ ● ◔ ◕)
const MOOD_GLYPHS = ["◐", "◑", "●", "◔", "◕"];
const MOOD_ANCHORS_EN = ["Awful", "Low", "Okay", "Good", "Great"];
const MOOD_ANCHORS_AR = ["سيئة جدًا", "منخفضة", "مقبولة", "جيدة", "ممتازة"];

const SEV_EN = ["None", "Mild", "Mod.", "Severe", "Worst"];
const SEV_AR = ["لا شيء", "خفيف", "متوسط", "شديد", "الأسوأ"];

function MoodLikert({ value, lang }) {
  const labels = lang === "ar" ? MOOD_ANCHORS_AR : MOOD_ANCHORS_EN;
  return (
    <div className="rh-likert">
      {[0, 1, 2, 3, 4].map(i => (
        <div key={i} className={"rh-likert-cell" + (i === value ? " on" : "")}>
          <div className="rh-likert-face">
            <span style={{ fontSize: 24, lineHeight: 1, fontFamily: "system-ui, serif" }}>{MOOD_GLYPHS[i]}</span>
          </div>
          <div className="rh-likert-lbl">{labels[i]}</div>
        </div>
      ))}
    </div>
  );
}

function Segmented({ value, lang }) {
  const anchors = lang === "ar" ? SEV_AR : SEV_EN;
  return (
    <div className="rh-segmented">
      {[0, 1, 2, 3, 4].map(i => (
        <div key={i} className={"rh-seg-cell fill-" + i + (i === value ? " active" : "") + (i > value ? " empty" : "")}>
          <div className="pad"></div>
          <div className="rh-seg-anchor">{anchors[i]}</div>
        </div>
      ))}
    </div>
  );
}

function PhaseSubheadPill({ phase, cycle, day, lang }) {
  const isRTL = lang === "ar";
  const variants = {
    treatment: { cls: "", en: "Treatment day", ar: "يوم العلاج" },
    nadir: { cls: "nadir", en: "Nadir window", ar: "فترة الهبوط المناعي" },
    recovery: { cls: "recovery", en: "Recovery", ar: "مرحلة التعافي" },
  };
  const v = variants[phase];
  const cycleLabel = isRTL ? `الدورة ${cycle === 2 ? "٢" : cycle}` : `Cycle ${cycle}`;
  const dayLabel = isRTL ? `اليوم ${({1:"١",9:"٩",17:"١٧"})[day] || day}` : `Day ${day}`;
  return (
    <div className={"rh-phase-sub-pill " + v.cls}>
      <span className="dot"></span>
      <span>{cycleLabel} · {dayLabel} · {isRTL ? v.ar : v.en}</span>
    </div>
  );
}

function Notes({ lang, filled }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-notes">
      <div className="rh-notes-head">
        <span className="rh-notes-ttl">{isRTL ? "هل تودين إضافة شيء؟" : "Anything else?"}</span>
        <span className="rh-notes-opt">{isRTL ? "اختياري" : "optional"}</span>
      </div>
      <div className={"rh-notes-input" + (filled ? " filled" : "")}>
        {filled
          ? (isRTL ? "شعرت بدوار خفيف عند الوقوف صباحاً..." : "Felt dizzy when standing up this morning...")
          : (isRTL ? "مثلًا: شعرت بدوار عند الوقوف…" : "E.g., felt dizzy when standing up…")
        }
        <div className="rh-notes-mic">
          <_IcoCV d={CVI.mic} size={12}/>
          {isRTL ? "تحدّثي" : "Speak"}
        </div>
      </div>
    </div>
  );
}

function SubmitFooter({ lang, label, disabled }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-submit-footer">
      <button className="rh-btn-primary" style={{ opacity: disabled ? .5 : 1 }}>
        {label || (isRTL ? "إرسال إلى الفريق الطبي" : "Send to care team")}
        <_IcoCV d={isRTL ? CVI.back : CVI.arrow} size={16}/>
      </button>
    </div>
  );
}

// =================== TREATMENT DAY ===================
function CheckinTreatmentScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll" style={{ paddingBottom: 120 }}>
        <header className="rh-topbar">
          <button className="rh-iconbtn"><_IcoCV d={isRTL ? CVI.forward : CVI.back}/></button>
          <div style={{ flex: 1 }}></div>
          <button className="rh-iconbtn" style={{ width: "auto", padding: "0 12px", fontSize: 13, fontWeight: 500, color: "var(--sand-500)" }}>
            {isRTL ? "تخطّي ›" : "Skip ›"}
          </button>
        </header>

        <div className="rh-checkin-greet">
          <span className="hi">{isRTL ? "صباح الخير،" : "Good morning,"}</span>
          <span className="name">{isRTL ? "ليلى" : "Layla"}</span>
          <PhaseSubheadPill phase="treatment" cycle={2} day={1} lang={lang}/>
        </div>

        <div className="rh-surface">
          <h3 className="rh-surface-title">{isRTL ? "كيف حالكِ بشكل عام اليوم؟" : "How are you overall?"}</h3>
          <MoodLikert value={3} lang={lang}/>
        </div>

        <div className="rh-surface">
          <h3 className="rh-surface-title">{isRTL ? "أعراض اليوم" : "Today's symptoms"}</h3>

          <div className="rh-symptom">
            <div className="rh-symptom-head">
              <span className="rh-symptom-name">{isRTL ? "غثيان" : "Nausea"}</span>
            </div>
            <Segmented value={0} lang={lang}/>
          </div>

          <div className="rh-symptom">
            <div className="rh-symptom-head">
              <span className="rh-symptom-name">{isRTL ? "إرهاق" : "Fatigue"}</span>
            </div>
            <Segmented value={1} lang={lang}/>
          </div>

          <div className="rh-symptom">
            <div className="rh-symptom-head">
              <span className="rh-symptom-name">{isRTL ? "موضع الحقن" : "Infusion site"}</span>
            </div>
            <Segmented value={0} lang={lang}/>
          </div>

          <button className="rh-add-symptom">
            <_IcoCV d={CVI.plus} size={14}/>
            {isRTL ? "إضافة عرض آخر" : "Add another symptom"}
          </button>
        </div>

        <Notes lang={lang}/>
      </div>

      <SubmitFooter lang={lang}/>
    </div>
  );
}

// =================== NADIR (default) ===================
function CheckinNadirScreen({ lang = "en", fever = false }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll" style={{ paddingBottom: 120 }}>
        <header className="rh-topbar">
          <button className="rh-iconbtn"><_IcoCV d={isRTL ? CVI.forward : CVI.back}/></button>
          <div style={{ flex: 1 }}></div>
          <button className="rh-iconbtn" style={{ width: "auto", padding: "0 12px", fontSize: 13, fontWeight: 500, color: "var(--sand-500)" }}>
            {isRTL ? "تخطّي ›" : "Skip ›"}
          </button>
        </header>

        {/* Red-flag banner (above everything else when fever) */}
        {fever && (
          <div className="rh-redflag">
            <div className="rh-redflag-head">
              <div className="rh-redflag-ic"><_IcoCV d={CVI.warning} size={20} sw={2.2}/></div>
              <div>
                <div className="rh-redflag-eyebrow">{isRTL ? "تنبيه عاجل" : "Urgent"}</div>
                <div className="rh-redflag-temp">{isRTL ? "درجة الحرارة ٣٨٫٤°م" : "Temperature 38.4°C"}</div>
              </div>
            </div>
            <p className="rh-redflag-body">
              {isRTL
                ? "في فترة الهبوط المناعي، أي حرارة ≥ ٣٨ مئوية تستدعي تواصلًا فوريًا مع فريقكِ الطبي."
                : "During nadir, any fever ≥ 38°C needs urgent attention from your care team."}
            </p>
            <div className="rh-redflag-actions">
              <button className="rh-btn-clay">
                <_IcoCV d={CVI.phone} size={16}/>
                {isRTL ? "اتصلي بالفريق الطبي الآن" : "Call care team now"}
              </button>
              <button className="rh-btn-redflag-secondary">
                {isRTL ? "متابعة التسجيل" : "Continue check-in"}
              </button>
            </div>
          </div>
        )}

        <div className="rh-checkin-greet">
          <span className="hi">{isRTL ? "مرحبًا،" : "Good morning,"}</span>
          <span className="name">{isRTL ? "ليلى" : "Layla"}</span>
          <PhaseSubheadPill phase="nadir" cycle={2} day={9} lang={lang}/>
          <p className="rh-phase-caution">
            {isRTL
              ? "مناعتكِ في أدنى مستوياتها. انتبهي جيدًا لأي ارتفاع في الحرارة أو علامات عدوى."
              : "Your immunity is at its lowest. Be extra alert for fever or infection."}
          </p>
        </div>

        <div className="rh-surface">
          <h3 className="rh-surface-title">{isRTL ? "كيف حالكِ بشكل عام اليوم؟" : "How are you overall?"}</h3>
          <MoodLikert value={fever ? 1 : 2} lang={lang}/>
        </div>

        <div className="rh-surface">
          <h3 className="rh-surface-title">{isRTL ? "أعراض اليوم" : "Today's symptoms"}</h3>

          <div className="rh-symptom">
            <div className="rh-symptom-head"><span className="rh-symptom-name">{isRTL ? "إرهاق" : "Fatigue"}</span></div>
            <Segmented value={fever ? 3 : 2} lang={lang}/>
          </div>

          <div className="rh-symptom">
            <div className="rh-symptom-head"><span className="rh-symptom-name">{isRTL ? "تقرحات الفم" : "Mouth sores"}</span></div>
            <Segmented value={1} lang={lang}/>
          </div>

          <div className="rh-symptom">
            <div className="rh-symptom-head"><span className="rh-symptom-name">{isRTL ? "فقدان الشهية" : "Appetite loss"}</span></div>
            <Segmented value={2} lang={lang}/>
          </div>

          <button className="rh-add-symptom">
            <_IcoCV d={CVI.plus} size={14}/>
            {isRTL ? "إضافة عرض آخر" : "Add another symptom"}
          </button>
        </div>

        {/* Temperature prompt — mirrors Home's Vitals tile */}
        <div className="rh-temp-prompt">
          <div className="rh-temp-prompt-ic">
            <_IcoCV d={CVI.thermo} size={18}/>
          </div>
          <div className="rh-temp-prompt-body">
            <div className="rh-temp-prompt-ttl">{isRTL ? "درجة الحرارة" : "Temperature"}</div>
            <div className="rh-temp-prompt-sub">
              {fever
                ? (isRTL ? "آخر تسجيل: ٣٨٫٤°م قبل ١٠ دقائق" : "Last logged: 38.4°C · 10 min ago")
                : (isRTL ? "لم يتم التسجيل بعد اليوم" : "Last logged: not yet today")}
            </div>
            {!fever && (
              <div className="rh-temp-prompt-cta">
                {isRTL ? "سجّلي درجة الحرارة الآن" : "Log temperature now"}
                <_IcoCV d={CVI.arrowRight} size={12}/>
              </div>
            )}
          </div>
        </div>

        <Notes lang={lang} filled={fever}/>
      </div>

      <SubmitFooter lang={lang}/>
    </div>
  );
}

// =================== RECOVERY ===================
function CheckinRecoveryScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll" style={{ paddingBottom: 120 }}>
        <header className="rh-topbar">
          <button className="rh-iconbtn"><_IcoCV d={isRTL ? CVI.forward : CVI.back}/></button>
          <div style={{ flex: 1 }}></div>
          <button className="rh-iconbtn" style={{ width: "auto", padding: "0 12px", fontSize: 13, fontWeight: 500, color: "var(--sand-500)" }}>
            {isRTL ? "تخطّي ›" : "Skip ›"}
          </button>
        </header>

        <div className="rh-checkin-greet">
          <span className="hi">{isRTL ? "صباح الخير،" : "Good morning,"}</span>
          <span className="name">{isRTL ? "ليلى" : "Layla"}</span>
          <PhaseSubheadPill phase="recovery" cycle={2} day={17} lang={lang}/>
          <p className="rh-phase-caution">
            {isRTL
              ? "من المتوقع أن تعود طاقتكِ تدريجيًا. استمري في التسجيل — الأنماط تساعد فريقكِ الطبي."
              : "Energy should be returning. Keep logging — patterns help your team."}
          </p>
        </div>

        <div className="rh-surface">
          <h3 className="rh-surface-title">{isRTL ? "كيف حالكِ بشكل عام اليوم؟" : "How are you overall?"}</h3>
          <MoodLikert value={3} lang={lang}/>
        </div>

        <div className="rh-surface">
          <h3 className="rh-surface-title">{isRTL ? "أعراض اليوم" : "Today's symptoms"}</h3>

          <div className="rh-symptom">
            <div className="rh-symptom-head"><span className="rh-symptom-name">{isRTL ? "مستوى الطاقة" : "Energy level"}</span></div>
            <Segmented value={2} lang={lang}/>
          </div>

          <div className="rh-symptom">
            <div className="rh-symptom-head"><span className="rh-symptom-name">{isRTL ? "المزاج" : "Mood"}</span></div>
            <Segmented value={1} lang={lang}/>
          </div>

          <div className="rh-symptom">
            <div className="rh-symptom-head"><span className="rh-symptom-name">{isRTL ? "فقدان الشهية" : "Appetite"}</span></div>
            <Segmented value={0} lang={lang}/>
          </div>

          <button className="rh-add-symptom">
            <_IcoCV d={CVI.plus} size={14}/>
            {isRTL ? "إضافة عرض آخر" : "Add another symptom"}
          </button>
        </div>

        <Notes lang={lang}/>
      </div>

      <SubmitFooter lang={lang}/>
    </div>
  );
}

// =================== SUCCESS (with trend) ===================
function CheckinSuccessV2Screen({ lang = "en" }) {
  const isRTL = lang === "ar";

  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-success-v2">
        <div className="rh-success-v2-top">
          <div className="rh-success-v2-tick">
            <_IcoCV d={CVI.check} size={44} sw={2.6}/>
          </div>
          <h1 className="rh-success-v2-ttl">
            {isRTL ? "تم التسجيل في ٩:١٤" : "Logged at 9:14 AM"}
          </h1>
          <p className="rh-success-v2-sub">{isRTL ? "فريقكِ الطبي يستطيع رؤية هذا." : "Your care team can see this."}</p>
        </div>

        <div className="rh-trend-card">
          <div className="rh-trend-head">
            <span className="rh-eyebrow">{isRTL ? "اليوم مقارنةً بالأمس" : "Today vs. yesterday"}</span>
          </div>
          <div className="rh-trend-row">
            <span className="rh-trend-name">{isRTL ? "الإرهاق" : "Fatigue"}</span>
            <span className="rh-trend-delta better">
              <svg className="rh-trend-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M12 5v14M19 12l-7 7-7-7"/></svg>
              {isRTL ? "أفضل" : "better"}
            </span>
          </div>
          <div className="rh-trend-row">
            <span className="rh-trend-name">{isRTL ? "الغثيان" : "Nausea"}</span>
            <span className="rh-trend-delta same">
              <svg className="rh-trend-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14"/></svg>
              {isRTL ? "كما هو" : "same"}
            </span>
          </div>
          <div className="rh-trend-row">
            <span className="rh-trend-name">{isRTL ? "الألم" : "Pain"}</span>
            <span className="rh-trend-delta worse">
              <svg className="rh-trend-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M12 19V5M5 12l7-7 7 7"/></svg>
              {isRTL ? "أسوأ قليلًا" : "slightly worse"}
            </span>
          </div>
        </div>

        <div className="rh-success-v2-actions">
          <button className="rh-btn-secondary">{isRTL ? "إضافة ملاحظة" : "Add a note"}</button>
          <button className="rh-btn-primary" style={{ height: 44, width: "auto" }}>{isRTL ? "تم" : "Done"}</button>
        </div>
      </div>

      {/* Bottom nav with green/sage FAB (FAB turned sage = check-in complete) */}
      <nav className="rh-nav-wrap">
        <div className="rh-nav">
          <div className="rh-tab rh-tab-on"><_IcoCV d={CVI.home} size={22}/><span>{isRTL ? "اليوم" : "Today"}</span></div>
          <div className="rh-tab"><_IcoCV d={CVI.heart} size={22}/><span>{isRTL ? "الصحة" : "Health"}</span></div>
          <div className="rh-tab rh-tab-spacer"></div>
          <div className="rh-tab"><_IcoCV d={CVI.users} size={22}/><span>{isRTL ? "تواصل" : "Connect"}</span></div>
          <div className="rh-tab"><_IcoCV d={CVI.user} size={22}/><span>{isRTL ? "الملف" : "Profile"}</span></div>
          <div className="rh-fab rh-fab-done">
            <_IcoCV d={CVI.check} size={22} sw={2.4}/>
          </div>
        </div>
      </nav>
    </div>
  );
}

Object.assign(window, {
  CheckinTreatmentScreen,
  CheckinNadirScreen,
  CheckinRecoveryScreen,
  CheckinSuccessV2Screen,
});
