import { serve } from 'https://deno.land@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const CHECKIN_PROMPT = `
You are evaluating a user's habit progress after 21-25 days.
Analyze the user's self-reported progress and return ONLY a valid JSON object matching the exact schema below. Do not include markdown code block syntax or conversational text.

Schema:
{
  "decision": "close" | "extend" | "restart",
  "message": "Write a warm, encouraging response to the user explaining the decision, citing behavioral psychology insights (Atomic Habits, Tiny Habits).",
  "reason": "Brief technical explanation of why this decision was reached."
}

Decision guidelines:
- close: Choose this if the user says the habit has become easy, automatic, consistent, or they can do it without reminders. This marks the habit complete!
- extend: Choose this if the user is showing progress but still struggles occasionally, forgets, or still feels dependent on notifications. This extends the program by 7 days.
- restart: Choose this if the user says it's not working, they completely failed, forgot most days, or it was too hard. This restarts the habit program with a recalibrated easier difficulty.
`

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { habit_name, user_response } = await req.json()
    const groqApiKey = Deno.env.get('GROQ_API_KEY')

    if (!groqApiKey) {
      return new Response(
        JSON.stringify({ error: 'GROQ_API_KEY is not configured.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const payload = {
      model: 'llama-3.3-70b-versatile',
      max_tokens: 1024,
      temperature: 0.2,
      messages: [
        { role: 'system', content: CHECKIN_PROMPT },
        { 
          role: 'user', 
          content: `Habit Goal Name: "${habit_name}". User's Day 21 Update Response: "${user_response}". Evaluate and return the decision JSON.`
        }
      ],
      response_format: { type: "json_object" }
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

    // Parse and validate JSON
    const checkinJson = JSON.parse(rawContent)

    return new Response(JSON.stringify(checkinJson), {
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
