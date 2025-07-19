-- Fix audit trigger function to properly extract record_id for each table

CREATE OR REPLACE FUNCTION "public"."audit_trigger_function"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    org_id uuid;
    old_jsonb jsonb;
    new_jsonb jsonb;
    record_id_value uuid;
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

    -- Extract the primary key (record_id) based on table name
    record_id_value := NULL;
    
    -- Handle different tables and their primary keys
    CASE TG_TABLE_NAME
        WHEN 'organizations' THEN
            record_id_value := CASE 
                WHEN TG_OP = 'DELETE' THEN (old_jsonb->>'organization_id')::uuid
                ELSE (new_jsonb->>'organization_id')::uuid 
            END;
        WHEN 'employees' THEN
            record_id_value := CASE 
                WHEN TG_OP = 'DELETE' THEN (old_jsonb->>'employee_id')::uuid
                ELSE (new_jsonb->>'employee_id')::uuid 
            END;
        WHEN 'roles' THEN
            record_id_value := CASE 
                WHEN TG_OP = 'DELETE' THEN (old_jsonb->>'role_id')::uuid
                ELSE (new_jsonb->>'role_id')::uuid 
            END;
        WHEN 'role_permissions' THEN
            record_id_value := CASE 
                WHEN TG_OP = 'DELETE' THEN (old_jsonb->>'role_permission_id')::uuid
                ELSE (new_jsonb->>'role_permission_id')::uuid 
            END;
        WHEN 'departments' THEN
            record_id_value := CASE 
                WHEN TG_OP = 'DELETE' THEN (old_jsonb->>'department_id')::uuid
                ELSE (new_jsonb->>'department_id')::uuid 
            END;
        WHEN 'sites' THEN
            record_id_value := CASE 
                WHEN TG_OP = 'DELETE' THEN (old_jsonb->>'site_id')::uuid
                ELSE (new_jsonb->>'site_id')::uuid 
            END;
        WHEN 'jobs' THEN
            record_id_value := CASE 
                WHEN TG_OP = 'DELETE' THEN (old_jsonb->>'job_id')::uuid
                ELSE (new_jsonb->>'job_id')::uuid 
            END;
        WHEN 'job_categories' THEN
            record_id_value := CASE 
                WHEN TG_OP = 'DELETE' THEN (old_jsonb->>'category_id')::uuid
                ELSE (new_jsonb->>'category_id')::uuid 
            END;
        WHEN 'users' THEN
            record_id_value := CASE 
                WHEN TG_OP = 'DELETE' THEN (old_jsonb->>'user_id')::uuid
                ELSE (new_jsonb->>'user_id')::uuid 
            END;
        ELSE
            -- For other tables, try to find a common pattern for primary keys
            -- First try with table_name + '_id'
            IF TG_OP = 'DELETE' THEN
                IF old_jsonb ? (TG_TABLE_NAME || '_id') THEN
                    record_id_value := (old_jsonb->>(TG_TABLE_NAME || '_id'))::uuid;
                ELSIF old_jsonb ? 'id' THEN
                    record_id_value := (old_jsonb->>'id')::uuid;
                END IF;
            ELSE
                IF new_jsonb ? (TG_TABLE_NAME || '_id') THEN
                    record_id_value := (new_jsonb->>(TG_TABLE_NAME || '_id'))::uuid;
                ELSIF new_jsonb ? 'id' THEN
                    record_id_value := (new_jsonb->>'id')::uuid;
                END IF;
            END IF;
    END CASE;

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
        record_id_value,
        TG_OP,
        old_jsonb,
        new_jsonb,
        auth.uid(),
        org_id
    );

    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$;