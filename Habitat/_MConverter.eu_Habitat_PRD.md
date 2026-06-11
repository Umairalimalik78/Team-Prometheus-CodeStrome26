**Habitat**

AI-Powered Habit Building Platform

Product Requirements Document (PRD)

Version 1.0 \| Hackathon Edition \| June 2026

# 1. Product Overview {#product-overview}

## 1.1 Executive Summary {#executive-summary}

Habitat is an AI-powered habit coaching platform that guides users through building sustainable habits using conversational AI. Unlike generic habit trackers, Habitat conducts deep intake interviews, generates personalized habit modules, and uses intelligent reminder tapering to transition users from dependency to autonomous routine --- mirroring scientifically-backed methods from behavioral psychology literature (e.g., Atomic Habits by James Clear, The Power of Habit by Charles Duhigg).

## 1.2 Problem Statement {#problem-statement}

Most people fail to build lasting habits because:

- Generic habit apps provide no personalization or coaching context

- Users don\'t understand their own blockers (distractions, triggers, environment)

- Reminder systems don\'t taper off --- creating dependency rather than autonomy

- There is no feedback loop to assess whether a habit has truly been internalized

## 1.3 Solution {#solution}

Habitat solves this by offering an AI coach that:

- Interviews the user to deeply understand their habit goal and personal obstacles

- Generates a fully personalized habit module with context-aware micro-suggestions

- Sends smart, tapering reminders that become less frequent as habit adherence improves

- Conducts 21--25 day check-ins and autonomy assessments to close or continue modules

## 1.4 Target Users {#target-users}

Primary users are individuals aged 18--40 who:

- Want to build productivity, wellness, or lifestyle habits

- Have previously tried and failed with standard habit trackers

- Are comfortable with conversational AI interfaces

- Are motivated but need structured guidance and accountability

# 2. Goals & Success Metrics {#goals-success-metrics}

## 2.1 Hackathon Goals {#hackathon-goals}

- Demonstrate end-to-end AI habit onboarding flow via conversational UI

- Show a functional personalized dashboard with at least one active habit module

- Illustrate the reminder system concept with tapering logic

- Impress judges with a compelling, emotionally resonant demo scenario

## 2.2 Success Metrics (Post-Launch KPIs) {#success-metrics-post-launch-kpis}

| **Metric** | **Target** | **Measurement** |
|----|----|----|
| Habit Module Completion Rate | \> 60% at day 25 | Modules marked complete |
| Reminder Dependency Rate | \< 30% users at day 25 | Users still needing reminders |
| User Retention (Day 7) | \> 50% | DAU / signup cohort |
| Avg Habits Tracked Per User | \> 2.5 | Dashboard module count |

# 3. Core Features & Requirements {#core-features-requirements}

## 3.1 AI Onboarding Interview (MVP --- Must Have) {#ai-onboarding-interview-mvp-must-have}

When a user wants to build a new habit, the AI initiates a guided conversational intake. The conversation covers:

- What habit the user wants to build and why it matters to them

- Previous attempts and what caused them to fail

- Current blockers: distractions, environment, triggers, time constraints

- Preferred schedule, available time slots, and energy levels throughout the day

- Accountability preferences (public, private, partner-based)

The AI is trained on / prompted with frameworks from:

- Atomic Habits --- habit stacking, environment design, identity-based habits

- The Power of Habit --- cue-routine-reward loops

- BJ Fogg\'s Tiny Habits --- starting with minimum viable behaviors

## 3.2 Habit Module Generation (MVP --- Must Have) {#habit-module-generation-mvp-must-have}

After the intake interview, the AI auto-generates a Habit Module and adds it to the user\'s dashboard. Each module includes:

- Habit Name & Description --- clearly labeled goal

- Why It Matters --- personalized motivation statement from interview

- Daily Action Plan --- specific micro-tasks broken down by day

- Environment Design Tips --- contextual suggestions (e.g., put the book on your pillow, put your phone in another room)

- Obstacle Playbook --- personalized responses to predicted blockers

- Progress Tracker --- visual streak calendar (days 1--25)

- Milestone Markers --- day 7, 14, 21, 25 checkpoints

## 3.3 Smart Reminder System (MVP --- Must Have) {#smart-reminder-system-mvp-must-have}

Reminders are intelligent and contextual, not generic push notifications.

### Reminder Phases:

- Days 1--7 (High Frequency): 2--3 reminders per day with motivational nudges and environment design tips

- Days 8--14 (Moderate): 1--2 reminders per day, more reflective in tone

- Days 15--21 (Reducing): 1 reminder per day, shifting to autonomy prompts

- Days 22--25 (Tapering): 1 reminder every 2--3 days

- Post Day 25 (Autonomy Check): Reminders paused; AI sends check-in message

Reminder content is habit-specific. Example for \'Read more, use phone less\':

- Morning: \'Good morning! Your book is waiting --- put your phone across the room before sitting down.\'

- Evening: \'Time to wind down. Phone goes to the kitchen. Book goes on your lap.\'

## 3.4 Progress Check-In & AI Evaluation (MVP --- Must Have) {#progress-check-in-ai-evaluation-mvp-must-have}

On day 21--25, the AI sends a structured check-in conversation:

- \'How has the habit been going? Are you following it most days without reminders?\'

- If YES: The AI begins reminder wind-down and marks the module as \'Autonomous Mode\'

- If PARTIAL: The AI diagnoses blockers, adjusts the plan, extends the module by 1 week

- If NO: The AI restarts a modified version of the habit module with recalibrated difficulty

## 3.5 Multi-Habit Dashboard (MVP --- Must Have) {#multi-habit-dashboard-mvp-must-have}

Users can run multiple habit modules simultaneously. The dashboard shows:

- Active habits with streak counters and phase indicators

- Completed / Autonomous habits (greyed out with success badge)

- Quick-add button to start a new habit via AI interview

- Weekly summary --- a brief AI-generated reflection on overall progress

## 3.6 Notifications & Reminders (MVP --- Must Have) {#notifications-reminders-mvp-must-have}

- Web push notifications (PWA) or in-app notifications

- Optional SMS reminders (stretch goal --- Twilio integration)

- User can snooze, dismiss, or mark reminder as \'done\' with one tap

- Snoozing too many times triggers a gentle AI intervention

## 3.7 Stretch Features (Nice to Have) {#stretch-features-nice-to-have}

- Habit Partner Mode --- share progress with an accountability partner

- Voice Onboarding --- use speech-to-text for the intake interview

- Wearable Integration --- sync with Apple Health / Google Fit for relevant habits

- Community Feed --- anonymized habit wins shared in a social feed

- Habit Library --- pre-built modules for top 20 common habits

# 4. User Flow {#user-flow}

## 4.1 Primary User Journey {#primary-user-journey}

| **Step** | **Action** | **System Response** | **Output** |
|----|----|----|----|
| 1 | User signs up / logs in | Onboarding screen with CTA: \'Build a new habit\' | Empty dashboard |
| 2 | Taps \'New Habit\' | AI launches intake interview chat | Conversation UI opens |
| 3 | Completes AI interview | AI generates personalized Habit Module | Module added to dashboard |
| 4 | Reviews module | Module detail view with daily plan + tips | User confirms & activates |
| 5 | Daily engagement | Smart reminders sent at optimal times | Streak tracked; reminders taper |
| 6 | Day 21--25 check-in | AI sends evaluation conversation | Module closed, extended, or adjusted |
| 7 | Habit internalized | Module archived with \'Habit Built\' badge | User prompted to start next habit |

# 5. Technical Architecture {#technical-architecture}

## 5.1 Recommended Tech Stack (Hackathon) {#recommended-tech-stack-hackathon}

| **Layer** | **Technology** | **Reason** |
|----|----|----|
| Frontend | React + Tailwind CSS (PWA) | Fast to build, mobile-friendly, supports push notifications |
| AI / LLM | Claude API (claude-sonnet-4) | Best conversational reasoning + tool use for intake flow |
| Backend | Node.js + Express or Next.js API routes | Lightweight, fast to scaffold for hackathon |
| Database | Supabase (Postgres + Auth) | Real-time, managed, free tier for hackathon |
| Notifications | Web Push API (via service worker) | No third-party dependency; works on mobile browsers |
| Deployment | Vercel | Zero-config deployment, free tier, fast CI |

## 5.2 AI Prompt Architecture {#ai-prompt-architecture}

The AI system uses a multi-stage prompting strategy:

- Stage 1 --- Intake System Prompt: Loaded with habit psychology frameworks. Asks structured questions and collects JSON-structured user profile.

- Stage 2 --- Module Generation Prompt: Takes the user profile and outputs a structured Habit Module JSON (plan, tips, obstacle map, reminder schedule).

- Stage 3 --- Reminder Generation Prompt: Generates daily reminder messages per phase based on module context.

- Stage 4 --- Check-In Prompt: Evaluates user\'s progress response and outputs a structured decision: Close / Extend / Restart.

## 5.3 Data Models (Simplified) {#data-models-simplified}

User: { id, name, email, timezone, preferences }

HabitModule: { id, userId, habitName, goal, blockers, dailyPlan\[\], tips\[\], reminderSchedule, phase, streakCount, status }

Reminder: { id, moduleId, scheduledAt, content, type, delivered, snoozed }

CheckIn: { id, moduleId, day, userResponse, aiDecision, adjustments }

# 6. UX & Design Principles {#ux-design-principles}

- Conversational First: The AI intake should feel like talking to a wise coach, not filling out a form

- One Thing At A Time: Dashboard is calm, never cluttered --- one featured habit at a time, others secondary

- Progress Feels Good: Streak visuals, milestone badges, and encouraging AI messages create positive reinforcement

- Reminders Feel Human: Notification copy is warm and specific, not robotic (\'Your book is waiting\' not \'Reminder: Read\')

- Mobile Optimized: Primary use case is on the phone --- swipe-based interactions, large tap targets

## 6.1 Key Screens {#key-screens}

- Onboarding / Sign Up --- minimal, explains value in 3 steps

- AI Chat Interface --- full-screen chat for intake interview

- Habit Module Detail --- visual card with daily plan, progress ring, and tip section

- Dashboard --- scrollable list of active habit modules with status badges

- Reminder Notification --- rich push notification with action buttons (Done / Snooze / Skip)

- Check-In Screen --- conversational review UI, triggered at day 21--25

# 7. Risks & Mitigations {#risks-mitigations}

| **Risk** | **Severity** | **Likelihood** | **Mitigation** |
|----|----|----|----|
| AI interview feels too long / tedious | High | Medium | Cap at 5 questions; use branching logic |
| Push notifications blocked by browsers | Medium | High | Fallback to in-app notification center |
| Users drop off before module completion | High | High | Re-engagement AI messages at day 3 and day 7 |
| LLM generates low-quality habit modules | High | Low | Extensive prompt engineering + test cases |
| Scope creep during hackathon | Medium | High | Lock MVP to 3 screens + 1 demo habit flow |

# 8. Hackathon Execution Plan {#hackathon-execution-plan}

## 8.1 Build Priority {#build-priority}

- P0 (Must Demo): AI intake interview chat → module generation → dashboard card

- P0 (Must Demo): Habit module detail view with daily plan and tips

- P1 (Should Demo): Mock reminder notification with tapering logic shown visually

- P1 (Should Demo): Day 21 check-in conversation flow

- P2 (Nice to Have): Real push notification delivery

- P2 (Nice to Have): Multiple active habits on dashboard

## 8.2 Suggested Team Splits (3-person team) {#suggested-team-splits-3-person-team}

- Person A --- Frontend: React app, dashboard, habit module UI, chat interface

- Person B --- AI/Backend: Claude API integration, prompt engineering, module generation logic

- Person C --- UX/Full-stack: Reminder system, Supabase schema, check-in flow, demo script

## 8.3 Demo Script {#demo-script}

Recommended demo narrative for judges:

- Show an empty dashboard --- relatable, we\'ve all been there

- Tap \'New Habit\' --- AI interview begins: \'I want to read more and use my phone less\'

- Walk through 3--4 interview questions highlighting personalization

- Show generated module appearing on dashboard with personalized tips

- Show what a contextual reminder looks like (\'Put your phone in another room\...\')

- Fast-forward to Day 21 check-in --- AI evaluates progress and closes the module

- User gets \'Habit Built\' badge --- emotional payoff moment

# 9. Appendix {#appendix}

## 9.1 Inspiration & Research Sources {#inspiration-research-sources}

- Atomic Habits --- James Clear: Identity-based habit formation, habit stacking, environment design

- The Power of Habit --- Charles Duhigg: Cue-routine-reward neurological loops

- Tiny Habits --- BJ Fogg: Minimum viable behaviors, celebration moments

- Nir Eyal\'s Hooked Model: Variable rewards and trigger-action loops

- Psychology research: 21--66 day habit formation range (Phillippa Lally, UCL, 2009)

## 9.2 Competitive Landscape {#competitive-landscape}

| **App** | **What They Do** | **Habitat Advantage** |
|----|----|----|
| Habitica | Gamified habit tracker | AI personalization + coaching depth |
| Streaks | Simple streak-based habits | AI intake + tapering reminder intelligence |
| Fabulous | Routine builder with nudges | Conversational AI, not static plans |
| Notion + AI | Manual habit journaling | Fully automated module generation |

*Document prepared for Hackathon submission. Version 1.0 --- June 2026.*
