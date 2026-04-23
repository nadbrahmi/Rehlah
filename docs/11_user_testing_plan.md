# DOCUMENT 11 — Real User Testing Plan
**Rehlah | Version 1.0 | April 2026**

---

> **Purpose of this document**: A complete, executable guide for conducting real-user testing of the Rehlah prototype. Includes study design, participant recruitment, session scripts, task scenarios, observation guides, consent templates, success metrics, and a post-test action framework.

---

## Part 1 — Why Test Now & What We're Testing

### Why Now
The Rehlah prototype is live at **https://nadbrahmi.github.io/Rehlah/** with all 20 screens implemented. Before moving to Phase 2 development (Arabic RTL, backend sync, clinical partnerships), we need to validate:

1. **First-session comprehension** — Can a cancer patient or caregiver understand what Rehlah is and why it's for them within 60 seconds of opening the app?
2. **Onboarding completion** — Can users complete the 5-step onboarding without assistance?
3. **Core loop usability** — Can users perform a daily check-in, add a medication, and log a lab result?
4. **Emotional resonance** — Does the tone, language, and design feel "right" for someone going through cancer?
5. **Information architecture** — Can users find the features they need without guidance?

### What We Are NOT Testing
- Backend performance (prototype is offline-first)
- Arabic language functionality (future phase)
- Clinical accuracy of AI responses (medical validation separate workstream)
- Caregiver shared-mode (not yet built)

---

## Part 2 — Study Design

### Study Type
**Moderated Remote Usability Testing** (primary)
**Unmoderated Diary Study** (secondary — for 14-day engagement validation)

### Sample Size
| Study | Participants | Rationale |
|-------|-------------|-----------|
| Moderated usability sessions | 8–10 | Nielsen's law: 5 users catch 85% of issues; 8–10 gives confidence across 2 user types |
| Diary study | 5 | Longitudinal engagement; high commitment required |
| Expert review (oncology nurse/patient advocate) | 2 | Clinical tone validation |

**Total: 15–17 participants**

### Participant Split
| Segment | Count | Criteria |
|---------|-------|---------|
| Active cancer patients (any type, any stage) | 4–5 | Currently in treatment or monitoring |
| Cancer survivors (≤2 years post-treatment) | 2 | Recent lived experience |
| Primary caregivers (family member managing a patient) | 2–3 | Active caregiving role |
| Total | 8–10 | — |

### Study Timeline
```
Week 1: Recruitment & screening (Days 1–5)
Week 2: Moderated sessions (Days 8–12)
Week 3: Analysis & synthesis (Days 15–17)
Week 4: Diary study runs simultaneously (Days 8–21)
Week 5: Diary analysis + report (Days 22–26)
```

---

## Part 3 — Participant Recruitment

### Recruiting Channels (Saudi Arabia focus)
1. **Oncology clinic partnerships** — Request nurse coordinators to share an opt-in flyer with patients (requires IRB/ethics approval or clinic director sign-off)
2. **Patient advocacy groups** — Zahra Breast Cancer Association (KSA), Nour Cancer Support, Saudi Cancer Foundation social media
3. **Social media recruitment** — Instagram/Twitter posts in relevant Arabic health communities; paid screening ads
4. **WhatsApp groups** — Cancer patient support groups (approach admins for permission)
5. **Personal networks** — Ask clinical advisors to introduce appropriate patients

### Recruitment Flyer (Template)
```
-------------------------------------------
نحن نبحث عن مشاركين / We're looking for participants
-------------------------------------------
هل أنت مريض بالسرطان أو مقدّم رعاية؟
Are you a cancer patient or caregiver?

نريد سماع رأيك في تطبيق صحي جديد يُسمى "رحلة"
We'd love your feedback on a new health app called Rehlah

✓ 45–60 minute video call (on your phone or computer)
✓ No medical knowledge required
✓ Completely anonymous — your health data stays private
✓ Compensation: 150 SAR gift voucher (or equivalent)
✓ Participation is 100% voluntary

To express interest, fill out this short form:
[SCREENING FORM LINK]

Questions? Contact: [researcher@rehlah.com]
-------------------------------------------
```

### Ethical & Safety Requirements (CRITICAL)
⚠️ **Cancer patients are a vulnerable population. Follow these safeguards:**

1. **No deception** — Participants must know they are testing an app prototype, not receiving clinical services
2. **Medical disclaimer** — Reiterate at start and end that Rehlah is not a medical device and does not replace clinical care
3. **Emotional safety protocol** — Sessions may trigger distress. Have a protocol ready (see Part 7)
4. **IRB/Ethics review** — If recruiting through clinics, institutional ethics approval is required
5. **Data minimisation** — Do not collect or store any real health data from participants
6. **Right to withdraw** — Participants can end the session at any time without explanation
7. **Compensation is not conditional** — Pay regardless of whether they complete all tasks

---

## Part 4 — Screening Questionnaire

### Screener Form (Google Forms / Typeform)

**Introduction text:**
> "Thank you for your interest in Rehlah user research. This short screening form (3 minutes) helps us understand if this study is right for you. All responses are confidential."

---

**Q1. Which of the following best describes you?** *(Select one)*
- [ ] I am currently receiving cancer treatment
- [ ] I completed cancer treatment within the last 2 years
- [ ] I am a family member or close friend who regularly helps someone with cancer
- [ ] I work in oncology or cancer care (nurse, social worker, patient navigator)
- [ ] None of the above

> *Disqualify: "None of the above"*

---

**Q2. How comfortable are you using apps on a smartphone?** *(Select one)*
- [ ] Very comfortable — I use many apps regularly
- [ ] Somewhat comfortable — I use a few apps (WhatsApp, maps)
- [ ] Not very comfortable — I avoid apps when I can
- [ ] I do not have a smartphone

> *Disqualify: "I do not have a smartphone"*
> *Note: Low comfort = prioritise for accessibility insights*

---

**Q3. Do you currently use any health apps or tools to track your symptoms, medications, or appointments?** *(Select one)*
- [ ] Yes, regularly
- [ ] I've tried some but don't use them consistently
- [ ] No, I haven't tried any
- [ ] I don't know what health apps are

---

**Q4. In the past month, how often have you felt uncertain or anxious about your health between doctor appointments?** *(Select one)*
- [ ] Almost every day
- [ ] Several times a week
- [ ] Once or twice
- [ ] Rarely or never

> *Recruit higher frequency respondents as priority*

---

**Q5. Which language do you prefer for the session?**
- [ ] English
- [ ] Arabic
- [ ] Either is fine

> *Note: Current prototype is English. Arabic-preference participants should be informed the app is in English only for now*

---

**Q6. Are you willing to join a 45–60 minute video call in the next 2 weeks?**
- [ ] Yes
- [ ] No

> *Disqualify: No*

---

**Q7. [Optional] Would you like to participate in a 2-week diary study where you use the app daily and share brief notes?**
- [ ] Yes, I'm interested
- [ ] No, the one-time session is fine

---

**Q8. Your name and contact (WhatsApp / Email):**
*(For scheduling only — stored securely)*

---

**Q9. [Optional — helps us ensure diversity] What type of cancer are you or your family member dealing with?**
*(Free text — not used for screening, used for participant mix)*

---

### Screener Scoring
| Response Pattern | Outcome |
|----------------|---------|
| Active patient, smartphone comfortable, high anxiety frequency | **Priority recruit** |
| Survivor or caregiver, any comfort level | **Recruit** |
| Low tech comfort + patient | **Recruit — accessibility insights** |
| No smartphone | **Disqualify** |
| Not patient/caregiver/clinical | **Disqualify** |

---

## Part 5 — Informed Consent

### Consent Form (English)

---

**INFORMED CONSENT FOR PARTICIPATION IN USABILITY RESEARCH**
**Rehlah App — User Testing Study**

**Study Title:** Usability and Experience Testing of the Rehlah Health Companion App
**Researcher:** [Name], [Organisation]
**Contact:** [email] | [phone/WhatsApp]
**Date of Version:** April 2026

---

**What is this study about?**
We are testing a prototype of a mobile health companion app called Rehlah, designed to support cancer patients and their caregivers between medical appointments. You have been invited because your experience is directly relevant to the app we are designing.

**What will I be asked to do?**
- Join a 45–60 minute video call (via Zoom, Google Meet, or WhatsApp Video)
- Use the Rehlah app prototype on your phone or computer while the researcher observes
- Complete 4–6 specific tasks (e.g., "Find where to log your mood today")
- Share your thoughts aloud as you use the app ("think aloud" method)
- Answer questions about your experience at the end

**Will my health data be used?**
No. You will be using a prototype with demo/sample data. You will not need to enter any real personal health information. If you accidentally enter real data, it is not stored anywhere and the researcher will delete the session recording immediately if requested.

**Will the session be recorded?**
With your permission, the session will be screen-recorded (and optionally audio-recorded) for analysis purposes only. Recordings are:
- Stored securely with password protection
- Accessible only to the research team
- Deleted after the study analysis is complete (within 90 days)
- Never shared externally or used for marketing

**Is participation voluntary?**
Yes. You may:
- Decline to answer any question
- Stop the session at any time
- Withdraw your data after the session (within 48 hours)

Declining or withdrawing will have no consequence whatsoever.

**Will I be compensated?**
Yes — participants receive a 150 SAR gift voucher (or equivalent in your local currency) upon completing the session, regardless of whether you finish all tasks.

**Important: This is not a medical service**
Rehlah is a prototype app and is not a medical device. Nothing in this study provides medical advice. If you have a health emergency, please contact your healthcare provider or emergency services.

**Do you have questions?**
Contact the researcher at: [email/WhatsApp]

---

**By proceeding with the session, you confirm:**
- [ ] I understand the purpose of this study
- [ ] I understand this is an app prototype, not a medical service
- [ ] I agree to the session being recorded (screen + audio) for research purposes
- [ ] I understand I can stop or withdraw at any time
- [ ] I am 18 years of age or older

**Participant signature / verbal confirmation:** ___________________________
**Date:** ___________________________
**Researcher witness:** ___________________________

---

### Consent Form (Arabic — النموذج العربي)

---

**موافقة مستنيرة للمشاركة في بحث قابلية الاستخدام**
**تطبيق رحلة — دراسة اختبار المستخدمين**

---

**ما الغرض من هذه الدراسة؟**
نقوم باختبار نموذج أولي لتطبيق مرافق صحي يُسمى "رحلة"، مصمم لدعم مرضى السرطان ومقدّمي الرعاية بينهم وبين المواعيد الطبية.

**ماذا سيُطلب مني؟**
- الانضمام إلى مكالمة فيديو تستمر 45–60 دقيقة
- استخدام تطبيق رحلة على هاتفك بينما يراقب الباحث
- إكمال 4–6 مهام محددة
- مشاركة أفكارك بصوت عالٍ أثناء الاستخدام
- الإجابة على أسئلة في نهاية الجلسة

**هل سيُستخدم بياناتي الصحية؟**
لا. ستستخدم بيانات تجريبية فقط. لا يتم تخزين أي بيانات صحية حقيقية.

**هل ستُسجَّل الجلسة؟**
بموافقتك، ستُسجَّل شاشتك للتحليل فقط، وتُحذف خلال 90 يوماً.

**هل المشاركة طوعية؟**
نعم. يمكنك الانسحاب في أي وقت دون أي عواقب.

**هل سأحصل على مكافأة؟**
نعم — قسيمة شراء بقيمة 150 ريال سعودي عند إتمام الجلسة.

---

**بالمتابعة، أؤكد موافقتي على ما سبق.**

---

## Part 6 — Moderated Session Script

### Pre-Session Setup Checklist
- [ ] Participant screener confirmed
- [ ] Consent collected (verbal or signed)
- [ ] Screen recording tool ready (Lookback.io / Maze / Zoom recording)
- [ ] Prototype URL ready: https://nadbrahmi.github.io/Rehlah/
- [ ] Observation notes template open
- [ ] Timer ready (session is 60 min max)
- [ ] Emotional support protocol reviewed (Part 7)

---

### Session Agenda (60 minutes)

| Phase | Duration | Content |
|-------|----------|---------|
| Welcome & consent | 5 min | Introductions, consent, recording permission |
| Context interview | 10 min | Background questions |
| Think-aloud brief | 3 min | Explain method |
| Task 1: First impression | 5 min | Welcome screen |
| Task 2: Onboarding | 10 min | Complete 5-step wizard |
| Task 3: First check-in | 8 min | Daily check-in (quick mode) |
| Task 4: Add medication | 5 min | Care Hub → medications |
| Task 5: Explore lab results | 5 min | Lab tracker |
| Task 6: AI assistant | 5 min | Ask a question |
| Debrief & SUS | 8 min | Post-test questions + SUS scale |
| Closing | 1 min | Compensation, thanks |

---

### PHASE 1 — Welcome & Consent (5 min)

**Moderator script:**

> "Hi [Name], thank you so much for joining me today. My name is [Name] and I'm part of the team building Rehlah.
>
> Before we start — just to set expectations: you are not being tested. The app is being tested. There are no right or wrong answers. If something is confusing, that's valuable information for us to improve.
>
> I'll ask you to think out loud — that means narrating what you're doing, what you're noticing, and what you're wondering about. It can feel a bit strange at first but it helps us enormously.
>
> The session will take about 45–60 minutes. I may take brief notes while you talk — please ignore that, I'm just capturing what you say.
>
> Do you have any questions before we begin?"

**→ Confirm consent and recording permission:**
> "Are you comfortable with me recording the screen during our session? The recording is only for research analysis and won't be shared anywhere."

---

### PHASE 2 — Context Interview (10 min)

*Objective: Understand the participant's lived experience to contextualise their reactions*

> "Before we look at the app, I'd love to understand a bit about your situation — only share what you're comfortable with."

**Q1 — Role**
> "Can you tell me a little about your experience with cancer — whether as a patient, survivor, or caregiver?"

*Listen for: diagnosis timeline, treatment phase, emotional state, support system*

**Q2 — Current tools**
> "Right now, between your medical appointments, how do you keep track of things — symptoms, medications, appointments? What tools or methods do you use?"

*Listen for: paper notebooks, WhatsApp, existing apps, nothing*

**Q3 — Pain points**
> "What's the most frustrating or difficult part of managing your health (or a family member's health) between appointments?"

*Listen for: anxiety, information overload, medication management, lab confusion*

**Q4 — Unmet need**
> "If you could have one thing to make this easier — one tool or piece of information — what would it be?"

*This is a gold-standard question. Capture verbatim.*

---

### PHASE 3 — Think-Aloud Brief (3 min)

> "Now I'm going to share a link with you / show you the app. Before you do anything, I want to explain how we'll work:
>
> I'm going to ask you to think out loud as you use the app. Say what you're looking at, what you're trying to do, what you expect to happen, and what you're confused about.
>
> For example, if you're on this screen and you see a button, you might say: 'I see a purple button that says Start. I think clicking it will take me into the app. Let me try.'
>
> Don't worry about saying the right things — just talk me through your experience. I'll try not to guide you or answer your questions during the tasks, because I want to see how you naturally use it. After each task, we can talk.
>
> Ready? Here's the app: [share screen / send link]"

---

### PHASE 4 — Task Scenarios

#### TASK 1 — First Impression (5 min)
**Setup:** Participant sees the Welcome screen for the first time.

**Moderator reads:**
> "Take a moment to look at this screen. Don't click anything yet — just tell me what you notice and what you understand about what this app does."

**Probing questions (after 60 seconds):**
- "What do you think this app is for?"
- "Who do you think it's designed for?"
- "Is there anything that catches your attention immediately?"
- "Is there anything confusing or unclear?"
- "Based on what you see, would you want to continue into the app? Why or why not?"

**Observation guide:**
- [ ] Can participant identify the app's purpose without reading every word?
- [ ] Does the emotional tone feel appropriate? (note any reactions)
- [ ] Do the feature pills communicate value?
- [ ] Does "No account needed" reduce friction?
- [ ] Time to first positive or negative reaction: _____ seconds

---

#### TASK 2 — Onboarding (10 min)
**Setup:** Participant is at the Welcome screen.

**Moderator reads:**
> "Now I'd like you to go ahead and start the app as you normally would — as if you just downloaded it and are setting it up for the first time. Tell me what you're doing as you go."

**Task success criteria:**
- [ ] Participant selects a role (patient or caregiver)
- [ ] Participant enters a name
- [ ] Participant selects a cancer type
- [ ] Participant selects a stage or uses "Not sure"
- [ ] Participant completes or skips the dates
- [ ] Participant reaches the Journey Created screen

**Probing questions (after completing or getting stuck):**
- "How did that feel overall?"
- "Was there any step where you weren't sure what to do?"
- "Did you feel like the app was asking for the right information?"
- "Was there anything you wished you could skip?"
- "The 'Not sure' option for cancer stage — did you notice it? What did you think of it?"
- "How did you feel seeing your name used in the app after entering it?"

**Observation guide:**
- [ ] Time to complete onboarding: _____ minutes
- [ ] Steps where participant hesitated (>5 sec): _____________
- [ ] Steps where participant asked a question: _____________
- [ ] Did participant notice/use "Not sure" option?
- [ ] Emotional reaction at Journey Created screen: _____________
- [ ] Did participant read the confetti/celebration screen or skip past it?

---

#### TASK 3 — First Daily Check-In (8 min)
**Setup:** Participant is on the Home screen after onboarding.

**Moderator reads:**
> "You've set up your profile. It's the morning of your first day with the app. I'd like you to complete what you would normally do first thing in the morning with this app."

*Wait — do not say "check-in." Let them discover it.*

**If participant cannot find the check-in after 60 seconds:**
> "Is there anything on this screen that might be for tracking how you're feeling today?"

**If still stuck after 30 more seconds:**
> "Let's try the button in the middle of the bottom bar — the circle button."

**Task success criteria:**
- [ ] Participant finds the check-in entry point
- [ ] Participant selects a mood emoji (Step 1)
- [ ] Participant moves sliders for physical symptoms (Step 2)
- [ ] Participant confirms medication (Step 3)
- [ ] Participant completes the check-in
- [ ] Participant reaches completion/celebration screen

**Probing questions:**
- "How easy or difficult was it to find where to do the check-in?"
- "The sliders for symptoms — did they make sense? Were there any symptoms missing that you'd want to track?"
- "The mood emojis — did they capture how you might actually feel?"
- "How long did this check-in feel? Did it feel too long, too short, or about right?"
- "After completing it — how did that make you feel?"

**Observation guide:**
- [ ] Time to find check-in entry: _____ seconds
- [ ] Time to complete check-in: _____ minutes
- [ ] Did participant use Quick Mode or Full Mode?
- [ ] Emotional reaction at completion screen: _____________
- [ ] Any slider values that caused confusion: _____________
- [ ] Did they understand the streak concept?

---

#### TASK 4 — Add a Medication (5 min)
**Setup:** Participant is on the Home screen.

**Moderator reads:**
> "You take a daily medication — let's say it's called Tamoxifen, and you take it every morning. Can you add it to the app?"

**Task success criteria:**
- [ ] Participant navigates to Care Hub (or medications via quick action)
- [ ] Participant opens medication tracker
- [ ] Participant finds the "Add medication" function
- [ ] Participant enters medication name and frequency
- [ ] Participant saves the medication

**Probing questions:**
- "How did you find the medications section?"
- "Was the process of adding a medication clear?"
- "If you were managing multiple medications, do you feel this would help you? How?"

**Observation guide:**
- [ ] Navigation path taken: _____________
- [ ] Time to complete: _____ minutes
- [ ] Points of confusion: _____________

---

#### TASK 5 — Lab Results (5 min)
**Setup:** Participant is anywhere in the app.

**Moderator reads:**
> "You just received your blood test results from your last appointment. Where would you go in this app to understand what those numbers mean?"

*Note: This tests information architecture and mental model, not just button-finding*

**Task success criteria:**
- [ ] Participant locates Lab Tracker or Lab Analyzer
- [ ] Participant understands the purpose of at least one lab value shown
- [ ] Participant can identify whether a value is in the normal range

**Probing questions:**
- "Were you able to find where lab results live in the app?"
- "When you look at this screen — does this format help you understand your results? What works? What doesn't?"
- "Is there anything missing that you'd want to see when reviewing lab results?"
- "The colour coding (green/orange/red) — is that clear?"

**Observation guide:**
- [ ] Navigation path: _____________
- [ ] Time to find: _____ seconds
- [ ] Could participant correctly identify in-range vs. out-of-range value?
- [ ] Emotional response to lab results screen: _____________

---

#### TASK 6 — AI Health Assistant (5 min)
**Setup:** Participant is anywhere in the app.

**Moderator reads:**
> "It's 11pm. You're feeling very nauseous and you're worried. You want to ask a question about whether this is normal. Where would you go in this app?"

**Task success criteria:**
- [ ] Participant locates AI assistant
- [ ] Participant sends a message or taps a quick-question chip
- [ ] Participant reads and reacts to the AI response

**Probing questions:**
- "Did you find the assistant easily?"
- "How did the response make you feel?"
- "Do you trust this kind of answer? Why or why not?"
- "Is there anything about the response that would make you more or less comfortable?"
- "Would you actually use this at 11pm if you were feeling anxious? Why or why not?"

**Observation guide:**
- [ ] Navigation path: _____________
- [ ] Did participant read disclaimer at the bottom?
- [ ] Emotional reaction to AI response: _____________
- [ ] Did participant use quick chips or typed their own?
- [ ] Did response feel reassuring or alarming?

---

### PHASE 5 — Post-Test Debrief (8 min)

#### System Usability Scale (SUS)
*Ask participant to rate each statement 1 (Strongly Disagree) to 5 (Strongly Agree):*

| # | Statement | Score (1–5) |
|---|-----------|-------------|
| 1 | I think I would like to use this app frequently | |
| 2 | I found the app unnecessarily complex | |
| 3 | I thought the app was easy to use | |
| 4 | I think I would need support to use this app | |
| 5 | I found the various functions in this app were well integrated | |
| 6 | I thought there was too much inconsistency in this app | |
| 7 | I would imagine that most people would learn to use this app very quickly | |
| 8 | I found the app very cumbersome to use | |
| 9 | I felt very confident using the app | |
| 10 | I needed to learn a lot of things before I could get going | |

**SUS Score Calculation:**
- Odd items: subtract 1 from score
- Even items: subtract from 5
- Sum all adjusted scores × 2.5
- **Score < 68** = Below average usability
- **Score 68–80** = Good usability
- **Score > 80** = Excellent usability
- **Target for Rehlah: ≥ 72 (Good)**

---

#### Debrief Interview Questions

**Emotional overall:**
> "Taking the whole session together — how did using this app feel? Not just usable, but feel."

**Value proposition:**
> "If a close friend who just got a cancer diagnosis asked you 'should I use this app?' — what would you say?"

**Missing features:**
> "Is there anything important to your daily experience that you expected to find but didn't?"

**Language and tone:**
> "Did the language feel right for someone going through what you're going through? Any words or phrases that felt off?"

**Trust:**
> "Did you feel the app was trustworthy? What made you feel that way — or not?"

**Arabic:**
> "The app is currently in English. How important would it be for you to have it in Arabic?"

**One change:**
> "If you could change one thing about what you saw today — what would it be?"

---

## Part 7 — Emotional Safety Protocol

### Why This Protocol Exists
Cancer patients in active treatment may experience distress during sessions triggered by:
- Seeing symptom-tracking screens (reminds them of bad days)
- Lab result screens (triggers anxiety)
- Community screens (reminds them of others who didn't survive)
- Simply talking about their diagnosis in detail

### Warning Signs to Watch For
- Extended silence
- Voice breaking or tearfulness
- Participant says they need a moment
- Participant asks to stop

### Moderator Response Protocol

**Level 1 — Mild distress (participant seems slightly emotional):**
> "I can see this might be bringing up some feelings. That's completely understandable. Take as long as you need. We don't have to continue this task if you'd prefer to move on."

**Level 2 — Visible tearfulness or voice breaking:**
> "Let's pause for a moment. You've shared something really meaningful and I appreciate it. Can I ask — are you okay to continue, or would you prefer to take a break or end the session here? Either is completely fine."

**Level 3 — Participant expresses significant distress:**
> "Your wellbeing is the most important thing right now. I'd like to stop the session and check in on you as a person first. The research is not important compared to how you're feeling right now."
>
> *[End session recording immediately]*
>
> *[Have on hand: list of support resources to share — see below]*

### Support Resources to Have Ready
- **KSA:** National Centre for Mental Health — 920033360
- **KSA:** Saudi Cancer Foundation patient support — www.cancerfoundation.org.sa
- **Regional:** Cancer Research UK Helpline (English) — 0808 800 4040
- **General:** Your clinical contact / oncology nurse (patient's own care team)

---

## Part 8 — Diary Study Protocol (14-Day)

### Purpose
Validate the 14-day UX flow in real conditions — do users actually check in consistently? Does Day 5 missed-check-in recovery work? Does Day 7 streak celebration land?

### Participant Commitment
- Use the prototype app once per day for 14 days
- Send a brief WhatsApp voice note or text after each day (2 min max)
- Attend one 20-minute debrief call at Day 7 and one at Day 14

### Daily Diary Prompt (sent via WhatsApp)
```
رحلة Daily Diary — Day [X]

Please answer in voice note or text — whatever is easier:
1. Did you open the app today? (Yes / No)
2. If yes — what did you do in the app?
3. One word to describe how the app made you feel today
4. Anything that confused you, frustrated you, or made you smile?

No right or wrong answers. 2 minutes is enough 💜
```

### Day 7 Mid-Point Check-In Questions
1. "Are you still using the app? What's driving you to continue or stop?"
2. "Has the app changed how you track your health in any way?"
3. "Is there a moment from the last 7 days where the app helped you or disappointed you?"
4. "The streak — did you notice it? Did it motivate you or add pressure?"

### Day 14 Final Interview Questions
1. "Looking back at 14 days — did the app become part of your routine?"
2. "Did you feel the app knew you better by Day 14 than Day 1?"
3. "Did anything in the app make you feel less alone?"
4. "Did you show the app to anyone — a family member, a doctor?"
5. "If we launched this tomorrow, would you download it for real?"

### Day 14 Success Criteria (from Doc 09)
| Criteria | Target |
|---------|--------|
| Check-ins completed | ≥ 7 of 14 days |
| Medication added | ≥ 1 |
| Lab result entered | ≥ 1 |
| AI assistant used | ≥ 1 |
| Community tab visited | ≥ 1 |

---

## Part 9 — Observation & Note-Taking Template

### During-Session Notes (one sheet per participant)

```
PARTICIPANT ID: P[01–10]
DATE: _______________
SESSION TYPE: Moderated / Diary
ROLE: Patient / Caregiver / Survivor
TECH COMFORT: High / Medium / Low

--- CONTEXT INTERVIEW ---
Current tools used: _______________
Biggest pain point: _______________
One thing they want: _______________

--- TASK OBSERVATIONS ---

TASK 1 (First Impression)
Time to state app purpose: ___ sec
App purpose stated correctly: Y / N
Notable quote: "_______________"
Emotional tone: Positive / Neutral / Confused / Concerned

TASK 2 (Onboarding)
Time to complete: ___ min
Completion: Full / Partial / Could not complete
Steps with hesitation: _______________
Reaction at Journey Created: _______________
Notable quote: "_______________"

TASK 3 (Check-In)
Time to find entry point: ___ sec
Time to complete: ___ min
Mode used: Quick / Full
Emotional reaction at completion: _______________
Notable quote: "_______________"

TASK 4 (Medication)
Navigation path taken: _______________
Completion: Y / N / Partial
Confusion points: _______________

TASK 5 (Lab Results)
Navigation path taken: _______________
Understood in-range / out-of-range: Y / N
Emotional reaction: _______________

TASK 6 (AI Assistant)
Input method: Quick chip / Typed
Response reaction: Reassured / Neutral / Skeptical / Concerned
Read disclaimer: Y / N / Unclear

--- POST-TEST ---
SUS Score: ___/100
"Would recommend to friend with cancer": Y / N / Maybe
Most important missing feature: _______________
Language/tone feedback: _______________
One word to describe app: "_______________"

--- MODERATOR NOTES ---
Most important observation: _______________
Highest-priority fix: _______________
Surprises: _______________
```

---

## Part 10 — Analysis Framework

### After All Sessions Are Complete

**Step 1 — Watch recordings (2x speed), highlight moments:**
- Confusion (participant hesitates >5 sec)
- Delight (positive vocal/visual reaction)
- Error (participant does something unintended)
- Verbatim (memorable direct quote)

**Step 2 — Affinity mapping (remote: FigJam / Miro):**
Cluster observations into themes:
- Navigation & IA issues
- Tone & language feedback
- Feature gaps
- Emotional reactions
- Technical issues

**Step 3 — Severity scoring for issues:**
| Severity | Definition | Action |
|---------|-----------|--------|
| **Critical (P0)** | Prevents task completion | Fix before any launch |
| **High (P1)** | Major confusion, significant effort | Fix in next sprint |
| **Medium (P2)** | Minor confusion, workaround exists | Backlog |
| **Low (P3)** | Polish / preference | Nice-to-have |

**Step 4 — Calculate aggregate SUS score:**
- Average all participant SUS scores
- Report with 95% confidence interval
- Compare against 68 benchmark

**Step 5 — Write synthesis report (Doc 12):**
- Executive summary (1 page)
- Top 5 findings with evidence quotes
- Issue list with severity ratings
- Recommendations with priority order
- What we validated (what works)

---

## Part 11 — Reporting Template

### Usability Test Report Structure (Doc 12)

```
1. Executive Summary
   - Study purpose and dates
   - Participants (number, mix)
   - Overall SUS score
   - Top 3 findings
   - Recommended next steps

2. Methodology
   - Study type and duration
   - Participant profiles
   - Tasks and scenarios
   - Analysis method

3. Key Findings (5–8 findings)
   For each finding:
   - Finding statement
   - Supporting evidence (quotes, observation count)
   - Severity (P0/P1/P2/P3)
   - Recommendation

4. Task Success Rates
   - Task 1: First Impression — % understood purpose
   - Task 2: Onboarding — % completed unaided
   - Task 3: Check-In — % completed within 3 min
   - Task 4: Medication — % completed unaided
   - Task 5: Lab Results — % correctly identified range
   - Task 6: AI Assistant — % felt reassured by response

5. What Worked (Validated)
   - Features/flows that tested well
   - Emotional moments that landed

6. Issue List
   | ID | Issue | Screen | Severity | Recommendation |

7. Quotes Highlight Reel
   - 8–10 most powerful verbatim quotes

8. Next Steps
   - P0/P1 fixes (immediate)
   - Phase 2 development priorities
   - Follow-on research questions
```

---

## Part 12 — Tools & Resources

### Recommended Testing Tools

| Need | Free Option | Paid Option |
|------|------------|-------------|
| Session recording | Zoom (cloud record) | Lookback.io, UserTesting.com |
| Screen + think-aloud | OBS Studio | Hotjar (screen record) |
| Unmoderated testing | Maze (free tier) | UserZoom, Optimal Workshop |
| Survey / screener | Google Forms, Typeform | SurveyMonkey |
| Affinity mapping | FigJam (free) | Miro, Dovetail |
| Participant scheduling | Calendly (free) | |
| Data storage | Google Drive (encrypted) | |

### Budget Estimate (8–10 participants)
| Item | Cost |
|------|------|
| Participant compensation (10 × 150 SAR) | 1,500 SAR |
| Recruiting ads (social media) | 300–500 SAR |
| Testing platform (Maze / Lookback basic) | 0–200 SAR/month |
| Transcription service | 100–200 SAR |
| **Total estimate** | **~2,200–2,400 SAR** |

---

## Part 13 — Quick-Start Checklist (Week-by-Week)

### Week 1 — Recruitment
- [ ] Finalise and publish screener (Google Forms)
- [ ] Post recruitment in 3+ channels
- [ ] Collect and score screener responses
- [ ] Confirm 8–10 participants + 5 diary study participants
- [ ] Send consent forms for review
- [ ] Schedule sessions (Calendly)
- [ ] Test prototype on your own device + test recording setup
- [ ] Brief any co-moderators or observers

### Week 2 — Sessions
- [ ] Run 8–10 moderated sessions (60 min each)
- [ ] Take notes using observation template (Part 9)
- [ ] Save recordings securely immediately after each session
- [ ] Do a quick debrief with your team after every 2 sessions to identify patterns early
- [ ] Send diary participants their first prompt via WhatsApp
- [ ] Track diary completion daily

### Week 3 — Analysis
- [ ] Watch all recordings (can be at 2x)
- [ ] Transfer notes into affinity map (FigJam/Miro)
- [ ] Calculate all SUS scores
- [ ] Write 5–8 key findings
- [ ] Rate all issues by severity
- [ ] Prepare synthesis report (Doc 12 template)

### Week 4 — Action
- [ ] Present findings to team
- [ ] Fix all P0 issues immediately
- [ ] Plan P1 fixes in next development sprint
- [ ] Brief diary study participants on Day 7 check-in call
- [ ] Document validated design decisions (what NOT to change)

---

*Document 11 of the Rehlah Specification Suite*
*Version 1.0 | April 2026*
*Live Prototype: https://nadbrahmi.github.io/Rehlah/*
*Repository: https://github.com/nadbrahmi/Rehlah/*
