# Habitat (Flutter) — Hackathon Scaffold

This folder contains a minimal Flutter scaffold for the Habitat hackathon project based on the documents in `Habitat/Documentation`.

Quick run (ensure Flutter 3.22+ is installed):

```bash
cd "u:/VIBE Coding/Hackathon/Habitat/habitat_app"
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://your.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

Files added:
- `lib/main.dart`, `lib/app.dart`
- `lib/core/constants/*` (colors, text styles)
- `lib/screens/*` (splash, login, dashboard, chat, habit detail)

Notes:
- This is a starter scaffold matching the TRD/UI spec. Implementations for Supabase, Edge Functions, and full chat logic are placeholders.
 - The app now supports generating a habit module from chat input, saving it, and previewing it in a dedicated habit detail screen.
Free services and deploy notes
- Supabase: free tier available and recommended for database + Edge Functions. Create a free project at https://app.supabase.com.
- Groq: the TRD references Groq (free tier). You can substitute any free LLM or keep Edge Functions as stubs for demo.

Deploy Edge Functions (Supabase CLI):
```bash
# Install supabase CLI: https://supabase.com/docs/guides/cli
cd "u:/VIBE Coding/Hackathon/Habitat/habitat_app/supabase"
supabase functions deploy groq-intake
supabase functions deploy groq-generate
supabase functions deploy groq-checkin
```

Run locally using Supabase CLI (dev):
```bash
supabase start
supabase functions serve groq-intake
```

Database migration (SQL):
```bash
# Open Supabase SQL Editor and paste habitat_app/supabase/migrations/001_initial_schema.sql
```

No paid services are required to demo the scaffold — the app falls back to mocked responses if no Supabase or Groq keys are provided.
