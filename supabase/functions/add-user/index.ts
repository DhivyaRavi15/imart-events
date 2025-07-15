/// <reference lib="deno.ns" />

import "https://deno.land/std@0.224.0/dotenv/load.ts";
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.5";
import type { Database } from "../_shared/database.types.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
// const isLocal = Deno.env.get("IS_LOCAL") === "true";
const isLocal = true;


const supabase = createClient<Database>(supabaseUrl, supabaseServiceRoleKey);

// CORS headers to include when running locally
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info",
};

serve(async (req: Request) => {
  // Handle OPTIONS request for CORS preflight when running locally
  if (isLocal && req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  }
  
  const { event, user } = await req.json();

  if (event !== "SIGNED_UP") {
    return new Response("Not handling this event", { 
      status: 200,
      headers: isLocal ? corsHeaders : { "Content-Type": "application/json" }
    });
  }

  let data;
  
  try {
    const { id, email, user_metadata } = user;
    
    // Regex patterns for validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const phoneRegex = /^\d{7,15}$/; // Phone number should be 7-15 digits
    
    // Validation for required fields
    const validationRules = [
      { value: id, message: "User ID is required" },
      { value: email, message: "Email is required" },
      { value: user_metadata, message: "User metadata is required" },
      { value: user_metadata?.first_name, message: "First name is required" },
      { value: user_metadata?.last_name, message: "Last name is required" },
      { value: user_metadata?.phone, message: "Phone number is required" },
      { value: user_metadata?.date_of_birth, message: "Date of birth is required" }
    ];

    for (const rule of validationRules) {
      if (!rule.value) {
        throw new Error(rule.message);
      }
    }
    
    // Regex validations
    if (!emailRegex.test(email)) {
      throw new Error("Invalid email format");
    }
    
    
    if (!phoneRegex.test(user_metadata.phone)) {
      throw new Error("Invalid phone number format. Must contain 7-15 digits only");
    }
    
    // Age validation (18+)
    const birthDate = new Date(user_metadata.date_of_birth);
    const today = new Date();
    
    if (isNaN(birthDate.getTime())) {
      throw new Error("Invalid date of birth format");
    }
    
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    if (age < 18) {
      throw new Error("User must be at least 18 years old");
    }
    
    const { first_name, last_name, phone, date_of_birth } = user_metadata;
    const currentTimestamp = new Date().toISOString();
    
    // Combine country code and phone number
    
    const userInsert: Database['public']['Tables']['users']['Insert'] = {
      user_id: id,
      email,
      first_name,
      last_name,
      phone,
      date_of_birth,
      active_status: true,
      created_at: currentTimestamp,
      registration_date: currentTimestamp,
    };

    const result = await supabase.from("users").insert([userInsert]);
    data = result;
    
    if (result.error) {
      // Create headers based on environment
      const headers = {
        "Content-Type": "application/json",
        ...(isLocal ? corsHeaders : {})
      };

      return new Response(JSON.stringify({ message: result.error.message, success: false}), { 
        status: 400,
        headers
      });
    }

  } catch (error) {
    console.error("Error processing user:", error);
    const errorMessage = error instanceof Error ? error.message : "Failed to insert user";
    
    // Create headers based on environment
    const headers = {
      "Content-Type": "application/json",
      ...(isLocal ? corsHeaders : {})
    };
    
    return new Response(JSON.stringify({ message: errorMessage, success: false}), { 
      status: 400,
      headers
    });
  }

  // Create headers based on environment
  const headers = {
    "Content-Type": "application/json",
    ...(isLocal ? corsHeaders : {})
  };

  return new Response(JSON.stringify({ message: "User added successfully", success: true }), { 
    status: 200,
    headers
  });
});