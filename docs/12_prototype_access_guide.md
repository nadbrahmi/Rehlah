# DOCUMENT 12 — Prototype Access Guide for User Testing
**Rehlah | Version 1.0 | April 2026**

---

> **Purpose:** A quick-reference guide for moderators, participants, and stakeholders on how to access, navigate, and share the Rehlah testable prototype.

---

## Live Prototype URL

```
https://nadbrahmi.github.io/Rehlah/
```

**No login required. No app download needed. Works on any device.**

---

## Device Compatibility

| Device | Experience | Notes |
|--------|-----------|-------|
| **iPhone (Safari)** | ✅ Best mobile experience | Use Safari for full-screen feel |
| **Android (Chrome)** | ✅ Best mobile experience | Use Chrome; can "Add to Home Screen" |
| **Desktop (Chrome/Edge)** | ✅ Good for moderated sessions | Use browser DevTools → mobile mode for realistic view |
| **Desktop (Firefox)** | ⚠️ Functional | Minor visual differences possible |
| **iPad / tablet** | ⚠️ Functional | UI designed for phone screens |

---

## How to Send to a Participant (WhatsApp / Email)

**WhatsApp message template:**
```
مرحباً [الاسم] / Hi [Name],

Thank you for joining our Rehlah user testing session!

Here is the prototype link:
👉 https://nadbrahmi.github.io/Rehlah/

Please open this on your phone (iPhone or Android).
No download needed — it opens directly in your browser.

Before our session:
✓ Make sure you're on WiFi
✓ Open the link once to confirm it loads
✓ Don't fill in your real health data — use whatever feels comfortable

See you on [DATE] at [TIME] 💜
```

---

## How to Set Up for a Moderated Session

### Option A — Participant shares their screen (recommended)
1. Open Zoom / Google Meet
2. Send prototype link to participant before the call
3. Ask them to open the prototype on their phone
4. On mobile: most platforms support screen sharing via the app
5. Or: ask participant to hold up phone to camera (lower tech but works)

### Option B — Moderator shares screen (desktop demo)
1. Open Chrome browser
2. Navigate to https://nadbrahmi.github.io/Rehlah/
3. Open Chrome DevTools (F12 or Cmd+Option+I)
4. Click the phone icon (Toggle Device Toolbar — Ctrl+Shift+M)
5. Select "iPhone 14 Pro" or "Galaxy S23" from dropdown
6. Share your screen in the meeting
7. Interact with prototype yourself while participant observes and comments

### Option C — Unmoderated (Maze integration)
1. Create a free Maze account at maze.co
2. Create a new test
3. Add your prototype URL: https://nadbrahmi.github.io/Rehlah/
4. Define tasks (matching tasks in Doc 11)
5. Generate a shareable Maze link
6. Send to participants — they complete at their own pace
7. Maze automatically records clicks, paths, and time on task

---

## Demo Mode vs. Real Onboarding

The prototype has two entry paths:

| Path | How to Start | When to Use |
|------|-------------|-------------|
| **Real onboarding** | Tap "Start My Journey" | For full usability sessions (Tasks 1–6) |
| **Demo mode** | Tap "Try a Demo" | For quick feature exploration or stakeholder demos |

**For user testing: always use "Start My Journey"** — this is the real experience.

**Demo mode shows:**
- Sarah's pre-populated data (breast cancer, Stage II, 8 weeks of demo data)
- Pre-filled check-ins, lab results, medications
- Useful for stakeholder demos and quick feature reviews

---

## Resetting the Prototype Between Sessions

Since the prototype uses local device storage:

**To reset on mobile:**
1. Open phone Settings
2. Go to Safari (iPhone) or Chrome (Android)
3. Clear browser data / history and website data
4. Reopen the prototype URL
5. App will show the Welcome screen again (fresh state)

**To reset on desktop Chrome:**
1. In the prototype tab, press Ctrl+Shift+I (DevTools)
2. Go to Application tab
3. Under Storage, click "Clear site data"
4. Refresh the page

**Alternatively:** Open the prototype in a Private/Incognito window for each participant — this automatically gives a clean state.

---

## Quick Feature Reference for Moderators

| Feature | Where to Find | Notes |
|---------|-------------|-------|
| Daily Check-In | Middle button (●) in bottom navigation | Quick mode or Full mode |
| Home screen | House icon (leftmost bottom nav) | Shows streak, today's prompt |
| Journey | Map/route icon (2nd bottom nav) | Milestones, phase overview |
| AI Assistant | Sparkle icon on Home quick actions OR Care Hub | 8 pre-set question chips |
| Lab Tracker | Care Hub → Labs OR Home quick actions | Shows CBC trends |
| Lab Analyzer | Lab Tracker → top right icon | Explains individual values |
| Medication Tracker | Care Hub → Medications | Add, mark as taken |
| Appointment Tracker | Care Hub → Appointments | Add, upcoming view |
| Community | People icon (rightmost bottom nav) | Feed, Coaches, Mentors, Stories |
| Profile | Hamburger/person icon (top right) | Settings, journey reset |
| Voice Check-In | Check-In screen → microphone icon | Simulated voice experience |

---

## Known Limitations (Prototype)

Inform participants of these before or after sessions:

1. **No real data storage** — Data is stored locally on the device and will disappear if cache is cleared
2. **English only** — Arabic version is in development
3. **AI responses are simulated** — The AI assistant uses pre-programmed responses, not a live AI model
4. **Voice check-in is simulated** — The voice recording is a demo flow, not real speech-to-text
5. **Community is prototype data** — Posts, coaches, mentors, and stories are sample content
6. **No push notifications** — Notification schedule exists in documentation but is not active in the prototype
7. **Lab results are manually entered** — No photo scanning yet

---

## Sharing the Prototype for Stakeholder Reviews

**For clinical advisors (oncologists, nurses):**
> "This is a functional prototype of Rehlah. You can explore it by tapping 'Try a Demo' to see pre-populated patient data. We'd especially value your feedback on the Lab Analyzer screen and AI Assistant responses. Here's the link: https://nadbrahmi.github.io/Rehlah/"

**For investors/partners:**
> "The live prototype is at https://nadbrahmi.github.io/Rehlah/ — tap 'Try a Demo' for the full Sarah experience. This demonstrates the complete 14-day journey with real interaction. No download required."

**For patient advocacy organisations:**
> "We'd love your community's feedback on this prototype. It's free to access at https://nadbrahmi.github.io/Rehlah/ and designed specifically for cancer patients and caregivers in the Arab world."

---

## QR Code for In-Person Testing

For clinic-based or in-person testing, print this QR code to give instant access:

**Generate QR code at:** https://qr.io or https://www.qr-code-generator.com
**URL to encode:** https://nadbrahmi.github.io/Rehlah/
**Suggested print size:** 5cm × 5cm minimum
**Include text below QR:** "Scan to try Rehlah — no download needed"

---

*Document 12 of the Rehlah Specification Suite*
*Version 1.0 | April 2026*
*Live Prototype: https://nadbrahmi.github.io/Rehlah/*
*Repository: https://github.com/nadbrahmi/Rehlah/*
