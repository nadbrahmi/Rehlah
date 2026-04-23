# DOCUMENT 14 — Going Live: Operational Requirements, Costs & Infrastructure
**Rehlah | Version 1.0 | April 2026**

---

> **Purpose:** A complete, honest answer to "what do I need to go from prototype to real users?" Covers every service, API, tool, compliance requirement, and cost — with three budget tiers and a phased rollout plan.

---

## EXECUTIVE SUMMARY

To accept real users, Rehlah needs **5 things that the prototype currently lacks**:

| # | What's Needed | Why | Estimated Cost |
|---|--------------|-----|---------------|
| 1 | **Backend + Database** | Data lives on device today — users lose everything if they uninstall | ~$0–50/month |
| 2 | **Authentication** | No accounts = no cloud sync, no re-login, no data recovery | ~$0–25/month |
| 3 | **Real AI** | Current AI is a keyword lookup table, not a real LLM | ~$20–200/month |
| 4 | **Push Notifications** | No check-in reminders = low retention | ~$0 |
| 5 | **App Store Distribution** | GitHub Pages is a demo, not a distribution channel | ~$100/year (Android) |

**Minimum operational cost for first 500 users: ~$50–150/month**
**One-time setup cost: ~$400–800**

---

## PART 1 — WHAT THE PROTOTYPE DOES TODAY (AND WHAT IT DOESN'T)

### Current State
```
User opens app
      ↓
Data stored in browser/phone local storage (SharedPreferences)
      ↓
No server. No account. No sync. No backup.
      ↓
User deletes app → ALL DATA GONE
User changes phone → ALL DATA GONE
User logs in from another device → IMPOSSIBLE
```

### What "Operational" Means
```
User creates account
      ↓
Data synced to secure cloud database
      ↓
User can delete app, change phones, re-login
      ↓
AI assistant uses real language model
      ↓
Push notifications remind them to check in
      ↓
Data is encrypted and HIPAA/PDPL compliant
```

---

## PART 2 — THE TECHNOLOGY STACK (RECOMMENDED)

### Why Firebase (Not a Custom Backend)
For a team of 1–3 people building a health app, Firebase is the right choice because:
- **No DevOps** — no servers to manage, patch, or scale
- **All-in-one** — Auth + Database + Push Notifications + Storage in one platform
- **Flutter SDK** — official Flutter packages, well maintained
- **Generous free tier** — 0–500 users costs essentially nothing
- **KSA data residency** — Firebase supports Middle East region (me-central2 in Qatar/UAE)
- **HIPAA BAA available** — Required for health data compliance (on paid plans)

### The Stack

```
┌─────────────────────────────────────────────────────────┐
│                        USERS                            │
│            Android App    iOS App (Phase 3)             │
└───────────────────────────┬─────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                   FIREBASE PLATFORM                      │
│                                                         │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │ Firebase    │  │  Firestore   │  │  Firebase     │  │
│  │ Auth        │  │  Database    │  │  Cloud        │  │
│  │             │  │              │  │  Messaging    │  │
│  │ Email/pass  │  │  Users       │  │  (FCM)        │  │
│  │ Google sign │  │  check_ins   │  │               │  │
│  │ Apple sign  │  │  medications │  │  Push notifs  │  │
│  │             │  │  lab_reports │  │  Reminders    │  │
│  │ FREE: 50K   │  │  appointments│  │               │  │
│  │ auth/month  │  │              │  │  FREE: always │  │
│  └─────────────┘  └──────────────┘  └───────────────┘  │
│                                                         │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │ Firebase    │  │  Firebase    │  │  Firebase     │  │
│  │ Storage     │  │  Functions   │  │  App Check    │  │
│  │             │  │  (optional)  │  │               │  │
│  │ Lab PDFs    │  │  AI proxy    │  │  Prevents     │  │
│  │ Profile     │  │  Scheduled   │  │  API abuse    │  │
│  │ images      │  │  tasks       │  │               │  │
│  │             │  │              │  │  FREE         │  │
│  │ FREE: 5GB   │  │ FREE: 2M     │  │               │  │
│  └─────────────┘  │ calls/month  │  └───────────────┘  │
│                   └──────────────┘                      │
└─────────────────────────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                      AI LAYER                            │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  OpenAI API (GPT-4o-mini)                       │   │
│  │                                                 │   │
│  │  • AI Health Assistant (chat)                   │   │
│  │  • Lab result plain-language explanation        │   │
│  │  • Symptom pattern interpretation               │   │
│  │  • Oncology-specific system prompt              │   │
│  │                                                 │   │
│  │  Cost: ~$0.15 per 1M input tokens               │   │
│  │  Estimated: $20–80/month for 500 active users   │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────┐
│                  DISTRIBUTION                            │
│                                                         │
│  Google Play Store ($25 one-time)                       │
│  Apple App Store ($99/year) — Phase 3                  │
│  Web (GitHub Pages — free, keep for demos)             │
└─────────────────────────────────────────────────────────┘
```

---

## PART 3 — SERVICE-BY-SERVICE BREAKDOWN

### SERVICE 1 — Firebase Authentication
**What it does:** Manages user accounts, login, password reset, session tokens

**Setup:**
1. Create Firebase project at console.firebase.google.com
2. Enable Email/Password authentication
3. (Optional later) Enable Google Sign-In and Apple Sign-In
4. Add `firebase_auth: 5.x` to Flutter pubspec.yaml

**Flutter code change required:**
```dart
// Replace current: navigate to /main directly after onboarding
// With: Firebase Auth + save UID + create Firestore user document

final credential = await FirebaseAuth.instance
    .createUserWithEmailAndPassword(email: email, password: password);
final uid = credential.user!.uid;
// Then save journey data to Firestore under /users/{uid}/
```

**Cost:**
| Tier | Auth per month | Cost |
|------|---------------|------|
| Free (Spark) | 50,000 MAU | $0 |
| Paid (Blaze) | 50,000 MAU free, then $0.0055/MAU | Pay-as-you-go |

**For first 500 users: FREE**
**For 10,000 users: ~$0/month** (still under free tier)

---

### SERVICE 2 — Firestore Database
**What it does:** Stores all user health data in the cloud — check-ins, medications, lab reports, appointments

**Data Structure:**
```
firestore/
├── users/
│   └── {userId}/
│       ├── profile          (document: name, cancer type, stage, treatment phase)
│       ├── journey          (document: diagnosis date, treatment start, milestones)
│       ├── check_ins/       (collection: one document per day)
│       │   └── {checkInId}  (mood, pain, fatigue, nausea, sleep, appetite, notes)
│       ├── medications/     (collection: one document per medication)
│       │   └── {medId}      (name, dose, frequency, times)
│       ├── med_logs/        (collection: daily dose confirmations)
│       │   └── {logId}      (medId, date, taken: bool)
│       ├── appointments/    (collection)
│       │   └── {apptId}     (title, doctor, date, notes, completed: bool)
│       └── lab_reports/     (collection)
│           └── {reportId}   (date, entries: [{metric, value}], notes)
```

**Flutter code change required:**
```dart
// Replace current SharedPreferences writes:
await prefs.setString('checkIns', jsonEncode(checkIns.map(...).toList()));

// With Firestore writes:
await FirebaseFirestore.instance
    .collection('users').doc(uid)
    .collection('check_ins').doc(checkIn.id)
    .set(checkIn.toMap());
```

**Firestore Pricing:**
| Operation | Free Tier (per day) | Paid Rate |
|-----------|-------------------|-----------|
| Reads | 50,000 | $0.06 per 100K |
| Writes | 20,000 | $0.18 per 100K |
| Deletes | 20,000 | $0.02 per 100K |
| Storage | 1 GB | $0.18/GB/month |

**Estimated usage per active user per day:**
- ~20 reads (loading screens)
- ~5 writes (check-in, med log, etc.)
- Daily for 500 users: 10,000 reads, 2,500 writes
- **Cost for 500 daily active users: FREE (under limits)**
- **Cost for 2,000 daily active users: ~$5–15/month**

---

### SERVICE 3 — Firebase Cloud Messaging (FCM)
**What it does:** Sends push notifications — check-in reminders, medication alerts, appointment reminders

**Cost: FREE — always, unlimited messages**

**Setup required:**
1. Enable FCM in Firebase Console
2. Add `firebase_messaging: 15.x` to Flutter
3. Request notification permission on Android 13+
4. Store device FCM token in Firestore on login
5. Send from Firebase Functions (scheduled) or Firebase Console (manual)

**Notification schedule (from Doc 09):**
```
9am — Daily check-in reminder ("How are you feeling today, [Name]?")
6pm — Medication reminder (if dose not logged)
+1h before appointment — Appointment reminder
On critical lab pattern — "Your [WBC] result needs attention — tap to see"
```

---

### SERVICE 4 — OpenAI API (Real AI Assistant)
**What it does:** Replaces the current keyword lookup table with a real language model that can answer any oncology question, reference the user's personal data, and provide contextually relevant responses.

**Model Recommendation: GPT-4o-mini**
- Excellent for health Q&A
- Low cost ($0.15/1M input tokens, $0.60/1M output tokens)
- Fast response (< 2 seconds)
- Strong safety guidelines built in
- Supports system prompts for medical context

**System Prompt Template:**
```
You are a compassionate health companion for cancer patients and caregivers.
Your role is to provide emotional support, practical health information, 
and help users understand their medical data.

User context:
- Name: {userName}
- Cancer type: {cancerType}
- Stage: {stage}  
- Treatment phase: {treatmentPhase}
- Recent mood: {avgMood}/5 (last 7 days)
- Recent symptoms: {topSymptoms}
- Latest labs: {latestLabSummary}

CRITICAL RULES:
1. Always end responses with: "This is not medical advice — please discuss with your care team"
2. Never diagnose conditions
3. Never recommend changing prescribed medications
4. When symptoms are severe (pain ≥4, fever mentioned, confusion), 
   always recommend immediate contact with care team
5. Be warm, supportive, and acknowledge the emotional weight of cancer
6. Use plain language — avoid medical jargon unless explaining a term
7. Responses should be 2–4 paragraphs maximum
8. If asked about something outside oncology/health, gently redirect
```

**Cost calculation:**
```
Average AI conversation:
- System prompt: ~400 tokens
- User message: ~50 tokens  
- Response: ~300 tokens
- Total per message: ~750 tokens

Users: 500
Daily AI messages per active user: 2 (estimate)
Daily total: 1,000 messages × 750 tokens = 750,000 tokens

Monthly: 22.5M tokens
Cost: 22.5M × $0.15/1M input + output ≈ $5–15/month for 500 users
```

**Cost table:**
| Active Users | AI Messages/Day | Monthly Cost |
|-------------|----------------|-------------|
| 100 | 200 | ~$2 |
| 500 | 1,000 | ~$10 |
| 2,000 | 4,000 | ~$40 |
| 10,000 | 20,000 | ~$200 |

**Alternative AI providers:**
| Provider | Model | Cost/1M tokens | Pros | Cons |
|---------|-------|---------------|------|------|
| **OpenAI** | GPT-4o-mini | $0.15 in / $0.60 out | Best quality, safety | Most expensive |
| **Anthropic** | Claude Haiku | $0.25 in / $1.25 out | Excellent at medical | Slightly slower |
| **Google** | Gemini 1.5 Flash | $0.075 in / $0.30 out | Cheapest, fast | Less fine-tuned |
| **Cohere** | Command R | $0.15 in / $0.60 out | Good multilingual | Less known |

**Recommendation: Start with GPT-4o-mini. Switch to Gemini Flash if costs need reducing.**

**Safety layer required:**
```dart
// Before sending to AI API, check for crisis keywords
final crisisKeywords = ['suicide', 'end it', 'can\'t go on', 'want to die'];
if (crisisKeywords.any((kw) => message.toLowerCase().contains(kw))) {
  // Do NOT send to AI
  // Show crisis support resources immediately
  showCrisisModal(context);
  return;
}
```

---

### SERVICE 5 — Firebase Storage (Optional but Recommended)
**What it does:** Stores lab report PDF/photo uploads so users can scan and upload paper results

**Free tier:** 5 GB storage, 1 GB/day download
**Paid:** $0.026/GB/month

**For first 500 users: Almost certainly FREE**
**For 2,000 users with PDFs: ~$2–5/month**

---

### SERVICE 6 — Google Play Store (Android Distribution)
**What it does:** The legitimate channel to distribute the app to Android users

**Requirements:**
- Google Play Developer account: **$25 one-time fee**
- App must meet Play Store policies (health apps have specific requirements)
- Must include privacy policy URL
- Must include medical disclaimer

**Important Play Store policies for health apps:**
- Must not claim to diagnose, treat, or cure conditions
- Must prominently display "not a substitute for professional medical advice"
- May require Personal Health/Medical information declaration
- Must comply with Google's sensitive information policies

**Timeline:** 3–7 days for initial review after submission

---

### SERVICE 7 — Privacy Policy & Terms of Service Hosting
**What it does:** Required by Play Store and legally required for any health app handling personal data

**Options:**
| Option | Cost | What You Get |
|--------|------|-------------|
| Termly.io | Free tier | Generates compliant policy |
| Iubenda | $27/year | PDPL + GDPR compliant |
| GitHub Pages | Free | Host your own policy (needs legal review) |
| Lawyer-drafted | $300–1,500 | Fully custom, highest protection |

**Minimum required documents:**
1. Privacy Policy (what data you collect, how it's used, how to delete)
2. Terms of Service (usage rules, disclaimers)
3. Medical Disclaimer (not a medical device statement)

---

### SERVICE 8 — Error Monitoring (Highly Recommended)
**What it does:** Alerts you when users hit crashes or errors — essential for a health app

**Recommendation: Sentry or Firebase Crashlytics**

| Tool | Cost | Features |
|------|------|---------|
| **Firebase Crashlytics** | FREE | Crash reports, breadcrumbs, alerts |
| **Sentry** | Free for small teams | More detailed, web dashboard |

**Add to Flutter:**
```yaml
firebase_crashlytics: 4.1.3
```

---

## PART 4 — THREE BUDGET TIERS

### Tier 1 — Lean Launch (0–200 users, first 3 months)
*Goal: Validate with real users at minimal cost*

| Service | Provider | Monthly Cost |
|---------|---------|-------------|
| Firebase Auth | Firebase Spark (free) | $0 |
| Firestore Database | Firebase Spark (free) | $0 |
| Push Notifications (FCM) | Firebase Spark (free) | $0 |
| Firebase Storage | Firebase Spark (free) | $0 |
| AI Assistant | OpenAI GPT-4o-mini | ~$5 |
| Error monitoring | Firebase Crashlytics | $0 |
| App distribution | Google Play Developer | $25 one-time |
| Privacy policy hosting | GitHub Pages | $0 |
| Domain (optional) | Namecheap/GoDaddy | $12/year |
| **TOTAL MONTHLY** | | **~$5/month** |
| **One-time setup** | | **~$25–50** |

**Annual cost (Tier 1): ~$85–110/year**

---

### Tier 2 — Growth Stage (200–2,000 users)
*Goal: Sustainable operations with real capabilities*

| Service | Provider | Monthly Cost |
|---------|---------|-------------|
| Firebase Blaze (pay-as-you-go) | Firestore + Auth + Storage | ~$10–30 |
| AI Assistant | OpenAI GPT-4o-mini | ~$20–50 |
| Error monitoring | Sentry Team plan | $26 |
| App distribution | Google Play (existing) | $0 |
| Email service (transactional) | Resend.com | $0–20 |
| Analytics | Firebase Analytics | $0 |
| Apple App Store (iOS) | Apple Developer | $99/year |
| **TOTAL MONTHLY** | | **~$60–130/month** |
| **Annual** | | **~$820–1,660** |

---

### Tier 3 — Scale (2,000–10,000 users)
*Goal: Production-grade with compliance and performance*

| Service | Provider | Monthly Cost |
|---------|---------|-------------|
| Firebase Blaze | Heavy usage | ~$50–150 |
| AI Assistant | OpenAI (volume) | ~$80–200 |
| HIPAA BAA with Firebase | Firebase Blaze required | Included |
| Error monitoring + APM | Sentry Business | $80 |
| Customer support tool | Intercom / Crisp | $39–74 |
| Email service | Postmark | $15 |
| Analytics (advanced) | Mixpanel Growth | $25 |
| Security audit | One-time/annual | $500–2,000/year |
| **TOTAL MONTHLY** | | **~$290–550/month** |

---

## PART 5 — COMPLIANCE REQUIREMENTS (HEALTH DATA)

### Saudi Arabia — PDPL (Personal Data Protection Law)
Saudi Arabia's PDPL (effective September 2023) applies to Rehlah:

| Requirement | What It Means for Rehlah | How to Comply |
|------------|------------------------|--------------|
| **Data minimisation** | Only collect what's needed | Don't ask for data you don't use |
| **Explicit consent** | Users must agree to data collection | Consent screen during onboarding |
| **Right to deletion** | Users can request all data deleted | "Delete my account" feature in Profile |
| **Data residency** | Sensitive data should stay in KSA/GCC | Use Firebase region: `me-central2` (Qatar) |
| **Security measures** | Protect health data technically | Firestore rules + encrypted transit |
| **Breach notification** | Report breaches to NDMO within 72h | Internal incident response plan |
| **Privacy Policy** | Must be accessible and specific | Publish at rehlah.com/privacy |

**NDMO (National Data Management Office):** ndmo.gov.sa
**Fine for non-compliance:** Up to 5M SAR (Category 3 violation)

### HIPAA (If Targeting US Users)
If Rehlah ever targets US patients:
- Firebase Blaze plan includes HIPAA Business Associate Agreement (BAA)
- Must enable encryption at rest (Firebase does this automatically)
- Must audit log all data access
- Cost: Included in Firebase Blaze (no additional charge)

### What You DON'T Need (for a companion app)
Rehlah is a **companion/tracker** — not a clinical tool. This means:
- **No FDA clearance** needed (it tracks, it doesn't diagnose)
- **No CE marking** needed (same reason)
- **No HL7/FHIR** compliance needed (no hospital integration yet)
- **No medical device registration** in Saudi Arabia (not a diagnostic tool)

**Key legal protection:** Always include this disclaimer, visible in app:
> *"Rehlah is a personal health companion app. It is not a medical device and does not provide medical advice, diagnosis, or treatment. Always consult your healthcare provider for medical decisions."*

---

## PART 6 — IMPLEMENTATION SEQUENCE

### Step 1 — Backend Setup (Week 1, ~6 hours of work)

```
1. Create Firebase project
   → console.firebase.google.com → Add project → Name: "Rehlah"
   → Select region: me-central2 (Qatar, closest to KSA)

2. Enable services
   → Authentication → Email/Password → Enable
   → Firestore → Create database → Production mode
   → Storage → Default rules
   → Cloud Messaging → No action needed (automatic)

3. Download configuration
   → Project settings → Android → Add app → package: com.rehlacare.care
   → Download google-services.json → place in android/app/

4. Add Flutter packages to pubspec.yaml:
   firebase_core: 3.6.0
   firebase_auth: 5.3.1
   cloud_firestore: 5.4.3
   firebase_messaging: 15.1.3
   firebase_crashlytics: 4.1.3
```

### Step 2 — Authentication Screen (Week 1–2, ~8 hours)

**New screens to build:**
- Login screen (email + password)
- Sign-up screen (email + password + confirm)
- Forgot password screen (email input → Firebase sends reset link)
- Email verification prompt

**Logic change in main.dart:**
```dart
// Current: Always go to WelcomeScreen
initialRoute: '/'

// New: Check auth state, then go to appropriate screen
home: StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.hasData) return MainScreen();  // Logged in
    return WelcomeScreen();                      // Not logged in
  },
)
```

### Step 3 — Migrate Data to Firestore (Week 2–3, ~12 hours)

Replace SharedPreferences calls with Firestore in AppProvider and LabProvider:

```dart
// In AppProvider, replace:
Future<void> _saveCheckIns() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('checkIns', jsonEncode(_checkIns.map((c) => c.toMap()).toList()));
}

// With:
Future<void> _saveCheckIn(CheckIn checkIn) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance
      .collection('users').doc(uid)
      .collection('check_ins').doc(checkIn.id)
      .set(checkIn.toMap());
}
```

**Migration also needed for:** medications, appointments, lab reports, user journey/profile

### Step 4 — Real AI Integration (Week 3, ~4 hours)

```dart
// Replace keyword matching with OpenAI API call
Future<String> getAIResponse(String userMessage) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final userContext = await _buildUserContext(uid); // fetch from Firestore
  
  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {
      'Authorization': 'Bearer ${Env.openAiKey}',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {'role': 'system', 'content': _buildSystemPrompt(userContext)},
        ..._chatHistory,
        {'role': 'user', 'content': userMessage},
      ],
      'max_tokens': 400,
      'temperature': 0.7,
    }),
  );
  
  final data = jsonDecode(response.body);
  return data['choices'][0]['message']['content'];
}
```

**⚠️ NEVER put the OpenAI API key in the Flutter app code** — it would be exposed.
**Use Firebase Functions as a proxy:**
```
Flutter App → Firebase Function → OpenAI API
```
The Firebase Function holds the API key server-side.

### Step 5 — Push Notifications (Week 4, ~4 hours)

```dart
// Request permission
final messaging = FirebaseMessaging.instance;
await messaging.requestPermission();

// Get and store token
final token = await messaging.getToken();
await FirebaseFirestore.instance
    .collection('users').doc(uid)
    .update({'fcmToken': token});

// Handle foreground messages
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Show in-app notification
});
```

Schedule daily reminders via Firebase Cloud Scheduler + Functions (no cost).

### Step 6 — Play Store Submission (Week 5)

```
1. Build release APK:
   flutter build apk --release

2. Sign the APK (signing key generated during build setup)

3. Create Play Console listing:
   → play.google.com/console
   → Create app → App name: Rehlah
   → Category: Medical → Health & Fitness

4. Required assets:
   → App icon: 512×512 PNG
   → Feature graphic: 1024×500 PNG
   → Screenshots: minimum 2 phone screenshots
   → Short description (80 chars): "Cancer companion. Track symptoms, labs & meds."
   → Full description (4000 chars): from Doc 01 product vision

5. Policy declarations:
   → Personal/Sensitive data declaration: YES (health data)
   → Privacy policy URL: https://[yourdomain]/privacy
   → Content rating: Everyone (no mature content)

6. Release to internal testing first (your own devices)
   → Then closed testing (invite specific email addresses)
   → Then open testing / production after validation
```

---

## PART 7 — SECURITY CHECKLIST

Before accepting real users, verify all of these:

### Firestore Security Rules
```javascript
// Default (INSECURE — prototype):
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;  // ← ANYONE CAN READ EVERYTHING
    }
  }
}

// Production (SECURE — required):
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      // Users can only access THEIR OWN data
      allow read, write: if request.auth != null 
                         && request.auth.uid == userId;
    }
  }
}
```

### API Key Security
- [ ] OpenAI API key → Store in Firebase Functions environment, NEVER in app
- [ ] Firebase config → Safe to include in app (Firestore rules protect the data)
- [ ] No hardcoded secrets in Flutter code or GitHub repository

### Data in Transit
- [ ] All Firebase calls use HTTPS/TLS automatically (built-in)
- [ ] No sensitive data in URL parameters
- [ ] No logging of health data to console in production

### Data at Rest
- [ ] Firestore encrypts data at rest automatically (AES-256)
- [ ] Add `flutter_secure_storage` for any locally cached sensitive tokens

---

## PART 8 — COMPLETE COST SUMMARY

### One-Time Costs
| Item | Cost (SAR) | Cost (USD) |
|------|-----------|-----------|
| Google Play Developer account | ~95 SAR | $25 |
| Privacy policy (Termly/Iubenda) | 0–100 SAR | $0–27 |
| Apple Developer (if iOS, Phase 3) | ~375 SAR | $99 |
| Domain name (optional) | ~45 SAR | $12 |
| **Total one-time** | **~140–615 SAR** | **~$37–163** |

### Monthly Costs by Stage

| Stage | Users | Firebase | OpenAI AI | Other | Total/Month |
|-------|-------|---------|---------|-------|------------|
| **Beta** | 0–100 | $0 | $2 | $0 | **$2/month** |
| **Early launch** | 100–500 | $0 | $10 | $0 | **$10/month** |
| **Growth** | 500–2K | $10–30 | $30–60 | $26 | **$65–115/month** |
| **Scale** | 2K–10K | $50–150 | $80–200 | $80 | **$210–430/month** |

### Annual Cost Summary (Most Likely Scenario: 500–1,000 users year 1)
```
Firebase (Blaze, light usage)         $120/year
OpenAI API                            $240/year  ($20/month average)
Google Play Developer                  $25 one-time
Sentry error monitoring               $0 (free tier)
Domain + hosting                       $45/year
Miscellaneous (misc tools)             $50/year
─────────────────────────────────────────────────
TOTAL YEAR 1 (500–1,000 users):       ~$480/year
                                       ~1,800 SAR/year
```

**Translation:** Rehlah costs less than **5 SAR per user per year** to operate at this scale.

---

## PART 9 — WHAT YOU CAN DEFER

These things are NOT required on Day 1 with real users:

| Feature | When to Add | Why Not Now |
|---------|------------|-------------|
| OCR / Lab photo scanning | Month 3–6 | Complex, adds $50–100/month in Vision API costs |
| Apple iOS App Store | Month 6+ | Requires Mac + $99/year + separate build |
| Arabic localisation | Month 3 | High impact but complex — do after core is validated |
| Caregiver shared mode | Phase 3 | Requires complex data sharing logic |
| Hospital FHIR integration | Phase 4 | Enterprise feature, needs clinical partnerships |
| Full HIPAA compliance | If entering US | Not required for KSA |
| Video consultations | Phase 4 | High complexity, separate service needed |
| Wearable integration | Phase 4 | Apple Watch / Fitbit APIs |

---

## PART 10 — THE MINIMUM VIABLE LAUNCH (12-WEEK PLAN)

**Assumption: 1–2 Flutter developers, part-time**

```
MONTH 1 — Backend & Auth
  Week 1: Firebase setup, Auth screens (login/signup/reset)
  Week 2: Migrate AppProvider to Firestore
  Week 3: Migrate LabProvider to Firestore
  Week 4: Test end-to-end with real accounts + fix bugs

MONTH 2 — AI & Notifications  
  Week 5: Firebase Function for OpenAI proxy
  Week 6: Replace keyword AI with real GPT-4o-mini
  Week 7: Push notifications (FCM + Firebase Scheduler)
  Week 8: Error monitoring + crash reporting setup

MONTH 3 — Launch Preparation
  Week 9:  Privacy policy, Terms of Service, Medical disclaimer
  Week 10: Google Play submission (internal testing)
  Week 11: Closed beta (50 users from user testing cohort)
  Week 12: Fix beta feedback → open launch

COST TO THIS POINT:
  Development time: Your team's time
  Services: ~$30–50 total (3 months at ~$10–15/month)
  One-time: $25 (Play Store)
  Total cash: ~$55–75 for the infrastructure
```

---

## APPENDIX — Quick Reference: All Service URLs

| Service | URL | Notes |
|---------|-----|-------|
| Firebase Console | console.firebase.google.com | Project dashboard |
| Firebase Pricing | firebase.google.com/pricing | Free vs Blaze calculator |
| OpenAI API | platform.openai.com | API keys + usage monitoring |
| OpenAI Pricing | openai.com/pricing | Token costs |
| Google Play Console | play.google.com/console | App distribution |
| NDMO (KSA) | ndmo.gov.sa | Data protection authority |
| Termly Privacy Policy | termly.io | Free policy generator |
| Sentry | sentry.io | Error monitoring |
| Firebase Crashlytics | firebase.google.com/crashlytics | Crash reporting |
| Firebase Region (Qatar) | me-central2 | Closest to KSA |

---

*Document 14 of the Rehlah Specification Suite*
*Version 1.0 | April 2026*
*Live Prototype: https://nadbrahmi.github.io/Rehlah/*
*Repository: https://github.com/nadbrahmi/Rehlah/*
