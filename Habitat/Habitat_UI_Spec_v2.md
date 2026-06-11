**Habitat**

App Flow & UI Specification Document

Inspired by Tiro App Design Language • Warm Brown Palette • Flutter Android

# **1\. Design System — Tiro-Inspired**

The Habitat app follows the same warm, earthy design language as the Tiro app — dark brown primary color, warm off-white backgrounds, serif-feel branding, and clean minimal layouts. This creates a calm, focused environment perfect for habit building.

## **1.1 Color Palette**

|     |     |     |     |
| --- | --- | --- | --- |
| **Token** | **Hex** | **Flutter Color** | **Usage** |
| primary | #2C1810 | Color(0xFF2C1810) | Buttons (Record btn), icons, active tabs, FAB |
| primaryMed | #5C3317 | Color(0xFF5C3317) | Section headings, important labels |
| primaryWarm | #8B4513 | Color(0xFF8B4513) | Accent text, links, streak numbers |
| primaryLight | #D4956A | Color(0xFFD4956A) | Inactive tabs, hint text, disabled state |
| background | #F5F0EB | Color(0xFFF5F0EB) | Main app background (warm off-white — Tiro-style) |
| surface | #FFFFFF | Colors.white | Cards, modals, input containers |
| inputBg | #F0EBE5 | Color(0xFFF0EBE5) | TextField background, tab bar container |
| textPrimary | #1A0F0A | Color(0xFF1A0F0A) | Main headings, bold text |
| textSecondary | #6B4C3B | Color(0xFF6B4C3B) | Body text, descriptions, labels |
| textHint | #A08070 | Color(0xFFA08070) | Placeholders, timestamps, captions |
| border | #E8DDD5 | Color(0xFFE8DDD5) | Card borders, dividers, input borders |
| success | #2D6A4F | Color(0xFF2D6A4F) | Habit complete, streak badges |
| error | #C0392B | Color(0xFFC0392B) | Delete actions (red — same as Tiro's Delete Note) |

## **1.2 Typography**

Tiro uses a serif-style app name with clean sans-serif body. Habitat follows same pattern:

|     |     |     |     |     |
| --- | --- | --- | --- | --- |
| **Style** | **Font** | **Size** | **Weight** | **Usage** |
| appName | Playfair Display | 32sp | Bold 700 | App name 'Habitat' in splash/appbar |
| screenTitle | DM Sans | 26sp | Bold 700 | Big screen headline (like 'Build habits that stick') |
| cardTitle | DM Sans | 18sp | SemiBold 600 | Habit card titles, section headings |
| bodyLarge | DM Sans | 16sp | Regular 400 | Body text, descriptions |
| bodyMedium | DM Sans | 14sp | Regular 400 | Secondary info, hints |
| buttonText | DM Sans | 16sp | SemiBold 600 | Button labels (like Tiro's 'Start Recording') |
| caption | DM Sans | 12sp | Regular 400 | Timestamps, small labels, tab inactive |

\# pubspec.yaml — Add Google Fonts

dependencies:

google_fonts: ^6.2.1

\# Usage in Flutter:

GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold)

GoogleFonts.dmSans(fontSize: 16)

## **1.3 Spacing & Shape**

- App background: warm off-white #F5F0EB (never pure white for background)
- Page horizontal padding: 20px (same as Tiro)
- Card border radius: 16px — smooth rounded cards
- Button border radius: 50px — fully pill-shaped buttons (exactly like Tiro's Record / Start Recording buttons)
- Tab bar container: borderRadius 50px, background inputBg (#F0EBE5)
- Active tab pill: borderRadius 50px, background primary (#2C1810), text white
- Input field border radius: 12px, background inputBg
- Bottom sheet / modals: borderRadius top 20px (Tiro's context menu style)

## **1.4 Key Component Specs**

### **PrimaryButton — Pill Shape (Tiro-style)**

- Height: 56px, full width, borderRadius: 50px (fully rounded)
- Background: primary (#2C1810), text: white, font: buttonText
- Left icon: optional (mic icon, waveform — like Tiro's Record button)
- Loading: white CircularProgressIndicator, size 22px
- Disabled: opacity 0.4

### **TabBar — Segmented (Tiro-style)**

- Container: borderRadius 50px, background #F0EBE5, padding 4px
- 3 tabs: same width, height 40px
- Active tab: background #2C1810, text white, borderRadius 50px
- Inactive tabs: no background, text #A08070 (light brown hint color)
- Example tabs for Habitat: 'Today' | 'Progress' | 'Tips'

### **HabitCard**

- Background: white, borderRadius: 16px, shadow: 0 2px 12px rgba(44,24,16,0.08)
- Border: 1px solid #E8DDD5
- Left accent bar: 4px wide, #2C1810, full height, borderRadius left
- Padding: 16px

### **ContextMenu / BottomSheet (Tiro-style)**

- Appears from right side or bottom as overlay
- Background white, borderRadius 16px, shadow
- Each option: icon (right side) + label (left), 48px height, divider between
- Destructive action (Delete): red text #C0392B + red trash icon — exactly like Tiro's 'Delete Note'
- Options for Habitat: Copy | Edit | Archive | Delete Habit

# **2\. Screen-by-Screen Specifications**

## **Screen 1 — SplashScreen**

**▸ Route**

/

**▸ Reference**

Tiro Image 8 — pure white bg, centered logo + app name, no clutter

**▸ Layout**

- Full screen, background: pure white (#FFFFFF) — exactly like Tiro splash
- Center of screen: app icon (square rounded, 80x80, dark brown bg #2C1810, white leaf/plant icon) + 'Habitat' in Playfair Display 32sp bold, #2C1810
- Icon and name side by side horizontally (same as Tiro's icon + 'Tiro' layout)
- No tagline, no loading bar — clean and minimal

**▸ Logic**

- Check Supabase session on init
- Show for minimum 1.5 seconds
- Navigate to /login or /dashboard

## **Screen 2 — LoginScreen**

**▸ Route**

/login

**▸ Reference**

Tiro Image 6 & 10 — full screen background image, logo top center, pill-shaped auth buttons at bottom

**▸ Layout**

- Full screen background: warm nature/lifestyle photo (person meditating, morning sunlight — conveys calm habit energy). Use a local asset image.
- Semi-transparent dark overlay: gradient from transparent (top) to rgba(0,0,0,0.5) (bottom)
- Center: Habitat icon (60px) + 'Habitat' in Playfair Display 28sp, white text
- Below center: tagline 'Build habits that stick.' in DM Sans 16sp, white 80% opacity
- Bottom section: white text 'No card required · Start for free' caption
- Buttons (bottom 40% of screen):
- \- 'Continue with Google' — pill button, white background, Google icon, dark text
- \- 'Continue with Email' — pill button, white background, @ icon, dark text
- \- Buttons: height 54px, borderRadius 50px, spacing 12px between
- Bottom fine print: 'By continuing you agree to Terms & Privacy Policy' in caption, white 60%

## **Screen 3 — SignupScreen**

**▸ Route**

/signup

**▸ Layout**

- Same background image as LoginScreen
- Email + Password + Name TextFields in a white card at bottom (bottom sheet style, borderRadius top 24px)
- Fields background: #F0EBE5, borderRadius 12px, border 1px #E8DDD5
- PrimaryButton: 'Create Account' — full pill, primary dark brown
- Link at bottom: 'Already have an account? Log in'

## **Screen 4 — OnboardingScreen**

**▸ Route**

/onboarding

**▸ Layout**

- Background: warm off-white #F5F0EB
- PageView — 3 pages with dot indicator
- Each page: large centered illustration (60% screen height), bold heading in DM Sans 24sp, description in bodyLarge
- Page 1: plant sprouting icon — 'Talk to Your AI Coach'
- Page 2: checklist icon — 'Get a Personalized Plan'
- Page 3: streak fire icon — 'Build It for Life'
- Bottom: 'Get Started' — full pill PrimaryButton (dark brown, white text) on last page
- 'Skip' TextButton top-right on pages 1 and 2, color textHint

## **Screen 5 — DashboardScreen**

**▸ Route**

/dashboard

**▸ Reference**

Tiro Image 1, 4, 9 — 'Home' AppBar with dropdown + profile icon, warm bg, card with tab selector, bottom suggestions section

**▸ AppBar**

- Background: transparent (inherits warm bg #F5F0EB), no elevation
- Left: 'Home ⌃' — DM Sans SemiBold 18sp, textPrimary + dropdown chevron (for future folder switching — like Tiro)
- Right: CircleAvatar — user initials, background #E8DDD5, size 36px (exactly like Tiro's profile icon)

**▸ Body — Background: #F5F0EB**

- Top: Big headline — 'Good morning, \[name\].' in screenTitle, textPrimary. Below: 'You have 3 active habits.' in bodyMedium, textSecondary
- Main action card (white, borderRadius 16px, padding 20px, shadow) — contains the 'New Habit' tab selector:
- Tab bar: 'Active' | 'Completed' | 'All' — Tiro-style pill segmented tabs (#F0EBE5 bg, active = #2C1810)
- Below tabs: ListView of HabitCards

**▸ HabitCard (inside main card)**

- Each card: white bg, borderRadius 12px, border 1px #E8DDD5, padding 14px
- Left accent: 4px brown bar
- Row 1: habit name (cardTitle) + phase badge pill (right)
- Row 2: LinearProgressIndicator — height 5px, color #2C1810, bg #E8DDD5, borderRadius 4px
- Row 3: '🔥 12 day streak' (bodyMedium, textSecondary) + 'Day 12/25' (caption, textHint)

**▸ Bottom Section (like Tiro's 'Good to do when you have time')**

- Section title: 'Quick Actions' in bodyMedium SemiBold, textHint
- Row items with icon + title + arrow — same as Tiro's list items
- Items: 'Start New Habit' | 'Review Today's Tasks' | 'Check Progress'

**▸ FAB**

- FloatingActionButton — background #2C1810, white + icon, borderRadius 16px (slightly rounded square — not circle)
- Bottom right, margin 20px

## **Screen 6 — ChatScreen (AI Intake Interview)**

**▸ Route**

/chat/:moduleId

**▸ Reference**

Tiro Image 9 — 'Real-time notes with Tiro.' heading style. Clean, focused.

**▸ AppBar**

- Background transparent, back arrow left
- Center: 'Habit Coach' in DM Sans SemiBold 16sp + small green dot + 'Online' in caption

**▸ Body**

- Background: #F5F0EB (warm off-white — not stark white)
- Big headline at top (like Tiro's screen title): 'Let's build your habit.' in screenTitle, textPrimary, centered, top padding 32px
- Chat bubbles below in ListView
- AI bubble: background white, border 1px #E8DDD5, borderRadius 16px 16px 16px 4px, text textPrimary
- User bubble: background #2C1810, text white, borderRadius 16px 16px 4px 16px
- Typing indicator: 3 warm brown dots (#8B4513) bouncing

**▸ Input Bar (bottom sticky — like Tiro's 'Ask Tiro anything' bar)**

- Background: white, top border 1px #E8DDD5
- TextField: background #F0EBE5, borderRadius 50px, hint: 'Type your message...' in textHint
- Mic icon left side of field (brown) — for future voice input
- Send button right: circle, background #2C1810, white send icon, size 40px
- This bar mirrors Tiro's bottom 'Ask Tiro anything' bar exactly

## **Screen 7 — HabitDetailScreen**

**▸ Route**

/habit/:moduleId

**▸ Reference**

Tiro Image 2 — Note detail with tabs (Note | Transcript | Meeting), 3-dot menu, blurred context menu

**▸ AppBar**

- Back arrow left + habit name (cardTitle, textPrimary) + date 'Started Jun 11' (caption, textHint)
- Right: download/share icon + 3-dot menu icon (like Tiro's exact AppBar layout)

**▸ Tab Bar — Tiro-style (below AppBar)**

- 3 tabs: 'Overview' | 'Daily Plan' | 'Tips' — pill segmented tabs, warm brown theme

**▸ Overview Tab**

- Progress section: CircularPercentIndicator, radius 55px, color #2C1810, center = streak number in screenTitle
- Streak calendar: 25 squares grid, completed = success green bg + checkmark, today = brown border glow
- 'Why it matters' card: background #FBF7F4, borderRadius 12px, italic bodyLarge, left border 4px #2C1810
- 'Mark Today Done' button: full width pill, primary dark brown — main CTA

**▸ Daily Plan Tab**

- List of day cards — today highlighted with brown left border
- Each item: Day number (bold) + task description + tip (italic, textHint)

**▸ 3-dot Context Menu (Tiro-style)**

- Bottom sheet overlay from right/bottom: white card, borderRadius 16px
- Options: 'Edit Habit' (pencil icon) | 'Share Progress' (share icon) | 'Archive' (folder icon) | 'Delete Habit' (red trash icon)
- Delete option: red text #C0392B — exactly like Tiro's 'Delete Note'

## **Screen 8 — CheckinScreen**

**▸ Route**

/checkin/:moduleId

**▸ Layout**

- Same warm background #F5F0EB
- Top headline: '21-Day Check-in 🌱' in screenTitle
- Subtitle: 'Let's see how far you've come.' in bodyLarge, textSecondary
- Same chat UI as ChatScreen — AI sends evaluation questions

**▸ Result States**

- CLOSE (Habit Built): full-screen warm overlay, '🏆 Habit Built!' in big screenTitle, confetti, 'Share' button + 'Start New Habit' button
- EXTEND (7 more days): card with warm bg, encouraging message, 'Continue' pill button
- RESTART: card with 'Let's adjust.' heading, new plan preview, 'Start Fresh' pill button

## **Screen 9 — ProfileScreen**

**▸ Route**

/profile

**▸ Reference**

Tiro Image 5 — Profile screen with avatar, toggle switches, sections, red Delete Account at bottom

**▸ Layout**

- AppBar: back arrow + no title (clean, like Tiro)
- Top: CircleAvatar (large, 60px, colored bg with initials) + username bold + email below + 'Logout' button top-right (outlined, borderRadius 8px) — exact Tiro layout
- Settings section (white card, borderRadius 12px):
- \- 'Daily Reminder Time' toggle/picker
- \- 'Notification Sound' toggle
- \- 'Dark Mode' toggle (future)
- Toggle style: iOS-style CupertinoSwitch, active color #2C1810 — same as Tiro
- 'Other' section: Privacy Policy | Terms of Service | Rate App | Share App
- Each item: label left + arrow right, 48px height, divider between
- Bottom: 'Manage Account' expandable → 'Delete Account' in red #C0392B — exactly like Tiro

# **3\. Navigation Flow**

App Launch (/)

└── SplashScreen

├── \[First time\] ──► LoginScreen ──► OnboardingScreen ──► Dashboard

├── \[Has account\] ──► LoginScreen ──► Dashboard

└── \[Logged in\] ──► Dashboard

DashboardScreen (/dashboard)

├── \[FAB or 'New Habit'\] ──► ChatScreen (/chat/new)

│ └── \[Complete\] ──► HabitDetailScreen (/habit/:id)

├── \[HabitCard tap\] ──► HabitDetailScreen (/habit/:id)

│ ├── \[Day 21\] ──► CheckinScreen (/checkin/:id)

│ └── \[3-dot menu\] ──► ContextMenu overlay

└── \[Profile avatar\] ──► ProfileScreen (/profile)

# **4\. Vibe Coding Prompt Template**

Copy-paste this exact prompt when asking AI to build any screen:

I am building a Flutter Android app called Habitat (habit building AI coach).

Design inspiration: Tiro app — warm brown palette, pill buttons, clean minimal.

COLOR TOKENS:

primary: Color(0xFF2C1810) // dark brown — buttons, icons

primaryWarm: Color(0xFF8B4513) // warm brown — accents, links

background: Color(0xFFF5F0EB) // warm off-white — app bg

surface: Color(0xFFFFFFFF) // white — cards

inputBg: Color(0xFFF0EBE5) // warm grey — inputs, tab container

textPrimary: Color(0xFF1A0F0A) // near black

textSecondary: Color(0xFF6B4C3B) // warm brown text

textHint: Color(0xFFA08070) // light hint

border: Color(0xFFE8DDD5) // warm border

TYPOGRAPHY: google_fonts — Playfair Display (app name), DM Sans (all body)

KEY STYLE RULES:

\- Buttons: height 56px, borderRadius 50px (fully pill-shaped)

\- Tab bar: pill-shaped container, active tab = dark brown pill

\- Cards: white bg, borderRadius 16px, border 1px #E8DDD5, subtle shadow

\- App background is ALWAYS #F5F0EB, not white

\- Destructive actions (Delete): Color(0xFFC0392B) red text

Now build the \[SCREEN NAME\] with these specs:

\[paste screen spec from this document\]

## **4.1 Build Order**

|     |     |     |
| --- | --- | --- |
| **#** | **Task** | **Notes** |
| 1   | app_colors.dart | Define all color tokens above as static const |
| 2   | app_text_styles.dart | Playfair Display + DM Sans styles via google_fonts |
| 3   | SplashScreen | White bg, centered icon + Habitat name side by side |
| 4   | LoginScreen | Background image + bottom pill buttons (Google, Email) |
| 5   | DashboardScreen | Warm bg, Home AppBar, Tiro-style tab bar, HabitCards |
| 6   | ChatScreen | Warm bg, big headline, chat bubbles, bottom input bar |
| 7   | HabitDetailScreen | 3 tabs (Overview/Plan/Tips), streak calendar, 3-dot menu |
| 8   | CheckinScreen | Same chat UI + result state screens |
| 9   | ProfileScreen | Tiro-style settings with toggles + red delete at bottom |

_Document v2.0 — Updated with Tiro-inspired design language. Habitat Hackathon — June 2026._