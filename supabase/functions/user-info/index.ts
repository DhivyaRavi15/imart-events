/// <reference lib="deno.ns" />

import "https://deno.land/std@0.224.0/dotenv/load.ts";
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient, SupabaseClient, User } from "https://esm.sh/@supabase/supabase-js@2.39.5";
import type { Database } from "../_shared/database.types.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const isLocal = true;

const supabase = createClient<Database>(supabaseUrl, supabaseServiceRoleKey);

// CORS headers to include when running locally
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, PUT, DELETE',
};


export async function getEmployeeAndRelatedData(user: User, supabase: SupabaseClient<Database>) {
  try {
    const { data: employeeInfo, error: employeeError } = await supabase
      .from("employees")
      .select(
        `
        *,
        organization:organization_id (
          *,
          organization_apps (
            *,
            app:app_id (
              *
            )
          )
        )
        `
      )
      .eq("employee_id", user.id)
      .single() as { data: any | null, error: any }; // Cast to the more specific type

    if (employeeError) {
      console.error("Error fetching employee data:", employeeError,`${user}`);
      
      
      // Check if the error is specifically PGRST116 (no rows or multiple rows returned)
      if (employeeError.code === "PGRST116") {
        console.log("Employee not found, attempting to create employee record...");
        
        try {
          // First, get user details from the users table
          const { data: userData, error: userError } = await supabase
            .from("users")
            .select("user_id, first_name, last_name, email")
            .eq("user_id", user.id)
            .single();

          if (userError || !userData) {
            console.error("Error fetching user data:", userError);
            return { 
              data: null, 
              error: { 
                code: "EMPLOYEE_EMPTY", 
                message: "Employee is empty" 
              } 
            };
          }

          // Create employee record using user data
          const { data: newEmployee, error: createError } = await supabase
            .from("employees")
            .insert({
              employee_id: user.id, // Use auth user ID as employee ID
              first_name: userData.first_name,
              last_name: userData.last_name,
              email: userData.email,
              status: "active",
              hire_date: new Date().toISOString()
            })
            .select()
            .single();

          if (createError) {
            console.error("Error creating employee record:", createError);
            return { 
              data: null, 
              error: { 
                code: "EMPLOYEE_EMPTY", 
                message: "Employee is empty" 
              } 
            };
          }

          console.log("Successfully created employee record:", newEmployee);
          
          // Now fetch the complete employee data with organization info
          const { data: completeEmployeeInfo, error: fetchError } = await supabase
            .from("employees")
            .select(
              `
              *,
              organization:organization_id (
                *,
                organization_apps (
                  *,
                  app:app_id (
                    *
                  )
                )
              )
              `
            )
            .eq("employee_id", user.id)
            .single();

          if (fetchError || !completeEmployeeInfo) {
            // If we can't fetch the complete info, return the basic employee data
            return { data: newEmployee, error: null };
          }

          return { data: completeEmployeeInfo, error: null };

        } catch (createEmployeeError) {
          console.error("Unexpected error creating employee:", createEmployeeError);
          return { 
            data: null, 
            error: { 
              code: "EMPLOYEE_EMPTY", 
              message: "Employee is empty" 
            } 
          };
        }
      }
      
      // For other database errors
      return { data: null, error: employeeError };
    }

    if (!employeeInfo) {
      console.log("No employee found for the given user ID.");
      return { 
        data: null, 
        error: { 
          code: "EMPLOYEE_EMPTY", 
          message: "Employee is empty" 
        } 
      };
    }

    // Now, employeeInfo will contain the deeply nested data:
    // employeeInfo.organization will have the organization details
    // employeeInfo.organization.organization_apps will be an array of organization_app records
    // Each organization_app record will have an 'app' property with the app details

    console.log("Employee Info:", employeeInfo);
    console.log("Organization Name:", employeeInfo.organization?.name);
    employeeInfo.organization?.organization_apps.forEach((orgApp: { app: { name: any; }; }) => {
      console.log("App Name:", orgApp.app?.name);
    });

    return { data: employeeInfo, error: null };
  } catch (error) {
    console.error("Unexpected error in getEmployeeAndRelatedData:", error);
    return { 
      data: null, 
      error: { 
        code: "EMPLOYEE_EMPTY", 
        message: "Employee is empty" 
      } 
    };
  }
}


serve(async (req: Request) => {
  // Handle OPTIONS request for CORS preflight
  console.log(req);
  console.log(isLocal);
  console.log(supabaseUrl );
  if (isLocal && req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  }
  
  try {
    // Only try to parse JSON for POST requests with content
    let event;
    if (req.method === "POST") {
      const contentType = req.headers.get("content-type");
      if (contentType && contentType.includes("application/json")) {
        const body = await req.json();
        event = body.event;
      } else {
        throw new Error("Content-Type must be application/json");
      }
    } else {
      throw new Error("Only POST requests are supported");
    }

    if (event !== "GET_USERINFO") {
      throw new Error("Invalid event type. Expected GET_USERINFO");
    }

    // Get user from JWT token in Authorization header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      throw new Error("Authorization header is required");
    }

    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    
    if (userError || !user) {
      throw new Error("Invalid or expired token");
    }



const { data, error } = await getEmployeeAndRelatedData(user, supabase);

    if (error) {
      // Check if it's our custom EMPLOYEE_EMPTY error
      if (error.code === "EMPLOYEE_EMPTY") {
        const headers = {
          "Content-Type": "application/json",
          ...(isLocal ? corsHeaders : {})
        };
        
        return new Response(JSON.stringify({ 
          message: error.message,
          code: error.code,
          success: false 
        }), { 
          status: 404, // Using 404 for "employee not found"
          headers
        });
      }
      
      // For other database errors
      throw new Error(`Employee database error: ${error.message || error}`);
    }

      

    // Create headers with conditional CORS support
    const headers = {
      "Content-Type": "application/json",
      ...(isLocal ? corsHeaders : {})
    };

    return new Response(JSON.stringify({ 
      data: {
        employee: data
      }, 
      success: true 
    }), { 
      status: 200,
      headers
    });

  } catch (error) {
    console.error("Error processing user info request:", error);
    const errorMessage = error instanceof Error ? error.message : "Failed to get user info";
    
    // Create headers with conditional CORS support
    const headers = {
      "Content-Type": "application/json",
      ...(isLocal ? corsHeaders : {})
    };
    
    return new Response(JSON.stringify({ 
      message: errorMessage, 
      success: false
    }), { 
      status: 400,
      headers
    });
  }
});
