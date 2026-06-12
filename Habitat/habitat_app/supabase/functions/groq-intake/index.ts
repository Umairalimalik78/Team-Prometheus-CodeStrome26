import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

serve(async (req) => {
  try {
    const { messages } = await req.json().catch(() => ({}));
    // Minimal echo / demo response for local testing
    const reply = {
      id: 'demo-reply',
      role: 'assistant',
      content: 'This is a demo intake reply. Replace with GROQ/Groq API integration.'
    };
    return new Response(JSON.stringify({ reply, messages }), { headers: { 'Content-Type': 'application/json' } });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500, headers: { 'Content-Type': 'application/json' } });
  }
});
