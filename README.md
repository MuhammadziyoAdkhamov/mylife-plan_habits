# MYLife Plan — Premium Flutter Habit Tracker

MYLife Plan is a local-first Flutter portfolio app based on a premium dark self-growth dashboard concept. It includes onboarding, login UI, dashboard, habit CRUD-lite flow, habit completion, streaks, XP, levels, badges, statistics, journey tasks, and profile/settings screens.

## A. Product Understanding
MYLife Plan is not a basic checkbox habit tracker. It is a premium personal growth system: the user creates habits, completes daily actions, earns XP, levels up, unlocks badges, follows a 30-day focus journey, and sees progress through analytics.

The reference image was interpreted as:
- dark navy/near-black product UI;
- purple/indigo primary gradient;
- cyan/emerald/gold accents;
- glassmorphism cards with subtle borders;
- large progress rings, XP, badges, profile stats;
- simple but high-quality mobile UX.

## B. Final Feature List

### Authentication UI
- Login/sign-up visual screen.
- Email and password inputs.
- Social login buttons as UI.
- Sign-in button navigates into the app and saves signed-in state locally.

### Onboarding
- Three premium onboarding pages.
- Page indicators.
- Get Started / Next / Let's Go behavior.
- Onboarding completion saved locally.

### Dashboard
- Greeting header.
- Today's focus energy/progress ring.
- Daily habits count.
- XP earned.
- Current streak.
- Today's habit list with completion toggles.
- Navigation to add habit and habit detail.

### Habit Management
- Add habit form.
- Category selection.
- Frequency selection.
- Reminder and goal text.
- Track habit switch.
- Local persistence.

### Habit Detail
- Weekly completion row.
- Day streak.
- Total XP.
- Monthly heatmap.
- Basic habit stats.

### Statistics
- Overall progress ring.
- Completed/missed/best streak cards.
- Mini weekly line chart.
- Category/habit overview tabs.

### Journey
- 30-day focus journey.
- Daily tasks.
- Completion state.
- XP reward.
- Locked future tasks.

### XP and Level System
- XP per habit completion.
- Daily bonus XP.
- Level calculation.
- XP progress to next level.
- XP history list.

### Badges
- Earned/locked badge grid.
- First Step, 7 Day Streak, Focus Master, Bookworm, Perfect Week and more.
- Unlock logic runs after actions.

### Profile/Settings
- Profile stats.
- Current/longest streak cards.
- Settings rows.
- Data reset/sign out behavior.

### Local Storage
- SharedPreferences JSON persistence.
- App works offline immediately.
- Data can later be replaced with Firebase/Supabase repositories.

### Animations and Microinteractions
- Button press scale.
- Animated progress rings.
- Animated habit tiles.
- Glow buttons/cards.
- Smooth navigation.

## C. App Architecture

Architecture style: feature-ready clean Flutter architecture with separate layers:
- `core`: theme, design tokens, helpers.
- `models`: serializable app models.
- `services`: persistence/storage.
- `providers`: state and business logic.
- `widgets`: reusable UI components.
- `screens`: full app screens.
- `routes`: GoRouter navigation.

State management: `Provider` + `ChangeNotifier`, beginner-readable and scalable.

Data flow:
UI -> AppState methods -> models updated -> local storage save -> notifyListeners -> UI rebuilds.

Local storage strategy:
SharedPreferences stores one JSON payload containing profile, habits, completions, badges, XP history, journey, onboarding, and auth flags.

Navigation structure:
- `/` splash
- `/onboarding`
- `/login`
- `/home`
- `/stats`
- `/journey`
- `/badges`
- `/profile`
- `/add-habit`
- `/habit/:id`
- `/xp`
- `/settings`

## D. Dependencies
- `provider`: state management.
- `shared_preferences`: local-first offline data.
- `google_fonts`: Poppins-style typography.
- `go_router`: clean navigation.
- `intl`: date formatting.

## E. Design System

### Colors
- Background: `#050816`
- Background 2: `#080D1F`
- Card: `#0D1328`
- Card 2: `#111936`
- Border: `#26304F`
- Primary Purple: `#7C5CFF`
- Indigo: `#4B6BFF`
- Cyan: `#22D3EE`
- Emerald: `#10B981`
- Gold: `#F59E0B`
- Error: `#F43F5E`
- Text White: `#FFFFFF`
- Text Gray: `#A1A1AA`
- Muted: `#6B7280`

### Typography
Poppins with sizes:
- Display: 34/40 Bold
- H1: 28/34 Bold
- H2: 22/28 SemiBold
- Body: 14/20 Regular
- Caption: 12/16 Medium

### Spacing
4, 8, 12, 16, 20, 24, 32.

### Radius
12, 16, 20, 24, 32.

### Effects
- Glass card: dark surface + 1px subtle border.
- Glow: primary color with low opacity blur.
- Active bottom nav: purple glow + filled circular icon background.

## F-I. Models, Logic, Screens, Components
All models, business logic, screens, and reusable widgets are implemented in `/lib`.

## K. Run Instructions

```bash
flutter create mylife_plan
cd mylife_plan
```

Replace the generated `pubspec.yaml`, `analysis_options.yaml`, and `lib/` folder with the files from this package.

Then run:

```bash
flutter pub get
flutter run
```

For Android device:

```bash
flutter devices
flutter run -d <device_id>
```

Common fixes:

```bash
flutter clean
flutter pub get
flutter doctor
flutter doctor --android-licenses
```

## L. Quality Checklist
- [x] All major screens included.
- [x] Navigation works through GoRouter.
- [x] Premium dark design system included.
- [x] Habit completion works.
- [x] XP and level logic works.
- [x] Badge unlock logic works.
- [x] Local data persistence works.
- [x] Code is structured to compile with Flutter stable.
- [x] Code is organized and scalable.
- [x] UI is responsive and portfolio-ready.
- [ ] Local build verification: run `flutter pub get` and `flutter run` on your PC because this sandbox has no Flutter SDK.
