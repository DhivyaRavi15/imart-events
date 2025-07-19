drop policy "Users can view jobs in their orgs" on "public"."jobs";

drop policy "create_job_policy" on "public"."jobs";

drop policy "delete_job_policy" on "public"."jobs";

alter table "public"."custom_users" enable row level security;

alter table "public"."employee_hierarchy" enable row level security;

alter table "public"."ethnicities" enable row level security;

alter table "public"."job_skills" enable row level security;

alter table "public"."notifications" enable row level security;

alter table "public"."organization_organization_types" enable row level security;

alter table "public"."organization_types" enable row level security;

alter table "public"."plan_apps" enable row level security;

alter table "public"."super_admins" enable row level security;

alter table "public"."user_ethnicities" enable row level security;

create policy "HR can manage employee hierarchy"
on "public"."employee_hierarchy"
as permissive
for all
to public
using ((EXISTS ( SELECT 1
   FROM employees e
  WHERE ((e.employee_id = employee_hierarchy.employee_id) AND has_permission_in_org(( SELECT auth.uid() AS uid), e.organization_id, 'manage_employees'::character varying)))))
with check ((EXISTS ( SELECT 1
   FROM employees e
  WHERE ((e.employee_id = employee_hierarchy.employee_id) AND has_permission_in_org(( SELECT auth.uid() AS uid), e.organization_id, 'manage_employees'::character varying)))));


create policy "Super admins can manage all employee hierarchy"
on "public"."employee_hierarchy"
as permissive
for all
to public
using (is_super_admin(( SELECT auth.uid() AS uid)))
with check (is_super_admin(( SELECT auth.uid() AS uid)));


create policy "Users can view hierarchy in their orgs"
on "public"."employee_hierarchy"
as permissive
for select
to public
using ((EXISTS ( SELECT 1
   FROM employees e
  WHERE ((e.employee_id = employee_hierarchy.employee_id) AND user_belongs_to_org(( SELECT auth.uid() AS uid), e.organization_id)))));


create policy "Anyone can view ethnicities"
on "public"."ethnicities"
as permissive
for select
to public
using (true);


create policy "Super admins can manage ethnicities"
on "public"."ethnicities"
as permissive
for all
to public
using (is_super_admin(( SELECT auth.uid() AS uid)))
with check (is_super_admin(( SELECT auth.uid() AS uid)));


create policy "Super admins can manage all notifications"
on "public"."notifications"
as permissive
for all
to public
using (is_super_admin(( SELECT auth.uid() AS uid)))
with check (is_super_admin(( SELECT auth.uid() AS uid)));


create policy "Users can update their own notifications"
on "public"."notifications"
as permissive
for update
to public
using ((user_id = ( SELECT auth.uid() AS uid)))
with check ((user_id = ( SELECT auth.uid() AS uid)));


create policy "Users can view their own notifications"
on "public"."notifications"
as permissive
for select
to public
using ((user_id = ( SELECT auth.uid() AS uid)));


create policy "Org owners can manage their org types"
on "public"."organization_organization_types"
as permissive
for all
to public
using (is_org_owner(( SELECT auth.uid() AS uid), organization_id))
with check (is_org_owner(( SELECT auth.uid() AS uid), organization_id));


create policy "Super admins can manage all org types"
on "public"."organization_organization_types"
as permissive
for all
to public
using (is_super_admin(( SELECT auth.uid() AS uid)))
with check (is_super_admin(( SELECT auth.uid() AS uid)));


create policy "Users can view org types for their orgs"
on "public"."organization_organization_types"
as permissive
for select
to public
using (user_belongs_to_org(( SELECT auth.uid() AS uid), organization_id));


create policy "Anyone can view organization types"
on "public"."organization_types"
as permissive
for select
to public
using (true);


create policy "Super admins can manage organization types"
on "public"."organization_types"
as permissive
for all
to public
using (is_super_admin(( SELECT auth.uid() AS uid)))
with check (is_super_admin(( SELECT auth.uid() AS uid)));


create policy "Anyone can view plan apps"
on "public"."plan_apps"
as permissive
for select
to public
using (true);


create policy "Super admins can manage plan apps"
on "public"."plan_apps"
as permissive
for all
to public
using (is_super_admin(( SELECT auth.uid() AS uid)))
with check (is_super_admin(( SELECT auth.uid() AS uid)));


create policy "Super admins can manage super admin records"
on "public"."super_admins"
as permissive
for all
to public
using (is_super_admin(( SELECT auth.uid() AS uid)))
with check (is_super_admin(( SELECT auth.uid() AS uid)));


create policy "Super admins can view all super admin records"
on "public"."super_admins"
as permissive
for select
to public
using (is_super_admin(( SELECT auth.uid() AS uid)));


create policy "Super admins can manage all user ethnicities"
on "public"."user_ethnicities"
as permissive
for all
to public
using (is_super_admin(( SELECT auth.uid() AS uid)))
with check (is_super_admin(( SELECT auth.uid() AS uid)));


create policy "Users can manage their own ethnicities"
on "public"."user_ethnicities"
as permissive
for all
to public
using ((user_id = ( SELECT auth.uid() AS uid)))
with check ((user_id = ( SELECT auth.uid() AS uid)));


create policy "Super admins can manage all user languages"
on "public"."user_languages"
as permissive
for all
to public
using (is_super_admin(( SELECT auth.uid() AS uid)))
with check (is_super_admin(( SELECT auth.uid() AS uid)));


create policy "Users can manage their own languages"
on "public"."user_languages"
as permissive
for all
to public
using ((user_id = ( SELECT auth.uid() AS uid)))
with check ((user_id = ( SELECT auth.uid() AS uid)));


create policy "Users can view jobs in their orgs"
on "public"."jobs"
as permissive
for select
to public
using ((((status)::text = 'published'::text) OR is_super_admin(( SELECT auth.uid() AS uid)) OR user_belongs_to_org(( SELECT auth.uid() AS uid), organization_id)));


create policy "create_job_policy"
on "public"."jobs"
as permissive
for insert
to public
with check ((has_permission_in_org(COALESCE((NULLIF(current_setting('app.current_user_id'::text, true), ''::text))::uuid, ( SELECT auth.uid() AS uid)), organization_id, 'create_job'::character varying) AND (created_by = COALESCE((NULLIF(current_setting('app.current_user_id'::text, true), ''::text))::uuid, ( SELECT auth.uid() AS uid)))));


create policy "delete_job_policy"
on "public"."jobs"
as permissive
for delete
to public
using (has_permission_in_org(COALESCE((NULLIF(current_setting('app.current_user_id'::text, true), ''::text))::uuid, ( SELECT auth.uid() AS uid)), organization_id, 'delete_job'::character varying));



