/// <reference lib="deno.ns" />

import "https://deno.land/std@0.224.0/dotenv/load.ts";
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.5";

// const supabaseUrl = Deno.env.get('https://uycpfzpkgepvlahagija.supabase.co')!;
// const supabaseServiceRoleKey = Deno.env.get('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV5Y3BmenBrZ2VwdmxhaGFnaWphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMyNDk3MzQsImV4cCI6MjA1ODgyNTczNH0.oD26PKieI_WBQvFOwFVbCWY5x4hR9_S5JBBO00KtnVM')!;


const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;


const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

serve(async (req: Request) => {
  const { event, user } = await req.json();

  if (event !== "SIGNED_UP") {
    return new Response("Not handling this event", { status: 200 });
  }

  try {
    const {id,email,user_metadata:{full_name}} = user;
      const { error } = await supabase.from("custom_users").insert([
    {
      id: id,
      email: email,
      full_name: full_name || null,
      created_at: new Date().toISOString(),
    },
  ]);
    if (error) {
    console.error("Insert error:", error.message);
    return new Response(error.message, { status: 500 });
  }
  } catch (error) {
    
        return new Response("Failed to insert user", { status: 500 });
  }




  return new Response("User added successfully", { status: 200 });
});
