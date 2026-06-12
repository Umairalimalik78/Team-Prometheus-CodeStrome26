import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

serve(async (req) => {
  try {
    const body = await req.json().catch(() => ({}));
    // Demo: return a simple habit module JSON structure
    const module = {
      habit_name: 'Demo Habit',
      goal_description: 'Demo goal',
      why_it_matters: 'Demo why',
      blockers: ['demo blocker'],
      env_design_tips: ['Put a book on your pillow'],
      daily_plan: [{ day: 1, task: 'Read 5 minutes', tip: 'Keep book visible' }],
      obstacle_playbook: [{ trigger: 'Phone', response: 'Place phone in another room' }],
      reminder_schedule: [{ phase: 1, frequency: '3x daily', days: '1-7' }],
      sample_reminders: [{ phase: 1, time: '08:00', message: 'Morning reminder (demo)' }]
    };
    return new Response(JSON.stringify(module), { headers: { 'Content-Type': 'application/json' } });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500, headers: { 'Content-Type': 'application/json' } });
  }
});
