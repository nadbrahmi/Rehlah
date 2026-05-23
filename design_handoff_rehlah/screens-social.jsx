// Rehlah · AI Chat + Connect screens

function _IcoC({ d, size = 20 }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{d}</svg>;
}
const _cI = {
  back: <path d="M15 18l-6-6 6-6"/>,
  forward: <path d="M9 18l6-6-6-6"/>,
  more: <><circle cx="5" cy="12" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="19" cy="12" r="1.5"/></>,
  send: <path d="M3 12l18-9-7 18-2-8-9-1z"/>,
  search: <><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></>,
  check: <path d="M5 12l5 5 9-11"/>,
};

function _BNavC({ lang, active = "connect" }) {
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
          : <div key={i} className={"rh-tab" + (active === map[i] ? " rh-tab-on" : "")}><_IcoC d={ic}/><span>{tabs[i > 2 ? i - 1 : i]}</span></div>
        )}
        <div className="rh-fab rh-fab-done"><_IcoC d={_cI.check} size={22}/></div>
      </div>
    </nav>
  );
}

// ============ AI Chat ============
function AIChatScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <header className="rh-topbar" style={{ position: "absolute", top: 56, left: 16, right: 16, zIndex: 5, padding: 0 }}>
        <button className="rh-iconbtn"><_IcoC d={isRTL ? _cI.forward : _cI.back}/></button>
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <div style={{ width: 28, height: 28, borderRadius: "50%", background: "var(--teal-700)", display: "grid", placeItems: "center" }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="1.8"><circle cx="12" cy="12" r="3"/><path d="M12 3v3M12 18v3M3 12h3M18 12h3"/></svg>
          </div>
          <div>
            <div style={{ fontSize: 14, fontWeight: 700, lineHeight: 1 }}>{isRTL ? "اسألي رحلة" : "Ask Rehlah"}</div>
            <div style={{ fontSize: 10, color: "var(--sand-500)" }}>{isRTL ? "ليس بديلاً عن طبيبك" : "Not a substitute for your doctor"}</div>
          </div>
        </div>
        <button className="rh-iconbtn"><_IcoC d={_cI.more}/></button>
      </header>

      <div className="rh-chat-scroll" style={{ paddingTop: 110 }}>
        <div className="rh-msg-day">{isRTL ? "اليوم · ١٤:٢٢" : "Today · 14:22"}</div>

        <div className="rh-msg rh-msg-bot">
          {isRTL
            ? "أهلاً سلمى. كيف يمكنني المساعدة اليوم؟"
            : "Hi Salma. How can I help today?"}
        </div>

        <div className="rh-suggestions">
          <span className="rh-suggestion">{isRTL ? "ما يعنيه آخر تحليل؟" : "What does my last lab mean?"}</span>
          <span className="rh-suggestion">{isRTL ? "متى أتصل بفريقي؟" : "When should I call my team?"}</span>
          <span className="rh-suggestion">{isRTL ? "أطعمة آمنة الليلة" : "Safe foods tonight"}</span>
        </div>

        <div className="rh-msg rh-msg-me">
          {isRTL ? "ماذا تعني نتائج تحاليلي الأخيرة؟" : "What do my latest lab results mean?"}
        </div>

        <div className="rh-msg rh-msg-bot">
          {isRTL
            ? "معظم نتائجك ضمن المعدل المتوقع لهذه المرحلة من الدورة. كريات الدم البيضاء انخفضت قليلاً (٣٫٤ × ١٠⁹/L) — وهذا شائع حول اليوم السابع."
            : "Most of your values are in the expected range for this point in the cycle. Your white-cell count dipped a little (3.4 ×10⁹/L) — common around day 7."}
        </div>
        <div className="rh-msg rh-msg-bot" style={{ marginTop: -6 }}>
          {isRTL
            ? "إنزيم الكبد ALT مرتفع قليلاً (٦٢ مقابل ٤٥ المرة الماضية). ليس مقلقاً وحده — لكنه يستحق ذكره يوم الخميس."
            : "Liver ALT is mildly elevated (62, up from 45). Not alarming on its own — worth mentioning Thursday."}
        </div>

        <div className="rh-msg rh-msg-bot" style={{ background: "var(--sand-100)", border: "none" }}>
          <div className="rh-msg-cite" style={{ background: "transparent", padding: 0, marginTop: 0, display: "flex", alignItems: "center", gap: 6 }}>
            <_IcoC d={<path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8M16 6l-4-4-4 4M12 2v14"/>} size={12}/>
            {isRTL ? "مصدر: نتائج ١٢ مايو · رحلة" : "Source: 12 May labs · Rehlah"}
          </div>
        </div>

        <div className="rh-msg rh-msg-me">
          {isRTL ? "هل يجب أن أكون قلقة؟" : "Should I be worried?"}
        </div>

        <div className="rh-msg rh-msg-bot">
          {isRTL
            ? "لا — لكن إن لاحظتِ صفاراً في البول أو تعباً شديداً غير معتاد، اتصلي بفريق د. عائشة فوراً. أضفت هذه النقطة لتقرير التجهيز."
            : "No — but if you notice dark urine or unusual fatigue, call Dr. Aisha's team right away. I've added this to your prep report."}
        </div>
      </div>

      <div className="rh-chat-input-bar">
        <div className="rh-chat-input">{isRTL ? "اكتبي سؤالك..." : "Type a question..."}</div>
        <button className="rh-chat-send"><_IcoC d={_cI.send} size={16}/></button>
      </div>
    </div>
  );
}

// ============ Connect (Tabs: Feed / Mentors / Coaches / Stories) ============
function ConnectScreen({ lang = "en" }) {
  const isRTL = lang === "ar";

  const stories = isRTL ? [
    { ttl: "ما تعلمته في الدورة الأولى", author: "أم محمد · ٤٢ · أبوظبي", glyph: "ﻡ", thumb: "" },
    { ttl: "كيف تتعاملين مع تساقط الشعر", author: "نورة · ٣٥ · العين", glyph: "ن", thumb: "rh-story-thumb-2" },
    { ttl: "عودة العمل بعد العلاج", author: "هند · ٤٧ · دبي", glyph: "ﻫ", thumb: "rh-story-thumb-3" },
  ] : [
    { ttl: "What I wish I knew in cycle 1", author: "Um Mohammed · 42 · Abu Dhabi", glyph: "M", thumb: "" },
    { ttl: "Coping with hair changes", author: "Noura · 35 · Al Ain", glyph: "N", thumb: "rh-story-thumb-2" },
    { ttl: "Returning to work after treatment", author: "Hind · 47 · Dubai", glyph: "H", thumb: "rh-story-thumb-3" },
  ];

  const mentors = isRTL ? [
    { name: "هدى المنصوري", sub: "ناجية · ٣ سنوات · سرطان الثدي", tags: ["الإرهاق", "العمل"], av: "ه" },
    { name: "ميرة الحمادي", sub: "ناجية · ٦ سنوات · مرحلة II", tags: ["الأمومة", "الغذاء"], av: "م" },
  ] : [
    { name: "Huda Al-Mansouri", sub: "Survivor · 3 yrs · breast cancer", tags: ["Fatigue", "Work"], av: "H" },
    { name: "Mira Al-Hammadi", sub: "Survivor · 6 yrs · stage II", tags: ["Motherhood", "Nutrition"], av: "M" },
  ];

  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <div style={{ width: 36 }}></div>
          <h1 className="rh-page-title">{isRTL ? "تواصل" : "Connect"}</h1>
          <button className="rh-iconbtn"><_IcoC d={_cI.search}/></button>
        </header>

        {/* Tabs */}
        <div className="rh-tabs">
          <div className="rh-tabs-x rh-tabs-x-on">{isRTL ? "الموجز" : "Feed"}</div>
          <div className="rh-tabs-x">{isRTL ? "مرشدات" : "Mentors"}</div>
          <div className="rh-tabs-x">{isRTL ? "مدرّبون" : "Coaches"}</div>
          <div className="rh-tabs-x">{isRTL ? "قصص" : "Stories"}</div>
        </div>

        {/* Mentor of the week */}
        <div className="rh-hero rh-hero-tight rh-hero-plum">
          <div className="rh-hero-bloom"></div>
          <div className="rh-eyebrow rh-eyebrow-onhero">{isRTL ? "مُرشدة الأسبوع" : "Mentor of the week"}</div>
          <h2 className="rh-hero-h2" style={{ marginBottom: 4 }}>{isRTL ? "هدى مرّت بدورتك تماماً." : "Huda walked your exact cycle."}</h2>
          <p style={{ fontSize: 12.5, color: "rgba(255,255,255,.78)", margin: "0 0 12px", position: "relative" }}>
            {isRTL ? "ناجية منذ ٣ سنوات. متاحة هذا الأسبوع." : "Survivor of 3 years. Available this week."}
          </p>
          <button className="rh-btn-warm rh-btn-sm" style={{ position: "relative" }}>{isRTL ? "اطلبي محادثة" : "Request a chat"}</button>
        </div>

        {/* Stories */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "قصص من ناجيات" : "Stories from survivors"}</span><span className="rh-section-cta">{isRTL ? "الكل" : "See all"}</span></div>

        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          {stories.map((s, i) => (
            <div key={i} className="rh-story">
              <div className={"rh-story-thumb " + (s.thumb || "")}>{s.glyph}</div>
              <div className="rh-story-body">
                <div className="rh-story-meta">{isRTL ? "٤ دقائق قراءة" : "4 min read"}</div>
                <div className="rh-story-ttl">{s.ttl}</div>
                <div className="rh-story-author">{s.author}</div>
              </div>
            </div>
          ))}
        </div>

        {/* Mentors short list */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "مرشدات قريبات منكِ" : "Mentors near you"}</span><span className="rh-section-cta">{isRTL ? "الكل" : "See all"}</span></div>

        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          {mentors.map((m, i) => (
            <div key={i} className="rh-mentor">
              <div className="rh-mentor-av" style={{ background: i === 0 ? "var(--saffron-300)" : "var(--sage-300)", color: i === 0 ? "var(--saffron-700)" : "var(--sage-700)" }}>{m.av}</div>
              <div className="rh-mentor-body">
                <div className="rh-mentor-name">{m.name}</div>
                <div className="rh-mentor-sub">{m.sub}</div>
                <div className="rh-mentor-tags">
                  {m.tags.map((t, j) => <span key={j} className="rh-mentor-tag">{t}</span>)}
                </div>
              </div>
              <span className="rh-pill rh-pill-pos"><span className="rh-dot"></span>{isRTL ? "متاحة" : "Available"}</span>
            </div>
          ))}
        </div>
      </div>

      <_BNavC lang={lang} active="connect"/>
    </div>
  );
}

Object.assign(window, { AIChatScreen, ConnectScreen });
