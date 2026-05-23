// Rehlah · Welcome, Onboarding, Caregiver Home

function _IcoO({ d, size = 20 }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">{d}</svg>;
}
const _oI = {
  back: <path d="M15 18l-6-6 6-6"/>,
  forward: <path d="M9 18l6-6-6-6"/>,
  more: <><circle cx="5" cy="12" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="19" cy="12" r="1.5"/></>,
  arrow: <path d="M5 12h14M13 6l6 6-6 6"/>,
  check: <path d="M5 12l5 5 9-11"/>,
  pill: <path d="M4 7h16M6 7v12a2 2 0 002 2h8a2 2 0 002-2V7M9 7V5a3 3 0 016 0v2"/>,
  thermo: <path d="M14 4a2 2 0 10-4 0v10a4 4 0 104 0z"/>,
  heart: <path d="M12 21s-7-4.5-7-10a4 4 0 017-2.6A4 4 0 0119 11c0 5.5-7 10-7 10z"/>,
};

// ============ Welcome ============
function WelcomeScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-welcome">
        <div className="rh-welcome-art">
          <div className="rh-welcome-orb">
            <span className="rh-welcome-glyph" style={{ fontFamily: "var(--font-sans)", fontWeight: 500, fontSize: 110, color: "var(--saffron-300)" }}>{isRTL ? "ر" : "ر"}</span>
          </div>
        </div>

        <div style={{ marginTop: 12 }}>
          <p className="rh-eyebrow" style={{ color: "var(--teal-700)", marginBottom: 8 }}>{isRTL ? "أهلاً بكِ" : "Welcome"}</p>
          <h1 className="rh-welcome-h">
            {isRTL ? <>رحلة <span style={{ color: "var(--saffron-700)" }}>تسير معكِ.</span></> : <>A journey, <span style={{ color: "var(--saffron-700)" }}>walked with you.</span></>}
          </h1>
          <p className="rh-welcome-sub">
            {isRTL
              ? "أدخلي رمز الدعوة من فريقكِ الطبي. سنرتب لكِ كل شيء — الأدوية والمواعيد والتحاليل — في مكان واحد."
              : "Enter the invite code from your care team. We'll set everything up — meds, appointments, labs — in one calm place."}
          </p>
        </div>

        <div className="rh-welcome-actions">
          <div className="rh-invite-field">
            <div style={{ display: "flex", flexDirection: "column" }}>
              <span className="lbl">{isRTL ? "رمز الدعوة" : "Invite code"}</span>
              <input defaultValue={isRTL ? "TWM ٧٤٢" : "TWM-742-AISHA"} readOnly/>
            </div>
          </div>
          <button className="rh-btn-primary">
            {isRTL ? "متابعة" : "Continue"}
            <_IcoO d={_oI.arrow} size={16}/>
          </button>
          <button className="rh-btn-ghost" style={{ alignSelf: "center", height: 36 }}>
            {isRTL ? "هل أنتِ مرافقة؟" : "Are you a caregiver?"}
          </button>
        </div>
      </div>
    </div>
  );
}

// ============ Onboarding ============
function OnboardingScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll" style={{ display: "flex", flexDirection: "column", paddingTop: 60 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "0 4px" }}>
          <div className="rh-dots">
            <span></span><span className="on"></span><span></span><span></span>
          </div>
          <span className="rh-section-cta">{isRTL ? "تخطّي" : "Skip"}</span>
        </div>

        {/* Visual */}
        <div className="rh-onb-art" style={{ marginTop: 24, marginBottom: 8 }}>
          <div className="rh-onb-art-circles">
            <div></div>
            <div></div>
            <div></div>
          </div>
          {/* Mock device overlay */}
          <div style={{ position: "relative", width: 160, height: 90, background: "var(--surface)", borderRadius: 18, boxShadow: "0 12px 30px rgba(40,30,20,.12)", padding: 12, zIndex: 1 }}>
            <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
              <div style={{ width: 24, height: 24, borderRadius: 8, background: "var(--sage-100)", color: "var(--sage-700)", display: "grid", placeItems: "center" }}>
                <_IcoO d={_oI.pill} size={12}/>
              </div>
              <div style={{ height: 8, flex: 1, background: "var(--sand-100)", borderRadius: 4 }}></div>
            </div>
            <div style={{ marginTop: 10, display: "flex", alignItems: "center", gap: 6 }}>
              <svg width="40" height="40" viewBox="0 0 40 40"><circle cx="20" cy="20" r="16" stroke="var(--sand-200)" strokeWidth="4" fill="none"/><circle cx="20" cy="20" r="16" stroke="var(--sage-500)" strokeWidth="4" fill="none" strokeDasharray="100" strokeDashoffset="25" strokeLinecap="round" transform="rotate(-90 20 20)"/></svg>
              <div>
                <div style={{ fontSize: 14, fontWeight: 700, lineHeight: 1 }}>{isRTL ? "٦/٨" : "6/8"}</div>
                <div style={{ fontSize: 9, color: "var(--sand-500)", marginTop: 2 }}>{isRTL ? "الجرعات اليوم" : "doses today"}</div>
              </div>
            </div>
          </div>
        </div>

        <div style={{ flex: 1, padding: "16px 4px" }}>
          <p className="rh-eyebrow" style={{ color: "var(--teal-700)" }}>{isRTL ? "الخطوة ٢ من ٤" : "Step 2 of 4"}</p>
          <h2 style={{ fontSize: 28, fontWeight: 400, fontFamily: "var(--font-editorial)", margin: "8px 0 12px", lineHeight: 1.1, letterSpacing: "-.015em" }}>
            {isRTL ? "كل دواء، في وقته." : "Every dose, on time."}
          </h2>
          <p style={{ fontSize: 14, color: "var(--sand-700)", margin: 0, lineHeight: 1.55 }}>
            {isRTL
              ? "تذكيرات لطيفة لكل جرعة. سجّل ما تأخذينه بضغطة واحدة. يرى فريقكِ التزامكِ في الوقت الحقيقي."
              : "Gentle reminders for every dose. Log what you take with one tap. Your team sees adherence in real time."}
          </p>
        </div>

        <button className="rh-btn-primary" style={{ marginTop: 0 }}>
          {isRTL ? "متابعة" : "Continue"}
          <_IcoO d={_oI.arrow} size={16}/>
        </button>
      </div>
    </div>
  );
}

// ============ Caregiver Home ============
function CaregiverHomeScreen({ lang = "en" }) {
  const isRTL = lang === "ar";
  return (
    <div className="rh-screen" dir={isRTL ? "rtl" : "ltr"} lang={lang}>
      <div className="rh-scroll">
        <header className="rh-topbar">
          <button className="rh-iconbtn" style={{ background: "var(--plum-100)", color: "var(--plum-700)", border: "none" }}>
            <_IcoO d={<><path d="M17 21v-2a4 4 0 00-4-4H7a4 4 0 00-4 4v2"/><circle cx="10" cy="7" r="4"/><path d="M21 11h-4M19 9v4"/></>} size={16}/>
          </button>
          <h1 className="rh-page-title">{isRTL ? "تتابعين سلمى" : "Watching Salma"}</h1>
          <button className="rh-iconbtn"><_IcoO d={_oI.more}/></button>
        </header>

        {/* Caregiver banner */}
        <div className="rh-cg-banner">
          <div className="rh-hero-bloom"></div>
          <div className="rh-eyebrow">{isRTL ? "وضع المرافق" : "Caregiver mode"}</div>
          <div className="rh-cg-banner-ttl">{isRTL ? "سلمى لم تسجّل اليوم" : "Salma hasn't checked in today"}</div>
          <div className="rh-cg-banner-sub">{isRTL ? "آخر تسجيل: أمس ٢١:٠٤ · شعرت بـ 'جيد'" : "Last check-in: yesterday 21:04 · felt 'good'"}</div>
        </div>

        {/* Quick stats */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "اليوم" : "Today"}</span><span className="rh-section-cta">{isRTL ? "السجل الكامل" : "Full log"}</span></div>

        <div className="rh-row-2">
          <div className="rh-metric">
            <span className="rh-metric-ic" style={{ background: "var(--sage-100)", color: "var(--sage-700)" }}>
              <_IcoO d={_oI.pill} size={16}/>
            </span>
            <div>
              <div className="rh-metric-label">{isRTL ? "الأدوية" : "Medication"}</div>
              <div className="rh-metric-val">{isRTL ? "٦/٨" : "6/8"}</div>
              <div className="rh-metric-when">{isRTL ? "آخر جرعة قبل ٤ س" : "Last dose 4h ago"}</div>
            </div>
          </div>
          <div className="rh-metric">
            <span className="rh-metric-ic" style={{ background: "var(--clay-100)", color: "var(--clay-700)" }}>
              <_IcoO d={_oI.thermo} size={16}/>
            </span>
            <div>
              <div className="rh-metric-label">{isRTL ? "الحرارة" : "Temperature"}</div>
              <div className="rh-metric-val">{isRTL ? "٣٨٫٩°" : "38.9°"}</div>
              <div className="rh-metric-when">{isRTL ? "قبل ساعتين" : "2h ago"}</div>
            </div>
          </div>
        </div>

        {/* Needs attention */}
        <div className="rh-section-head"><span className="rh-eyebrow" style={{ color: "var(--clay-700)" }}>{isRTL ? "يحتاج انتباهاً" : "Needs attention"}</span></div>

        <div className="rh-tool-row" style={{ background: "var(--clay-100)", borderColor: "var(--clay-300)" }}>
          <div className="rh-tool-ic" style={{ background: "white", color: "var(--clay-700)" }}><_IcoO d={_oI.thermo} size={18}/></div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "حمى طفيفة سُجّلت" : "Slight fever logged"}</div>
            <div className="rh-tool-sub">{isRTL ? "٣٨٫٩° قبل ساعتين · أكثر من ٣٨٫٥ لمدة ٤ ساعات يستوجب اتصالاً" : "38.9° 2h ago · over 38.5° for 4h means call"}</div>
          </div>
          <button className="rh-btn-warm rh-btn-sm">{isRTL ? "اتصلي" : "Call"}</button>
        </div>

        <div className="rh-tool-row" style={{ background: "var(--saffron-100)", borderColor: "var(--saffron-300)" }}>
          <div className="rh-tool-ic" style={{ background: "white", color: "var(--saffron-700)" }}><_IcoO d={_oI.pill} size={18}/></div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "جرعة فائتة في ١٣:٠٠" : "Missed 13:00 dose"}</div>
            <div className="rh-tool-sub">{isRTL ? "أوندانسيترون · يمكن تأخيرها ولكن ذكّريها" : "Ondansetron · OK to delay but remind her"}</div>
          </div>
          <button className="rh-btn-ghost">{isRTL ? "تذكير" : "Remind"}</button>
        </div>

        {/* Today schedule */}
        <div className="rh-section-head"><span className="rh-eyebrow">{isRTL ? "ما تبقى من اليوم" : "Rest of today"}</span></div>

        <div className="rh-tool-row">
          <div className="rh-tool-ic" style={{ background: "var(--saffron-100)", color: "var(--saffron-700)", fontFamily: "ui-monospace, monospace", fontSize: 11, fontWeight: 700 }}>
            17:00
          </div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "كابيسيتابين · ١٥٠٠ مغ" : "Capecitabine · 1500 mg"}</div>
            <div className="rh-tool-sub">{isRTL ? "خلال ٤٥ دقيقة" : "In 45 minutes"}</div>
          </div>
          <span className="rh-pill rh-pill-warn"><span className="rh-dot"></span>{isRTL ? "قريباً" : "Due soon"}</span>
        </div>

        <div className="rh-tool-row">
          <div className="rh-tool-ic" style={{ background: "var(--sand-100)", color: "var(--sand-500)", fontFamily: "ui-monospace, monospace", fontSize: 11, fontWeight: 700 }}>
            22:00
          </div>
          <div className="rh-tool-body">
            <div className="rh-tool-ttl">{isRTL ? "كابيسيتابين · ١٥٠٠ مغ" : "Capecitabine · 1500 mg"}</div>
            <div className="rh-tool-sub">{isRTL ? "قبل النوم · مع الطعام" : "Bedtime · with food"}</div>
          </div>
          <span className="rh-pill rh-pill-neutral"><span className="rh-dot"></span>{isRTL ? "مجدولة" : "Scheduled"}</span>
        </div>

        <button className="rh-btn-secondary" style={{ width: "100%", marginTop: 12 }}>
          <_IcoO d={_oI.heart} size={16}/>
          {isRTL ? "إرسال رسالة لطيفة لسلمى" : "Send Salma a kind note"}
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { WelcomeScreen, OnboardingScreen, CaregiverHomeScreen });
