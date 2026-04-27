# Rehlah · رحلة — Flutter App

## What this is
AI-powered oncology companion for cancer patients. Built in Flutter (iOS + Android). Bilingual: Arabic + English.

## Tech Stack
- Flutter 3.x / Dart 3.x
- State: flutter_riverpod ^2.5.1
- Navigation: go_router ^13.2.0
- Local DB: hive_flutter
- HTTP / AI: http + flutter_dotenv (Anthropic API)
- Fonts: Inter (Latin) + Almarai (Arabic)

## Design System — Soft Dawn Theme
- Primary: #7B5CC4  |  Background: #F5F2FC  |  Surface: #FFFFFF
- Peach (warnings): #E09060  |  Teal (success): #3DB87A
- Text1: #2A2040  |  Text2: #6858A0  |  Text3: #B8A8D8
- ALL tokens in: lib/core/theme/app_theme.dart

## Architecture
lib/
  core/
    theme/app_theme.dart        ← colors, text styles, radius, shadows, ThemeData
    widgets/shared_widgets.dart ← HeroCard, SurfaceCard, ToolRow, AppBottomNav, etc
    utils/
      models.dart               ← all data models + MockData
      app_router.dart           ← go_router config
      shell_screen.dart         ← bottom nav shell
  features/
    home/                       ← Screen 1: Home
    checkin/                    ← Screens 2-4: Check-in flow (emoji → sliders → success)
    ai_chat/                    ← Screen 5: AI Chat (wire to Anthropic API)
    my_health/                  ← Screens 6-7: Journey + What to Expect
    care/
      labs/                     ← Screens 9-11: Lab results, history, add form
      medications/              ← Screen 12: Medications + adherence
      appointments/             ← Screens 13-14: Appointments + Prep report
    connect/                    ← Screen 15: Community (Feed/Mentors/Coaches/Stories)
    profile/                    ← Screens 16-17: Profile + Privacy

## Screens (17 total)
1. Home          — mood strip, hero check-in, quick tiles, next appointment
2. Check-in      — emoji mood selector + symptom chips
3. Sliders       — interactive 0–10 symptom sliders (fatigue/pain/nausea/fever/mood)
4. Success       — 4s auto-return countdown
5. AI Chat       — chat UI, wire to Anthropic claude-sonnet-4-6
6. My Health     — Journey tab (phase card + milestones)
7. My Health     — What to Expect tab (cycle dots + side effects)
8. (Care Hub)    — accessed via Care tab → LabResultsScreen
9. Lab Results   — hero status + AI summary + metric cards
10. Lab History  — chronological list
11. Lab Add Form — manual entry form
12. Medications  — adherence hero + daily med list
13. Appointments — countdown hero + upcoming/past list
14. Prep Report  — AI-generated doctor briefing
15. Connect      — 4 tabs: Feed / Mentors / Coaches / Stories
16. Profile      — completion bar + personal/treatment info
17. Privacy      — data controls

## AI Chat Setup
Replace placeholder in ai_chat_screen.dart `_send()` method:
```dart
final response = await http.post(
  Uri.parse('https://api.anthropic.com/v1/messages'),
  headers: {
    'Content-Type': 'application/json',
    'x-api-key': dotenv.env['ANTHROPIC_API_KEY']!,
    'anthropic-version': '2023-06-01',
  },
  body: jsonEncode({
    'model': 'claude-sonnet-4-6',
    'max_tokens': 800,
    'system': 'You are Rehlah AI, a compassionate oncology companion for cancer patients. Always end responses with emotional validation. Never give specific medical advice — always recommend consulting their care team.',
    'messages': _messages.map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text}).toList(),
  }),
);
```

## Getting Started
```bash
flutter pub get
flutter run
```

## Key Design Rules
- Orange for warnings, never red
- Labs never appear on home screen
- Survivorship 🌟 always visible at bottom of milestones
- Moderation banner before community content
- FAB turns green when check-in is complete
- Past appointments at 40% opacity
