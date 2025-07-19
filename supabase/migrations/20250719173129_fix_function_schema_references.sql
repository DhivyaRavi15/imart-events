-- Fix function schema references to prevent "relation does not exist" errors

-- Fix the is_super_admin function to properly reference the public.super_admins table
CREATE OR REPLACE FUNCTION "public"."is_super_admin"("p_user_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.super_admins
        WHERE user_id = p_user_id
    );
END;
$$;

-- Fix the check_max_organizations_per_user function to properly reference the public.organizations table
CREATE OR REPLACE FUNCTION "public"."check_max_organizations_per_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Count active organizations for the primary owner
  IF (
    SELECT COUNT(*) 
    FROM public.organizations 
    WHERE primary_owner = NEW.primary_owner 
      AND deleted_at IS NULL
  ) > 3 THEN
    RAISE EXCEPTION 'Maximum of 3 active organizations per user exceeded';
  END IF;
  RETURN NEW;
END;
$$;

-- Fix has_permission_in_org function if it exists and has schema issues
CREATE OR REPLACE FUNCTION "public"."has_permission_in_org"("p_user_id" "uuid", "p_organization_id" "uuid", "p_permission_name" character varying) RETURNS boolean
    LANGUAGE "plpgsql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    is_authorized BOOLEAN;
    is_org_active BOOLEAN;
BEGIN
    -- Check if user is a super admin (they bypass all permission checks)
    IF public.is_super_admin(p_user_id) THEN
        RETURN TRUE;
    END IF;
    
    -- Check if the organization is active
    SELECT active INTO is_org_active
    FROM public.organizations
    WHERE organization_id = p_organization_id
      AND deleted_at IS NULL;
    
    -- If organization is inactive, only allow view permissions
    IF is_org_active = FALSE AND p_permission_name NOT LIKE 'view_%' THEN
        RETURN FALSE;
    END IF;
    
    -- Check if organization has jobs app permission for job-related operations
    IF p_permission_name LIKE 'jobs_%' THEN 
        IF NOT public.has_jobs_app_permission(p_organization_id) THEN 
            RETURN FALSE; 
        END IF; 
    END IF; 

    -- Check regular permissions
    SELECT EXISTS (
        SELECT 1
        FROM public.employees e
        JOIN public.roles r ON e.role_id = r.role_id
        JOIN public.role_permissions rp ON r.role_id = rp.role_id
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

-- Note: is_org_owner and user_belongs_to_org functions already have correct schema prefixes
-- No need to modify them