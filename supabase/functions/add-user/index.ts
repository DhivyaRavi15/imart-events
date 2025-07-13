/// <reference lib="deno.ns" />

import "https://deno.land/std@0.224.0/dotenv/load.ts";
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.5";
import type { Database } from "../_shared/database.types.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient<Database>(supabaseUrl, supabaseServiceRoleKey);

serve(async (req: Request) => {
  const { event, user } = await req.json();

  if (event !== "SIGNED_UP") {
    return new Response("Not handling this event", { status: 200 });
  }

  let data;
  
  try {
    const { id, email, user_metadata } = user;
    
    // Validation for required fields
    const validationRules = [
      { value: id, message: "User ID is required" },
      { value: email, message: "Email is required" },
      { value: user_metadata, message: "User metadata is required" },
      { value: user_metadata?.first_name, message: "First name is required" },
      { value: user_metadata?.last_name, message: "Last name is required" }
    ];

    for (const rule of validationRules) {
      if (!rule.value) {
        throw new Error(rule.message);
      }
    }
    
    const { first_name, last_name } = user_metadata;
    const currentTimestamp = new Date().toISOString();
    
    const userInsert: Database['public']['Tables']['users']['Insert'] = {
      user_auth_id: id,
      email: email,
      first_name: first_name,
      last_name: last_name,
      active_status: true,
      created_at: currentTimestamp,
      registration_date: currentTimestamp,
    };

    const result = await supabase.from("users").insert([userInsert]);
    data = result;
    
    if (result.error) {

      return new Response(JSON.stringify({ message: result.error.message, success: false}), { 
        status: 400,
        headers: { "Content-Type": "application/json" }
      });
    }
  } catch (error) {
    console.error("Error processing user:", error);
    const errorMessage = error instanceof Error ? error.message : "Failed to insert user";
    return new Response(JSON.stringify({ message: errorMessage, success: false}), { 
    status: 400,
    headers: { "Content-Type": "application/json" }
  });
  }

  return new Response(JSON.stringify({ message: "User added successfully", success: true }), { 
    status: 200,
    headers: { "Content-Type": "application/json" }
  });
});