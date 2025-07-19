-- Fix the audit trigger function to properly extract record_id
-- This migration must run before any data seeding that triggers audit logs

CREATE OR REPLACE FUNCTION "public"."audit_trigger_function"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    org_id uuid;
    old_jsonb jsonb;
    new_jsonb jsonb;
    record_primary_key uuid;
BEGIN
    -- Convert records to jsonb for easier handling
    old_jsonb := CASE WHEN TG_OP = 'DELETE' OR TG_OP = 'UPDATE' THEN to_jsonb(OLD) ELSE NULL END;
    new_jsonb := CASE WHEN TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN to_jsonb(NEW) ELSE NULL END;
    
    -- Try to extract organization_id from the record
    org_id := NULL;
    IF TG_OP = 'DELETE' THEN
        IF old_jsonb ? 'organization_id' THEN
            org_id := (old_jsonb->>'organization_id')::uuid;
        END IF;
    ELSE
        IF new_jsonb ? 'organization_id' THEN
            org_id := (new_jsonb->>'organization_id')::uuid;
        END IF;
    END IF;

    -- Extract the primary key based on table name
    record_primary_key := NULL;
    IF TG_OP = 'DELETE' THEN
        record_primary_key := CASE TG_TABLE_NAME
            WHEN 'organizations' THEN (old_jsonb->>'organization_id')::uuid
            WHEN 'departments' THEN (old_jsonb->>'department_id')::uuid
            WHEN 'employees' THEN (old_jsonb->>'employee_id')::uuid
            WHEN 'roles' THEN (old_jsonb->>'role_id')::uuid
            WHEN 'jobs' THEN (old_jsonb->>'job_id')::uuid
            WHEN 'sites' THEN (old_jsonb->>'site_id')::uuid
            WHEN 'users' THEN (old_jsonb->>'user_id')::uuid
            WHEN 'apps' THEN (old_jsonb->>'app_id')::uuid
            WHEN 'plans' THEN (old_jsonb->>'plan_id')::uuid
            WHEN 'skills' THEN (old_jsonb->>'skill_id')::uuid
            WHEN 'organization_types' THEN (old_jsonb->>'type_id')::uuid
            WHEN 'ethnicities' THEN (old_jsonb->>'ethnicity_id')::uuid
            WHEN 'job_categories' THEN (old_jsonb->>'category_id')::uuid
            ELSE NULL
        END;
    ELSE
        record_primary_key := CASE TG_TABLE_NAME
            WHEN 'organizations' THEN (new_jsonb->>'organization_id')::uuid
            WHEN 'departments' THEN (new_jsonb->>'department_id')::uuid
            WHEN 'employees' THEN (new_jsonb->>'employee_id')::uuid
            WHEN 'roles' THEN (new_jsonb->>'role_id')::uuid
            WHEN 'jobs' THEN (new_jsonb->>'job_id')::uuid
            WHEN 'sites' THEN (new_jsonb->>'site_id')::uuid
            WHEN 'users' THEN (new_jsonb->>'user_id')::uuid
            WHEN 'apps' THEN (new_jsonb->>'app_id')::uuid
            WHEN 'plans' THEN (new_jsonb->>'plan_id')::uuid
            WHEN 'skills' THEN (new_jsonb->>'skill_id')::uuid
            WHEN 'organization_types' THEN (new_jsonb->>'type_id')::uuid
            WHEN 'ethnicities' THEN (new_jsonb->>'ethnicity_id')::uuid
            WHEN 'job_categories' THEN (new_jsonb->>'category_id')::uuid
            ELSE NULL
        END;
    END IF;

    -- Insert audit record
    INSERT INTO public.audit_logs (
        table_name,
        record_id,
        operation,
        old_values,
        new_values,
        changed_by,
        organization_id
    ) VALUES (
        TG_TABLE_NAME,
        record_primary_key,
        TG_OP,
        old_jsonb,
        new_jsonb,
        auth.uid(),
        org_id
    );

    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$;