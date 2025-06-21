
/// <reference lib="deno.ns" />

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.43.3?dts';



const supabaseUrl = Deno.env.get('https://uycpfzpkgepvlahagija.supabase.co')!;
const supabaseServiceRoleKey = Deno.env.get('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV5Y3BmenBrZ2VwdmxhaGFnaWphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMyNDk3MzQsImV4cCI6MjA1ODgyNTczNH0.oD26PKieI_WBQvFOwFVbCWY5x4hR9_S5JBBO00KtnVM')!;

const supabaseClient = createClient(supabaseUrl, supabaseServiceRoleKey);

serve(async (req:Request) => {
  const { event, user } = await req.json();

  if (event !== 'SIGNED_UP') {
    return new Response('Not handling this event', { status: 200 });
  }

  const { error } = await supabaseClient.from('custom_users').insert([
    {
      id: user.id,
      email: user.email,
      full_name: user.user_metadata?.full_name || null,
      created_at: new Date().toISOString(),
    },
  ]);

  if (error) {
    console.error('Error inserting user:', error.message);
    return new Response('Database insert error', { status: 500 });
  }

  return new Response('User added successfully', { status: 200 });
});


