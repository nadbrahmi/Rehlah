// Rehlah · Labs + Appointments screens

function _IcoL({ d, size = 20 }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{d}</svg>;
}
const _labsI = {
  back: <path d="M15 18l-6-6 6-6"/>,
  forward: <path d="M9 18l6-6-6-6"/>,
  more: <><circle cx="5" cy="12" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="19" cy="12" r="1.5"/></>,
  plus: <><path d="M12 5v14M5 12h14"/></>,
  check: <path d="M5 12l5 5 9-11"/>,
  spark: <><path d="M12 3v3M12 18v3M3 12h3M18 12h3M5.6 5.6l2.1 2.1M16.3 16.3l2.1 2.1M5.6 18.4l2.1-2.1M16.3 7.7l2.1-2.1"/><circle cx="12" cy="12" r="3"/></>,
  cal: <><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 9h18M8 3v4M16 3v4"/></>,
  flask: <><path d="M9 3v6l-5 9a2 2 0 002 3h12a2 2 0 002-3l-5-9V3M9 3h6"/></>,
  mapPin: <><path d="M12 22s7-7 7-12a7 7 0 10-14 0c0 5 7 12 7 12z"/><circle cx="12" cy="10" r="2.5"/></>,
};

function _BNavL({ lang, active = "health" }) {
  const tabs = lang === "ar" ? ["اليوم", "الصحة", "تواصل", "الملف"] : ["Today", "Health", "Connect", "Profile"];
  const tabIcons = [
    <path d="M3 11l9-7 9 7v9a1 1 0 01-1 1h-5v-6h-6v6H4a1 1 0 01-1-1z"/>,
    <path d="M12 21s-7-4.5-7-10a4 4 0 017-2.6A4 4 0 0119 11c0 5.5-7 10-7 10z"/>,
    null,
    <><path d="M17 21v-2a4 4 0 00-4-4H7a4 4 0 00-4 4v2"/><circle cx="10" cy="7" r="4"/></>,
    <><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0116 0"/></>,
  ];
  const map = ["home", "health", null, "connect", "profile"];
  return (
    <nav className="rh-nav-wrap">
      <div className="rh-nav">
        {tabIcons.map((ic, i) => i === 2
          ? <div key={i} className="rh-tab rh-tab-spacer"></div>
          : <div key={i} className={"rh-tab" + (active === map[i] ? " rh-tab-on" : "")}><_IcoL d={ic}/><span>{tabs[i > 2 ? i - 1 : i]}</span></div>
        )}
        <div className="rh-fab rh-fab-done"><_IcoL d={_labsI.check} size={22}/></div>
      </div>
    </nav>
  );
}

// ============ Lab Results ============
function LabResultsScreen({ lang = "en" }) {
  const isRTL = lang === "ar";

  const metrics = isRTL ? [
    { name: "الهيموجلوبين", val: "11.8", unit: "g/dL", pos: 55, status: "ok" },
    { name: "كريات الدم البيضاء", val: "3.4", unit: "×10⁹/L", pos: 28, status: "low" },
    { name: "الصفائح الدموية", val: "182", unit: "×10⁹/L", pos: 62, status: "ok" },
    { name: "الكرياتينين", val: "0.8", unit: "mg/dL", pos: 48, status: "ok" },
    { name: "ALT", val: "62", unit: "U/L", pos: 78, status: "high" },
  ] : [
    { name: "Hemoglobin", val: "11.8", unit: "g/dL", pos: 55, status: "ok" },
    { name: "White cells", val: "3.4", unit: "×10⁹/L", pos: 28, status: "low" },
    { name: "Platelets", val: "182", unit: "×10⁹/L", pos: 62, status: "ok" },
    { name: "Creatinine", val: "0.8", unit: "mg/dL", pos: 48, status: "ok" },
    { name: "ALT", val: "62", unit: "U/L", pos: 78, status: "high" },
  ];

  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <button className="rh-iconbtn"><_IcoL d={isRTL ? _labsI.forward : _labsI.back}/></button>
          <h1 className="rh-page-title">{isRTL ? "نتائج التحاليل" : "Lab results"}</h1>
          <button className="rh-iconbtn"><_IcoL d={_labsI.more}/></button>
        </header>

        {/* Hero summary */}
        <div className="rh-hero rh-hero-tight">
          <div className="rh-hero-bloom"></div>
          <div className="rh-eyebrow rh-eyebrow-onhero">{isRTL ? "آخر سحب · ١٢ مايو" : "Last drawn · 12 May"}</div>
          <h2 className="rh-hero-h2" style={{ marginBottom: 12 }}>{isRTL ? "غالباً ضمن المعدل" : "Mostly in range"}</h2>
          <div style={{ display: "flex", gap: 8, position: "relative" }}>
            <div className="rh-summary-chip" style={{ background: "var(--sage-500)" }}>
              <span className="rh-summary-num">3</span>
              <span className="rh-summary-lbl">{isRTL ? "ضمن" : "in range"}</span>
            </div>
            <div className="rh-summary-chip" style={{ background: "var(--saffron-500)", color: "var(--sand-950)" }}>
              <span className="rh-summary-num" style={{ color: "var(--sand-950)" }}>1</span>
              <span className="rh-summary-lbl" style={{ color: "var(--saffron-700)" }}>{isRTL ? "منخفض" : "low"}</span>
            </div>
            <div className="rh-summary-chip" style={{ background: "var(--clay-500)" }}>
              <span className="rh-summary-num">1</span>
              <span className="rh-summary-lbl">{isRTL ? "مرتفع" : "high"}</span>
            </div>
          </div>
        </div>

        {/* AI summary */}
        <div className="rh-ai-summary">
          <div className="rh-ai-summary-head">
            <div className="rh-ai-sparkle"><_IcoL d={_labsI.spark} size={16}/></div>
            <div className="rh-eyebrow" style={{ color: "var(--teal-700)" }}>{isRTL ? "ملخّص رحلة" : "Rehlah summary"}</div>
          </div>
          <p>{isRTL
            ? "كريات الدم البيضاء انخفضت قليلاً — أمر شائع في هذه المرحلة من الدورة وضمن المتوقع لطبيبك."
            : "Your white-cell count dipped slightly — common at this point in the cycle and within what your team expects."}</p>
          <p>{isRTL
            ? "إنزيمات الكبد (ALT) ارتفعت قليلاً. يستحق ذكرها في موعد الخميس."
            : "Liver ALT is mildly elevated. Worth mentioning at Thursday's appointment."}</p>
        </div>

        {/* Metric list */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "النتائج" : "All metrics"}</span></div>

        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          {metrics.map((m, i) => (
            <div key={i} className="rh-lab-row">
              <span className="rh-lab-name">{m.name}</span>
              <div className="rh-lab-bar">
                <div className="rh-lab-marker" style={{ left: m.pos + "%" }}/>
              </div>
              <span className="rh-lab-val">{m.val}<span className="rh-lab-unit">{m.unit}</span></span>
            </div>
          ))}
        </div>

        <button className="rh-btn-secondary" style={{ width: "100%", marginTop: 12 }}>
          {isRTL ? "عرض السجل الكامل" : "View full history"}
        </button>
      </div>

      <_BNavL lang={lang} active="health"/>
    </div>
  );
}

// ============ Lab History ============
function LabHistoryScreen({ lang = "en" }) {
  const isRTL = lang === "ar";

  const entries = isRTL ? [
    { date: "١٢ مايو", panel: "تعداد دم شامل + وظائف كبد", status: "ok", note: "غالباً ضمن المعدل" },
    { date: "٢٨ أبريل", panel: "تعداد دم شامل", status: "warn", note: "كريات بيضاء منخفضة" },
    { date: "١٤ أبريل", panel: "تعداد دم شامل + كيمياء", status: "ok", note: "كل شيء سليم" },
    { date: "٢٨ مارس", panel: "ما قبل الجراحة", status: "ok", note: "موافق على الجراحة" },
    { date: "١٢ مارس", panel: "تحاليل التشخيص", status: "alert", note: "تأكيد التشخيص" },
  ] : [
    { date: "12 May", panel: "CBC + liver function", status: "ok", note: "Mostly in range" },
    { date: "28 Apr", panel: "CBC", status: "warn", note: "White cells low" },
    { date: "14 Apr", panel: "CBC + chemistry", status: "ok", note: "All clear" },
    { date: "28 Mar", panel: "Pre-surgery panel", status: "ok", note: "Cleared for surgery" },
    { date: "12 Mar", panel: "Diagnostic panel", status: "alert", note: "Diagnosis confirmed" },
  ];

  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <button className="rh-iconbtn"><_IcoL d={isRTL ? _labsI.forward : _labsI.back}/></button>
          <h1 className="rh-page-title">{isRTL ? "سجل التحاليل" : "Lab history"}</h1>
          <button className="rh-iconbtn"><_IcoL d={_labsI.plus}/></button>
        </header>

        <div className="rh-segctrl" style={{ alignSelf: "start" }}>
          <span className="rh-seg rh-seg-on">{isRTL ? "الكل" : "All"}</span>
          <span className="rh-seg">{isRTL ? "تعداد الدم" : "CBC"}</span>
          <span className="rh-seg">{isRTL ? "الكبد" : "Liver"}</span>
        </div>

        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "بالترتيب الزمني" : "Chronological"}</span></div>

        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          {entries.map((e, i) => (
            <div key={i} className="rh-tool-row">
              <div className="rh-tool-ic" style={{
                background: e.status === "ok" ? "var(--sage-100)" : e.status === "warn" ? "var(--saffron-100)" : "var(--clay-100)",
                color: e.status === "ok" ? "var(--sage-700)" : e.status === "warn" ? "var(--saffron-700)" : "var(--clay-700)",
                fontFamily: "ui-monospace, monospace", fontSize: 11, fontWeight: 700,
                lineHeight: 1, padding: 6,
              }}>
                {e.date.split(" ")[0]}
              </div>
              <div className="rh-tool-body">
                <div className="rh-tool-ttl">{e.panel}</div>
                <div className="rh-tool-sub">{e.date} · {e.note}</div>
              </div>
              <span className="rh-chev">{isRTL ? "‹" : "›"}</span>
            </div>
          ))}
        </div>
      </div>

      <_BNavL lang={lang} active="health"/>
    </div>
  );
}

// ============ Lab Add Form ============
function LabAddScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <button className="rh-iconbtn"><_IcoL d={isRTL ? _labsI.forward : _labsI.back}/></button>
          <h1 className="rh-page-title">{isRTL ? "إضافة نتيجة" : "Add result"}</h1>
          <span className="rh-section-cta">{isRTL ? "إلغاء" : "Cancel"}</span>
        </header>

        <p style={{ margin: 0, fontSize: 13, color: "var(--sand-700)", lineHeight: 1.5 }}>
          {isRTL
            ? "أدخلي تفاصيل التحليل يدوياً، أو ارفعي صورة وسنقرأها لكِ."
            : "Enter manually, or upload a photo and we'll read it for you."}
        </p>

        <button className="rh-btn-secondary" style={{ width: "100%" }}>
          <_IcoL d={<><rect x="3" y="5" width="18" height="14" rx="2"/><circle cx="12" cy="12" r="3"/><path d="M9 5l1-2h4l1 2"/></>} size={16}/>
          {isRTL ? "رفع صورة" : "Upload a photo"}
        </button>

        <div className="rh-section-head" style={{ marginInline: 0 }}>
          <span className="rh-eyebrow">{isRTL ? "أو املئي يدوياً" : "Or fill manually"}</span>
        </div>

        <div className="rh-field">
          <div className="rh-field-lbl">{isRTL ? "اسم اللوحة" : "Panel name"}</div>
          <div className="rh-field-val">{isRTL ? "تعداد دم شامل" : "Complete Blood Count"}</div>
        </div>

        <div className="rh-field">
          <div className="rh-field-lbl">{isRTL ? "التاريخ" : "Date"}</div>
          <div className="rh-field-val">{isRTL ? "١٧ مايو ٢٠٢٦" : "17 May 2026"}</div>
        </div>

        <div className="rh-row-2">
          <div className="rh-field">
            <div className="rh-field-lbl">{isRTL ? "الهيموجلوبين" : "Hemoglobin"}</div>
            <div className="rh-field-val" style={{ fontFamily: "ui-monospace, monospace" }}>{isRTL ? "١١٫٨" : "11.8"} <span style={{ fontSize: 11, color: "var(--sand-500)" }}>g/dL</span></div>
          </div>
          <div className="rh-field">
            <div className="rh-field-lbl">{isRTL ? "كريات بيضاء" : "WBC"}</div>
            <div className="rh-field-placeholder">{isRTL ? "أدخلي قيمة" : "Enter value"}</div>
          </div>
          <div className="rh-field">
            <div className="rh-field-lbl">{isRTL ? "الصفائح" : "Platelets"}</div>
            <div className="rh-field-placeholder">{isRTL ? "أدخلي قيمة" : "Enter value"}</div>
          </div>
          <div className="rh-field">
            <div className="rh-field-lbl">{isRTL ? "الكرياتينين" : "Creatinine"}</div>
            <div className="rh-field-placeholder">{isRTL ? "أدخلي قيمة" : "Enter value"}</div>
          </div>
        </div>

        <div className="rh-tool-row rh-tool-row-add">
          <div className="rh-tool-ic" style={{ background: "var(--teal-100)", color: "var(--teal-700)" }}>
            <_IcoL d={_labsI.plus} size={18}/>
          </div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "أضيفي قياساً آخر" : "Add another metric"}</div>
          </div>
        </div>

        <button className="rh-btn-primary" style={{ marginTop: 12 }}>{isRTL ? "حفظ النتيجة" : "Save result"}</button>
      </div>
    </div>
  );
}

// ============ Appointments ============
function AppointmentsScreen({ lang = "en" }) {
  const isRTL = lang === "ar";

  const upcoming = isRTL ? [
    { day: "٢١", mon: "مايو", title: "د. عائشة · الأورام", when: "الخميس · ١٠:٣٠", where: "مستشفى توام · الطابق ٣", primary: true },
    { day: "٠٤", mon: "يون", title: "تعداد دم شامل", when: "الجمعة · ٠٨:٠٠", where: "مختبر الفيصل" },
    { day: "١٢", mon: "يون", title: "د. عائشة · متابعة", when: "السبت · ١١:٠٠", where: "مستشفى توام" },
  ] : [
    { day: "21", mon: "MAY", title: "Dr. Aisha · Oncology", when: "Thursday · 10:30", where: "Tawam Hospital · Floor 3", primary: true },
    { day: "04", mon: "JUN", title: "Lab draw · CBC", when: "Friday · 08:00", where: "Al Faisal Lab" },
    { day: "12", mon: "JUN", title: "Dr. Aisha · follow-up", when: "Saturday · 11:00", where: "Tawam Hospital" },
  ];

  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <button className="rh-iconbtn"><_IcoL d={isRTL ? _labsI.forward : _labsI.back}/></button>
          <h1 className="rh-page-title">{isRTL ? "المواعيد" : "Appointments"}</h1>
          <button className="rh-iconbtn"><_IcoL d={_labsI.plus}/></button>
        </header>

        {/* Countdown hero */}
        <div className="rh-hero rh-hero-tight">
          <div className="rh-hero-bloom"></div>
          <div className="rh-eyebrow rh-eyebrow-onhero">{isRTL ? "الموعد القادم خلال" : "Next appointment in"}</div>
          <div style={{ display: "flex", alignItems: "baseline", gap: 8, marginTop: 6, position: "relative" }}>
            <span style={{ fontSize: 56, fontWeight: 700, color: "white", lineHeight: 1, letterSpacing: "-.02em", fontVariantNumeric: "tabular-nums" }}>
              {isRTL ? "٤" : "4"}
            </span>
            <span style={{ fontSize: 18, color: "rgba(255,255,255,.78)", fontWeight: 500 }}>{isRTL ? "أيام" : "days"}</span>
          </div>
          <div style={{ marginTop: 12, position: "relative", display: "flex", gap: 8, alignItems: "center" }}>
            <button className="rh-btn-warm rh-btn-sm">{isRTL ? "تجهيز بالذكاء" : "AI prep report"}</button>
            <span style={{ fontSize: 12, color: "rgba(255,255,255,.7)" }}>{isRTL ? "د. عائشة · الخميس" : "Dr. Aisha · Thu"}</span>
          </div>
        </div>

        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "قادمة" : "Upcoming"}</span></div>

        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          {upcoming.map((a, i) => (
            <div key={i} className="rh-appt" style={a.primary ? { borderColor: "var(--saffron-300)", boxShadow: "0 4px 14px rgba(212,162,88,.18)" } : {}}>
              <div className="rh-appt-date">
                <div className="rh-appt-day">{a.day}</div>
                <div className="rh-appt-mon">{a.mon}</div>
              </div>
              <div className="rh-appt-body">
                <div className="rh-appt-ttl">{a.title}</div>
                <div className="rh-appt-meta">{a.when} · {a.where}</div>
                {a.primary
                  ? <button className="rh-btn-ghost"><_IcoL d={_labsI.mapPin} size={14}/>{isRTL ? "الاتجاهات" : "Directions"}</button>
                  : <button className="rh-btn-ghost">{isRTL ? "التفاصيل" : "Details"}</button>}
              </div>
            </div>
          ))}
        </div>

        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "ماضية" : "Past"}</span></div>

        <div className="rh-tool-row" style={{ opacity: .65 }}>
          <div className="rh-tool-ic" style={{ background: "var(--sand-100)", color: "var(--sand-500)", fontFamily: "ui-monospace, monospace", fontWeight: 700, fontSize: 11 }}>
            12 May
          </div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "سحب دم" : "Lab draw"}</div>
            <div className="rh-tool-sub">{isRTL ? "مختبر الفيصل · ٠٨:٠٠" : "Al Faisal Lab · 08:00"}</div>
          </div>
          <span className="rh-pill rh-pill-pos"><span className="rh-dot"></span>{isRTL ? "تم" : "Done"}</span>
        </div>
      </div>

      <_BNavL lang={lang} active="health"/>
    </div>
  );
}

// ============ Prep Report ============
function PrepReportScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <button className="rh-iconbtn"><_IcoL d={isRTL ? _labsI.forward : _labsI.back}/></button>
          <h1 className="rh-page-title">{isRTL ? "تقرير التجهيز" : "Prep report"}</h1>
          <button className="rh-iconbtn"><_IcoL d={<><path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8"/><path d="M16 6l-4-4-4 4"/><path d="M12 2v14"/></>}/></button>
        </header>

        {/* AI hero */}
        <div className="rh-hero rh-hero-tight">
          <div className="rh-hero-bloom"></div>
          <div className="rh-ai-summary-head" style={{ position: "relative", margin: 0 }}>
            <div className="rh-ai-sparkle" style={{ background: "var(--saffron-500)", color: "var(--sand-950)" }}><_IcoL d={_labsI.spark} size={16}/></div>
            <div className="rh-eyebrow rh-eyebrow-onhero">{isRTL ? "جاهز لـ د. عائشة" : "Ready for Dr. Aisha"}</div>
          </div>
          <h2 className="rh-hero-h2" style={{ marginTop: 10, marginBottom: 8 }}>{isRTL ? "ملخص رحلتك حتى اليوم" : "Your journey, summarised"}</h2>
          <p style={{ fontSize: 12.5, color: "rgba(255,255,255,.78)", margin: 0, position: "relative", lineHeight: 1.5 }}>
            {isRTL
              ? "أُعِدّ بواسطة رحلة بناءً على تسجيلاتك وتحاليلك آخر ٣ أسابيع."
              : "Generated from your check-ins and labs over the past 3 weeks."}
          </p>
        </div>

        {/* Section: Going well */}
        <div className="rh-section-head"><span className="rh-eyebrow" style={{ color: "var(--sage-700)" }}>{isRTL ? "يسير جيداً" : "Going well"}</span></div>
        <div className="rh-tool-row" style={{ background: "var(--sage-100)", borderColor: "var(--sage-300)" }}>
          <div className="rh-tool-ic" style={{ background: "white", color: "var(--sage-700)" }}><_IcoL d={_labsI.check} size={16}/></div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "التزام الأدوية ٩٢٪" : "Medication adherence 92%"}</div>
            <div className="rh-tool-sub">{isRTL ? "أربع جرعات فقط فاتت في الدورة" : "Only 4 missed doses this cycle"}</div>
          </div>
        </div>
        <div className="rh-tool-row" style={{ background: "var(--sage-100)", borderColor: "var(--sage-300)" }}>
          <div className="rh-tool-ic" style={{ background: "white", color: "var(--sage-700)" }}><_IcoL d={_labsI.check} size={16}/></div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "المزاج مستقر" : "Mood is steady"}</div>
            <div className="rh-tool-sub">{isRTL ? "متوسط ٣٫٨ من ٥ على مدى ٢١ يوماً" : "Avg 3.8 of 5 over 21 days"}</div>
          </div>
        </div>

        {/* Section: Worth raising */}
        <div className="rh-section-head"><span className="rh-eyebrow" style={{ color: "var(--clay-700)" }}>{isRTL ? "يستحق الذكر" : "Worth raising"}</span></div>
        <div className="rh-tool-row" style={{ background: "var(--clay-100)", borderColor: "var(--clay-300)" }}>
          <div className="rh-tool-ic" style={{ background: "white", color: "var(--clay-700)" }}>!</div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "إنزيمات الكبد مرتفعة قليلاً" : "Liver ALT mildly elevated"}</div>
            <div className="rh-tool-sub">{isRTL ? "ALT ٦٢ مقابل ٤٥ الدورة السابقة" : "ALT 62 vs 45 last cycle"}</div>
          </div>
        </div>
        <div className="rh-tool-row" style={{ background: "var(--clay-100)", borderColor: "var(--clay-300)" }}>
          <div className="rh-tool-ic" style={{ background: "white", color: "var(--clay-700)" }}>!</div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "تنميل جديد في الأصابع" : "New tingling in fingertips"}</div>
            <div className="rh-tool-sub">{isRTL ? "ذُكر ٣ مرات منذ ٥ مايو" : "Reported 3 times since 5 May"}</div>
          </div>
        </div>

        {/* Questions to ask */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "أسئلة لطبيبك" : "Questions to ask"}</span></div>
        <div className="rh-tool-row">
          <div className="rh-tool-body">
            <div className="rh-tool-ttl" style={{ fontWeight: 400 }}>{isRTL ? "هل التنميل علامة على شيء يجب تعديله؟" : "Is the tingling something we should adjust for?"}</div>
          </div>
        </div>
        <div className="rh-tool-row">
          <div className="rh-tool-body">
            <div className="rh-tool-ttl" style={{ fontWeight: 400 }}>{isRTL ? "ماذا يعني ارتفاع ALT في هذه المرحلة؟" : "What does mildly raised ALT mean at this point?"}</div>
          </div>
        </div>

        <button className="rh-btn-primary" style={{ marginTop: 12 }}>{isRTL ? "إرسال للطبيب" : "Send to Dr. Aisha"}</button>
        <button className="rh-btn-secondary" style={{ width: "100%" }}>{isRTL ? "تنزيل PDF" : "Download as PDF"}</button>
      </div>
    </div>
  );
}

Object.assign(window, { LabResultsScreen, LabHistoryScreen, LabAddScreen, AppointmentsScreen, PrepReportScreen });
