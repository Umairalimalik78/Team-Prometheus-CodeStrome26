**Habitat**

App Flow & UI Specification Document

Version 3.0 | Flutter Android | Light Mode | Warm Brown Palette

# **1\. Design System**

## **1.1 Color Palette**

|     |     |     |     |
| --- | --- | --- | --- |
| **Token** | **Hex** | **Flutter** | **Usage** |
| primary | #2C1810 | Color(0xFF2C1810) | Buttons, active tab, FAB, icons |
| primaryMed | #5C3317 | Color(0xFF5C3317) | Section headings |
| primaryWarm | #8B4513 | Color(0xFF8B4513) | Accent text, links, streak numbers |
| primaryLight | #D4956A | Color(0xFFD4956A) | Inactive tabs, hint text |
| background | #F5F0EB | Color(0xFFF5F0EB) | App background (warm off-white) |
| surface | #FFFFFF | Colors.white | Cards, modals, sheets |
| inputBg | #F0EBE5 | Color(0xFFF0EBE5) | TextField bg, tab container bg |
| textPrimary | #1A0F0A | Color(0xFF1A0F0A) | Headings, bold text |
| textSecondary | #6B4C3B | Color(0xFF6B4C3B) | Body text, descriptions |
| textHint | #A08070 | Color(0xFFA08070) | Placeholders, timestamps, captions |
| border | #E8DDD5 | Color(0xFFE8DDD5) | Card borders, dividers |
| success | #2D6A4F | Color(0xFF2D6A4F) | Habit complete, streak done |
| successLight | #D8F0E5 | Color(0xFFD8F0E5) | Completed streak calendar cell |
| error | #C0392B | Color(0xFFC0392B) | Delete actions, errors |

## **1.2 Typography**

|     |     |     |     |     |
| --- | --- | --- | --- | --- |
| **Style** | **Font** | **Size** | **Weight** | **Usage** |
| appName | Playfair Display | 32sp | Bold 700 | App name in splash |
| screenTitle | DM Sans | 24sp | Bold 700 | Main screen headline |
| cardTitle | DM Sans | 17sp | SemiBold 600 | Habit card titles, section heads |
| bodyLarge | DM Sans | 15sp | Regular 400 | Body text, descriptions |
| bodyMedium | DM Sans | 13sp | Regular 400 | Secondary info, sub-labels |
| buttonLabel | DM Sans | 16sp | SemiBold 600 | All button text |
| caption | DM Sans | 12sp | Regular 400 | Timestamps, small labels |

\# pubspec.yaml

google_fonts: ^6.2.1

\# Usage

GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: primary)

GoogleFonts.dmSans(fontSize: 15, color: textSecondary)

## **1.3 Shape, Spacing & Elevation**

- App background: always #F5F0EB — never pure white
- Page horizontal padding: 20px on all screens
- Button shape: borderRadius 50px (fully pill-shaped), height 56px, full width
- Card shape: borderRadius 16px, border 1px #E8DDD5, shadow: Elevation 1 (0 2px 8px rgba(44,24,16,0.07))
- Input field: borderRadius 12px, background #F0EBE5, no visible border unless focused
- Tab container (segmented): borderRadius 50px, background #F0EBE5, padding 4px
- Active tab pill: borderRadius 50px, background #2C1810, text white
- Inactive tab text: color #A08070
- Bottom sheet / context menu: borderRadius top-left 20px, top-right 20px, background white
- Section label above grouped rows: 12sp, uppercase, #A08070, margin-bottom 6px

## **1.4 Reusable Components**

### **PrimaryButton**

- Height 56px, full width, borderRadius 50px
- Background: #2C1810, text: white, font: buttonLabel
- Loading state: white CircularProgressIndicator size 22px in center
- Disabled: opacity 0.4

### **SegmentedTabBar**

- Used on: Dashboard (Home tab), HabitDetail
- Container: background #F0EBE5, borderRadius 50px, padding 4px, height 44px
- Active tab: background #2C1810, text white, borderRadius 50px
- Inactive tab: transparent bg, text #A08070
- Tab text: DM Sans 14sp SemiBold

### **HabitCard**

- White background, borderRadius 16px, border 1px #E8DDD5, shadow elevation 1
- Left accent bar: 4px wide, #2C1810, full card height, borderRadius on left side
- Padding: 14px

### **ListRow (used in Profile)**

- Height: 52px, background white, horizontal padding 16px
- Left: square icon container 34x34px, borderRadius 8px, background #F5F0EB, icon color #5C3317
- Right: chevron icon, color #C8B8AE
- Divider between rows: 0.5px #F0EBE5

### **ToggleRow (used in Profile)**

- Same as ListRow but right side = CupertinoSwitch
- Active color: #2C1810, track color off: #D6CEC8

# **2\. Bottom Navigation Bar**

The bottom nav bar is persistent across all 4 main screens. It uses icon + label style. Active tab: icon and label color = #2C1810. Inactive: color = #A08070. Background: white, top border 1px #E8DDD5. Height: 64px.

|     |     |     |     |
| --- | --- | --- | --- |
| **Tab #** | **Label** | **Icon** | **Screen it loads** |
| 1   | Home | ti-home (outline / filled) | DashboardScreen — today's habits + quick add |
| 2   | Habits | ti-list-check | HabitsScreen — all active + completed habits list |
| 3   | Progress | ti-chart-bar | ProgressScreen — streaks, stats, history |
| 4   | Profile | ti-user-circle | ProfileScreen — settings, account |

_💡 Screens that do NOT show bottom nav: SplashScreen, LoginScreen, SignupScreen, OnboardingScreen, ChatScreen, HabitDetailScreen, CheckinScreen. These are pushed on top of the nav stack._

# **3\. Screen Specifications**

## **Screen 1 — SplashScreen**

**▸ Route**

/ (initial route, no bottom nav)

**▸ Background**

Pure white #FFFFFF

**▸ Layout**

- Center of screen: app icon (80x80px, rounded square borderRadius 20px, background #2C1810, white leaf/plant icon inside) placed left of app name
- App name 'Habitat' in Playfair Display 32sp Bold, color #2C1810 — placed right of icon
- Icon and name horizontally centered together as a group
- No tagline, no loading indicator, no other elements

**▸ Logic**

- Check Supabase session on init — minimum 1.5s display time
- Has session → /dashboard | No session → /login

## **Screen 2 — LoginScreen**

**▸ Route**

/login (no bottom nav)

**▸ Background**

Full-screen lifestyle photo (warm, natural — person in morning light). Use local asset. Gradient overlay: transparent top to rgba(0,0,0,0.55) bottom half.

**▸ Layout**

- Top center (40% from top): app icon 52px + 'Habitat' Playfair Display 26sp white
- Below logo: 'Build habits that stick.' DM Sans 15sp white 75% opacity
- Bottom section (lower 45% of screen): 3 pill buttons stacked, gap 12px:
- Button 1: 'Continue with Google' — white bg, Google icon left, dark text
- Button 2: 'Continue with Email' — white bg, @ icon left, dark text
- All buttons: height 54px, borderRadius 50px, DM Sans SemiBold 15sp
- Fine print at very bottom: 'By continuing you agree to our Terms & Privacy Policy' caption white 55% opacity

**▸ Logic**

- Google → Supabase OAuth | Email → /signup | Success → /dashboard

## **Screen 3 — SignupScreen**

**▸ Route**

/signup (no bottom nav)

**▸ Background**

Same lifestyle photo + gradient overlay as LoginScreen

**▸ Layout**

- Same logo at top as LoginScreen
- Bottom white card: borderRadius top 24px, padding 24px, background white
- Inside card: Full Name field + Email field + Password field
- Fields: background #F0EBE5, borderRadius 12px, DM Sans 15sp, padding 14px 16px
- PrimaryButton: 'Create Account' — full pill dark brown, below fields
- Below button: 'Already have an account? Log in' — DM Sans 13sp, textHint, 'Log in' in primaryWarm bold

## **Screen 4 — OnboardingScreen**

**▸ Route**

/onboarding (no bottom nav, shown once)

**▸ Background**

#F5F0EB warm off-white

**▸ Layout**

- PageView with 3 pages — horizontal swipe
- Each page: large illustration top 55% (simple line art icon, color #2C1810), bold heading DM Sans 22sp textPrimary center, description bodyLarge textSecondary center below
- Page 1 — icon: seedling plant — heading: 'Talk to your AI coach' — desc: 'Tell us what habit you want to build and why'
- Page 2 — icon: checklist — heading: 'Get your personalized plan' — desc: 'AI creates a custom module just for you'
- Page 3 — icon: fire streak — heading: 'Build it for life' — desc: 'Smart reminders fade as you grow stronger'
- Bottom: dot indicator (3 dots, active = #2C1810, inactive = #E8DDD5)
- 'Get Started' PrimaryButton — shows only on page 3 → /dashboard
- 'Skip' TextButton top-right — color #A08070 — on pages 1 & 2 only → /dashboard

## **Screen 5 — DashboardScreen \[Tab 1: Home\]**

**▸ Route**

/dashboard (bottom nav tab 1)

**▸ Bottom Nav**

Tabs: Home | Habits | Progress | Profile — Active: Home

**▸ AppBar**

- Background #F5F0EB, no elevation, no border
- Left: 'Home' DM Sans SemiBold 18sp textPrimary + small dropdown chevron
- Right: user CircleAvatar 36px (initials, background #E8DDD5, textPrimary)

**▸ Body — background #F5F0EB, padding 20px**

- Greeting: 'Good morning, Ahmed.' screenTitle textPrimary
- Sub: 'You have 3 active habits today.' bodyMedium textSecondary — margin-bottom 20px

**▸ Today's Focus Card (white, borderRadius 16px, padding 16px, shadow elevation 1)**

- Label: 'TODAY'S FOCUS' — caption uppercase textHint
- SegmentedTabBar inside card: 'Pending' | 'Done' — 2 tabs
- Pending tab: list of today's habit tasks — each row has habit name + checkbox
- Done tab: same list but completed items with green checkmark + strikethrough text
- Empty state (all done): small celebration message + checkmark illustration

**▸ FAB**

- Position: bottom right, margin 20px above bottom nav
- Shape: slightly rounded square borderRadius 16px, size 56px, background #2C1810, white + icon
- Tap → opens ChatScreen to start new habit interview

## **Screen 6 — HabitsScreen \[Tab 2: Habits\]**

**▸ Route**

/habits (bottom nav tab 2)

**▸ Bottom Nav**

Tabs: Home | Habits | Progress | Profile — Active: Habits

**▸ AppBar**

- Title: 'My Habits' DM Sans SemiBold 18sp textPrimary, center
- Right: search icon button, color textSecondary

**▸ Body — background #F5F0EB, padding 20px**

- SegmentedTabBar at top: 'Active' | 'Completed' — 2 tabs

**▸ Active Tab**

- ListView of HabitCards — one per active habit_module, gap 12px
- HabitCard contains: left accent bar + habit name (cardTitle) + phase badge chip (right) + LinearProgressIndicator (height 5px, color #2C1810, bg #E8DDD5) + '🔥 X day streak' bodyMedium textSecondary + 'Day X/25' caption textHint
- Tap card → HabitDetailScreen
- Empty state: plant illustration + 'No active habits yet' + 'Start one with AI' PrimaryButton

**▸ Completed Tab**

- Same card style but muted — background #F8F5F2, left bar color #2D6A4F (success green)
- Shows: habit name + '✓ Habit Built' badge + completion date

## **Screen 7 — ChatScreen \[AI Intake Interview\]**

**▸ Route**

/chat/:moduleId (pushed on top, no bottom nav)

**▸ AppBar**

- Back arrow left — shows exit confirmation dialog on tap
- Center: 'Habit Coach' DM Sans SemiBold 15sp + green dot 8px + 'Online' caption textHint
- Background #F5F0EB, no elevation

**▸ Body — background #F5F0EB**

- Top: 'Let's build your habit.' screenTitle textPrimary, centered, padding-top 28px
- Below: ListView of chat bubbles, auto-scrolls to bottom on new message
- AI bubble: white bg, border 1px #E8DDD5, borderRadius 16px 16px 16px 4px, padding 12px 14px, max-width 78%, align left
- User bubble: background #2C1810, text white, borderRadius 16px 16px 4px 16px, padding 12px 14px, max-width 78%, align right
- Typing indicator: 3 animated dots, color #8B4513, shown while awaiting AI reply

**▸ Bottom Input Bar (sticky)**

- White background, top border 1px #E8DDD5, padding 10px 16px
- TextField: background #F0EBE5, borderRadius 50px, hint 'Type your message...' textHint, DM Sans 14sp
- Right of field: send button — circle 40px, background #2C1810, white send icon
- Send button disabled (opacity 0.4) when field is empty

**▸ Interview Complete State**

- Input bar hidden, centered card shown: '✨ Generating your habit plan...' bodyLarge textPrimary
- Indeterminate LinearProgressIndicator below, color #2C1810
- On success: navigate to HabitDetailScreen, replace chat route

## **Screen 8 — HabitDetailScreen**

**▸ Route**

/habit/:moduleId (pushed on top, no bottom nav)

**▸ AppBar**

- Back arrow left
- Center: habit name cardTitle textPrimary (truncated if too long)
- Right: 3-dot menu icon — opens context menu bottom sheet

**▸ Context Menu Bottom Sheet**

- White card, borderRadius top 20px, padding 8px 0
- Options: 'Edit Habit' (pencil icon) | 'Share Progress' (share icon) | 'Archive' (folder icon) | 'Delete Habit' (trash icon, red text #C0392B)
- Each option: icon left in 34px square container + label bodyLarge | divider between rows

**▸ Tab Bar (below AppBar, inside screen)**

- SegmentedTabBar: 'Overview' | 'Daily Plan' | 'Tips' — 3 tabs, background #F0EBE5

**▸ Overview Tab**

- Progress ring: CircularPercentIndicator radius 55px, lineWidth 8px, color #2C1810, bg #E8DDD5, center = streak number screenTitle + 'days' caption below
- Streak calendar: 5x5 grid of 25 squares, size 38px each, gap 6px, borderRadius 8px
- Completed: bg #D8F0E5, green checkmark icon
- Missed: bg #FDECEA, small x icon color error
- Future: bg #F0EBE5, day number caption textHint
- Today: border 2px #2C1810, no fill
- 'Why it matters' card: bg #FBF7F4, borderRadius 12px, left border 4px #2C1810, italic bodyLarge textSecondary, padding 14px
- 'Mark Today Done' PrimaryButton at bottom — full width pill, primary brown

**▸ Daily Plan Tab**

- ListView of day task rows — today's row: border-left 4px #2C1810, bg white, elevated
- Each row: 'Day X' caption textHint + task bodyLarge textPrimary + tip italic bodyMedium textHint below

**▸ Tips Tab**

- 'Environment Tips' section: horizontal scrollable row of chips — outlined, #E8DDD5 border, bodyMedium textSecondary
- 'Obstacle Playbook' section: ExpansionTile list, each item trigger bold + response text on expand

## **Screen 9 — ProgressScreen \[Tab 3: Progress\]**

**▸ Route**

/progress (bottom nav tab 3)

**▸ Bottom Nav**

Tabs: Home | Habits | Progress | Profile — Active: Progress

**▸ AppBar**

- Title: 'Progress' DM Sans SemiBold 18sp textPrimary, center

**▸ Body — background #F5F0EB, padding 20px**

**▸ Stats Summary Row (3 cards side by side)**

- Card 1: 'Active Habits' — big number + label below
- Card 2: 'Best Streak' — days number + fire emoji
- Card 3: 'Completed' — number of habits fully built
- Each card: white bg, borderRadius 14px, border 1px #E8DDD5, center-aligned, padding 14px

**▸ Per-Habit Progress Section**

- Section title: 'Habit Progress' cardTitle textPrimary
- For each active habit: row with habit name + mini LinearProgressIndicator + 'Day X/25' right-aligned
- Row bg: white, borderRadius 12px, padding 14px, border 1px #E8DDD5, gap 8px between rows

**▸ Weekly Activity Chart**

- Simple bar chart (fl_chart package) — 7 bars for last 7 days
- Bar color: #2C1810, bg bar: #E8DDD5, borderRadius 4px
- X-axis: day abbreviations (Mon, Tue...) caption textHint
- Title above: 'Last 7 Days' cardTitle textPrimary

## **Screen 10 — CheckinScreen**

**▸ Route**

/checkin/:moduleId (pushed on top, no bottom nav)

**▸ Trigger**

Auto-triggered when habit reaches day 21. User cannot dismiss without completing.

**▸ AppBar**

- No back button — user must complete check-in
- Title: '21-Day Check-in 🌱' DM Sans SemiBold 16sp textPrimary

**▸ Layout**

- Same chat UI as ChatScreen — same bubbles, same input bar
- AI opens with a congratulatory message and asks 2-3 evaluation questions
- User responds → sent to groq-checkin edge function

**▸ Result Screens (full screen, replaces chat)**

- CLOSE — 'Habit Built! 🏆' screenTitle, green success background overlay, confetti animation, 'Start New Habit' PrimaryButton
- EXTEND — encouragement message card, '7 more days added' badge, 'Continue' PrimaryButton
- RESTART — 'Let's adjust.' heading, simplified plan preview card, 'Start Fresh' PrimaryButton

## **Screen 11 — ProfileScreen \[Tab 4: Profile\]**

**▸ Route**

/profile (bottom nav tab 4)

**▸ Bottom Nav**

Tabs: Home | Habits | Progress | Profile — Active: Profile

**▸ AppBar**

- Back arrow left (navigates to previous tab, not a separate back)
- No title — clean like Tiro

**▸ User Header**

- CircleAvatar 52px — colored background with user initials, DM Sans SemiBold 20sp white
- Right of avatar: name DM Sans SemiBold 16sp textPrimary + email caption textHint below
- Far right: 'Logout' button — outlined, borderRadius 8px, border 1px #E8DDD5, DM Sans 13sp textPrimary, padding 6px 14px

**▸ Settings Section**

- Section label: 'SETTINGS' caption uppercase textHint
- White card, borderRadius 14px — contains 3 ListRows:
- Row 1: bell icon — 'Daily Reminders' — ToggleRow (active by default)
- Row 2: moon icon — 'Do Not Disturb' — ToggleRow (inactive by default)
- Row 3: clock icon — 'Reminder Time' — shows current time '8:00 AM' as sub-label — tap to open time picker

**▸ Support Section**

- Section label: 'SUPPORT' caption uppercase textHint
- White card, borderRadius 14px — contains 2 ListRows:
- Row 1: help-circle icon — 'How to Use Habitat' — chevron right
- Row 2: message icon — 'Contact Support' — chevron right

**▸ Other Section**

- Section label: 'OTHER' caption uppercase textHint
- White card, borderRadius 14px — contains 3 ListRows:
- Row 1: share icon — 'Share Habitat' — chevron right
- Row 2: lock icon — 'Privacy Policy' — chevron right
- Row 3: file-text icon — 'Terms of Service' — chevron right

**▸ Manage Account Section**

- Section label: 'MANAGE ACCOUNT' caption uppercase textHint
- White card, borderRadius 14px — single row:
- Row: trash icon (red #C0392B) — 'Delete Account' — text color #C0392B — tap shows confirmation dialog

# **4\. Navigation Flow**

App Launch (/)

└── SplashScreen

├── \[First time\] → OnboardingScreen → LoginScreen → Dashboard

├── \[Logged out\] → LoginScreen → Dashboard

└── \[Logged in\] → DashboardScreen

Bottom Nav (persistent on tabs 1-4)

Tab 1: DashboardScreen (/dashboard)

Tab 2: HabitsScreen (/habits)

Tab 3: ProgressScreen (/progress)

Tab 4: ProfileScreen (/profile)

Pushed screens (no bottom nav, full screen)

DashboardScreen FAB → ChatScreen (/chat/new)

HabitsScreen card tap → HabitDetailScreen (/habit/:id)

ChatScreen complete → HabitDetailScreen (/habit/:id)

HabitDetail day 21 → CheckinScreen (/checkin/:id)

Checkin close/extend → HabitsScreen (/habits)

# **5\. Vibe Coding Prompt Template**

Use this exact prompt every time you ask AI to build a screen:

I am building a Flutter Android app called Habitat (AI habit coach).

DESIGN TOKENS:

primary: Color(0xFF2C1810)

primaryWarm: Color(0xFF8B4513)

background: Color(0xFFF5F0EB) // always use this, never white bg

surface: Colors.white

inputBg: Color(0xFFF0EBE5)

textPrimary: Color(0xFF1A0F0A)

textSecondary: Color(0xFF6B4C3B)

textHint: Color(0xFFA08070)

border: Color(0xFFE8DDD5)

success: Color(0xFF2D6A4F)

error: Color(0xFFC0392B)

TYPOGRAPHY: google_fonts — Playfair Display (app name), DM Sans (all else)

STYLE RULES:

\- Buttons: height 56px, borderRadius 50px, fully pill-shaped

\- Segmented tab bar: borderRadius 50px container, active tab = dark brown pill

\- Cards: white bg, borderRadius 16px, border 1px #E8DDD5, shadow elevation 1

\- App bg is ALWAYS #F5F0EB

\- Delete/destructive text: Color(0xFFC0392B)

\- Bottom nav: 4 tabs — Home, Habits, Progress, Profile

STATE MANAGEMENT: Riverpod | NAVIGATION: go_router | BACKEND: Supabase

Now build \[SCREEN NAME\]:

\[paste screen spec from Section 3 of this document\]

## **5.1 Screen Build Order**

|     |     |     |
| --- | --- | --- |
| **#** | **What to build** | **Notes** |
| 1   | app_colors.dart + app_text_styles.dart | Define all tokens — every other file imports this |
| 2   | Bottom nav shell | ScaffoldWithBottomNav wrapper — 4 tabs wired up |
| 3   | SplashScreen + LoginScreen | Auth flow first — nothing else works without this |
| 4   | DashboardScreen | Tab 1 — home with today's tasks + FAB |
| 5   | ChatScreen | Core AI feature — Groq API call here |
| 6   | HabitsScreen | Tab 2 — habit card list, active/completed tabs |
| 7   | HabitDetailScreen | 3 tabs, streak calendar, mark done, context menu |
| 8   | ProgressScreen | Tab 3 — stats cards + bar chart |
| 9   | ProfileScreen | Tab 4 — settings, toggles, delete account |
| 10  | CheckinScreen | Same chat UI + result states |
| 11  | OnboardingScreen | Polish last — not critical for demo |

_Habitat UI Specification v3.0 — Flutter Android — June 2026_