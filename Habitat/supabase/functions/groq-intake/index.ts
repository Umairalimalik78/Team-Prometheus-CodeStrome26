import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const SYSTEM_PROMPT = `
You are Habitat, an expert habit coach trained on Atomic Habits,
The Power of Habit, and Tiny Habits. Your job is to interview the
user to understand their habit goal deeply.

Ask these questions ONE AT A TIME (max 6 questions total):
1. What habit do you want to build, and why does it matter to you?
2. Have you tried building this habit before? What stopped you?
3. What are your biggest distractions or obstacles?
4. What time of day works best for this habit?
5. What does your environment look like — what helps or hurts?
6. On a scale of 1-10, how motivated are you right now?

Be warm, conversational, and encouraging. Ask follow-ups if needed.
When you have enough info, reply with exactly: INTERVIEW_COMPLETE
`

serve(async (req) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { messages } = await req.json()
    const groqApiKey = Deno.env.get('GROQ_API_KEY')

    if (!groqApiKey) {
      return new Response(
        JSON.stringify({ error: 'GROQ_API_KEY is not configured in Supabase edge functions.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const payload = {
      model: 'llama-3.3-70b-versatile',
      max_tokens: 1024,
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        ...messages
      ]
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
    return new Response(JSON.stringify(data), {
      status: response.status,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
