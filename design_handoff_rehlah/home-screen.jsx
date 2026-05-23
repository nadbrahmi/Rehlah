// Rehlah Home screen v2 — applies the design-system tokens.
// Component receives `lang` ("en" | "ar") and renders the appropriate copy + direction.

const COPY = {
  en: {
    salaam: "Good morning",
    name: "Salma",
    phaseEyebrow: "Cycle 2 of 6",
    phaseTitle: "Recovery week · Day 7",
    phaseSub: "Nadir window expected in 3 days",
    phasePill: "Nadir soon",
    heroEyebrow: "Today's check-in",
    heroTitle: "How are you feeling?",
    heroSub: "Two minutes · helps your team know how to support you today.",
    heroCta: "Start check-in",
    medsLabel: "Medication",
    medsCaption: "6 of 8 doses today",
    vitalsLabel: "Vitals",
    vitalsValue: "38.9°",
    vitalsUnit: "max",
    vitalsCaption: "2h ago · slight fever",
    appointmentEyebrow: "Next appointment",
    appointmentTitle: "Dr. Aisha · Oncology",
    appointmentMeta: "Thursday 21 May · 10:30 · Tawam",
    appointmentCta: "Prep with AI",
    careTeamLabel: "Your care team",
    careTeamCta: "Manage",
    askEyebrow: "Ask Rehlah",
    askTitle: "What does my latest lab mean?",
    tabs: ["Today", "Health", "Connect", "Profile"],
  },
  ar: {
    salaam: "صباح الخير",
    name: "سلمى",
    phaseEyebrow: "الدورة ٢ من ٦",
    phaseTitle: "أسبوع التعافي · اليوم ٧",
    phaseSub: "أدنى نقطة متوقعة خلال ٣ أيام",
    phasePill: "اقتراب الحد الأدنى",
    heroEyebrow: "تسجيل اليوم",
    heroTitle: "كيف تشعرين اليوم؟",
    heroSub: "دقيقتان · لمساعدة فريقك على دعمك اليوم.",
    heroCta: "ابدئي التسجيل",
    medsLabel: "الأدوية",
    medsCaption: "٦ من ٨ جرعات اليوم",
    vitalsLabel: "العلامات الحيوية",
    vitalsValue: "٣٨٫٩°",
    vitalsUnit: "أقصى",
    vitalsCaption: "قبل ساعتين · حرارة طفيفة",
    appointmentEyebrow: "الموعد القادم",
    appointmentTitle: "د. عائشة · الأورام",
    appointmentMeta: "الخميس ٢١ مايو · ١٠:٣٠ · توام",
    appointmentCta: "تجهيز بالذكاء الاصطناعي",
    careTeamLabel: "فريق العناية",
    careTeamCta: "إدارة",
    askEyebrow: "اسأل رحلة",
    askTitle: "ماذا تعني نتائج تحاليلي الأخيرة؟",
    tabs: ["اليوم", "الصحة", "تواصل", "الملف"],
  },
};

// Tiny stroke icon set
const Ico = ({ path, size = 20 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{path}</svg>
);
const ICONS = {
  pill: <><path d="M4 7h16M6 7v12a2 2 0 002 2h8a2 2 0 002-2V7M9 7V5a3 3 0 016 0v2"/></>,
  thermo: <><path d="M14 4a2 2 0 10-4 0v10a4 4 0 104 0z"/></>,
  calendar: <><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 9h18M8 3v4M16 3v4"/></>,
  spark: <><path d="M12 3v3M12 18v3M3 12h3M18 12h3M5.6 5.6l2.1 2.1M16.3 16.3l2.1 2.1M5.6 18.4l2.1-2.1M16.3 7.7l2.1-2.1"/><circle cx="12" cy="12" r="3"/></>,
  arrow: <><path d="M5 12h14M13 6l6 6-6 6"/></>,
  arrowR: <><path d="M5 12h14M13 6l6 6-6 6"/></>,
  home: <><path d="M3 11l9-7 9 7v9a1 1 0 01-1 1h-5v-6h-6v6H4a1 1 0 01-1-1z"/></>,
  heart: <><path d="M12 21s-7-4.5-7-10a4 4 0 017-2.6A4 4 0 0119 11c0 5.5-7 10-7 10z"/></>,
  users: <><path d="M17 21v-2a4 4 0 00-4-4H7a4 4 0 00-4 4v2"/><circle cx="10" cy="7" r="4"/><path d="M21 11h-4M19 9v4"/></>,
  user: <><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0116 0"/></>,
  check: <><path d="M5 12l5 5 9-11"/></>,
};

function HomeScreen({ lang }) {
  const t = COPY[lang];
  const isRTL = lang === "ar";

  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        {/* Greeting */}
        <header className="rh-greet">
          <div>
            <div className="rh-hi">{t.salaam}</div>
            <div className="rh-name">{t.name}</div>
          </div>
          <div className="rh-avatar">{isRTL ? "س" : "S"}</div>
        </header>

        {/* Phase banner */}
        <div className="rh-phase">
          <div className="rh-phase-ic">2</div>
          <div className="rh-phase-body">
            <div className="rh-eyebrow rh-eyebrow-warm">{t.phaseEyebrow}</div>
            <div className="rh-phase-ttl">{t.phaseTitle}</div>
            <div className="rh-phase-sub">{t.phaseSub}</div>
          </div>
          <span className="rh-pill rh-pill-warn"><span className="rh-dot"></span>{t.phasePill}</span>
        </div>

        {/* Hero check-in */}
        <div className="rh-hero">
          <div className="rh-hero-bloom"></div>
          <div className="rh-eyebrow rh-eyebrow-onhero">{t.heroEyebrow}</div>
          <h2 className="rh-hero-ttl">{t.heroTitle}</h2>
          <p className="rh-hero-sub">{t.heroSub}</p>
          <button className="rh-btn-warm">
            {t.heroCta}
            <Ico path={ICONS.arrow} size={16} />
          </button>
        </div>

        {/* Meds + Vitals row */}
        <div className="rh-row-2">
          <div className="rh-card rh-tap">
            <div className="rh-card-head">
              <span className="rh-card-ic rh-ic-sage"><Ico path={ICONS.pill} size={16} /></span>
              <span className="rh-eyebrow">{t.medsLabel}</span>
            </div>
            <div className="rh-meds-body">
              <div className="rh-ring">
                <svg width="52" height="52">
                  <circle cx="26" cy="26" r="22" stroke="var(--sand-200)" strokeWidth="5" fill="none"/>
                  <circle cx="26" cy="26" r="22" stroke="var(--sage-500)" strokeWidth="5" fill="none"
                    strokeDasharray="138" strokeDashoffset="34.5" strokeLinecap="round"
                    transform="rotate(-90 26 26)"/>
                </svg>
                <div className="rh-ring-num">{isRTL ? "٦/٨" : "6/8"}</div>
              </div>
              <div className="rh-meds-meta">
                <div className="rh-num">75%</div>
                <div className="rh-card-sub">{t.medsCaption}</div>
              </div>
            </div>
          </div>

          <div className="rh-card rh-tap">
            <div className="rh-card-head">
              <span className="rh-card-ic rh-ic-clay"><Ico path={ICONS.thermo} size={16} /></span>
              <span className="rh-eyebrow">{t.vitalsLabel}</span>
            </div>
            <div className="rh-vitals-body">
              <div className="rh-num rh-num-lg">
                {t.vitalsValue}
                <span className="rh-num-unit">{t.vitalsUnit}</span>
              </div>
              <svg viewBox="0 0 100 30" className="rh-spark">
                <path d="M2,22 L18,20 L34,18 L50,16 L66,10 L82,6 L98,4"
                      fill="none" stroke="var(--clay-500)" strokeWidth="1.8"
                      strokeLinecap="round" strokeLinejoin="round"/>
                <circle cx="98" cy="4" r="2.4" fill="var(--clay-500)"/>
              </svg>
              <div className="rh-card-sub">{t.vitalsCaption}</div>
            </div>
          </div>
        </div>

        {/* Appointment */}
        <div className="rh-appt">
          <div className="rh-appt-date">
            <div className="rh-appt-day">{isRTL ? "٢١" : "21"}</div>
            <div className="rh-appt-mon">{isRTL ? "مايو" : "MAY"}</div>
          </div>
          <div className="rh-appt-body">
            <div className="rh-eyebrow">{t.appointmentEyebrow}</div>
            <div className="rh-appt-ttl">{t.appointmentTitle}</div>
            <div className="rh-appt-meta">{t.appointmentMeta}</div>
            <button className="rh-btn-ghost">
              <Ico path={ICONS.spark} size={14} />
              {t.appointmentCta}
            </button>
          </div>
        </div>

        {/* Ask Rehlah prompt */}
        <div className="rh-ask">
          <div className="rh-ask-ic"><Ico path={ICONS.spark} size={18}/></div>
          <div className="rh-ask-body">
            <div className="rh-eyebrow rh-eyebrow-onhero">{t.askEyebrow}</div>
            <div className="rh-ask-ttl">{t.askTitle}</div>
          </div>
          <Ico path={isRTL ? <path d="M19 12H5M11 6L5 12l6 6"/> : ICONS.arrow} size={18}/>
        </div>

        {/* Care team */}
        <div className="rh-team">
          <div className="rh-team-head">
            <span className="rh-eyebrow">{t.careTeamLabel}</span>
            <span className="rh-team-cta">{t.careTeamCta}</span>
          </div>
          <div className="rh-team-row">
            <div className="rh-av rh-av-saffron">{isRTL ? "ع" : "DA"}<span>{isRTL ? "د. عائشة" : "Dr. Aisha"}</span></div>
            <div className="rh-av rh-av-teal">{isRTL ? "ن" : "NM"}<span>{isRTL ? "نور" : "Nour"}</span></div>
            <div className="rh-av rh-av-clay">{isRTL ? "ف" : "FT"}<span>{isRTL ? "فاطمة" : "Fatima"}</span></div>
            <div className="rh-av rh-av-sage">{isRTL ? "ر" : "RH"}<span>{isRTL ? "ريم" : "Reem"}</span></div>
            <div className="rh-av rh-av-add">+<span>{isRTL ? "إضافة" : "Invite"}</span></div>
          </div>
        </div>

        <div style={{ height: 32 }}></div>
      </div>

      {/* Bottom nav */}
      <nav className="rh-nav-wrap">
        <div className="rh-nav">
          <div className="rh-tab rh-tab-on">
            <Ico path={ICONS.home} size={22}/>
            <span>{t.tabs[0]}</span>
          </div>
          <div className="rh-tab">
            <Ico path={ICONS.heart} size={22}/>
            <span>{t.tabs[1]}</span>
          </div>
          <div className="rh-tab rh-tab-spacer"></div>
          <div className="rh-tab">
            <Ico path={ICONS.users} size={22}/>
            <span>{t.tabs[2]}</span>
          </div>
          <div className="rh-tab">
            <Ico path={ICONS.user} size={22}/>
            <span>{t.tabs[3]}</span>
          </div>
          <div className="rh-fab" title="Check-in complete">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
              <path d="M5 12l5 5 9-11"/>
            </svg>
          </div>
        </div>
      </nav>
    </div>
  );
}

window.HomeScreen = HomeScreen;
