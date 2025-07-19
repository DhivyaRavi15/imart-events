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

// Types and constants
interface CustomError {
  code: string;
  message: string;
}

interface ServiceResult<T> {
  data: T | null;
  error: CustomError | null;
}

const EMPLOYEE_SELECT_QUERY = `
  *
`;

const EMPLOYEE_EMPTY_ERROR: CustomError = {
  code: "EMPLOYEE_EMPTY",
  message: "Employee is empty"
};

// Utility functions
function createErrorResult<T>(error: CustomError): ServiceResult<T> {
  return { data: null, error };
}

function createSuccessResult<T>(data: T): ServiceResult<T> {
  return { data, error: null };
}

function createResponseHeaders(): Record<string, string> {
  return {
    "Content-Type": "application/json",
    ...(isLocal ? corsHeaders : {})
  };
}

// Database service functions
async function fetchUserData(userId: string, supabase: SupabaseClient<Database>): Promise<ServiceResult<any>> {
  try {
    const { data: userData, error: userError } = await supabase
      .from("users")
      .select("user_id, first_name, last_name, email")
      .eq("user_id", userId)
      .single();

    if (userError || !userData) {
      console.error("Error fetching user data:", userError);
      return createErrorResult(EMPLOYEE_EMPTY_ERROR);
    }

    return createSuccessResult(userData);
  } catch (error) {
    console.error("Unexpected error fetching user data:", error);
    return createErrorResult(EMPLOYEE_EMPTY_ERROR);
  }
}

async function createEmployeeRecord(user: User, userData: any, supabase: SupabaseClient<Database>): Promise<ServiceResult<any>> {
  try {
    const { data: newEmployee, error: createError } = await supabase
      .from("employees")
      .insert({
        employee_id: user.id,
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
      return createErrorResult(EMPLOYEE_EMPTY_ERROR);
    }

    console.log("Successfully created employee record:", newEmployee);
    return createSuccessResult(newEmployee);
  } catch (error) {
    console.error("Unexpected error creating employee:", error);
    return createErrorResult(EMPLOYEE_EMPTY_ERROR);
  }
}

async function fetchEmployeeWithOrganization(userId: string, supabase: SupabaseClient<Database>): Promise<ServiceResult<any>> {
  try {
    const { data: employeeInfo, error: employeeError } = await supabase
      .from("employees")
      .select(EMPLOYEE_SELECT_QUERY)
      .eq("employee_id", userId)
      .single() as { data: any | null, error: any };

    if (employeeError) {
      return createErrorResult({ code: employeeError.code, message: employeeError.message });
    }

    if (!employeeInfo) {
      return createErrorResult(EMPLOYEE_EMPTY_ERROR);
    }

    console.log("Fetched employee data:", employeeInfo);

    // If employee has an organization_id, fetch organization data separately
    if (employeeInfo.organization_id) {
      try {
        const { data: organizationData, error: orgError } = await supabase
          .from("organizations")
          .select(`
            *,
            organization_apps (
              *,
              app:app_id (
                *
              )
            )
          `)
          .eq("organization_id", employeeInfo.organization_id)
          .single();

          console.log("Fetched organization data:", organizationData);
          console.log("Fetched orgError:", orgError);

        if (!orgError && organizationData) {
          employeeInfo.organization = organizationData;
          
          // Log organization and app details
          console.log("Employee Info:", employeeInfo);
          console.log("Organization Name:", organizationData.organization_name);
          organizationData.organization_apps?.forEach((orgApp: { app: { app_name: any; }; }) => {
            console.log("App Name:", orgApp.app?.app_name);
          });
        }
      } catch (orgFetchError) {
        console.warn("Could not fetch organization data:", orgFetchError);
        // Continue without organization data
      }
    }

    return createSuccessResult(employeeInfo);
  } catch (error) {
    console.error("Unexpected error fetching employee with organization:", error);
    return createErrorResult(EMPLOYEE_EMPTY_ERROR);
  }
}

async function handleEmployeeNotFound(user: User, supabase: SupabaseClient<Database>): Promise<ServiceResult<any>> {
  console.log("Employee not found, attempting to create employee record...");
  
  // Fetch user data
  const userResult = await fetchUserData(user.id, supabase);
  if (userResult.error) {
    return userResult;
  }

  // Create employee record
  const employeeResult = await createEmployeeRecord(user, userResult.data, supabase);
  if (employeeResult.error) {
    return employeeResult;
  }

  // Try to fetch complete employee data with organization info
  const completeResult = await fetchEmployeeWithOrganization(user.id, supabase);
  if (completeResult.error) {
    // If we can't fetch the complete info, return the basic employee data
    return createSuccessResult(employeeResult.data);
  }

  return completeResult;
}

export async function getEmployeeAndRelatedData(user: User, supabase: SupabaseClient<Database>): Promise<ServiceResult<any>> {
  try {
    console.log("Fetching employee data for user:", user.id);
    
    // Try to fetch existing employee
    const employeeResult = await fetchEmployeeWithOrganization(user.id, supabase);
    
    // If employee exists, return it
    if (employeeResult.data) {
      return employeeResult;
    }
    
    // If error is PGRST116 (employee not found), try to create one
    if (employeeResult.error?.code === "PGRST116") {
      return await handleEmployeeNotFound(user, supabase);
    }
    
    // For other errors, return the error
    return employeeResult;
    
  } catch (error) {
    console.error("Unexpected error in getEmployeeAndRelatedData:", error);
    return createErrorResult(EMPLOYEE_EMPTY_ERROR);
  }
}


// Request handling functions
async function validateRequest(req: Request): Promise<{ event: string; user: User }> {
  // Validate method and content type
  if (req.method !== "POST") {
    throw new Error("Only POST requests are supported");
  }

  const contentType = req.headers.get("content-type");
  if (!contentType || !contentType.includes("application/json")) {
    throw new Error("Content-Type must be application/json");
  }

  // Parse and validate event
  const body = await req.json();
  const event = body.event;
  
  if (event !== "GET_USERINFO") {
    throw new Error("Invalid event type. Expected GET_USERINFO");
  }

  // Validate and extract user from JWT
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    throw new Error("Authorization header is required");
  }

  const token = authHeader.replace("Bearer ", "");
  const { data: { user }, error: userError } = await supabase.auth.getUser(token);
  
  if (userError || !user) {
    throw new Error("Invalid or expired token");
  }

  return { event, user };
}

function createErrorResponse(message: string, status: number = 400): Response {
  return new Response(JSON.stringify({ 
    message, 
    success: false
  }), { 
    status,
    headers: createResponseHeaders()
  });
}

function createEmployeeEmptyResponse(error: CustomError): Response {
  return new Response(JSON.stringify({ 
    message: error.message,
    code: error.code,
    success: false 
  }), { 
    status: 404,
    headers: createResponseHeaders()
  });
}

function createSuccessResponse(data: any): Response {
  return new Response(JSON.stringify({ 
    data: { employee: data }, 
    success: true 
  }), { 
    status: 200,
    headers: createResponseHeaders()
  });
}

serve(async (req: Request) => {
  // Handle OPTIONS request for CORS preflight
  if (isLocal && req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: corsHeaders,
    });
  }
  
  try {
    // Validate request and extract user
    const { user } = await validateRequest(req);
    
    // Get employee data
    const { data, error } = await getEmployeeAndRelatedData(user, supabase);

    if (error) {
      // Handle custom EMPLOYEE_EMPTY error
      if (error.code === "EMPLOYEE_EMPTY") {
        return createEmployeeEmptyResponse(error);
      }
      
      // For other database errors
      throw new Error(`Employee database error: ${error.message || error}`);
    }

    return createSuccessResponse(data);

  } catch (error) {
    console.error("Error processing user info request:", error);
    const errorMessage = error instanceof Error ? error.message : "Failed to get user info";
    return createErrorResponse(errorMessage);
  }
});
