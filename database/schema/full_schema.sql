

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."add_super_admin"("p_email" "text", "p_admin_user_id" "uuid" DEFAULT NULL::"uuid") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Find the user by email
    SELECT id INTO v_user_id
    FROM auth.users
    WHERE email = p_email;
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'User with email % not found', p_email;
    END IF;
    
    -- Add user to super_admins table if not already there
    INSERT INTO public.super_admins (user_id, created_by)
    VALUES (v_user_id, COALESCE(p_admin_user_id, auth.uid()))
    ON CONFLICT (user_id) DO NOTHING;
    
    RETURN v_user_id;
END;
$$;


ALTER FUNCTION "public"."add_super_admin"("p_email" "text", "p_admin_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."audit_trigger_function"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    org_id uuid;
    old_jsonb jsonb;
    new_jsonb jsonb;
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
        CASE 
            WHEN TG_OP = 'DELETE' THEN (old_jsonb->>'organization_id')::uuid
            ELSE (new_jsonb->>'organization_id')::uuid 
        END,
        TG_OP,
        old_jsonb,
        new_jsonb,
        auth.uid(),
        org_id
    );

    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$;


ALTER FUNCTION "public"."audit_trigger_function"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_max_organizations_per_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Count active organizations for the primary owner
  IF (
    SELECT COUNT(*) 
    FROM organizations 
    WHERE primary_owner = NEW.primary_owner 
      AND deleted_at IS NULL
  ) > 3 THEN
    RAISE EXCEPTION 'Maximum of 3 active organizations per user exceeded';
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."check_max_organizations_per_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_organization_ids"("p_user_id" "uuid" DEFAULT "auth"."uid"()) RETURNS "uuid"[]
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT ARRAY_AGG(DISTINCT organization_id)
  FROM public.employees 
  WHERE employee_id = p_user_id 
    AND deleted_at IS NULL;
$$;


ALTER FUNCTION "public"."get_user_organization_ids"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_role_in_org"("p_user_id" "uuid", "p_organization_id" "uuid") RETURNS "text"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT r.role_name
  FROM public.employees e
  JOIN public.roles r ON e.role_id = r.role_id
  WHERE e.employee_id = p_user_id 
    AND e.organization_id = p_organization_id 
    AND e.deleted_at IS NULL
    AND r.deleted_at IS NULL
  LIMIT 1;
$$;


ALTER FUNCTION "public"."get_user_role_in_org"("p_user_id" "uuid", "p_organization_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_job_translation_permission"("p_user_id" "uuid", "p_job_id" "uuid", "p_permission_name" character varying) RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    v_organization_id UUID;
BEGIN
    -- Check if user is a super admin (they bypass all permission checks)
    IF is_super_admin(p_user_id) THEN
        RETURN TRUE;
    END IF;
    
    -- Get the organization_id from the parent job
    SELECT organization_id INTO v_organization_id
    FROM jobs
    WHERE job_id = p_job_id;
    
    -- If job doesn't exist, return false
    IF v_organization_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Use the updated has_permission_in_org function that checks for active status
    RETURN has_permission_in_org(p_user_id, v_organization_id, p_permission_name);
END;
$$;


ALTER FUNCTION "public"."has_job_translation_permission"("p_user_id" "uuid", "p_job_id" "uuid", "p_permission_name" character varying) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_jobs_app_permission"("org_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
DECLARE
  has_permission boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM public.organization_apps oa
    JOIN public.apps a ON oa.app_id = a.app_id
    WHERE oa.organization_id = org_id
      AND oa.is_active = true
      AND a.is_active = true
      AND a.app_name ILIKE '%jobs%'
  ) INTO has_permission;
  
  RETURN has_permission;
END;
$$;


ALTER FUNCTION "public"."has_jobs_app_permission"("org_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_permission_in_org"("p_user_id" "uuid", "p_organization_id" "uuid", "p_permission_name" character varying) RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    AS $$
DECLARE
    is_authorized BOOLEAN;
    is_org_active BOOLEAN;
BEGIN
    -- Check if user is a super admin (they bypass all permission checks)
    IF is_super_admin(p_user_id) THEN
        RETURN TRUE;
    END IF;
    
    -- Check if the organization is active
    SELECT active INTO is_org_active
    FROM organizations
    WHERE organization_id = p_organization_id
      AND deleted_at IS NULL;
    
    -- If organization is inactive, only allow view permissions
    IF is_org_active = FALSE AND p_permission_name NOT LIKE 'view_%' THEN
        RETURN FALSE;
    END IF;
    
    -- Check if organization has jobs app permission for job-related operations
    IF p_permission_name LIKE 'jobs_%' THEN 
        IF NOT has_jobs_app_permission(p_organization_id) THEN 
            RETURN FALSE; 
        END IF; 
    END IF; 

    -- Check regular permissions
    SELECT EXISTS (
        SELECT 1
        FROM employees e
        JOIN roles r ON e.role_id = r.role_id
        JOIN role_permissions rp ON r.role_id = rp.role_id
        WHERE e.user_id = p_user_id
          AND e.organization_id = p_organization_id
          AND r.organization_id = p_organization_id
          AND rp.organization_id = p_organization_id
          AND rp.permission_name = p_permission_name
          AND e.deleted_at IS NULL
          AND r.deleted_at IS NULL
    ) INTO is_authorized;

    RETURN is_authorized;
END;
$$;


ALTER FUNCTION "public"."has_permission_in_org"("p_user_id" "uuid", "p_organization_id" "uuid", "p_permission_name" character varying) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_org_owner"("p_user_id" "uuid", "p_organization_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 
    FROM public.organizations 
    WHERE organization_id = p_organization_id
      AND (primary_owner = p_user_id OR secondary_owner = p_user_id)
      AND deleted_at IS NULL
  );
$$;


ALTER FUNCTION "public"."is_org_owner"("p_user_id" "uuid", "p_organization_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_super_admin"("p_user_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM super_admins
        WHERE user_id = p_user_id
    );
END;
$$;


ALTER FUNCTION "public"."is_super_admin"("p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."remove_super_admin"("p_email" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    v_user_id UUID;
    v_rows_deleted INTEGER;
BEGIN
    -- Find the user by email
    SELECT id INTO v_user_id
    FROM auth.users
    WHERE email = p_email;
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'User with email % not found', p_email;
    END IF;
    
    -- Remove user from super_admins table
    DELETE FROM public.super_admins
    WHERE user_id = v_user_id;
    
    GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
    
    RETURN v_rows_deleted > 0;
END;
$$;


ALTER FUNCTION "public"."remove_super_admin"("p_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_organization_status"("p_organization_id" "uuid", "p_active" boolean) RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    v_user_id UUID;
    v_rows_updated INTEGER;
BEGIN
    v_user_id := auth.uid();
    
    -- Check if user is a super admin
    IF NOT is_super_admin(v_user_id) THEN
        RAISE EXCEPTION 'Only super admins can change organization status';
    END IF;
    
    -- Update organization status
    UPDATE public.organizations
    SET active = p_active
    WHERE organization_id = p_organization_id;
    
    GET DIAGNOSTICS v_rows_updated = ROW_COUNT;
    
    RETURN v_rows_updated > 0;
END;
$$;


ALTER FUNCTION "public"."set_organization_status"("p_organization_id" "uuid", "p_active" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."setup_org_admin_permissions"("p_organization_id" "uuid", "p_role_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    permission_names TEXT[] := ARRAY[
        'create_job',
        'read_job', 
        'update_job',
        'delete_job',
        'approve_job',
        'manage_employees',
        'view_employees',
        'manage_departments',
        'manage_roles',
        'view_analytics',
        'manage_organization',
        'manage_permissions'
    ];
    perm_name TEXT;  -- Changed variable name to avoid conflict
BEGIN
    -- Insert all default permissions for the org_super_admin role
    FOREACH perm_name IN ARRAY permission_names
    LOOP
        INSERT INTO public.role_permissions (role_id, organization_id, permission_name)
        VALUES (p_role_id, p_organization_id, perm_name)
        ON CONFLICT (role_id, organization_id, permission_name) DO NOTHING;
    END LOOP;
    
    RETURN TRUE;
END;
$$;


ALTER FUNCTION "public"."setup_org_admin_permissions"("p_organization_id" "uuid", "p_role_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."setup_org_admin_permissions"("p_organization_id" "uuid", "p_role_id" "uuid") IS 'Sets up default permissions for org_super_admin role in an organization';



CREATE OR REPLACE FUNCTION "public"."setup_org_admin_role"("p_organization_id" "uuid", "p_user_id" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    v_role_id uuid;
    v_employee_id uuid;
    v_role_name text;
BEGIN
    -- Create a unique role name for this organization
    v_role_name := 'org_super_admin_' || p_organization_id::text;
    
    -- Create org_super_admin role if not exists
    INSERT INTO public.roles (organization_id, role_name, role_description)
    VALUES (p_organization_id, v_role_name, 'Organization Super Administrator')
    ON CONFLICT (role_name) DO NOTHING
    RETURNING role_id INTO v_role_id;
    
    -- If role already exists, get its ID
    IF v_role_id IS NULL THEN
        SELECT role_id INTO v_role_id 
        FROM public.roles 
        WHERE organization_id = p_organization_id 
        AND role_name = v_role_name
        AND deleted_at IS NULL;
    END IF;
    
    -- Setup default permissions for the org_super_admin role
    PERFORM public.setup_org_admin_permissions(p_organization_id, v_role_id);
    
    -- Add user as employee with this role
    -- Note: employee_id should be the same as user_id based on the FK constraint
    INSERT INTO public.employees (
        employee_id,
        organization_id, 
        role_id, 
        first_name, 
        last_name, 
        email,
        hire_date,
        status,
        job_title
    )
    SELECT 
        p_user_id,  -- employee_id = user_id
        p_organization_id,
        v_role_id,
        COALESCE(u.first_name, au.raw_user_meta_data->>'first_name', 'Admin'),
        COALESCE(u.last_name, au.raw_user_meta_data->>'last_name', 'User'),
        COALESCE(u.email, au.email),
        CURRENT_DATE,
        'active',
        'Organization Administrator'
    FROM auth.users au
    LEFT JOIN public.users u ON u.user_id = au.id
    WHERE au.id = p_user_id
    ON CONFLICT (employee_id) DO UPDATE SET
        organization_id = p_organization_id,
        role_id = v_role_id,
        status = 'active',
        job_title = 'Organization Administrator'
    RETURNING employee_id INTO v_employee_id;
    
    RETURN v_role_id;
END;
$$;


ALTER FUNCTION "public"."setup_org_admin_role"("p_organization_id" "uuid", "p_user_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."setup_org_admin_role"("p_organization_id" "uuid", "p_user_id" "uuid") IS 'Creates org_super_admin role, assigns permissions, and adds user as employee with admin role';



CREATE OR REPLACE FUNCTION "public"."trigger_setup_org_admin"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
BEGIN
    -- Only setup admin role for INSERT operations and when primary_owner is set
    IF TG_OP = 'INSERT' AND NEW.primary_owner IS NOT NULL THEN
        -- Call setup_org_admin_role function with explicit schema
        PERFORM public.setup_org_admin_role(NEW.organization_id, NEW.primary_owner);
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."trigger_setup_org_admin"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."trigger_setup_org_admin"() IS 'Trigger function that automatically sets up admin role when organization is created';



CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."user_belongs_to_org"("p_user_id" "uuid", "p_organization_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 
    FROM public.employees 
    WHERE employee_id = p_user_id 
      AND organization_id = p_organization_id 
      AND deleted_at IS NULL
  );
$$;


ALTER FUNCTION "public"."user_belongs_to_org"("p_user_id" "uuid", "p_organization_id" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."apps" (
    "app_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "app_name" character varying(255) NOT NULL,
    "app_description" "text",
    "app_version" character varying(255),
    "app_icon_url" character varying(255),
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "app_category" character varying(255),
    "developer" character varying(255),
    "release_date" "date",
    "required_permissions" "jsonb",
    "external_url" character varying(255),
    "app_settings_schema" "jsonb",
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."apps" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."audit_logs" (
    "audit_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "table_name" "text" NOT NULL,
    "record_id" "uuid" NOT NULL,
    "operation" "text" NOT NULL,
    "old_values" "jsonb",
    "new_values" "jsonb",
    "changed_by" "uuid",
    "organization_id" "uuid",
    "changed_at" timestamp with time zone DEFAULT "now"(),
    "ip_address" "inet",
    "user_agent" "text",
    CONSTRAINT "audit_logs_operation_check" CHECK (("operation" = ANY (ARRAY['INSERT'::"text", 'UPDATE'::"text", 'DELETE'::"text"])))
);


ALTER TABLE "public"."audit_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."custom_users" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "email" "text",
    "full_name" "text",
    "last_name" "text"
);


ALTER TABLE "public"."custom_users" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."departments" (
    "department_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "organization_id" "uuid",
    "department_name" "text" NOT NULL,
    "department_description" "text",
    "status" character varying(255),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "deleted_at" timestamp with time zone,
    CONSTRAINT "departments_status_check" CHECK ((("status")::"text" = ANY (ARRAY[('active'::character varying)::"text", ('inactive'::character varying)::"text", ('suspended'::character varying)::"text"])))
);


ALTER TABLE "public"."departments" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."employee_hierarchy" (
    "hierarchy_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "employee_id" "uuid",
    "manager_employee_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."employee_hierarchy" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."employees" (
    "employee_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "site_id" "uuid",
    "department_id" "uuid",
    "organization_id" "uuid",
    "role_id" "uuid",
    "first_name" "text" NOT NULL,
    "last_name" "text",
    "email" "text",
    "phone" "text",
    "address" "text",
    "image_url" character varying(255),
    "linkedin_url" character varying(255),
    "job_title" "text",
    "hire_date" "date",
    "status" character varying(255),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "gender" character varying(255),
    "date_of_birth" "date",
    "deleted_at" timestamp with time zone,
    CONSTRAINT "employees_gender_check" CHECK ((("gender")::"text" = ANY (ARRAY[('male'::character varying)::"text", ('female'::character varying)::"text", ('other'::character varying)::"text", ('prefer not to say'::character varying)::"text"]))),
    CONSTRAINT "employees_status_check" CHECK ((("status")::"text" = ANY (ARRAY[('active'::character varying)::"text", ('pendingStart'::character varying)::"text", ('suspended'::character varying)::"text", ('onNotice'::character varying)::"text", ('resigned'::character varying)::"text", ('terminated'::character varying)::"text", ('dismissed'::character varying)::"text", ('noShow'::character varying)::"text", ('onLeave'::character varying)::"text", ('retired'::character varying)::"text"])))
);


ALTER TABLE "public"."employees" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ethnicities" (
    "ethnicity_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "ethnicity_name" character varying(255) NOT NULL,
    "country_code" character varying(3)
);


ALTER TABLE "public"."ethnicities" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."job_categories" (
    "category_id" "uuid" NOT NULL,
    "category_name" character varying(255),
    "organization_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."job_categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."job_skills" (
    "job_skill_id" "uuid" NOT NULL,
    "job_id" "uuid",
    "skill_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."job_skills" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."job_translations" (
    "job_id" "uuid" NOT NULL,
    "language_code" character varying(10) NOT NULL,
    "job_title" "text" NOT NULL,
    "job_description" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."job_translations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."jobs" (
    "job_id" "uuid" NOT NULL,
    "site_id" "uuid",
    "department_id" "uuid",
    "organization_id" "uuid",
    "organization_type_id" "uuid",
    "job_type" character varying(255),
    "salary_range_min" numeric,
    "salary_range_max" numeric,
    "currency" character varying(3) DEFAULT 'INR'::character varying,
    "location" character varying(255),
    "city" character varying(255),
    "state" character varying(255),
    "country" character varying(255),
    "postal_code" character varying(255),
    "experience_required" character varying(255),
    "education_required" character varying(255),
    "skills_required" "text",
    "posting_date" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "application_deadline" "date",
    "status" character varying(255),
    "job_category" "uuid",
    "is_internal" boolean DEFAULT false,
    "created_by" "uuid",
    "approved_by" "uuid",
    "approval_date" timestamp without time zone,
    "deleted_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "check_application_deadline" CHECK ((("application_deadline" IS NULL) OR ("application_deadline" >= ("posting_date")::"date"))),
    CONSTRAINT "check_salary_range" CHECK ((("salary_range_min" IS NULL) OR ("salary_range_max" IS NULL) OR ("salary_range_min" <= "salary_range_max"))),
    CONSTRAINT "jobs_job_type_check" CHECK ((("job_type")::"text" = ANY (ARRAY[('full-time'::character varying)::"text", ('part-time'::character varying)::"text", ('contract'::character varying)::"text", ('internship'::character varying)::"text", ('temporary'::character varying)::"text"]))),
    CONSTRAINT "jobs_status_check" CHECK ((("status")::"text" = ANY (ARRAY[('open'::character varying)::"text", ('closed'::character varying)::"text", ('filled'::character varying)::"text", ('draft'::character varying)::"text"])))
);


ALTER TABLE "public"."jobs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "notification_id" "uuid" NOT NULL,
    "user_id" "uuid",
    "message" "text",
    "notification_type" character varying(255),
    "related_id" "uuid",
    "is_read" boolean DEFAULT false,
    "created_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."organization_apps" (
    "organization_app_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "organization_id" "uuid",
    "app_id" "uuid",
    "organization_plan_id" "uuid",
    "installation_date" timestamp with time zone DEFAULT "now"(),
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."organization_apps" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."organization_organization_types" (
    "organization_organization_type_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "organization_id" "uuid",
    "organization_type_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."organization_organization_types" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."organization_plans" (
    "organization_plan_id" "uuid" NOT NULL,
    "organization_id" "uuid",
    "plan_id" "uuid",
    "start_date" timestamp without time zone NOT NULL,
    "end_date" timestamp without time zone NOT NULL,
    "payment_status" character varying(255),
    "payment_id" character varying(255),
    "ends_at" timestamp without time zone,
    "free_trail_ends_at" timestamp without time zone,
    "created_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "is_active" boolean DEFAULT true,
    "cancelled_at" timestamp without time zone,
    "renewal_date" timestamp without time zone,
    "payment_method" character varying(255),
    "billing_cycle" character varying(255),
    "quantity" integer,
    "discount_applied" boolean,
    "notes" "text",
    "trial_end_notification_sent" boolean DEFAULT false,
    CONSTRAINT "check_organization_plan_dates" CHECK (("start_date" <= "end_date")),
    CONSTRAINT "organization_plans_payment_status_check" CHECK ((("payment_status")::"text" = ANY (ARRAY[('pending'::character varying)::"text", ('paid'::character varying)::"text", ('failed'::character varying)::"text", ('refunded'::character varying)::"text", ('freetrail'::character varying)::"text"])))
);


ALTER TABLE "public"."organization_plans" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."organization_types" (
    "organization_type_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "type_name" character varying(255) NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."organization_types" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."organizations" (
    "organization_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "organization_name" "text" NOT NULL,
    "organization_description" "text",
    "contact_person" character varying(255),
    "contact_email" character varying(255),
    "contact_phone" character varying(255),
    "secondary_contact_person" character varying(255),
    "secondary_contact_phone" character varying(255),
    "secondary_phone" character varying(255),
    "address" character varying(255),
    "city" character varying(255),
    "state" character varying(255),
    "country" character varying(255),
    "postal_code" character varying(255),
    "logo_url" character varying(255),
    "registration_date" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "account_status" character varying(255),
    "description" "text",
    "website_url" character varying(255),
    "google_place_id" character varying(255),
    "google_maps_url" character varying(255),
    "google_business_category" character varying(255),
    "created_by" "uuid",
    "secondary_owner" "uuid",
    "primary_owner" "uuid",
    "active" boolean DEFAULT true NOT NULL,
    "deleted_at" timestamp with time zone,
    CONSTRAINT "organizations_account_status_check" CHECK ((("account_status")::"text" = ANY (ARRAY[('active'::character varying)::"text", ('inactive'::character varying)::"text", ('suspended'::character varying)::"text"])))
);


ALTER TABLE "public"."organizations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."plan_apps" (
    "plan_app_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "plan_id" "uuid",
    "app_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."plan_apps" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."plans" (
    "plan_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "plan_name" character varying(255) NOT NULL,
    "description" "text",
    "price" numeric(10,2) NOT NULL,
    "currency" character varying(3) DEFAULT 'USD'::character varying,
    "is_free_trial_avail" boolean DEFAULT false,
    "free_trail_period" interval,
    "duration_days" integer,
    "features" "jsonb",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."plans" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."role_permissions" (
    "role_permission_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "role_id" "uuid" NOT NULL,
    "organization_id" "uuid" NOT NULL,
    "permission_name" character varying NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."role_permissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."roles" (
    "role_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "organization_id" "uuid",
    "role_name" "text" NOT NULL,
    "role_description" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "deleted_at" timestamp with time zone
);


ALTER TABLE "public"."roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."saved_jobs" (
    "saved_job_id" "uuid" NOT NULL,
    "user_id" "uuid",
    "job_id" "uuid",
    "saved_date" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."saved_jobs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sites" (
    "site_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "organization_id" "uuid",
    "site_name" "text" NOT NULL,
    "site_description" "text",
    "address" "text",
    "contact_person" "text",
    "contact_email" "text",
    "contact_phone" "text",
    "google_location" "text",
    "google_business_information" "text",
    "status" character varying(255),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "deleted_at" timestamp with time zone,
    CONSTRAINT "sites_status_check" CHECK ((("status")::"text" = ANY (ARRAY[('active'::character varying)::"text", ('inactive'::character varying)::"text", ('suspended'::character varying)::"text"])))
);


ALTER TABLE "public"."sites" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."skills" (
    "skill_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "skill_name" character varying(255)
);


ALTER TABLE "public"."skills" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."super_admins" (
    "super_admin_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "first_name" character varying(255) NOT NULL,
    "last_name" character varying(255),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid"
);


ALTER TABLE "public"."super_admins" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_education" (
    "education_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "institution_name" character varying(255),
    "degree" character varying(255),
    "field_of_study" character varying(255),
    "start_date" "date",
    "end_date" "date",
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "check_education_dates" CHECK ((("start_date" IS NULL) OR ("end_date" IS NULL) OR ("start_date" <= "end_date")))
);


ALTER TABLE "public"."user_education" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_ethnicities" (
    "user_ethnicity_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "ethnicity_id" "uuid"
);


ALTER TABLE "public"."user_ethnicities" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_job_history" (
    "job_history_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "company_name" character varying(255),
    "job_title" character varying(255),
    "start_date" "date",
    "end_date" "date",
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "check_job_history_dates" CHECK ((("start_date" IS NULL) OR ("end_date" IS NULL) OR ("start_date" <= "end_date")))
);


ALTER TABLE "public"."user_job_history" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_languages" (
    "language_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "language_name" character varying(255),
    "proficiency" character varying(255),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "user_languages_proficiency_check" CHECK ((("proficiency")::"text" = ANY (ARRAY[('basic'::character varying)::"text", ('conversational'::character varying)::"text", ('fluent'::character varying)::"text", ('native'::character varying)::"text"])))
);


ALTER TABLE "public"."user_languages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_skills" (
    "user_skill_id" "uuid" NOT NULL,
    "user_id" "uuid",
    "skill_id" "uuid"
);


ALTER TABLE "public"."user_skills" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "user_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "first_name" character varying(255) NOT NULL,
    "last_name" character varying(255),
    "gender" character varying(255),
    "email" character varying(255),
    "date_of_birth" "date",
    "phone" character varying(255),
    "address" character varying(255),
    "city" character varying(255),
    "state" character varying(255),
    "country" character varying(255),
    "postal_code" character varying(255),
    "resume_url" character varying(255),
    "image_url" character varying(255),
    "linkedin_url" character varying(255),
    "current_job_title" character varying(255),
    "last_sign_in_at" "date",
    "current_job_org" character varying(255),
    "active_status" boolean DEFAULT true,
    "registration_date" timestamp with time zone DEFAULT ("now"() AT TIME ZONE 'utc'::"text"),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "deleted_at" timestamp with time zone,
    CONSTRAINT "users_gender_check" CHECK ((("gender")::"text" = ANY (ARRAY[('male'::character varying)::"text", ('female'::character varying)::"text", ('other'::character varying)::"text", ('prefer not to say'::character varying)::"text"])))
);


ALTER TABLE "public"."users" OWNER TO "postgres";


ALTER TABLE ONLY "public"."apps"
    ADD CONSTRAINT "apps_pkey" PRIMARY KEY ("app_id");



ALTER TABLE ONLY "public"."audit_logs"
    ADD CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("audit_id");



ALTER TABLE ONLY "public"."custom_users"
    ADD CONSTRAINT "custom_users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."departments"
    ADD CONSTRAINT "departments_pkey" PRIMARY KEY ("department_id");



ALTER TABLE ONLY "public"."employee_hierarchy"
    ADD CONSTRAINT "employee_hierarchy_pkey" PRIMARY KEY ("hierarchy_id");



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_pkey" PRIMARY KEY ("employee_id");



ALTER TABLE ONLY "public"."ethnicities"
    ADD CONSTRAINT "ethnicities_pkey" PRIMARY KEY ("ethnicity_id");



ALTER TABLE ONLY "public"."job_categories"
    ADD CONSTRAINT "job_categories_pkey" PRIMARY KEY ("category_id");



ALTER TABLE ONLY "public"."job_skills"
    ADD CONSTRAINT "job_skills_pkey" PRIMARY KEY ("job_skill_id");



ALTER TABLE ONLY "public"."job_translations"
    ADD CONSTRAINT "job_translations_pkey" PRIMARY KEY ("job_id", "language_code");



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_pkey" PRIMARY KEY ("job_id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("notification_id");



ALTER TABLE ONLY "public"."organization_apps"
    ADD CONSTRAINT "organization_apps_organization_id_app_id_key" UNIQUE ("organization_id", "app_id");



ALTER TABLE ONLY "public"."organization_apps"
    ADD CONSTRAINT "organization_apps_pkey" PRIMARY KEY ("organization_app_id");



ALTER TABLE ONLY "public"."organization_organization_types"
    ADD CONSTRAINT "organization_organization_typ_organization_id_organization__key" UNIQUE ("organization_id", "organization_type_id");



ALTER TABLE ONLY "public"."organization_organization_types"
    ADD CONSTRAINT "organization_organization_types_pkey" PRIMARY KEY ("organization_organization_type_id");



ALTER TABLE ONLY "public"."organization_plans"
    ADD CONSTRAINT "organization_plans_organization_id_plan_id_key" UNIQUE ("organization_id", "plan_id");



ALTER TABLE ONLY "public"."organization_plans"
    ADD CONSTRAINT "organization_plans_pkey" PRIMARY KEY ("organization_plan_id");



ALTER TABLE ONLY "public"."organization_types"
    ADD CONSTRAINT "organization_types_pkey" PRIMARY KEY ("organization_type_id");



ALTER TABLE ONLY "public"."organization_types"
    ADD CONSTRAINT "organization_types_type_name_key" UNIQUE ("type_name");



ALTER TABLE ONLY "public"."organizations"
    ADD CONSTRAINT "organizations_pkey" PRIMARY KEY ("organization_id");



ALTER TABLE ONLY "public"."plan_apps"
    ADD CONSTRAINT "plan_apps_pkey" PRIMARY KEY ("plan_app_id");



ALTER TABLE ONLY "public"."plan_apps"
    ADD CONSTRAINT "plan_apps_plan_id_app_id_key" UNIQUE ("plan_id", "app_id");



ALTER TABLE ONLY "public"."plans"
    ADD CONSTRAINT "plans_pkey" PRIMARY KEY ("plan_id");



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("role_permission_id");



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_role_id_organization_id_permission_name_key" UNIQUE ("role_id", "organization_id", "permission_name");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("role_id");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_role_name_key" UNIQUE ("role_name");



ALTER TABLE ONLY "public"."saved_jobs"
    ADD CONSTRAINT "saved_jobs_pkey" PRIMARY KEY ("saved_job_id");



ALTER TABLE ONLY "public"."sites"
    ADD CONSTRAINT "sites_pkey" PRIMARY KEY ("site_id");



ALTER TABLE ONLY "public"."skills"
    ADD CONSTRAINT "skills_pkey" PRIMARY KEY ("skill_id");



ALTER TABLE ONLY "public"."skills"
    ADD CONSTRAINT "skills_skill_name_key" UNIQUE ("skill_name");



ALTER TABLE ONLY "public"."super_admins"
    ADD CONSTRAINT "super_admins_pkey" PRIMARY KEY ("super_admin_id");



ALTER TABLE ONLY "public"."job_skills"
    ADD CONSTRAINT "unique_job_skill" UNIQUE ("job_id", "skill_id");



ALTER TABLE ONLY "public"."organization_apps"
    ADD CONSTRAINT "unique_organization_app" UNIQUE ("organization_id", "app_id");



ALTER TABLE ONLY "public"."plan_apps"
    ADD CONSTRAINT "unique_plan_app" UNIQUE ("plan_id", "app_id");



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "unique_role_permission" UNIQUE ("role_id", "organization_id", "permission_name");



ALTER TABLE ONLY "public"."saved_jobs"
    ADD CONSTRAINT "unique_saved_job" UNIQUE ("user_id", "job_id");



ALTER TABLE ONLY "public"."user_skills"
    ADD CONSTRAINT "unique_user_skill" UNIQUE ("user_id", "skill_id");



ALTER TABLE ONLY "public"."user_education"
    ADD CONSTRAINT "user_education_pkey" PRIMARY KEY ("education_id");



ALTER TABLE ONLY "public"."user_ethnicities"
    ADD CONSTRAINT "user_ethnicities_pkey" PRIMARY KEY ("user_ethnicity_id");



ALTER TABLE ONLY "public"."user_ethnicities"
    ADD CONSTRAINT "user_ethnicities_user_id_ethnicity_id_key" UNIQUE ("user_id", "ethnicity_id");



ALTER TABLE ONLY "public"."user_job_history"
    ADD CONSTRAINT "user_job_history_pkey" PRIMARY KEY ("job_history_id");



ALTER TABLE ONLY "public"."user_languages"
    ADD CONSTRAINT "user_languages_pkey" PRIMARY KEY ("language_id");



ALTER TABLE ONLY "public"."user_skills"
    ADD CONSTRAINT "user_skills_pkey" PRIMARY KEY ("user_skill_id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("user_id");



CREATE INDEX "idx_audit_logs_changed_at" ON "public"."audit_logs" USING "btree" ("changed_at");



CREATE INDEX "idx_audit_logs_changed_by" ON "public"."audit_logs" USING "btree" ("changed_by");



CREATE INDEX "idx_audit_logs_organization" ON "public"."audit_logs" USING "btree" ("organization_id");



CREATE INDEX "idx_audit_logs_table_record" ON "public"."audit_logs" USING "btree" ("table_name", "record_id");



CREATE INDEX "idx_departments_organization" ON "public"."departments" USING "btree" ("organization_id") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_employees_organization" ON "public"."employees" USING "btree" ("organization_id") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_employees_role" ON "public"."employees" USING "btree" ("role_id") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_employees_status" ON "public"."employees" USING "btree" ("status") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_employees_user_id" ON "public"."employees" USING "btree" ("employee_id");



CREATE INDEX "idx_jobs_created_by" ON "public"."jobs" USING "btree" ("created_by") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_jobs_location" ON "public"."jobs" USING "btree" ("city", "state", "country") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_jobs_organization" ON "public"."jobs" USING "btree" ("organization_id") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_jobs_posting_date" ON "public"."jobs" USING "btree" ("posting_date") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_jobs_status" ON "public"."jobs" USING "btree" ("status") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_organization_apps_org_active" ON "public"."organization_apps" USING "btree" ("organization_id", "is_active");



CREATE INDEX "idx_organizations_active" ON "public"."organizations" USING "btree" ("active") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_organizations_created_by" ON "public"."organizations" USING "btree" ("created_by") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_organizations_primary_owner" ON "public"."organizations" USING "btree" ("primary_owner") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_role_permissions_permission" ON "public"."role_permissions" USING "btree" ("permission_name", "organization_id");



CREATE INDEX "idx_role_permissions_role_org" ON "public"."role_permissions" USING "btree" ("role_id", "organization_id");



CREATE INDEX "idx_roles_organization" ON "public"."roles" USING "btree" ("organization_id") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_saved_jobs_job" ON "public"."saved_jobs" USING "btree" ("job_id");



CREATE INDEX "idx_saved_jobs_user" ON "public"."saved_jobs" USING "btree" ("user_id");



CREATE INDEX "idx_sites_organization" ON "public"."sites" USING "btree" ("organization_id") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_users_active" ON "public"."users" USING "btree" ("active_status") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_users_email" ON "public"."users" USING "btree" ("email") WHERE ("deleted_at" IS NULL);



CREATE INDEX "idx_users_user_id" ON "public"."users" USING "btree" ("user_id");



CREATE OR REPLACE TRIGGER "audit_employees_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."employees" FOR EACH ROW EXECUTE FUNCTION "public"."audit_trigger_function"();



CREATE OR REPLACE TRIGGER "audit_jobs_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."jobs" FOR EACH ROW EXECUTE FUNCTION "public"."audit_trigger_function"();



CREATE OR REPLACE TRIGGER "audit_organizations_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."organizations" FOR EACH ROW EXECUTE FUNCTION "public"."audit_trigger_function"();



CREATE OR REPLACE TRIGGER "audit_role_permissions_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."role_permissions" FOR EACH ROW EXECUTE FUNCTION "public"."audit_trigger_function"();



CREATE OR REPLACE TRIGGER "audit_roles_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."roles" FOR EACH ROW EXECUTE FUNCTION "public"."audit_trigger_function"();



CREATE OR REPLACE TRIGGER "auto_setup_org_admin" AFTER INSERT ON "public"."organizations" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_setup_org_admin"();



COMMENT ON TRIGGER "auto_setup_org_admin" ON "public"."organizations" IS 'Automatically sets up admin role and permissions for organization primary owner';



CREATE OR REPLACE TRIGGER "enforce_max_organizations_per_user" BEFORE INSERT OR UPDATE ON "public"."organizations" FOR EACH ROW EXECUTE FUNCTION "public"."check_max_organizations_per_user"();



CREATE OR REPLACE TRIGGER "update_apps_updated_at" BEFORE UPDATE ON "public"."apps" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_departments_updated_at" BEFORE UPDATE ON "public"."departments" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_employees_updated_at" BEFORE UPDATE ON "public"."employees" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_jobs_updated_at" BEFORE UPDATE ON "public"."jobs" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_organizations_updated_at" BEFORE UPDATE ON "public"."organizations" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_plans_updated_at" BEFORE UPDATE ON "public"."plans" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_roles_updated_at" BEFORE UPDATE ON "public"."roles" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_sites_updated_at" BEFORE UPDATE ON "public"."sites" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



CREATE OR REPLACE TRIGGER "update_users_updated_at" BEFORE UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."departments"
    ADD CONSTRAINT "departments_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id");



ALTER TABLE ONLY "public"."employee_hierarchy"
    ADD CONSTRAINT "employee_hierarchy_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("employee_id");



ALTER TABLE ONLY "public"."employee_hierarchy"
    ADD CONSTRAINT "employee_hierarchy_manager_employee_id_fkey" FOREIGN KEY ("manager_employee_id") REFERENCES "public"."employees"("employee_id");



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "public"."departments"("department_id");



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id");



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("role_id");



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "employees_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("site_id");



ALTER TABLE ONLY "public"."departments"
    ADD CONSTRAINT "fk_departments_organization" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."employee_hierarchy"
    ADD CONSTRAINT "fk_employee_hierarchy_employee" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("employee_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."employee_hierarchy"
    ADD CONSTRAINT "fk_employee_hierarchy_manager" FOREIGN KEY ("manager_employee_id") REFERENCES "public"."employees"("employee_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "fk_employee_user" FOREIGN KEY ("employee_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "fk_employees_department" FOREIGN KEY ("department_id") REFERENCES "public"."departments"("department_id");



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "fk_employees_organization" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id");



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "fk_employees_role" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("role_id");



ALTER TABLE ONLY "public"."employees"
    ADD CONSTRAINT "fk_employees_site" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("site_id");



ALTER TABLE ONLY "public"."job_categories"
    ADD CONSTRAINT "fk_job_categories_organization" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."job_skills"
    ADD CONSTRAINT "fk_job_skills_job" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("job_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."job_skills"
    ADD CONSTRAINT "fk_job_skills_skill" FOREIGN KEY ("skill_id") REFERENCES "public"."skills"("skill_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "fk_jobs_approved_by" FOREIGN KEY ("approved_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "fk_jobs_category" FOREIGN KEY ("job_category") REFERENCES "public"."job_categories"("category_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "fk_jobs_created_by" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "fk_jobs_department" FOREIGN KEY ("department_id") REFERENCES "public"."departments"("department_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "fk_jobs_organization" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "fk_jobs_site" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("site_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "fk_notifications_user" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."organization_apps"
    ADD CONSTRAINT "fk_org_apps_app" FOREIGN KEY ("app_id") REFERENCES "public"."apps"("app_id");



ALTER TABLE ONLY "public"."organization_apps"
    ADD CONSTRAINT "fk_org_apps_organization" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id");



ALTER TABLE ONLY "public"."organization_apps"
    ADD CONSTRAINT "fk_org_apps_plan" FOREIGN KEY ("organization_plan_id") REFERENCES "public"."organization_plans"("organization_plan_id");



ALTER TABLE ONLY "public"."organization_organization_types"
    ADD CONSTRAINT "fk_org_org_types_organization" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."organization_organization_types"
    ADD CONSTRAINT "fk_org_org_types_type" FOREIGN KEY ("organization_type_id") REFERENCES "public"."organization_types"("organization_type_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."organization_plans"
    ADD CONSTRAINT "fk_org_plans_organization" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id");



ALTER TABLE ONLY "public"."organization_plans"
    ADD CONSTRAINT "fk_org_plans_plan" FOREIGN KEY ("plan_id") REFERENCES "public"."plans"("plan_id");



ALTER TABLE ONLY "public"."organization_apps"
    ADD CONSTRAINT "fk_organization_apps_app" FOREIGN KEY ("app_id") REFERENCES "public"."apps"("app_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."organization_apps"
    ADD CONSTRAINT "fk_organization_apps_organization" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."organization_apps"
    ADD CONSTRAINT "fk_organization_apps_plan" FOREIGN KEY ("organization_plan_id") REFERENCES "public"."organization_plans"("organization_plan_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."organization_plans"
    ADD CONSTRAINT "fk_organization_plans_organization" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."organization_plans"
    ADD CONSTRAINT "fk_organization_plans_plan" FOREIGN KEY ("plan_id") REFERENCES "public"."plans"("plan_id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."organizations"
    ADD CONSTRAINT "fk_organizations_created_by" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."organizations"
    ADD CONSTRAINT "fk_organizations_primary_owner" FOREIGN KEY ("primary_owner") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."organizations"
    ADD CONSTRAINT "fk_organizations_secondary_owner" FOREIGN KEY ("secondary_owner") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."plan_apps"
    ADD CONSTRAINT "fk_plan_apps_app" FOREIGN KEY ("app_id") REFERENCES "public"."apps"("app_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."plan_apps"
    ADD CONSTRAINT "fk_plan_apps_plan" FOREIGN KEY ("plan_id") REFERENCES "public"."plans"("plan_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."organizations"
    ADD CONSTRAINT "fk_primary_owner_user" FOREIGN KEY ("primary_owner") REFERENCES "public"."users"("user_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "fk_role_permissions_organization" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "fk_role_permissions_role" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("role_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "fk_roles_organization" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."saved_jobs"
    ADD CONSTRAINT "fk_saved_jobs_job" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("job_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."saved_jobs"
    ADD CONSTRAINT "fk_saved_jobs_user" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."organizations"
    ADD CONSTRAINT "fk_secondary_owner_user" FOREIGN KEY ("secondary_owner") REFERENCES "public"."users"("user_id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."sites"
    ADD CONSTRAINT "fk_sites_organization" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."super_admins"
    ADD CONSTRAINT "fk_super_admins_created_by" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."super_admins"
    ADD CONSTRAINT "fk_super_admins_user" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "fk_user_auth" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_education"
    ADD CONSTRAINT "fk_user_education_user" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_ethnicities"
    ADD CONSTRAINT "fk_user_ethnicities_ethnicity" FOREIGN KEY ("ethnicity_id") REFERENCES "public"."ethnicities"("ethnicity_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_ethnicities"
    ADD CONSTRAINT "fk_user_ethnicities_user" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_job_history"
    ADD CONSTRAINT "fk_user_job_history_user" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_languages"
    ADD CONSTRAINT "fk_user_languages_user" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_skills"
    ADD CONSTRAINT "fk_user_skills_skill" FOREIGN KEY ("skill_id") REFERENCES "public"."skills"("skill_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_skills"
    ADD CONSTRAINT "fk_user_skills_user" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."job_categories"
    ADD CONSTRAINT "job_categories_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id");



ALTER TABLE ONLY "public"."job_skills"
    ADD CONSTRAINT "job_skills_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("job_id");



ALTER TABLE ONLY "public"."job_skills"
    ADD CONSTRAINT "job_skills_skill_id_fkey" FOREIGN KEY ("skill_id") REFERENCES "public"."skills"("skill_id");



ALTER TABLE ONLY "public"."job_translations"
    ADD CONSTRAINT "job_translations_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("job_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "public"."departments"("department_id");



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_job_category_fkey" FOREIGN KEY ("job_category") REFERENCES "public"."job_categories"("category_id");



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id");



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_organization_type_id_fkey" FOREIGN KEY ("organization_type_id") REFERENCES "public"."organization_types"("organization_type_id");



ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "public"."sites"("site_id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."organization_apps"
    ADD CONSTRAINT "organization_apps_app_id_fkey" FOREIGN KEY ("app_id") REFERENCES "public"."apps"("app_id");



ALTER TABLE ONLY "public"."organization_apps"
    ADD CONSTRAINT "organization_apps_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id");



ALTER TABLE ONLY "public"."organization_apps"
    ADD CONSTRAINT "organization_apps_organization_plan_id_fkey" FOREIGN KEY ("organization_plan_id") REFERENCES "public"."organization_plans"("organization_plan_id");



ALTER TABLE ONLY "public"."organization_organization_types"
    ADD CONSTRAINT "organization_organization_types_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id");



ALTER TABLE ONLY "public"."organization_organization_types"
    ADD CONSTRAINT "organization_organization_types_organization_type_id_fkey" FOREIGN KEY ("organization_type_id") REFERENCES "public"."organization_types"("organization_type_id");



ALTER TABLE ONLY "public"."organization_plans"
    ADD CONSTRAINT "organization_plans_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id");



ALTER TABLE ONLY "public"."organization_plans"
    ADD CONSTRAINT "organization_plans_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "public"."plans"("plan_id");



ALTER TABLE ONLY "public"."organizations"
    ADD CONSTRAINT "organizations_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."organizations"
    ADD CONSTRAINT "organizations_primary_owner_fkey" FOREIGN KEY ("primary_owner") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."organizations"
    ADD CONSTRAINT "organizations_secondary_owner_fkey" FOREIGN KEY ("secondary_owner") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."plan_apps"
    ADD CONSTRAINT "plan_apps_app_id_fkey" FOREIGN KEY ("app_id") REFERENCES "public"."apps"("app_id");



ALTER TABLE ONLY "public"."plan_apps"
    ADD CONSTRAINT "plan_apps_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "public"."plans"("plan_id");



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id");



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("role_id");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id");



ALTER TABLE ONLY "public"."saved_jobs"
    ADD CONSTRAINT "saved_jobs_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("job_id");



ALTER TABLE ONLY "public"."saved_jobs"
    ADD CONSTRAINT "saved_jobs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."sites"
    ADD CONSTRAINT "sites_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("organization_id");



ALTER TABLE ONLY "public"."super_admins"
    ADD CONSTRAINT "super_admins_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."super_admins"
    ADD CONSTRAINT "super_admins_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."user_education"
    ADD CONSTRAINT "user_education_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."user_ethnicities"
    ADD CONSTRAINT "user_ethnicities_ethnicity_id_fkey" FOREIGN KEY ("ethnicity_id") REFERENCES "public"."ethnicities"("ethnicity_id");



ALTER TABLE ONLY "public"."user_ethnicities"
    ADD CONSTRAINT "user_ethnicities_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."user_job_history"
    ADD CONSTRAINT "user_job_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."user_languages"
    ADD CONSTRAINT "user_languages_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id");



ALTER TABLE ONLY "public"."user_skills"
    ADD CONSTRAINT "user_skills_skill_id_fkey" FOREIGN KEY ("skill_id") REFERENCES "public"."skills"("skill_id");



ALTER TABLE ONLY "public"."user_skills"
    ADD CONSTRAINT "user_skills_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id");



CREATE POLICY "Anyone can view active apps" ON "public"."apps" FOR SELECT USING ((("is_active" = true) AND ("deleted_at" IS NULL)));



CREATE POLICY "Anyone can view active plans" ON "public"."plans" FOR SELECT USING ((("is_active" = true) AND ("deleted_at" IS NULL)));



CREATE POLICY "Anyone can view skills" ON "public"."skills" FOR SELECT USING (true);



CREATE POLICY "Employees can update their own profile" ON "public"."employees" FOR UPDATE TO "authenticated" USING ((("employee_id" = "auth"."uid"()) OR ( SELECT "public"."is_super_admin"("auth"."uid"()) AS "is_super_admin"))) WITH CHECK ((("employee_id" = "auth"."uid"()) OR ( SELECT "public"."is_super_admin"("auth"."uid"()) AS "is_super_admin")));



CREATE POLICY "Enable users to view their own data only" ON "public"."custom_users" FOR SELECT TO "authenticated" USING (("id" = "auth"."uid"()));



CREATE POLICY "Job managers can manage job skills" ON "public"."job_skills" USING (("public"."is_super_admin"("auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."jobs" "j"
  WHERE (("j"."job_id" = "job_skills"."job_id") AND "public"."has_permission_in_org"("auth"."uid"(), "j"."organization_id", 'manage_jobs'::character varying))))));



CREATE POLICY "Org admins can manage departments" ON "public"."departments" USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."has_permission_in_org"("auth"."uid"(), "organization_id", 'manage_departments'::character varying) OR "public"."is_org_owner"("auth"."uid"(), "organization_id")));



CREATE POLICY "Org admins can manage employees" ON "public"."employees" USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."has_permission_in_org"("auth"."uid"(), "organization_id", 'manage_employees'::character varying) OR "public"."is_org_owner"("auth"."uid"(), "organization_id")));



CREATE POLICY "Org admins can manage job categories" ON "public"."job_categories" USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."has_permission_in_org"("auth"."uid"(), "organization_id", 'manage_jobs'::character varying) OR "public"."is_org_owner"("auth"."uid"(), "organization_id")));



CREATE POLICY "Org admins can manage role permissions" ON "public"."role_permissions" USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."has_permission_in_org"("auth"."uid"(), "organization_id", 'manage_roles'::character varying) OR "public"."is_org_owner"("auth"."uid"(), "organization_id")));



CREATE POLICY "Org admins can manage roles" ON "public"."roles" USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."has_permission_in_org"("auth"."uid"(), "organization_id", 'manage_roles'::character varying) OR "public"."is_org_owner"("auth"."uid"(), "organization_id")));



CREATE POLICY "Org admins can manage sites" ON "public"."sites" USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."has_permission_in_org"("auth"."uid"(), "organization_id", 'manage_sites'::character varying) OR "public"."is_org_owner"("auth"."uid"(), "organization_id")));



CREATE POLICY "Org admins can view their org audit logs" ON "public"."audit_logs" FOR SELECT USING ((("organization_id" IS NOT NULL) AND "public"."user_belongs_to_org"("auth"."uid"(), "organization_id") AND "public"."has_permission_in_org"("auth"."uid"(), "organization_id", 'view_audit_logs'::character varying)));



CREATE POLICY "Org owners can update their orgs" ON "public"."organizations" FOR UPDATE USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."is_org_owner"("auth"."uid"(), "organization_id")));



CREATE POLICY "Super admins can manage skills" ON "public"."skills" USING ("public"."is_super_admin"("auth"."uid"()));



CREATE POLICY "Users can create organizations" ON "public"."organizations" FOR INSERT WITH CHECK ((("primary_owner" = "auth"."uid"()) OR ("created_by" = "auth"."uid"())));



CREATE POLICY "Users can manage their own education" ON "public"."user_education" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can manage their own job history" ON "public"."user_job_history" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can manage their own saved jobs" ON "public"."saved_jobs" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can manage their own skills" ON "public"."user_skills" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can only update their own record" ON "public"."users" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own profile" ON "public"."users" FOR UPDATE USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can view departments in their orgs" ON "public"."departments" FOR SELECT USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."user_belongs_to_org"("auth"."uid"(), "organization_id")));



CREATE POLICY "Users can view employees in their orgs" ON "public"."employees" FOR SELECT USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."user_belongs_to_org"("auth"."uid"(), "organization_id") OR ("employee_id" = "auth"."uid"())));



CREATE POLICY "Users can view job skills" ON "public"."job_skills" FOR SELECT USING (true);



CREATE POLICY "Users can view jobs in their orgs" ON "public"."jobs" FOR SELECT USING (((("status")::"text" = 'published'::"text") OR "public"."is_super_admin"("auth"."uid"()) OR "public"."user_belongs_to_org"("auth"."uid"(), "organization_id")));



CREATE POLICY "Users can view orgs they belong to" ON "public"."organizations" FOR SELECT USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."user_belongs_to_org"("auth"."uid"(), "organization_id") OR ("primary_owner" = "auth"."uid"()) OR ("secondary_owner" = "auth"."uid"())));



CREATE POLICY "Users can view role permissions in their orgs" ON "public"."role_permissions" FOR SELECT USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."user_belongs_to_org"("auth"."uid"(), "organization_id")));



CREATE POLICY "Users can view roles in their orgs" ON "public"."roles" FOR SELECT USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."user_belongs_to_org"("auth"."uid"(), "organization_id")));



CREATE POLICY "Users can view sites in their orgs" ON "public"."sites" FOR SELECT USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."user_belongs_to_org"("auth"."uid"(), "organization_id")));



CREATE POLICY "Users can view their org apps" ON "public"."organization_apps" FOR SELECT USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."user_belongs_to_org"("auth"."uid"(), "organization_id")));



CREATE POLICY "Users can view their org plans" ON "public"."organization_plans" FOR SELECT USING (("public"."is_super_admin"("auth"."uid"()) OR "public"."user_belongs_to_org"("auth"."uid"(), "organization_id")));



ALTER TABLE "public"."apps" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."audit_logs" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "create_job_policy" ON "public"."jobs" FOR INSERT WITH CHECK (("public"."has_permission_in_org"(COALESCE((NULLIF("current_setting"('app.current_user_id'::"text", true), ''::"text"))::"uuid", "auth"."uid"()), "organization_id", 'create_job'::character varying) AND ("created_by" = COALESCE((NULLIF("current_setting"('app.current_user_id'::"text", true), ''::"text"))::"uuid", "auth"."uid"()))));



CREATE POLICY "create_job_translation_policy" ON "public"."job_translations" FOR INSERT WITH CHECK ("public"."has_job_translation_permission"(COALESCE((NULLIF("current_setting"('app.current_user_id'::"text", true), ''::"text"))::"uuid", "auth"."uid"()), "job_id", 'create_job'::character varying));



CREATE POLICY "delete_job_policy" ON "public"."jobs" FOR DELETE USING ("public"."has_permission_in_org"(COALESCE((NULLIF("current_setting"('app.current_user_id'::"text", true), ''::"text"))::"uuid", "auth"."uid"()), "organization_id", 'delete_job'::character varying));



CREATE POLICY "delete_job_translation_policy" ON "public"."job_translations" FOR DELETE USING ("public"."has_job_translation_permission"(COALESCE((NULLIF("current_setting"('app.current_user_id'::"text", true), ''::"text"))::"uuid", "auth"."uid"()), "job_id", 'delete_job'::character varying));



ALTER TABLE "public"."departments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."employees" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."job_categories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."job_translations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."jobs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."organization_apps" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."organization_plans" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."organizations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."plans" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."role_permissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."saved_jobs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."sites" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."skills" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "update_job_policy" ON "public"."jobs" FOR UPDATE USING ("public"."has_permission_in_org"(COALESCE((NULLIF("current_setting"('app.current_user_id'::"text", true), ''::"text"))::"uuid", "auth"."uid"()), "organization_id", 'update_job'::character varying)) WITH CHECK ("public"."has_permission_in_org"(COALESCE((NULLIF("current_setting"('app.current_user_id'::"text", true), ''::"text"))::"uuid", "auth"."uid"()), "organization_id", 'update_job'::character varying));



CREATE POLICY "update_job_translation_policy" ON "public"."job_translations" FOR UPDATE USING ("public"."has_job_translation_permission"(COALESCE((NULLIF("current_setting"('app.current_user_id'::"text", true), ''::"text"))::"uuid", "auth"."uid"()), "job_id", 'update_job'::character varying)) WITH CHECK ("public"."has_job_translation_permission"(COALESCE((NULLIF("current_setting"('app.current_user_id'::"text", true), ''::"text"))::"uuid", "auth"."uid"()), "job_id", 'update_job'::character varying));



ALTER TABLE "public"."user_education" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_job_history" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_languages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_skills" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";




















































































































































































GRANT ALL ON FUNCTION "public"."add_super_admin"("p_email" "text", "p_admin_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."add_super_admin"("p_email" "text", "p_admin_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_super_admin"("p_email" "text", "p_admin_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."audit_trigger_function"() TO "anon";
GRANT ALL ON FUNCTION "public"."audit_trigger_function"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."audit_trigger_function"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_max_organizations_per_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_max_organizations_per_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_max_organizations_per_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_organization_ids"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_organization_ids"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_organization_ids"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_role_in_org"("p_user_id" "uuid", "p_organization_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_role_in_org"("p_user_id" "uuid", "p_organization_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_role_in_org"("p_user_id" "uuid", "p_organization_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."has_job_translation_permission"("p_user_id" "uuid", "p_job_id" "uuid", "p_permission_name" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."has_job_translation_permission"("p_user_id" "uuid", "p_job_id" "uuid", "p_permission_name" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_job_translation_permission"("p_user_id" "uuid", "p_job_id" "uuid", "p_permission_name" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."has_jobs_app_permission"("org_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."has_jobs_app_permission"("org_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_jobs_app_permission"("org_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."has_permission_in_org"("p_user_id" "uuid", "p_organization_id" "uuid", "p_permission_name" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."has_permission_in_org"("p_user_id" "uuid", "p_organization_id" "uuid", "p_permission_name" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_permission_in_org"("p_user_id" "uuid", "p_organization_id" "uuid", "p_permission_name" character varying) TO "service_role";



GRANT ALL ON FUNCTION "public"."is_org_owner"("p_user_id" "uuid", "p_organization_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_org_owner"("p_user_id" "uuid", "p_organization_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_org_owner"("p_user_id" "uuid", "p_organization_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_super_admin"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_super_admin"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_super_admin"("p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."remove_super_admin"("p_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."remove_super_admin"("p_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."remove_super_admin"("p_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_organization_status"("p_organization_id" "uuid", "p_active" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."set_organization_status"("p_organization_id" "uuid", "p_active" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_organization_status"("p_organization_id" "uuid", "p_active" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."setup_org_admin_permissions"("p_organization_id" "uuid", "p_role_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."setup_org_admin_permissions"("p_organization_id" "uuid", "p_role_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."setup_org_admin_permissions"("p_organization_id" "uuid", "p_role_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."setup_org_admin_role"("p_organization_id" "uuid", "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."setup_org_admin_role"("p_organization_id" "uuid", "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."setup_org_admin_role"("p_organization_id" "uuid", "p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."trigger_setup_org_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."trigger_setup_org_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trigger_setup_org_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT ALL ON FUNCTION "public"."user_belongs_to_org"("p_user_id" "uuid", "p_organization_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."user_belongs_to_org"("p_user_id" "uuid", "p_organization_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_belongs_to_org"("p_user_id" "uuid", "p_organization_id" "uuid") TO "service_role";



























GRANT ALL ON TABLE "public"."apps" TO "anon";
GRANT ALL ON TABLE "public"."apps" TO "authenticated";
GRANT ALL ON TABLE "public"."apps" TO "service_role";



GRANT ALL ON TABLE "public"."audit_logs" TO "anon";
GRANT ALL ON TABLE "public"."audit_logs" TO "authenticated";
GRANT ALL ON TABLE "public"."audit_logs" TO "service_role";



GRANT ALL ON TABLE "public"."custom_users" TO "anon";
GRANT ALL ON TABLE "public"."custom_users" TO "authenticated";
GRANT ALL ON TABLE "public"."custom_users" TO "service_role";



GRANT ALL ON TABLE "public"."departments" TO "anon";
GRANT ALL ON TABLE "public"."departments" TO "authenticated";
GRANT ALL ON TABLE "public"."departments" TO "service_role";



GRANT ALL ON TABLE "public"."employee_hierarchy" TO "anon";
GRANT ALL ON TABLE "public"."employee_hierarchy" TO "authenticated";
GRANT ALL ON TABLE "public"."employee_hierarchy" TO "service_role";



GRANT ALL ON TABLE "public"."employees" TO "anon";
GRANT ALL ON TABLE "public"."employees" TO "authenticated";
GRANT ALL ON TABLE "public"."employees" TO "service_role";



GRANT ALL ON TABLE "public"."ethnicities" TO "anon";
GRANT ALL ON TABLE "public"."ethnicities" TO "authenticated";
GRANT ALL ON TABLE "public"."ethnicities" TO "service_role";



GRANT ALL ON TABLE "public"."job_categories" TO "anon";
GRANT ALL ON TABLE "public"."job_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."job_categories" TO "service_role";



GRANT ALL ON TABLE "public"."job_skills" TO "anon";
GRANT ALL ON TABLE "public"."job_skills" TO "authenticated";
GRANT ALL ON TABLE "public"."job_skills" TO "service_role";



GRANT ALL ON TABLE "public"."job_translations" TO "anon";
GRANT ALL ON TABLE "public"."job_translations" TO "authenticated";
GRANT ALL ON TABLE "public"."job_translations" TO "service_role";



GRANT ALL ON TABLE "public"."jobs" TO "anon";
GRANT ALL ON TABLE "public"."jobs" TO "authenticated";
GRANT ALL ON TABLE "public"."jobs" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON TABLE "public"."organization_apps" TO "anon";
GRANT ALL ON TABLE "public"."organization_apps" TO "authenticated";
GRANT ALL ON TABLE "public"."organization_apps" TO "service_role";



GRANT ALL ON TABLE "public"."organization_organization_types" TO "anon";
GRANT ALL ON TABLE "public"."organization_organization_types" TO "authenticated";
GRANT ALL ON TABLE "public"."organization_organization_types" TO "service_role";



GRANT ALL ON TABLE "public"."organization_plans" TO "anon";
GRANT ALL ON TABLE "public"."organization_plans" TO "authenticated";
GRANT ALL ON TABLE "public"."organization_plans" TO "service_role";



GRANT ALL ON TABLE "public"."organization_types" TO "anon";
GRANT ALL ON TABLE "public"."organization_types" TO "authenticated";
GRANT ALL ON TABLE "public"."organization_types" TO "service_role";



GRANT ALL ON TABLE "public"."organizations" TO "anon";
GRANT ALL ON TABLE "public"."organizations" TO "authenticated";
GRANT ALL ON TABLE "public"."organizations" TO "service_role";



GRANT ALL ON TABLE "public"."plan_apps" TO "anon";
GRANT ALL ON TABLE "public"."plan_apps" TO "authenticated";
GRANT ALL ON TABLE "public"."plan_apps" TO "service_role";



GRANT ALL ON TABLE "public"."plans" TO "anon";
GRANT ALL ON TABLE "public"."plans" TO "authenticated";
GRANT ALL ON TABLE "public"."plans" TO "service_role";



GRANT ALL ON TABLE "public"."role_permissions" TO "anon";
GRANT ALL ON TABLE "public"."role_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."role_permissions" TO "service_role";



GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";



GRANT ALL ON TABLE "public"."saved_jobs" TO "anon";
GRANT ALL ON TABLE "public"."saved_jobs" TO "authenticated";
GRANT ALL ON TABLE "public"."saved_jobs" TO "service_role";



GRANT ALL ON TABLE "public"."sites" TO "anon";
GRANT ALL ON TABLE "public"."sites" TO "authenticated";
GRANT ALL ON TABLE "public"."sites" TO "service_role";



GRANT ALL ON TABLE "public"."skills" TO "anon";
GRANT ALL ON TABLE "public"."skills" TO "authenticated";
GRANT ALL ON TABLE "public"."skills" TO "service_role";



GRANT ALL ON TABLE "public"."super_admins" TO "anon";
GRANT ALL ON TABLE "public"."super_admins" TO "authenticated";
GRANT ALL ON TABLE "public"."super_admins" TO "service_role";



GRANT ALL ON TABLE "public"."user_education" TO "anon";
GRANT ALL ON TABLE "public"."user_education" TO "authenticated";
GRANT ALL ON TABLE "public"."user_education" TO "service_role";



GRANT ALL ON TABLE "public"."user_ethnicities" TO "anon";
GRANT ALL ON TABLE "public"."user_ethnicities" TO "authenticated";
GRANT ALL ON TABLE "public"."user_ethnicities" TO "service_role";



GRANT ALL ON TABLE "public"."user_job_history" TO "anon";
GRANT ALL ON TABLE "public"."user_job_history" TO "authenticated";
GRANT ALL ON TABLE "public"."user_job_history" TO "service_role";



GRANT ALL ON TABLE "public"."user_languages" TO "anon";
GRANT ALL ON TABLE "public"."user_languages" TO "authenticated";
GRANT ALL ON TABLE "public"."user_languages" TO "service_role";



GRANT ALL ON TABLE "public"."user_skills" TO "anon";
GRANT ALL ON TABLE "public"."user_skills" TO "authenticated";
GRANT ALL ON TABLE "public"."user_skills" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
