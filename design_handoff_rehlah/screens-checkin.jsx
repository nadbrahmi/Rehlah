// Rehlah · Check-in screens (Emoji, Sliders, Success)

const _checkinI = {
  back: <path d="M15 18l-6-6 6-6"/>,
  forward: <path d="M9 18l6-6-6-6"/>,
  check: <path d="M5 12l5 5 9-11"/>,
  close: <><path d="M6 6l12 12M18 6l-12 12"/></>,
};

function _MoodFace({ pose, on }) {
  const mouths = {
    sad:   "M8 15c1.5-2 6.5-2 8 0",
    low:   "M8 14c1.5-1 6.5-1 8 0",
    ok:    "M8.5 14h7",
    good:  "M8 13c1.5 2 6.5 2 8 0",
    great: "M7.5 12c1.5 3 7.5 3 9 0",
  };
  return (
    <svg viewBox="0 0 24 24">
      <circle cx="12" cy="12" r="9"/>
      <path d={mouths[pose]}/>
      <path d="M8 9.5h.01M16 9.5h.01"/>
    </svg>
  );
}

function _IcoB({ d, size = 20 }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{d}</svg>;
}

// ============ Emoji check-in ============
function CheckinEmojiScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  const symptoms = isRTL
    ? ["إرهاق", "غثيان", "ألم", "صداع", "قلة شهية", "قشعريرة", "تنميل", "ضيق نفس"]
    : ["Fatigue", "Nausea", "Pain", "Headache", "Low appetite", "Chills", "Tingling", "Breathlessness"];
  const onSet = new Set([0, 2, 3]);

  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <button className="rh-iconbtn"><_IcoB d={_checkinI.close}/></button>
          <h1 className="rh-page-title">{isRTL ? "تسجيل اليوم" : "Today's check-in"}</h1>
          <button className="rh-iconbtn" style={{ background: "var(--teal-700)", color: "white", border: "none", fontSize: 12, fontWeight: 600 }}>
            {isRTL ? "١/٢" : "1/2"}
          </button>
        </header>

        <div>
          <p className="rh-eyebrow" style={{ color: "var(--teal-700)" }}>{isRTL ? "الدورة ٢ · اليوم ٧" : "Cycle 2 · Day 7"}</p>
          <h2 style={{ margin: "4px 0 0", fontSize: 26, fontWeight: 700, letterSpacing: "-.015em", fontFamily: "var(--font-editorial)", fontWeight: 400 }}>
            {isRTL ? "كيف تشعرين اليوم؟" : "How are you feeling today?"}
          </h2>
        </div>

        <div className="rh-mood-row" style={{ paddingBottom: 24 }}>
          {[
            { p: "sad", l: isRTL ? "متعب" : "Down" },
            { p: "low", l: isRTL ? "ضعيف" : "Low" },
            { p: "ok", l: isRTL ? "عادي" : "OK" },
            { p: "good", l: isRTL ? "جيد" : "Good", on: true },
            { p: "great", l: isRTL ? "ممتاز" : "Great" },
          ].map((m, i) => (
            <div key={i} className={"rh-mood" + (m.on ? " rh-mood-on" : "")}>
              <_MoodFace pose={m.p} on={m.on}/>
              <div className="rh-mood-lbl" style={m.on ? { color: "var(--teal-700)", fontWeight: 600 } : {}}>{m.l}</div>
            </div>
          ))}
        </div>

        <div style={{ marginTop: 16 }}>
          <h3 style={{ margin: 0, fontSize: 16, fontWeight: 700 }}>{isRTL ? "أي أعراض اليوم؟" : "Any symptoms today?"}</h3>
          <p style={{ margin: "4px 0 12px", fontSize: 12, color: "var(--sand-500)" }}>{isRTL ? "حدّدي ما ينطبق · اختياري" : "Tap any that apply · optional"}</p>
          <div className="rh-chip-row">
            {symptoms.map((s, i) => (
              <span key={i} className={"rh-chip" + (onSet.has(i) ? " rh-chip-on" : "")}>{s}</span>
            ))}
          </div>
        </div>

        <button className="rh-btn-primary" style={{ marginTop: 28 }}>
          {isRTL ? "متابعة" : "Continue"}
          <_IcoB d={isRTL ? _checkinI.back : _checkinI.forward} size={16}/>
        </button>

        <button className="rh-btn-ghost" style={{ alignSelf: "center", marginTop: 8 }}>
          {isRTL ? "استخدمي المؤشرات بدلاً من ذلك" : "Use sliders instead"}
        </button>
      </div>
    </div>
  );
}

// ============ Slider check-in ============
function CheckinSlidersScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  const items = isRTL
    ? [["الإرهاق", 6], ["الغثيان", 2], ["الألم", 3], ["الحمى", 1], ["قلة الشهية", 4]]
    : [["Fatigue", 6], ["Nausea", 2], ["Pain", 3], ["Fever", 1], ["Appetite", 4]];

  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <button className="rh-iconbtn"><_IcoB d={isRTL ? _checkinI.forward : _checkinI.back}/></button>
          <h1 className="rh-page-title">{isRTL ? "تسجيل اليوم" : "Today's check-in"}</h1>
          <button className="rh-iconbtn" style={{ background: "var(--teal-700)", color: "white", border: "none", fontSize: 12, fontWeight: 600 }}>
            {isRTL ? "٢/٢" : "2/2"}
          </button>
        </header>

        <div>
          <p className="rh-eyebrow" style={{ color: "var(--teal-700)" }}>{isRTL ? "تقييم الشدة" : "Severity"}</p>
          <h2 style={{ margin: "4px 0 0", fontSize: 22, fontWeight: 700, letterSpacing: "-.01em" }}>
            {isRTL ? "كم تشعرين بكل من هذه؟" : "How much of each?"}
          </h2>
          <p style={{ margin: "4px 0 0", fontSize: 12, color: "var(--sand-500)" }}>
            {isRTL ? "من ٠ (لا شيء) إلى ١٠ (شديد)" : "0 = none, 10 = severe"}
          </p>
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 20, marginTop: 8 }}>
          {items.map(([name, v], i) => (
            <div key={i} className="rh-slider">
              <div className="rh-slider-meta">
                <span className="rh-slider-lbl">{name}</span>
                <span className="rh-slider-val">{isRTL ? `${["٠","١","٢","٣","٤","٥","٦","٧","٨","٩","١٠"][v]} / ١٠` : `${v} / 10`}</span>
              </div>
              <div className="rh-slider-track">
                <div className="rh-slider-fill" style={{ width: `${v * 10}%` }}/>
                <div className="rh-slider-thumb" style={{ left: `${v * 10}%` }}/>
              </div>
              <div className="rh-slider-ticks">
                {(isRTL ? ["٠","٢","٤","٦","٨","١٠"] : ["0","2","4","6","8","10"]).map((t, j) => <span key={j}>{t}</span>)}
              </div>
            </div>
          ))}
        </div>

        <div style={{ marginTop: 12 }}>
          <p className="rh-eyebrow">{isRTL ? "ملاحظة لفريقك" : "Note for your team"}</p>
          <div className="rh-field" style={{ marginTop: 8, minHeight: 56 }}>
            <div className="rh-field-placeholder">{isRTL ? "ماذا تريدين أن يعرفوا؟ (اختياري)" : "Anything they should know? (optional)"}</div>
          </div>
        </div>

        <button className="rh-btn-primary" style={{ marginTop: 16 }}>
          {isRTL ? "حفظ التسجيل" : "Save check-in"}
        </button>
      </div>
    </div>
  );
}

// ============ Check-in success ============
function CheckinSuccessScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang} style={{ background: "var(--sand-50)" }}>
      <div className="rh-success">
        <div className="rh-success-orb">
          <_IcoB d={_checkinI.check} size={56}/>
        </div>
        <div>
          <h1 className="rh-success-h">{isRTL ? "تم الحفظ" : "Saved."}</h1>
          <p style={{ fontSize: 14, color: "var(--sand-500)", margin: "8px 0 0", letterSpacing: "0" }}>
            {isRTL ? "شكراً لمشاركتك يومك." : "Thank you for sharing your day."}
          </p>
        </div>
        <p className="rh-success-sub">
          {isRTL
            ? "تم إرسال تسجيلك إلى د. عائشة وفريقها. إن تغير شيء جوهري، ستتلقين رسالة منا."
            : "Your check-in has been sent to Dr. Aisha and her team. If anything stands out, we'll let you know."}
        </p>

        <div style={{ display: "flex", gap: 8, width: "100%", maxWidth: 280 }}>
          <div className="rh-stat-chip">
            <div className="n">{isRTL ? "٧" : "7"}</div>
            <div className="l">{isRTL ? "أيام متتالية" : "day streak"}</div>
          </div>
          <div className="rh-stat-chip">
            <div className="n">{isRTL ? "٨٦٪" : "86%"}</div>
            <div className="l">{isRTL ? "إكمال الدورة" : "cycle done"}</div>
          </div>
        </div>

        <div className="rh-success-countdown">{isRTL ? "العودة خلال ٤ ث" : "Returning in 4s"}</div>
      </div>
    </div>
  );
}

Object.assign(window, { CheckinEmojiScreen, CheckinSlidersScreen, CheckinSuccessScreen });
