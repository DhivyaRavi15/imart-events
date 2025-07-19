drop policy "Org admins can view their org audit logs" on "public"."audit_logs";

drop policy "Enable users to view their own data only" on "public"."custom_users";

drop policy "Org admins can manage departments" on "public"."departments";

drop policy "Users can view departments in their orgs" on "public"."departments";

drop policy "Org admins can manage employees" on "public"."employees";

drop policy "Users can view employees in their orgs" on "public"."employees";

drop policy "Org admins can manage job categories" on "public"."job_categories";

drop policy "Job managers can manage job skills" on "public"."job_skills";

drop policy "create_job_translation_policy" on "public"."job_translations";

drop policy "delete_job_translation_policy" on "public"."job_translations";

drop policy "update_job_translation_policy" on "public"."job_translations";

drop policy "update_job_policy" on "public"."jobs";

drop policy "Users can view their org apps" on "public"."organization_apps";

drop policy "Users can view their org plans" on "public"."organization_plans";

drop policy "Org owners can update their orgs" on "public"."organizations";

drop policy "Users can create organizations" on "public"."organizations";

drop policy "Users can view orgs they belong to" on "public"."organizations";

drop policy "Org admins can manage role permissions" on "public"."role_permissions";

drop policy "Users can view role permissions in their orgs" on "public"."role_permissions";

drop policy "Org admins can manage roles" on "public"."roles";

drop policy "Users can view roles in their orgs" on "public"."roles";

drop policy "Users can manage their own saved jobs" on "public"."saved_jobs";

drop policy "Org admins can manage sites" on "public"."sites";

drop policy "Users can view sites in their orgs" on "public"."sites";

drop policy "Super admins can manage skills" on "public"."skills";

drop policy "Users can manage their own education" on "public"."user_education";

drop policy "Users can manage their own job history" on "public"."user_job_history";

drop policy "Users can manage their own skills" on "public"."user_skills";

CREATE INDEX idx_employee_hierarchy_employee_id ON public.employee_hierarchy USING btree (employee_id);

CREATE INDEX idx_employee_hierarchy_manager_employee_id ON public.employee_hierarchy USING btree (manager_employee_id);

CREATE INDEX idx_employees_department_id ON public.employees USING btree (department_id);

CREATE INDEX idx_employees_site_id ON public.employees USING btree (site_id);

CREATE INDEX idx_job_categories_organization_id ON public.job_categories USING btree (organization_id);

CREATE INDEX idx_job_skills_skill_id ON public.job_skills USING btree (skill_id);

CREATE INDEX idx_jobs_approved_by ON public.jobs USING btree (approved_by);

CREATE INDEX idx_jobs_department_id ON public.jobs USING btree (department_id);

CREATE INDEX idx_jobs_job_category ON public.jobs USING btree (job_category);

CREATE INDEX idx_jobs_organization_type_id ON public.jobs USING btree (organization_type_id);

CREATE INDEX idx_jobs_site_id ON public.jobs USING btree (site_id);

CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id);

CREATE INDEX idx_organization_apps_app_id ON public.organization_apps USING btree (app_id);

CREATE INDEX idx_organization_apps_organization_plan_id ON public.organization_apps USING btree (organization_plan_id);

CREATE INDEX idx_organization_organization_types_organization_type_id ON public.organization_organization_types USING btree (organization_type_id);

CREATE INDEX idx_organization_plans_plan_id ON public.organization_plans USING btree (plan_id);

CREATE INDEX idx_organizations_secondary_owner ON public.organizations USING btree (secondary_owner);

CREATE INDEX idx_plan_apps_app_id ON public.plan_apps USING btree (app_id);

CREATE INDEX idx_role_permissions_organization_id ON public.role_permissions USING btree (organization_id);

CREATE INDEX idx_super_admins_created_by ON public.super_admins USING btree (created_by);

CREATE INDEX idx_super_admins_user_id ON public.super_admins USING btree (user_id);

CREATE INDEX idx_user_education_user_id ON public.user_education USING btree (user_id);

CREATE INDEX idx_user_ethnicities_ethnicity_id ON public.user_ethnicities USING btree (ethnicity_id);

CREATE INDEX idx_user_job_history_user_id ON public.user_job_history USING btree (user_id);

CREATE INDEX idx_user_languages_user_id ON public.user_languages USING btree (user_id);

CREATE INDEX idx_user_skills_skill_id ON public.user_skills USING btree (skill_id);

create policy "Org admins can view their org audit logs"
on "public"."audit_logs"
as permissive
for select
to public
using (((organization_id IS NOT NULL) AND user_belongs_to_org(( SELECT auth.uid() AS uid), organization_id) AND has_permission_in_org(( SELECT auth.uid() AS uid), organization_id, 'view_audit_logs'::character varying)));


create policy "Enable users to view their own data only"
on "public"."custom_users"
as permissive
for select
to authenticated
using ((id = ( SELECT auth.uid() AS uid)));


create policy "Org admins can manage departments"
on "public"."departments"
as permissive
for all
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR has_permission_in_org(( SELECT auth.uid() AS uid), organization_id, 'manage_departments'::character varying) OR is_org_owner(( SELECT auth.uid() AS uid), organization_id)));


create policy "Users can view departments in their orgs"
on "public"."departments"
as permissive
for select
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR user_belongs_to_org(( SELECT auth.uid() AS uid), organization_id)));


create policy "Org admins can manage employees"
on "public"."employees"
as permissive
for all
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR has_permission_in_org(( SELECT auth.uid() AS uid), organization_id, 'manage_employees'::character varying) OR is_org_owner(( SELECT auth.uid() AS uid), organization_id)));


create policy "Users can view employees in their orgs"
on "public"."employees"
as permissive
for select
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR user_belongs_to_org(( SELECT auth.uid() AS uid), organization_id) OR (employee_id = ( SELECT auth.uid() AS uid))));


create policy "Org admins can manage job categories"
on "public"."job_categories"
as permissive
for all
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR has_permission_in_org(( SELECT auth.uid() AS uid), organization_id, 'manage_jobs'::character varying) OR is_org_owner(( SELECT auth.uid() AS uid), organization_id)));


create policy "Job managers can manage job skills"
on "public"."job_skills"
as permissive
for all
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR (EXISTS ( SELECT 1
   FROM jobs j
  WHERE ((j.job_id = job_skills.job_id) AND has_permission_in_org(( SELECT auth.uid() AS uid), j.organization_id, 'manage_jobs'::character varying))))));


create policy "create_job_translation_policy"
on "public"."job_translations"
as permissive
for insert
to public
with check (has_job_translation_permission(COALESCE((NULLIF(current_setting('app.current_user_id'::text, true), ''::text))::uuid, ( SELECT auth.uid() AS uid)), job_id, 'create_job'::character varying));


create policy "delete_job_translation_policy"
on "public"."job_translations"
as permissive
for delete
to public
using (has_job_translation_permission(COALESCE((NULLIF(current_setting('app.current_user_id'::text, true), ''::text))::uuid, ( SELECT auth.uid() AS uid)), job_id, 'delete_job'::character varying));


create policy "update_job_translation_policy"
on "public"."job_translations"
as permissive
for update
to public
using (has_job_translation_permission(COALESCE((NULLIF(current_setting('app.current_user_id'::text, true), ''::text))::uuid, ( SELECT auth.uid() AS uid)), job_id, 'update_job'::character varying))
with check (has_job_translation_permission(COALESCE((NULLIF(current_setting('app.current_user_id'::text, true), ''::text))::uuid, ( SELECT auth.uid() AS uid)), job_id, 'update_job'::character varying));


create policy "update_job_policy"
on "public"."jobs"
as permissive
for update
to public
using (has_permission_in_org(COALESCE((NULLIF(current_setting('app.current_user_id'::text, true), ''::text))::uuid, ( SELECT auth.uid() AS uid)), organization_id, 'update_job'::character varying))
with check (has_permission_in_org(COALESCE((NULLIF(current_setting('app.current_user_id'::text, true), ''::text))::uuid, ( SELECT auth.uid() AS uid)), organization_id, 'update_job'::character varying));


create policy "Users can view their org apps"
on "public"."organization_apps"
as permissive
for select
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR user_belongs_to_org(( SELECT auth.uid() AS uid), organization_id)));


create policy "Users can view their org plans"
on "public"."organization_plans"
as permissive
for select
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR user_belongs_to_org(( SELECT auth.uid() AS uid), organization_id)));


create policy "Org owners can update their orgs"
on "public"."organizations"
as permissive
for update
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR is_org_owner(( SELECT auth.uid() AS uid), organization_id)));


create policy "Users can create organizations"
on "public"."organizations"
as permissive
for insert
to public
with check (((primary_owner = ( SELECT auth.uid() AS uid)) OR (created_by = ( SELECT auth.uid() AS uid))));


create policy "Users can view orgs they belong to"
on "public"."organizations"
as permissive
for select
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR user_belongs_to_org(( SELECT auth.uid() AS uid), organization_id) OR (primary_owner = ( SELECT auth.uid() AS uid)) OR (secondary_owner = ( SELECT auth.uid() AS uid))));


create policy "Org admins can manage role permissions"
on "public"."role_permissions"
as permissive
for all
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR has_permission_in_org(( SELECT auth.uid() AS uid), organization_id, 'manage_roles'::character varying) OR is_org_owner(( SELECT auth.uid() AS uid), organization_id)));


create policy "Users can view role permissions in their orgs"
on "public"."role_permissions"
as permissive
for select
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR user_belongs_to_org(( SELECT auth.uid() AS uid), organization_id)));


create policy "Org admins can manage roles"
on "public"."roles"
as permissive
for all
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR has_permission_in_org(( SELECT auth.uid() AS uid), organization_id, 'manage_roles'::character varying) OR is_org_owner(( SELECT auth.uid() AS uid), organization_id)));


create policy "Users can view roles in their orgs"
on "public"."roles"
as permissive
for select
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR user_belongs_to_org(( SELECT auth.uid() AS uid), organization_id)));


create policy "Users can manage their own saved jobs"
on "public"."saved_jobs"
as permissive
for all
to public
using ((user_id = ( SELECT auth.uid() AS uid)));


create policy "Org admins can manage sites"
on "public"."sites"
as permissive
for all
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR has_permission_in_org(( SELECT auth.uid() AS uid), organization_id, 'manage_sites'::character varying) OR is_org_owner(( SELECT auth.uid() AS uid), organization_id)));


create policy "Users can view sites in their orgs"
on "public"."sites"
as permissive
for select
to public
using ((is_super_admin(( SELECT auth.uid() AS uid)) OR user_belongs_to_org(( SELECT auth.uid() AS uid), organization_id)));


create policy "Super admins can manage skills"
on "public"."skills"
as permissive
for all
to public
using (is_super_admin(( SELECT auth.uid() AS uid)));


create policy "Users can manage their own education"
on "public"."user_education"
as permissive
for all
to public
using ((user_id = ( SELECT auth.uid() AS uid)));


create policy "Users can manage their own job history"
on "public"."user_job_history"
as permissive
for all
to public
using ((user_id = ( SELECT auth.uid() AS uid)));


create policy "Users can manage their own skills"
on "public"."user_skills"
as permissive
for all
to public
using ((user_id = ( SELECT auth.uid() AS uid)));



