// Rehlah · Health journey screens — Journey, Expect, Cycle Tracker

function _IcoJ({ d, size = 20 }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{d}</svg>;
}
const _journeyI = {
  back: <path d="M15 18l-6-6 6-6"/>,
  forward: <path d="M9 18l6-6-6-6"/>,
  more: <><circle cx="5" cy="12" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="19" cy="12" r="1.5"/></>,
  plus: <><path d="M12 5v14M5 12h14"/></>,
  check: <path d="M5 12l5 5 9-11"/>,
};

function _BottomNavJ({ lang, active = "health" }) {
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
          : <div key={i} className={"rh-tab" + (active === map[i] ? " rh-tab-on" : "")}><_IcoJ d={ic}/><span>{tabs[i > 2 ? i - 1 : i]}</span></div>
        )}
        <div className="rh-fab rh-fab-done">
          <_IcoJ d={_journeyI.check} size={22}/>
        </div>
      </div>
    </nav>
  );
}

// ============ My Health — Journey ============
function JourneyScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <button className="rh-iconbtn"><_IcoJ d={isRTL ? _journeyI.forward : _journeyI.back}/></button>
          <h1 className="rh-page-title">{isRTL ? "رحلتك" : "Your journey"}</h1>
          <button className="rh-iconbtn"><_IcoJ d={_journeyI.more}/></button>
        </header>

        {/* Phase hero */}
        <div className="rh-hero rh-hero-tight">
          <div className="rh-hero-bloom"></div>
          <div className="rh-eyebrow rh-eyebrow-onhero">{isRTL ? "أنتِ الآن في" : "You are in"}</div>
          <h2 className="rh-hero-h2" style={{ marginBottom: 10 }}>{isRTL ? "العلاج الكيميائي · الدورة ٢ من ٦" : "Chemotherapy · Cycle 2 of 6"}</h2>
          <div className="rh-j-cycles" style={{ position: "relative" }}>
            <span className="rh-j-cycle done">1</span>
            <span className="rh-j-cycle on">2</span>
            <span className="rh-j-cycle">3</span>
            <span className="rh-j-cycle">4</span>
            <span className="rh-j-cycle">5</span>
            <span className="rh-j-cycle">6</span>
            <span style={{ marginInlineStart: 4, fontSize: 11, alignSelf: "center", color: "rgba(255,255,255,.7)" }}>
              {isRTL ? "تتبقى ٤ دورات" : "4 to go"}
            </span>
          </div>
        </div>

        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "خطّ الرحلة" : "Treatment path"}</span></div>

        {/* Journey timeline */}
        <div className="rh-journey">
          <div className="rh-j-item rh-j-done">
            <div className="rh-j-card">
              <div className="rh-j-eyebrow">{isRTL ? "اكتمل · ١٢ مارس" : "Complete · 12 Mar"}</div>
              <div className="rh-j-ttl">{isRTL ? "التشخيص والمرحلة" : "Diagnosis & staging"}</div>
              <div className="rh-j-sub">{isRTL ? "أوضح الطبيب الخطة وراجع التحاليل والصور" : "Diagnosis confirmed, staging scans reviewed"}</div>
            </div>
          </div>
          <div className="rh-j-item rh-j-done">
            <div className="rh-j-card">
              <div className="rh-j-eyebrow">{isRTL ? "اكتمل · ٢٨ مارس" : "Complete · 28 Mar"}</div>
              <div className="rh-j-ttl">{isRTL ? "الجراحة" : "Surgery"}</div>
              <div className="rh-j-sub">{isRTL ? "تعافٍ سلس على مدى أسبوعين" : "Smooth recovery over 14 days"}</div>
            </div>
          </div>
          <div className="rh-j-item rh-j-now rh-j-current">
            <div className="rh-j-card">
              <div className="rh-j-eyebrow">{isRTL ? "أنتِ هنا · الدورة ٢" : "You are here · Cycle 2"}</div>
              <div className="rh-j-ttl">{isRTL ? "العلاج الكيميائي · ٦ دورات" : "Chemotherapy · 6 cycles"}</div>
              <div className="rh-j-sub">{isRTL ? "بدأت ١٢ أبريل · المتوقع الانتهاء ٢٠ أغسطس" : "Started 12 Apr · expected end 20 Aug"}</div>
              <div style={{ display: "flex", gap: 6, marginTop: 10 }}>
                <span className="rh-pill rh-pill-warn"><span className="rh-dot"></span>{isRTL ? "اقتراب الحد الأدنى" : "Nadir soon"}</span>
                <span className="rh-pill rh-pill-pos"><span className="rh-dot"></span>{isRTL ? "تحاليل ضمن المعدل" : "Labs in range"}</span>
              </div>
            </div>
          </div>
          <div className="rh-j-item">
            <div className="rh-j-card">
              <div className="rh-j-eyebrow">{isRTL ? "قادمة · سبتمبر" : "Upcoming · September"}</div>
              <div className="rh-j-ttl">{isRTL ? "العلاج الإشعاعي" : "Radiation therapy"}</div>
              <div className="rh-j-sub">{isRTL ? "٢٠ جلسة على مدى ٤ أسابيع" : "20 sessions over 4 weeks"}</div>
            </div>
          </div>
          <div className="rh-j-item">
            <div className="rh-j-card">
              <div className="rh-j-eyebrow">{isRTL ? "قادمة · ٢٠٢٧" : "Upcoming · 2027"}</div>
              <div className="rh-j-ttl">{isRTL ? "المتابعة طويلة المدى" : "Long-term follow-up"}</div>
              <div className="rh-j-sub">{isRTL ? "زيارات كل ٣ أشهر للسنة الأولى" : "Every 3 months for the first year"}</div>
            </div>
          </div>
        </div>
      </div>

      <_BottomNavJ lang={lang} active="health"/>
    </div>
  );
}

// ============ My Health — Expect ============
function ExpectScreen({ lang = "en" }) {
  const isRTL = lang === "ar";

  const upcoming = isRTL ? [
    ["إرهاق", "high", "أيام ٤–١٠ من الدورة"],
    ["غثيان", "med", "خلال ٤٨ ساعة من الجرعة"],
    ["تساقط شعر", "med", "بدأ في الدورة الأخيرة"],
    ["تنميل أطراف", "low", "تراكمي · راقبيه"],
    ["قرح فموية", "low", "أقل احتمالاً معكِ"],
  ] : [
    ["Fatigue", "high", "Days 4–10 of cycle"],
    ["Nausea", "med", "Within 48h of dose"],
    ["Hair thinning", "med", "Started last cycle"],
    ["Tingling in fingers", "low", "Cumulative — track it"],
    ["Mouth sores", "low", "Less likely for you"],
  ];

  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <button className="rh-iconbtn"><_IcoJ d={isRTL ? _journeyI.forward : _journeyI.back}/></button>
          <h1 className="rh-page-title">{isRTL ? "ما المتوقع" : "What to expect"}</h1>
          <button className="rh-iconbtn"><_IcoJ d={_journeyI.more}/></button>
        </header>

        {/* Day strip */}
        <div>
          <div className="rh-section-head" style={{ marginInline: 0 }}>
            <span className="rh-eyebrow">{isRTL ? "الدورة ٢ · هذه الأيام" : "Cycle 2 · these days"}</span>
            <span className="rh-section-cta">{isRTL ? "الدورة كاملة" : "View cycle"}</span>
          </div>
          <div className="rh-day-strip" style={{ marginTop: 8 }}>
            {[
              { d: isRTL ? "س" : "S", n: 5 },
              { d: isRTL ? "ح" : "M", n: 6 },
              { d: isRTL ? "ن" : "T", n: 7, today: true },
              { d: isRTL ? "ث" : "W", n: 8, nadir: true },
              { d: isRTL ? "أ" : "T", n: 9, nadir: true },
              { d: isRTL ? "خ" : "F", n: 10, nadir: true },
              { d: isRTL ? "ج" : "S", n: 11 },
            ].map((c, i) => (
              <div key={i} className={"rh-day-cell" + (c.today ? " today" : c.nadir ? " nadir" : "")}>
                <span className="d">{c.d}</span>
                <span className="n">{isRTL ? ["٠","١","٢","٣","٤","٥","٦","٧","٨","٩","١٠","١١"][c.n] : c.n}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Forecast hero */}
        <div className="rh-hero rh-hero-tight rh-hero-plum">
          <div className="rh-hero-bloom"></div>
          <div className="rh-eyebrow rh-eyebrow-onhero">{isRTL ? "هذه الأيام" : "These days"}</div>
          <h2 className="rh-hero-h2" style={{ marginBottom: 6 }}>{isRTL ? "نتوقع تعباً أكثر — والباقي يهدأ" : "Expect more fatigue — and the rest eases"}</h2>
          <p style={{ fontSize: 12.5, color: "rgba(255,255,255,.78)", margin: 0, position: "relative", lineHeight: 1.5 }}>
            {isRTL
              ? "أنتِ بين أيام ٧–١٠ من الدورة. مناعتك في أدنى نقطة. ابتعدي عن الازدحام، اشربي ماءً كثيراً، ونامي مبكراً."
              : "You are in days 7–10. White-cell counts are at their lowest. Skip crowds, hydrate well, sleep early."}
          </p>
        </div>

        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "أعراض محتملة هذه الدورة" : "Likely this cycle"}</span></div>

        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          {upcoming.map(([n, level, when], i) => (
            <div key={i} className="rh-se-row">
              <div className="rh-se-bar-wrap">
                <div className="rh-se-name">{n}</div>
                <div className="rh-se-bar">
                  <div className={"rh-se-bar-fill " + level} style={{ width: level === "high" ? "82%" : level === "med" ? "54%" : "22%" }}/>
                </div>
                <div className="rh-se-likelihood">{when}</div>
              </div>
              <span className={"rh-pill " + (level === "high" ? "rh-pill-alert" : level === "med" ? "rh-pill-warn" : "rh-pill-neutral")}>
                {level === "high" ? (isRTL ? "مرجح" : "Likely") : level === "med" ? (isRTL ? "محتمل" : "Possible") : (isRTL ? "أقل" : "Less likely")}
              </span>
            </div>
          ))}
        </div>

        <div className="rh-ask">
          <div className="rh-ask-ic" style={{ background: "var(--plum-500)" }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="1.8"><circle cx="12" cy="12" r="3"/><path d="M12 2v3M12 19v3M3 12h3M18 12h3"/></svg>
          </div>
          <div className="rh-ask-body">
            <div className="rh-eyebrow" style={{ color: "var(--plum-700)" }}>{isRTL ? "اسألي رحلة" : "Ask Rehlah"}</div>
            <div className="rh-ask-ttl">{isRTL ? "متى يجب أن أتصل بفريقي؟" : "When should I call my team?"}</div>
          </div>
          <_IcoJ d={isRTL ? _journeyI.back : _journeyI.forward}/>
        </div>
      </div>

      <_BottomNavJ lang={lang} active="health"/>
    </div>
  );
}

// ============ Cycle Tracker ============
function CycleTrackerScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  // Build calendar grid for May (sample): starts Thu, 31 days. We'll do a 5x7 grid.
  const days = [];
  for (let i = -2; i <= 32; i++) days.push(i);
  // States: cycle days 1-14 = saffron, today = May 17 (day index 17), nadir 19-22
  const cycleStart = 11; // May 11 → day 1
  const todayDate = 17;
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <button className="rh-iconbtn"><_IcoJ d={isRTL ? _journeyI.forward : _journeyI.back}/></button>
          <h1 className="rh-page-title">{isRTL ? "تتبع الدورة" : "Cycle tracker"}</h1>
          <button className="rh-iconbtn"><_IcoJ d={_journeyI.more}/></button>
        </header>

        {/* Cycle info phase */}
        <div className="rh-phase">
          <div className="rh-phase-ic">{isRTL ? "٢" : "2"}</div>
          <div className="rh-phase-body">
            <div className="rh-eyebrow rh-eyebrow-warm">{isRTL ? "الدورة ٢ · اليوم ٧" : "Cycle 2 · Day 7"}</div>
            <div className="rh-phase-ttl">{isRTL ? "أسبوع التعافي بدأ" : "Recovery week starting"}</div>
            <div className="rh-phase-sub">{isRTL ? "تبقى ١٤ يوماً للدورة القادمة" : "14 days until next cycle"}</div>
          </div>
        </div>

        {/* Calendar */}
        <div className="rh-cal">
          <div className="rh-cal-head">
            <div className="rh-cal-nav" style={{ display: "inline-flex" }}>
              <button><_IcoJ d={isRTL ? _journeyI.forward : _journeyI.back} size={14}/></button>
            </div>
            <div className="rh-cal-month">{isRTL ? "مايو ٢٠٢٦" : "May 2026"}</div>
            <div className="rh-cal-nav" style={{ display: "inline-flex" }}>
              <button><_IcoJ d={isRTL ? _journeyI.back : _journeyI.forward} size={14}/></button>
            </div>
          </div>

          <div className="rh-cal-grid">
            {(isRTL ? ["أ","ث","ر","خ","ج","س","ح"] : ["Mo","Tu","We","Th","Fr","Sa","Su"]).map((d, i) => (
              <div key={"dow"+i} className="rh-cal-dow">{d}</div>
            ))}
            {[
              null, null, null, 1, 2, 3, 4,
              5, 6, 7, 8, 9, 10, 11,
              12, 13, 14, 15, 16, 17, 18,
              19, 20, 21, 22, 23, 24, 25,
              26, 27, 28, 29, 30, 31, null,
            ].map((d, i) => {
              if (d === null) return <div key={i} className="rh-cal-day muted"></div>;
              const isToday = d === todayDate;
              const isCycle = d >= cycleStart && d <= cycleStart + 13 && !isToday;
              const isNadir = d >= 18 && d <= 21 && !isToday;
              const isAppt = d === 21;
              return (
                <div key={i} className={"rh-cal-day" + (isToday ? " today" : isNadir ? " nadir" : isCycle ? " cycle" : "")}>
                  <span>{isRTL ? ["","١","٢","٣","٤","٥","٦","٧","٨","٩","١٠","١١","١٢","١٣","١٤","١٥","١٦","١٧","١٨","١٩","٢٠","٢١","٢٢","٢٣","٢٤","٢٥","٢٦","٢٧","٢٨","٢٩","٣٠","٣١"][d] : d}</span>
                  {isAppt && <div className="markers"><span style={{ background: "var(--sky-500)" }}></span></div>}
                  {(isCycle || isToday) && d >= cycleStart && d <= cycleStart + 5 && <div className="markers"><span style={{ background: "var(--sage-500)" }}></span></div>}
                </div>
              );
            })}
          </div>

          <div className="rh-cal-legend">
            <div className="rh-cal-legend-item"><span className="sw" style={{ background: "var(--teal-700)" }}></span>{isRTL ? "اليوم" : "Today"}</div>
            <div className="rh-cal-legend-item"><span className="sw" style={{ background: "var(--saffron-100)" }}></span>{isRTL ? "أيام الدورة" : "Cycle days"}</div>
            <div className="rh-cal-legend-item"><span className="sw" style={{ background: "var(--clay-100)" }}></span>{isRTL ? "حد أدنى متوقع" : "Nadir"}</div>
            <div className="rh-cal-legend-item"><span className="sw" style={{ background: "var(--sky-500)" }}></span>{isRTL ? "موعد" : "Appointment"}</div>
          </div>
        </div>

        {/* Next cycle CTA */}
        <div className="rh-tool-row">
          <span className="rh-tool-ic" style={{ background: "var(--saffron-100)", color: "var(--saffron-700)" }}>
            <_IcoJ d={<><path d="M12 2v4M12 18v4M3 12h4M17 12h4"/><circle cx="12" cy="12" r="6"/></>} size={18}/>
          </span>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "الدورة ٣ تبدأ" : "Cycle 3 begins"}</div>
            <div className="rh-tool-sub">{isRTL ? "٣١ مايو · بعد ١٤ يوماً" : "31 May · in 14 days"}</div>
          </div>
          <span className="rh-pill rh-pill-info"><span className="rh-dot"></span>{isRTL ? "مجدول" : "Scheduled"}</span>
        </div>
      </div>

      <_BottomNavJ lang={lang} active="health"/>
    </div>
  );
}

Object.assign(window, { JourneyScreen, ExpectScreen, CycleTrackerScreen });
