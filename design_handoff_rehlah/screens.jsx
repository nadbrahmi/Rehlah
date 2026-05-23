// Rehlah · Medications, Vitals, Care Hub screens
// All applying the v0.1 design-system tokens.

const Ico2 = ({ d, size = 20, sw = 1.8 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round">{d}</svg>
);

const I = {
  back: <path d="M15 18l-6-6 6-6"/>,
  forward: <path d="M9 18l6-6-6-6"/>,
  more: <><circle cx="5" cy="12" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="19" cy="12" r="1.5"/></>,
  plus: <><path d="M12 5v14M5 12h14"/></>,
  pill: <><path d="M4 7h16M6 7v12a2 2 0 002 2h8a2 2 0 002-2V7M9 7V5a3 3 0 016 0v2"/></>,
  thermo: <><path d="M14 4a2 2 0 10-4 0v10a4 4 0 104 0z"/></>,
  heart: <><path d="M3 12h4l3-7 4 14 3-7h4"/></>,
  drop: <><path d="M12 3l6 8a6 6 0 11-12 0l6-8z"/></>,
  walk: <><path d="M4 18l5-5 4 4 7-9"/></>,
  flask: <><path d="M9 3v6l-5 9a2 2 0 002 3h12a2 2 0 002-3l-5-9V3M9 3h6M7 14h10"/></>,
  cal: <><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 9h18M8 3v4M16 3v4"/></>,
  vit: <><path d="M12 2v6m0 0l-3-3m3 3l3-3"/><path d="M5 13a7 7 0 0014 0"/></>,
  book: <><path d="M4 5a2 2 0 012-2h11v18H6a2 2 0 01-2-2V5z"/><path d="M9 7h6M9 11h6"/></>,
  spark: <><path d="M12 3v3M12 18v3M3 12h3M18 12h3M5.6 5.6l2.1 2.1M16.3 16.3l2.1 2.1M5.6 18.4l2.1-2.1M16.3 7.7l2.1-2.1"/><circle cx="12" cy="12" r="3"/></>,
  home: <path d="M3 11l9-7 9 7v9a1 1 0 01-1 1h-5v-6h-6v6H4a1 1 0 01-1-1z"/>,
  hrt: <path d="M12 21s-7-4.5-7-10a4 4 0 017-2.6A4 4 0 0119 11c0 5.5-7 10-7 10z"/>,
  users: <><path d="M17 21v-2a4 4 0 00-4-4H7a4 4 0 00-4 4v2"/><circle cx="10" cy="7" r="4"/></>,
  user: <><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0116 0"/></>,
  check: <path d="M5 12l5 5 9-11"/>,
};

// Shared topbar
function TopBar({ title, lang }) {
  const isRTL = lang === "ar";
  return (
    <header className="rh-topbar">
      <button className="rh-iconbtn">
        <Ico2 d={isRTL ? I.forward : I.back} size={20}/>
      </button>
      <h1 className="rh-page-title">{title}</h1>
      <button className="rh-iconbtn"><Ico2 d={I.more} size={20}/></button>
    </header>
  );
}

// Shared bottom nav
function BottomNav({ active = "care", lang, complete = true }) {
  const tabs = lang === "ar"
    ? ["اليوم", "الصحة", "تواصل", "الملف"]
    : ["Today", "Health", "Connect", "Profile"];
  const map = { home: 0, health: 1, connect: 2, profile: 3 };
  return (
    <nav className="rh-nav-wrap">
      <div className="rh-nav">
        <div className={"rh-tab" + (active === "home" ? " rh-tab-on" : "")}><Ico2 d={I.home} size={22}/><span>{tabs[0]}</span></div>
        <div className={"rh-tab" + (active === "health" ? " rh-tab-on" : "")}><Ico2 d={I.hrt} size={22}/><span>{tabs[1]}</span></div>
        <div className="rh-tab rh-tab-spacer"></div>
        <div className={"rh-tab" + (active === "connect" ? " rh-tab-on" : "")}><Ico2 d={I.users} size={22}/><span>{tabs[2]}</span></div>
        <div className={"rh-tab" + (active === "profile" ? " rh-tab-on" : "")}><Ico2 d={I.user} size={22}/><span>{tabs[3]}</span></div>
        <div className={"rh-fab" + (complete ? " rh-fab-done" : "")}>
          {complete
            ? <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12l5 5 9-11"/></svg>
            : <Ico2 d={I.plus} size={22} sw={2.4}/>
          }
        </div>
      </div>
    </nav>
  );
}

// =================== MEDICATIONS ===================
function MedicationsScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <TopBar lang={lang} title={isRTL ? "الأدوية" : "Medications"} />

        {/* Adherence hero */}
        <div className="rh-hero rh-hero-tight">
          <div className="rh-hero-bloom"></div>
          <div className="rh-adh">
            <div className="rh-ring rh-ring-lg">
              <svg width="100" height="100">
                <circle cx="50" cy="50" r="42" stroke="rgba(255,255,255,.18)" strokeWidth="8" fill="none"/>
                <circle cx="50" cy="50" r="42" stroke="var(--saffron-500)" strokeWidth="8" fill="none"
                  strokeDasharray="263.9" strokeDashoffset="65.97" strokeLinecap="round"
                  transform="rotate(-90 50 50)"/>
              </svg>
              <div className="rh-ring-stack">
                <div className="rh-ring-pct">75%</div>
                <div className="rh-ring-cap">{isRTL ? "اليوم" : "today"}</div>
              </div>
            </div>
            <div className="rh-adh-meta">
              <div className="rh-eyebrow rh-eyebrow-onhero">{isRTL ? "الالتزام" : "Adherence"}</div>
              <div className="rh-adh-big">{isRTL ? "٦ من ٨" : "6 of 8"}</div>
              <div className="rh-adh-sub">{isRTL ? "جرعتان متبقيتان اليوم" : "Two doses remaining today"}</div>
            </div>
          </div>
        </div>

        {/* Day label */}
        <div className="rh-section-head">
          <span className="rh-eyebrow">{isRTL ? "اليوم · ١٧ مايو" : "Today · 17 May"}</span>
          <span className="rh-section-cta">{isRTL ? "اعرض الأسبوع" : "View week"}</span>
        </div>

        {/* Timeline */}
        <div className="rh-timeline">
          <div className="rh-tl-item rh-tl-taken">
            <div className="rh-tl-time">08:00</div>
            <div className="rh-tl-card">
              <div className="rh-tl-card-body">
                <div className="rh-tl-name">{isRTL ? "أناستروزول" : "Anastrozole"}</div>
                <div className="rh-tl-dose">1 mg · {isRTL ? "مع الطعام" : "with food"}</div>
              </div>
              <span className="rh-pill rh-pill-pos"><span className="rh-dot"></span>{isRTL ? "تم" : "Taken 08:04"}</span>
            </div>
          </div>

          <div className="rh-tl-item rh-tl-taken">
            <div className="rh-tl-time">09:00</div>
            <div className="rh-tl-card">
              <div className="rh-tl-card-body">
                <div className="rh-tl-name">{isRTL ? "أوميبرازول" : "Omeprazole"}</div>
                <div className="rh-tl-dose">20 mg</div>
              </div>
              <span className="rh-pill rh-pill-pos"><span className="rh-dot"></span>{isRTL ? "تم" : "Taken 09:02"}</span>
            </div>
          </div>

          <div className="rh-tl-item rh-tl-missed">
            <div className="rh-tl-time">13:00</div>
            <div className="rh-tl-card">
              <div className="rh-tl-card-body">
                <div className="rh-tl-name">{isRTL ? "أوندانسيترون" : "Ondansetron"}</div>
                <div className="rh-tl-dose">8 mg · {isRTL ? "للغثيان" : "as needed"}</div>
              </div>
              <span className="rh-pill rh-pill-alert"><span className="rh-dot"></span>{isRTL ? "فائتة" : "Missed"}</span>
            </div>
          </div>

          <div className="rh-tl-item rh-tl-next">
            <div className="rh-tl-time">17:00</div>
            <div className="rh-tl-card rh-tl-card-active">
              <div className="rh-tl-card-body">
                <div className="rh-tl-name">{isRTL ? "كابيسيتابين" : "Capecitabine"}</div>
                <div className="rh-tl-dose">1500 mg · {isRTL ? "خلال ٤٥ دقيقة" : "in 45 min"}</div>
              </div>
              <button className="rh-btn-warm rh-btn-sm">{isRTL ? "خذي الآن" : "Take now"}</button>
            </div>
          </div>

          <div className="rh-tl-item">
            <div className="rh-tl-time">22:00</div>
            <div className="rh-tl-card">
              <div className="rh-tl-card-body">
                <div className="rh-tl-name">{isRTL ? "كابيسيتابين" : "Capecitabine"}</div>
                <div className="rh-tl-dose">1500 mg</div>
              </div>
              <span className="rh-pill rh-pill-neutral"><span className="rh-dot"></span>{isRTL ? "مجدولة" : "Scheduled"}</span>
            </div>
          </div>
        </div>

        {/* Add medication tile */}
        <div className="rh-tool-row rh-tool-row-add">
          <span className="rh-tool-ic" style={{ background: "var(--teal-100)", color: "var(--teal-700)" }}>
            <Ico2 d={I.plus} size={18}/>
          </span>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "أضيفي دواءً" : "Add a medication"}</div>
            <div className="rh-tool-sub">{isRTL ? "أو دعي ممرضتك تضيفه" : "Or have your nurse add it for you"}</div>
          </div>
          <span className="rh-chev">{isRTL ? "‹" : "›"}</span>
        </div>
      </div>

      <BottomNav active="care" lang={lang} complete={true}/>
    </div>
  );
}

// =================== VITALS ===================
function VitalsScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <TopBar lang={lang} title={isRTL ? "العلامات الحيوية" : "Vitals"} />

        {/* Nadir banner (cycle-aware) */}
        <div className="rh-phase rh-phase-alert">
          <div className="rh-phase-ic" style={{ background: "var(--clay-500)", color: "white" }}>!</div>
          <div className="rh-phase-body">
            <div className="rh-eyebrow" style={{ color: "var(--clay-700)" }}>{isRTL ? "نافذة الحد الأدنى" : "Nadir window"}</div>
            <div className="rh-phase-ttl">{isRTL ? "سجلي درجة حرارتك مرتين اليوم" : "Log your temperature twice today"}</div>
            <div className="rh-phase-sub">{isRTL ? "خطر العدوى يرتفع أيام ٧–١٠" : "Infection risk peaks days 7–10"}</div>
          </div>
        </div>

        {/* Temperature hero */}
        <div className="rh-hero rh-hero-tight">
          <div className="rh-hero-bloom"></div>
          <div className="rh-eyebrow rh-eyebrow-onhero">{isRTL ? "أقصى حرارة اليوم" : "My maximum today"}</div>
          <div className="rh-vital-hero-row">
            <div className="rh-vital-stat">
              <span className="rh-vital-num">{isRTL ? "٣٨٫٩" : "38.9"}</span>
              <span className="rh-vital-unit">°C</span>
            </div>
            <span className="rh-pill rh-pill-warn" style={{ height: 26, fontSize: 12 }}>
              <span className="rh-dot"></span>{isRTL ? "حرارة طفيفة" : "Slight fever"}
            </span>
          </div>
          <div className="rh-vital-when">{isRTL ? "سُجّلت ١٤:٠٨ · قبل ساعتين" : "Recorded 14:08 · 2 hours ago"}</div>
        </div>

        {/* Trend chart card */}
        <div className="rh-card-plain">
          <div className="rh-chart-head">
            <span className="rh-eyebrow">{isRTL ? "آخر ٧ أيام" : "Last 7 days"}</span>
            <div className="rh-segctrl">
              <span className="rh-seg rh-seg-on">{isRTL ? "يوم" : "Day"}</span>
              <span className="rh-seg">{isRTL ? "أسبوع" : "Week"}</span>
              <span className="rh-seg">{isRTL ? "دورة" : "Cycle"}</span>
            </div>
          </div>
          <svg viewBox="0 0 320 130" className="rh-chart">
            <defs>
              <linearGradient id="vchart-fill" x1="0" x2="0" y1="0" y2="1">
                <stop offset="0" stopColor="oklch(.380 .060 195)" stopOpacity=".22"/>
                <stop offset="1" stopColor="oklch(.380 .060 195)" stopOpacity="0"/>
              </linearGradient>
            </defs>
            {/* y-axis hints */}
            <line x1="0" y1="35" x2="320" y2="35" stroke="var(--sand-200)" strokeDasharray="2 4"/>
            <line x1="0" y1="80" x2="320" y2="80" stroke="var(--sand-200)" strokeDasharray="2 4"/>
            <text x="6" y="32" fontSize="9" fill="var(--sand-500)" fontFamily="ui-monospace">38.5°</text>
            <text x="6" y="77" fontSize="9" fill="var(--sand-500)" fontFamily="ui-monospace">37.0°</text>

            <path d="M20,90 L65,86 L110,82 L155,75 L200,55 L245,42 L290,28"
                  fill="none" stroke="var(--teal-700)" strokeWidth="2.4"
                  strokeLinecap="round" strokeLinejoin="round"/>
            <path d="M20,90 L65,86 L110,82 L155,75 L200,55 L245,42 L290,28 L290,130 L20,130 Z"
                  fill="url(#vchart-fill)"/>
            {[[20,90],[65,86],[110,82],[155,75],[200,55],[245,42],[290,28]].map(([x,y],i)=>(
              <circle key={i} cx={x} cy={y} r={i===6?6:3} fill={i===6?"var(--teal-700)":"var(--surface)"} stroke="var(--teal-700)" strokeWidth="2"/>
            ))}
            <text x="290" y="18" fontSize="11" fill="var(--sand-900)" fontWeight="700" textAnchor="middle" fontFamily="Tajawal">38.9°</text>
          </svg>
          <div className="rh-chart-x">
            {(isRTL ? ["خ","ج","س","ح","ن","ث","أ"] : ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]).map((d,i)=>(
              <span key={i} className={i===6 ? "rh-chart-x-on" : ""}>{d}</span>
            ))}
          </div>
        </div>

        {/* Other vitals */}
        <div className="rh-row-2">
          <div className="rh-metric">
            <span className="rh-metric-ic" style={{ background: "var(--sky-100)", color: "var(--sky-500)" }}>
              <Ico2 d={I.heart} size={16}/>
            </span>
            <div>
              <div className="rh-metric-label">{isRTL ? "النبض" : "Heart rate"}</div>
              <div className="rh-metric-val">{isRTL ? "٨٢" : "82"} <span>bpm</span></div>
              <div className="rh-metric-when">{isRTL ? "قبل ساعتين" : "2h ago"}</div>
            </div>
          </div>
          <div className="rh-metric">
            <span className="rh-metric-ic" style={{ background: "var(--sage-100)", color: "var(--sage-700)" }}>
              <Ico2 d={I.drop} size={16}/>
            </span>
            <div>
              <div className="rh-metric-label">{isRTL ? "الأكسجين" : "Oxygen"}</div>
              <div className="rh-metric-val">{isRTL ? "٩٨" : "98"}<span>%</span></div>
              <div className="rh-metric-when">{isRTL ? "قبل ساعتين" : "2h ago"}</div>
            </div>
          </div>
        </div>

        <button className="rh-btn-warm rh-btn-block">
          <Ico2 d={I.plus} size={16}/>
          {isRTL ? "سجّلي الحرارة" : "Record temperature"}
        </button>
      </div>

      <BottomNav active="health" lang={lang} complete={true}/>
    </div>
  );
}

// =================== CARE HUB ===================
function CareHubScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <div style={{ width: 36 }}></div>
          <h1 className="rh-page-title">{isRTL ? "مركز العناية" : "Care"}</h1>
          <button className="rh-iconbtn"><Ico2 d={I.more} size={20}/></button>
        </header>

        {/* Today summary hero */}
        <div className="rh-hero rh-hero-tight">
          <div className="rh-hero-bloom"></div>
          <div className="rh-eyebrow rh-eyebrow-onhero">{isRTL ? "اليوم" : "Today"}</div>
          <h2 className="rh-hero-h2">{isRTL ? "ثلاث مهام في انتظارك" : "Three things on your plate"}</h2>
          <div className="rh-summary-row">
            <div className="rh-summary-chip">
              <span className="rh-summary-num">2</span>
              <span className="rh-summary-lbl">{isRTL ? "جرعتان" : "doses"}</span>
            </div>
            <div className="rh-summary-chip">
              <span className="rh-summary-num">1</span>
              <span className="rh-summary-lbl">{isRTL ? "فحص حرارة" : "temp log"}</span>
            </div>
            <div className="rh-summary-chip">
              <span className="rh-summary-num">1</span>
              <span className="rh-summary-lbl">{isRTL ? "تسجيل" : "check-in"}</span>
            </div>
          </div>
        </div>

        {/* Section: Track */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "تتبّعي" : "Track"}</span></div>

        <div className="rh-tool-row">
          <span className="rh-tool-ic" style={{ background: "var(--sage-100)", color: "var(--sage-700)" }}>
            <Ico2 d={I.pill} size={18}/>
          </span>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "الأدوية" : "Medications"}</div>
            <div className="rh-tool-sub">{isRTL ? "٦ من ٨ جرعات اليوم" : "6 of 8 doses today"}</div>
          </div>
          <span className="rh-pill rh-pill-warn"><span className="rh-dot"></span>{isRTL ? "جرعة قريبة" : "Due soon"}</span>
        </div>

        <div className="rh-tool-row">
          <span className="rh-tool-ic" style={{ background: "var(--clay-100)", color: "var(--clay-700)" }}>
            <Ico2 d={I.thermo} size={18}/>
          </span>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "العلامات الحيوية" : "Vitals"}</div>
            <div className="rh-tool-sub">{isRTL ? "أقصى ٣٨٫٩° · قبل ساعتين" : "Max 38.9° · 2h ago"}</div>
          </div>
          <span className="rh-chev">{isRTL ? "‹" : "›"}</span>
        </div>

        <div className="rh-tool-row">
          <span className="rh-tool-ic" style={{ background: "var(--saffron-100)", color: "var(--saffron-700)" }}>
            <Ico2 d={I.book} size={18}/>
          </span>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "اليوميات" : "Journal"}</div>
            <div className="rh-tool-sub">{isRTL ? "آخر تدوينة قبل يومين" : "Last entry 2 days ago"}</div>
          </div>
          <span className="rh-chev">{isRTL ? "‹" : "›"}</span>
        </div>

        {/* Section: Records */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "السجلات" : "Records"}</span></div>

        <div className="rh-tool-row">
          <span className="rh-tool-ic" style={{ background: "var(--teal-100)", color: "var(--teal-700)" }}>
            <Ico2 d={I.flask} size={18}/>
          </span>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "نتائج التحاليل" : "Lab results"}</div>
            <div className="rh-tool-sub">{isRTL ? "آخر سحب ١٢ مايو" : "Last drawn 12 May"}</div>
          </div>
          <span className="rh-pill rh-pill-pos"><span className="rh-dot"></span>{isRTL ? "ضمن المعدل" : "In range"}</span>
        </div>

        <div className="rh-tool-row">
          <span className="rh-tool-ic" style={{ background: "var(--sky-100)", color: "var(--sky-500)" }}>
            <Ico2 d={I.cal} size={18}/>
          </span>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "المواعيد" : "Appointments"}</div>
            <div className="rh-tool-sub">{isRTL ? "د. عائشة · خلال ٤ أيام" : "Dr. Aisha · in 4 days"}</div>
          </div>
          <span className="rh-chev">{isRTL ? "‹" : "›"}</span>
        </div>

        {/* AI prep CTA */}
        <div className="rh-ask">
          <div className="rh-ask-ic"><Ico2 d={I.spark} size={18}/></div>
          <div className="rh-ask-body">
            <div className="rh-eyebrow" style={{ color: "var(--teal-700)" }}>{isRTL ? "تجهيز بالذكاء الاصطناعي" : "AI prep report"}</div>
            <div className="rh-ask-ttl">{isRTL ? "ملخص لطبيبك للموعد القادم" : "A briefing for your doctor"}</div>
          </div>
          <Ico2 d={isRTL ? I.back : I.forward} size={18}/>
        </div>
      </div>

      <BottomNav active="health" lang={lang} complete={true}/>
    </div>
  );
}

Object.assign(window, { MedicationsScreen, VitalsScreen, CareHubScreen });
