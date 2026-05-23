// Rehlah · Profile + Privacy screens

function _IcoP({ d, size = 20 }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{d}</svg>;
}
const _pI = {
  back: <path d="M15 18l-6-6 6-6"/>,
  forward: <path d="M9 18l6-6-6-6"/>,
  more: <><circle cx="5" cy="12" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="19" cy="12" r="1.5"/></>,
  check: <path d="M5 12l5 5 9-11"/>,
  edit: <><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4z"/></>,
  shield: <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>,
  user: <><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0116 0"/></>,
  heart: <path d="M12 21s-7-4.5-7-10a4 4 0 017-2.6A4 4 0 0119 11c0 5.5-7 10-7 10z"/>,
  bell: <><path d="M6 8a6 6 0 1112 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10 21a2 2 0 004 0"/></>,
  globe: <><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 010 18M12 3a14 14 0 000 18"/></>,
  download: <><path d="M4 16v3a2 2 0 002 2h12a2 2 0 002-2v-3"/><path d="M7 11l5 5 5-5"/><path d="M12 16V3"/></>,
  trash: <><path d="M3 6h18M8 6V4a2 2 0 012-2h4a2 2 0 012 2v2M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/></>,
};

function _BNavP({ lang, active = "profile" }) {
  const tabs = lang === "ar" ? ["اليوم", "الصحة", "تواصل", "الملف"] : ["Today", "Health", "Connect", "Profile"];
  const tabIcons = [
    <path d="M3 11l9-7 9 7v9a1 1 0 01-1 1h-5v-6h-6v6H4a1 1 0 01-1-1z"/>,
    _pI.heart,
    null,
    <><path d="M17 21v-2a4 4 0 00-4-4H7a4 4 0 00-4 4v2"/><circle cx="10" cy="7" r="4"/></>,
    _pI.user,
  ];
  const map = ["home", "health", null, "connect", "profile"];
  return (
    <nav className="rh-nav-wrap">
      <div className="rh-nav">
        {tabIcons.map((ic, i) => i === 2
          ? <div key={i} className="rh-tab rh-tab-spacer"></div>
          : <div key={i} className={"rh-tab" + (active === map[i] ? " rh-tab-on" : "")}><_IcoP d={ic}/><span>{tabs[i > 2 ? i - 1 : i]}</span></div>
        )}
        <div className="rh-fab rh-fab-done"><_IcoP d={_pI.check} size={22}/></div>
      </div>
    </nav>
  );
}

// ============ Profile ============
function ProfileScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  const checkins = isRTL ? [
    { d: "اليوم", mood: "good", chips: ["إرهاق ٦", "صداع ٣"] },
    { d: "أمس", mood: "ok", chips: ["إرهاق ٥", "غثيان ٢"] },
    { d: "السبت", mood: "great", chips: ["لا أعراض"] },
    { d: "الجمعة", mood: "good", chips: ["إرهاق ٤"] },
  ] : [
    { d: "Today", mood: "good", chips: ["Fatigue 6", "Headache 3"] },
    { d: "Yesterday", mood: "ok", chips: ["Fatigue 5", "Nausea 2"] },
    { d: "Saturday", mood: "great", chips: ["No symptoms"] },
    { d: "Friday", mood: "good", chips: ["Fatigue 4"] },
  ];

  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <div style={{ width: 36 }}></div>
          <h1 className="rh-page-title">{isRTL ? "ملفك" : "Profile"}</h1>
          <button className="rh-iconbtn"><_IcoP d={_pI.edit} size={16}/></button>
        </header>

        {/* Profile hero */}
        <div className="rh-profile-hero">
          <div className="rh-hero-bloom"></div>
          <div className="rh-profile-av">{isRTL ? "س" : "S"}</div>
          <div className="rh-profile-name" style={{ position: "relative" }}>{isRTL ? "سلمى الحوسني" : "Salma Al-Hosani"}</div>
          <div className="rh-profile-sub" style={{ position: "relative" }}>{isRTL ? "الدورة ٢ من ٦ · سرطان الثدي" : "Cycle 2 of 6 · Breast cancer"}</div>

          <div className="rh-profile-prog" style={{ position: "relative" }}>
            <div className="rh-progbar"><div className="rh-progbar-fill" style={{ width: "82%" }}/></div>
            <div className="rh-progbar-row">
              <span>{isRTL ? "اكتمال الملف" : "Profile complete"}</span>
              <span>{isRTL ? "٨٢٪" : "82%"}</span>
            </div>
          </div>
        </div>

        {/* Personal info */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "البيانات الشخصية" : "Personal"}</span><span className="rh-section-cta">{isRTL ? "تعديل" : "Edit"}</span></div>

        <div className="rh-tool-row">
          <div className="rh-tool-body">
            <div className="rh-tool-sub" style={{ marginTop: 0 }}>{isRTL ? "تاريخ الميلاد" : "Date of birth"}</div>
            <div className="rh-tool-ttl" style={{ marginTop: 2 }}>{isRTL ? "١٤ مارس ١٩٨٧" : "14 March 1987"}</div>
          </div>
        </div>
        <div className="rh-tool-row">
          <div className="rh-tool-body">
            <div className="rh-tool-sub" style={{ marginTop: 0 }}>{isRTL ? "اللغة" : "Language"}</div>
            <div className="rh-tool-ttl" style={{ marginTop: 2 }}>{isRTL ? "العربية · English" : "English · العربية"}</div>
          </div>
        </div>

        {/* Treatment info */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "العلاج" : "Treatment"}</span></div>

        <div className="rh-tool-row">
          <div className="rh-tool-body">
            <div className="rh-tool-sub" style={{ marginTop: 0 }}>{isRTL ? "البروتوكول" : "Protocol"}</div>
            <div className="rh-tool-ttl" style={{ marginTop: 2 }}>{isRTL ? "AC-T كل ٣ أسابيع" : "AC-T every 3 weeks"}</div>
          </div>
        </div>
        <div className="rh-tool-row">
          <div className="rh-tool-body">
            <div className="rh-tool-sub" style={{ marginTop: 0 }}>{isRTL ? "المركز" : "Centre"}</div>
            <div className="rh-tool-ttl" style={{ marginTop: 2 }}>{isRTL ? "مستشفى توام · العين" : "Tawam Hospital · Al Ain"}</div>
          </div>
        </div>

        {/* Check-in history */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "آخر التسجيلات" : "Recent check-ins"}</span><span className="rh-section-cta">{isRTL ? "الكل" : "See all"}</span></div>

        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          {checkins.map((c, i) => {
            const moodMap = {
              great: { bg: "var(--sage-100)", fg: "var(--sage-700)", glyph: "◠" },
              good: { bg: "var(--teal-100)", fg: "var(--teal-700)", glyph: "◡" },
              ok: { bg: "var(--sand-100)", fg: "var(--sand-700)", glyph: "—" },
              low: { bg: "var(--saffron-100)", fg: "var(--saffron-700)", glyph: "⌒" },
            }[c.mood];
            return (
              <div key={i} className="rh-tool-row">
                <div className="rh-tool-ic" style={{ background: moodMap.bg, color: moodMap.fg, fontSize: 18, fontWeight: 700 }}>{moodMap.glyph}</div>
                <div className="rh-tool-body">
                  <div className="rh-tool-ttl">{c.d}</div>
                  <div className="rh-tool-sub">{c.chips.join(" · ")}</div>
                </div>
                <span className="rh-chev">{isRTL ? "‹" : "›"}</span>
              </div>
            );
          })}
        </div>

        {/* Settings */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "الإعدادات" : "Settings"}</span></div>

        <div className="rh-tool-row">
          <div className="rh-tool-ic"><_IcoP d={_pI.bell} size={18}/></div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "التنبيهات" : "Notifications"}</div>
            <div className="rh-tool-sub">{isRTL ? "تذكيرات الدواء · المواعيد" : "Medication · appointments"}</div>
          </div>
          <span className="rh-chev">{isRTL ? "‹" : "›"}</span>
        </div>
        <div className="rh-tool-row">
          <div className="rh-tool-ic"><_IcoP d={_pI.shield} size={18}/></div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "الخصوصية والبيانات" : "Privacy & data"}</div>
          </div>
          <span className="rh-chev">{isRTL ? "‹" : "›"}</span>
        </div>
        <div className="rh-tool-row">
          <div className="rh-tool-ic"><_IcoP d={_pI.globe} size={18}/></div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "اللغة" : "Language"}</div>
            <div className="rh-tool-sub">{isRTL ? "العربية" : "English"}</div>
          </div>
          <span className="rh-chev">{isRTL ? "‹" : "›"}</span>
        </div>
      </div>

      <_BNavP lang={lang} active="profile"/>
    </div>
  );
}

// ============ Privacy ============
function PrivacyScreen({ lang = "en" }) {
  const isRTL = lang === "ar";

  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <button className="rh-iconbtn"><_IcoP d={isRTL ? _pI.forward : _pI.back}/></button>
          <h1 className="rh-page-title">{isRTL ? "الخصوصية والبيانات" : "Privacy & data"}</h1>
          <div style={{ width: 36 }}></div>
        </header>

        {/* Hero */}
        <div className="rh-hero rh-hero-tight">
          <div className="rh-hero-bloom"></div>
          <div className="rh-eyebrow rh-eyebrow-onhero">{isRTL ? "بياناتك" : "Your data"}</div>
          <h2 className="rh-hero-h2" style={{ marginBottom: 6 }}>{isRTL ? "ملككِ. وحدكِ." : "Yours. Always."}</h2>
          <p style={{ fontSize: 12.5, color: "rgba(255,255,255,.78)", margin: 0, position: "relative", lineHeight: 1.5 }}>
            {isRTL
              ? "يصل إليها فريق العناية الذي تختارينه أنتِ. لا نبيعها أبداً، ولا نشاركها مع أي طرف ثالث."
              : "Visible only to the care team you choose. We never sell it, never share with third parties."}
          </p>
        </div>

        {/* Who can see */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "من يستطيع الرؤية" : "Who can see"}</span></div>

        <div className="rh-tog-row">
          <div className="rh-av rh-av-saffron" style={{ width: 36, height: 36, fontSize: 14 }}>{isRTL ? "ع" : "DA"}</div>
          <div className="rh-tog-body">
            <div className="rh-tog-ttl">{isRTL ? "د. عائشة · الأورام" : "Dr. Aisha · Oncology"}</div>
            <div className="rh-tog-sub">{isRTL ? "كل التسجيلات والتحاليل والمواعيد" : "All check-ins, labs, appointments"}</div>
          </div>
          <span className="rh-tog rh-tog-on"></span>
        </div>

        <div className="rh-tog-row">
          <div className="rh-av rh-av-teal" style={{ width: 36, height: 36, fontSize: 14 }}>{isRTL ? "ن" : "NM"}</div>
          <div className="rh-tog-body">
            <div className="rh-tog-ttl">{isRTL ? "نور · ممرضة العناية" : "Nour · care nurse"}</div>
            <div className="rh-tog-sub">{isRTL ? "كل البيانات" : "All data"}</div>
          </div>
          <span className="rh-tog rh-tog-on"></span>
        </div>

        <div className="rh-tog-row">
          <div className="rh-av rh-av-clay" style={{ width: 36, height: 36, fontSize: 14 }}>{isRTL ? "ف" : "FT"}</div>
          <div className="rh-tog-body">
            <div className="rh-tog-ttl">{isRTL ? "فاطمة · أختي" : "Fatima · sister"}</div>
            <div className="rh-tog-sub">{isRTL ? "المواعيد فقط · لا تسجيلات" : "Appointments only · no check-ins"}</div>
          </div>
          <span className="rh-tog rh-tog-on"></span>
        </div>

        {/* Controls */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "تحكم" : "Controls"}</span></div>

        <div className="rh-tog-row">
          <div className="rh-tool-ic" style={{ background: "var(--teal-100)", color: "var(--teal-700)" }}><_IcoP d={_pI.shield} size={18}/></div>
          <div className="rh-tog-body">
            <div className="rh-tog-ttl">{isRTL ? "اليوميات الخاصة" : "Private journal entries"}</div>
            <div className="rh-tog-sub">{isRTL ? "لا تُشارَك حتى مع طبيبك" : "Not shared, even with your doctor"}</div>
          </div>
          <span className="rh-tog rh-tog-on"></span>
        </div>

        <div className="rh-tog-row">
          <div className="rh-tool-ic" style={{ background: "var(--sage-100)", color: "var(--sage-700)" }}>
            <_IcoP d={<><circle cx="12" cy="12" r="3"/><path d="M12 3v3M12 18v3M3 12h3M18 12h3"/></>} size={18}/>
          </div>
          <div className="rh-tog-body">
            <div className="rh-tog-ttl">{isRTL ? "تحسين الذكاء الاصطناعي" : "Help improve Rehlah's AI"}</div>
            <div className="rh-tog-sub">{isRTL ? "تحاليل مجهّلة الهوية لتحسين الاقتراحات" : "Anonymous insights, no identifiers"}</div>
          </div>
          <span className="rh-tog"></span>
        </div>

        {/* Data actions */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "بياناتك" : "Your data"}</span></div>

        <div className="rh-tool-row">
          <div className="rh-tool-ic" style={{ background: "var(--sand-100)", color: "var(--sand-700)" }}><_IcoP d={_pI.download} size={18}/></div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "تنزيل كل بياناتي" : "Download all my data"}</div>
            <div className="rh-tool-sub">{isRTL ? "ملف PDF + CSV" : "PDF + CSV export"}</div>
          </div>
          <span className="rh-chev">{isRTL ? "‹" : "›"}</span>
        </div>

        <div className="rh-tool-row">
          <div className="rh-tool-ic" style={{ background: "var(--clay-100)", color: "var(--clay-700)" }}><_IcoP d={_pI.trash} size={18}/></div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl" style={{ color: "var(--clay-700)" }}>{isRTL ? "حذف الحساب" : "Delete account"}</div>
            <div className="rh-tool-sub">{isRTL ? "نهائي · يلزم تأكيد من د. عائشة" : "Permanent · requires Dr. Aisha's confirmation"}</div>
          </div>
          <span className="rh-chev">{isRTL ? "‹" : "›"}</span>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { ProfileScreen, PrivacyScreen });
