import { serve } from 'https://deno.land@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const GENERATE_PROMPT = `
You are a habit creation engine. Based on the intake conversation, generate a structured habit module.
Return ONLY a valid JSON object matching the exact schema below. Do not include markdown code block syntax (like \`\`\`json) or any conversational text. Return ONLY the raw JSON string.

Schema:
{
  "habit_name": "String representing the concise, action-oriented title of the habit (e.g. Read More, Use Phone Less)",
  "goal_description": "String representing the overarching goal",
  "why_it_matters": "String representing the personalized motivation statement from the user's interview",
  "blockers": ["String obstacle 1", "String obstacle 2"],
  "env_design_tips": ["Environment adjustment 1", "Environment adjustment 2", "Environment adjustment 3"],
  "daily_plan": [
    { "day": 1, "task": "Specific micro-task for day 1", "tip": "Context-aware tip 1" },
    ...
    { "day": 25, "task": "Specific task for day 25", "tip": "Context-aware tip 25" }
  ],
  "obstacle_playbook": [
    { "trigger": "Predicted distraction trigger 1", "response": "Concrete actionable response 1" },
    { "trigger": "Predicted distraction trigger 2", "response": "Concrete actionable response 2" }
  ],
  "reminder_schedule": [
    { "phase": 1, "frequency": "3x daily", "days": "1-7" },
    { "phase": 2, "frequency": "2x daily", "days": "8-14" },
    { "phase": 3, "frequency": "1x daily", "days": "15-21" },
    { "phase": 4, "frequency": "every 2 days", "days": "22-25" }
  ],
  "sample_reminders": [
    { "phase": 1, "time": "8:00 AM", "message": "Morning prompt" },
    { "phase": 1, "time": "1:00 PM", "message": "Afternoon prompt" },
    { "phase": 1, "time": "8:00 PM", "message": "Evening prompt" }
  ]
}
`

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { messages } = await req.json()
    const groqApiKey = Deno.env.get('GROQ_API_KEY')

    if (!groqApiKey) {
      return new Response(
        JSON.stringify({ error: 'GROQ_API_KEY is not configured.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const payload = {
      model: 'llama-3.3-70b-versatile',
      max_tokens: 2048,
      temperature: 0.2, // low temperature for structured JSON compliance
      messages: [
        { role: 'system', content: GENERATE_PROMPT },
        { role: 'user', content: `Here is the interview history: ${JSON.stringify(messages)}. Generate the module.` }
      ],
      response_format: { type: "json_object" } // Force JSON output if supported by Groq API
    }

    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${groqApiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    })

    const data = await response.json()
    const rawContent = data.choices[0].message.content.trim()

    // Parse it and return the inner structure directly to make it clean
    const habitJson = JSON.parse(rawContent)

    return new Response(JSON.stringify(habitJson), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
