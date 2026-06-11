# CLAUDE.md — FlexPro Coaching App

## Project Overview
Flutter fitness coaching app for Tasos Misailidis. Targets Android (primary) and iOS.
Firebase backend (Auth, Firestore). Riverpod for state. GoRouter for navigation.
App ID: `com.tasos.flexpro_coaching`

## Running the App
```bash
flutter run                    # Android device
flutter run --release          # Release mode
flutter build apk --release    # Build release APK
flutter gen-l10n               # Regenerate localization after editing ARB files
```

---

## THIS IS A COACHING SYSTEM — NOT A WORKOUT TRACKER

Core entities (everything maps to one of these):
- User (Athlete)
- Coach
- Program
- WorkoutSession
- ProgressData
- CoachFeedback

---

## Architecture
Feature-first structure under `lib/`:
```
lib/
  main.dart
  app.dart
  core/
    constants/          # AppColors, AppTextStyles
    providers/          # locale_provider, theme_provider, notification_provider
    router/             # app_router.dart — all routes
    services/           # notification_service.dart
    theme/              # app_theme.dart, tokens.dart
    widgets/            # ALL shared/reusable widgets live here
    firebase_availability.dart
  features/
    today/              # PRIMARY home screen
    programs/           # Training structure
    progress/           # History + analytics
    coach/              # Coaching layer (shell tab)
    profile/            # Identity + body data
    workout/            # Full-screen session mode ONLY
    auth/
    onboarding/
    splash/
  models/
  services/
  l10n/
```

---

## Navigation (NON-NEGOTIABLE)

### Shell tabs (bottom nav via MainShell):
1. `/today` — TODAY (default, replaces /home)
2. `/programs` — PROGRAMS
3. `/progress` — PROGRESS
4. `/coach` — COACH (promoted from full-screen to shell tab)
5. `/profile` — PROFILE

### Full-screen routes (no shell):
- `/workout/active` — workout session mode
- `/workout/history` — session history
- `/exercises` — exercise library
- `/paywall`, `/privacy`, `/terms`

### CRITICAL:
- `/workout` is NOT a shell tab
- `/home` route is REMOVED — today is the new home
- Workout is launched from TODAY only via CTA button
- Auth guard applies to all shell routes

---

## Design System (tokens.dart)

### Spacing scale
```dart
static const double xs = 4;
static const double sm = 8;
static const double md = 12;
static const double base = 16;
static const double lg = 24;
static const double xl = 32;
static const double xxl = 40;
```

### Surface hierarchy
- `surface1` — page background
- `surface2` — cards
- `surface3` — elevated elements / modals

### Button variants
- `btn-primary` — main CTA
- `btn-secondary` — secondary action
- `btn-ghost` — tertiary / destructive
- `btn-danger` — delete/remove
- `btn-icon` — icon-only

### Card variants
- `card-base` — standard content card
- `card-hero` — large featured card (today's session)
- `card-stat` — metric/number display
- `card-program` — program listing card

---

## SetCard Component (workout logging)

Each set = one card. File: `lib/core/widgets/set_card.dart`

Required fields per card:
- Set number label
- Weight input (large touch target)
- Reps input (large touch target)
- RPE chip (selector)
- Complete button (tap to mark done)

Rules:
- NO HTML tables
- NO multi-column cramped inputs
- Large touch targets (min 48px)
- Mobile-first design
- Visual state: pending / active / completed

---

## Screen Specifications

### TODAY screen (`lib/features/today/`)
Answers: "What do I do today?"
Must include:
- Coach header note / message card
- Today's assigned session card (card-hero)
- "Start Workout" CTA (btn-primary) → navigates to /workout/active
- Recovery/readiness inputs
- Minimal activity feed
Wired to: `todaysWorkoutProvider`, `enrollmentProvider`

### PROGRAMS screen (`lib/features/programs/`)
Answers: "What is my training structure?"
Must include:
- Active program (highlighted card-hero)
- Program detail screen (tap to expand)
- Program library (secondary list)
Must NOT duplicate today's session content.

### PROGRESS screen (`lib/features/progress/`)
Answers: "How am I progressing?"
Three sub-sections (tabs or scroll sections):
- Training history (session timeline)
- Exercise history (per-lift progression charts)
- Body metrics (weight, body fat, measurements)
No mixed/uncategorized charts.

### COACH screen (`lib/features/coach/`)
Answers: "What has my coach said?"
Must include:
- Coach feed (posts/updates)
- Weekly check-ins
- Program assignment updates
- Feedback cards
This is a persistent system layer — not settings.

### PROFILE screen (`lib/features/profile/`)
Answers: "Who am I as an athlete?"
Must include:
- Athlete profile info
- Body stats
- Goals
- Measurements
- Minimal preferences (locale, notifications)
No settings bloat.

---

## Coding Conventions
- Screens: `ConsumerWidget` or `ConsumerStatefulWidget`
- Providers: `*_providers.dart` co-located with their feature
- Colors: `AppColors` only — never hardcode
- Spacing: tokens only — never hardcode
- Localized strings: `AppLocalizations.of(context)!` — never hardcode user-facing text
- Navigation: `context.go()` for tab nav, `context.push()` for stack nav
- New reusable widgets → `lib/core/widgets/` only (not lib/shared/widgets/)

---

## Icons
- NO emojis as icons
- Use Lucide icons package or inline SVG only
- Icon-only buttons must have semantic labels

---

## Strict Prohibitions
- No HTML tables for workout logging
- No inline styles inside widgets
- No hardcoded colors or spacing values
- No "coming soon" placeholder UI
- No non-functional buttons (filters, search, etc.)
- No greyed-out locked cards without real behavior
- No meta refresh reloads
- No duplicated navigation logic

---

## Firebase
- Project: `flexpro-coaching`
- `firebase_options.dart` — gitignored, regenerate with `flutterfire configure`
- `google-services.json` — gitignored, download from Firebase Console
- Google Sign-In SHA-1 debug: `99:13:57:A8:5B:CD:F1:95:7B:59:C5:97:79:96:78:32:8D:64:87:A4`
- Google Sign-In SHA-1 release: `5F:D2:06:6E:1C:D5:5B:9E:76:C5:E6:13:89:48:F9:85:48:16:D0:9A`
- Web OAuth client ID: `956635335187-s0tsg1vm41oa2ghmvau46lbg9ki93m89.apps.googleusercontent.com`
- Linux: Firebase unavailable — always check `firebaseAvailableProvider` before Firebase calls

## Android Signing
- Keystore: `android/flexpro-release.jks` (gitignored)
- Key alias: `flexpro-key`
- Config: `android/key.properties` (gitignored)

## Never Commit
- `android/key.properties`
- `android/flexpro-release.jks`
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

---

## Session Rules
- Work on ONE feature or component per session
- Do not touch unrelated files
- After each task state: what changed + what comes next
- If a task would produce 200+ lines of new code, stop and ask to split it

---

## Current Build Phase
Phase: REDESIGN
Last completed: Session 19
Next task: Session 20