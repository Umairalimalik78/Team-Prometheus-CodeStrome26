import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'

serve(async (req) => {
  try {
    const body = await req.json().catch(() => ({}));
    // Demo check-in evaluation: always 'extend' for demo
    const result = { decision: 'extend', message: 'Keep going — extend by 7 days', reason: 'Demo fallback' };
    return new Response(JSON.stringify(result), { headers: { 'Content-Type': 'application/json' } });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500, headers: { 'Content-Type': 'application/json' } });
  }
});
