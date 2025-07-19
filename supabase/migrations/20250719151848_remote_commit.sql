create extension if not exists "pgjwt" with schema "extensions";


create table "public"."apps" (
    "app_id" uuid not null default gen_random_uuid(),
    "app_name" character varying(255) not null,
    "app_description" text,
    "app_version" character varying(255),
    "app_icon_url" character varying(255),
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "app_category" character varying(255),
    "developer" character varying(255),
    "release_date" date,
    "required_permissions" jsonb,
    "external_url" character varying(255),
    "app_settings_schema" jsonb,
    "deleted_at" timestamp with time zone
);


alter table "public"."apps" enable row level security;

create table "public"."audit_logs" (
    "audit_id" uuid not null default gen_random_uuid(),
    "table_name" text not null,
    "record_id" uuid not null,
    "operation" text not null,
    "old_values" jsonb,
    "new_values" jsonb,
    "changed_by" uuid,
    "organization_id" uuid,
    "changed_at" timestamp with time zone default now(),
    "ip_address" inet,
    "user_agent" text
);


alter table "public"."audit_logs" enable row level security;

create table "public"."custom_users" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "email" text,
    "full_name" text,
    "last_name" text
);


create table "public"."departments" (
    "department_id" uuid not null default gen_random_uuid(),
    "organization_id" uuid,
    "department_name" text not null,
    "department_description" text,
    "status" character varying(255),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone
);


alter table "public"."departments" enable row level security;

create table "public"."employee_hierarchy" (
    "hierarchy_id" uuid not null default gen_random_uuid(),
    "employee_id" uuid,
    "manager_employee_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."employees" (
    "employee_id" uuid not null default gen_random_uuid(),
    "site_id" uuid,
    "department_id" uuid,
    "organization_id" uuid,
    "role_id" uuid,
    "first_name" text not null,
    "last_name" text,
    "email" text,
    "phone" text,
    "address" text,
    "image_url" character varying(255),
    "linkedin_url" character varying(255),
    "job_title" text,
    "hire_date" date,
    "status" character varying(255),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "gender" character varying(255),
    "date_of_birth" date,
    "deleted_at" timestamp with time zone
);


alter table "public"."employees" enable row level security;

create table "public"."ethnicities" (
    "ethnicity_id" uuid not null default gen_random_uuid(),
    "ethnicity_name" character varying(255) not null,
    "country_code" character varying(3)
);


create table "public"."job_categories" (
    "category_id" uuid not null,
    "category_name" character varying(255),
    "organization_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."job_categories" enable row level security;

create table "public"."job_skills" (
    "job_skill_id" uuid not null,
    "job_id" uuid,
    "skill_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."job_translations" (
    "job_id" uuid not null,
    "language_code" character varying(10) not null,
    "job_title" text not null,
    "job_description" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."job_translations" enable row level security;

create table "public"."jobs" (
    "job_id" uuid not null,
    "site_id" uuid,
    "department_id" uuid,
    "organization_id" uuid,
    "organization_type_id" uuid,
    "job_type" character varying(255),
    "salary_range_min" numeric,
    "salary_range_max" numeric,
    "currency" character varying(3) default 'INR'::character varying,
    "location" character varying(255),
    "city" character varying(255),
    "state" character varying(255),
    "country" character varying(255),
    "postal_code" character varying(255),
    "experience_required" character varying(255),
    "education_required" character varying(255),
    "skills_required" text,
    "posting_date" timestamp without time zone default CURRENT_TIMESTAMP,
    "application_deadline" date,
    "status" character varying(255),
    "job_category" uuid,
    "is_internal" boolean default false,
    "created_by" uuid,
    "approved_by" uuid,
    "approval_date" timestamp without time zone,
    "deleted_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."jobs" enable row level security;

create table "public"."notifications" (
    "notification_id" uuid not null,
    "user_id" uuid,
    "message" text,
    "notification_type" character varying(255),
    "related_id" uuid,
    "is_read" boolean default false,
    "created_at" timestamp without time zone default CURRENT_TIMESTAMP
);


create table "public"."organization_apps" (
    "organization_app_id" uuid not null default gen_random_uuid(),
    "organization_id" uuid,
    "app_id" uuid,
    "organization_plan_id" uuid,
    "installation_date" timestamp with time zone default now(),
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."organization_apps" enable row level security;

create table "public"."organization_organization_types" (
    "organization_organization_type_id" uuid not null default gen_random_uuid(),
    "organization_id" uuid,
    "organization_type_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."organization_plans" (
    "organization_plan_id" uuid not null,
    "organization_id" uuid,
    "plan_id" uuid,
    "start_date" timestamp without time zone not null,
    "end_date" timestamp without time zone not null,
    "payment_status" character varying(255),
    "payment_id" character varying(255),
    "ends_at" timestamp without time zone,
    "free_trail_ends_at" timestamp without time zone,
    "created_at" timestamp without time zone default CURRENT_TIMESTAMP,
    "updated_at" timestamp without time zone default CURRENT_TIMESTAMP,
    "is_active" boolean default true,
    "cancelled_at" timestamp without time zone,
    "renewal_date" timestamp without time zone,
    "payment_method" character varying(255),
    "billing_cycle" character varying(255),
    "quantity" integer,
    "discount_applied" boolean,
    "notes" text,
    "trial_end_notification_sent" boolean default false
);


alter table "public"."organization_plans" enable row level security;

create table "public"."organization_types" (
    "organization_type_id" uuid not null default gen_random_uuid(),
    "type_name" character varying(255) not null,
    "description" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."organizations" (
    "organization_id" uuid not null default gen_random_uuid(),
    "organization_name" text not null,
    "organization_description" text,
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
    "registration_date" timestamp without time zone default CURRENT_TIMESTAMP,
    "account_status" character varying(255),
    "description" text,
    "website_url" character varying(255),
    "google_place_id" character varying(255),
    "google_maps_url" character varying(255),
    "google_business_category" character varying(255),
    "created_by" uuid,
    "secondary_owner" uuid,
    "primary_owner" uuid,
    "active" boolean not null default true,
    "deleted_at" timestamp with time zone
);


alter table "public"."organizations" enable row level security;

create table "public"."plan_apps" (
    "plan_app_id" uuid not null default gen_random_uuid(),
    "plan_id" uuid,
    "app_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."plans" (
    "plan_id" uuid not null default gen_random_uuid(),
    "plan_name" character varying(255) not null,
    "description" text,
    "price" numeric(10,2) not null,
    "currency" character varying(3) default 'USD'::character varying,
    "is_free_trial_avail" boolean default false,
    "free_trail_period" interval,
    "duration_days" integer,
    "features" jsonb,
    "is_active" boolean default true,
    "created_at" timestamp without time zone default CURRENT_TIMESTAMP,
    "updated_at" timestamp without time zone default CURRENT_TIMESTAMP,
    "deleted_at" timestamp with time zone
);


alter table "public"."plans" enable row level security;

create table "public"."role_permissions" (
    "role_permission_id" uuid not null default gen_random_uuid(),
    "role_id" uuid not null,
    "organization_id" uuid not null,
    "permission_name" character varying not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."role_permissions" enable row level security;

create table "public"."roles" (
    "role_id" uuid not null default gen_random_uuid(),
    "organization_id" uuid,
    "role_name" text not null,
    "role_description" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone
);


alter table "public"."roles" enable row level security;

create table "public"."saved_jobs" (
    "saved_job_id" uuid not null,
    "user_id" uuid,
    "job_id" uuid,
    "saved_date" timestamp without time zone default CURRENT_TIMESTAMP,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."saved_jobs" enable row level security;

create table "public"."sites" (
    "site_id" uuid not null default gen_random_uuid(),
    "organization_id" uuid,
    "site_name" text not null,
    "site_description" text,
    "address" text,
    "contact_person" text,
    "contact_email" text,
    "contact_phone" text,
    "google_location" text,
    "google_business_information" text,
    "status" character varying(255),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone
);


alter table "public"."sites" enable row level security;

create table "public"."skills" (
    "skill_id" uuid not null default gen_random_uuid(),
    "skill_name" character varying(255)
);


alter table "public"."skills" enable row level security;

create table "public"."super_admins" (
    "super_admin_id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "first_name" character varying(255) not null,
    "last_name" character varying(255),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "created_by" uuid
);


create table "public"."user_education" (
    "education_id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "institution_name" character varying(255),
    "degree" character varying(255),
    "field_of_study" character varying(255),
    "start_date" date,
    "end_date" date,
    "description" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."user_education" enable row level security;

create table "public"."user_ethnicities" (
    "user_ethnicity_id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "ethnicity_id" uuid
);


create table "public"."user_job_history" (
    "job_history_id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "company_name" character varying(255),
    "job_title" character varying(255),
    "start_date" date,
    "end_date" date,
    "description" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."user_job_history" enable row level security;

create table "public"."user_languages" (
    "language_id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "language_name" character varying(255),
    "proficiency" character varying(255),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."user_languages" enable row level security;

create table "public"."user_skills" (
    "user_skill_id" uuid not null,
    "user_id" uuid,
    "skill_id" uuid
);


alter table "public"."user_skills" enable row level security;

create table "public"."users" (
    "user_id" uuid not null default gen_random_uuid(),
    "first_name" character varying(255) not null,
    "last_name" character varying(255),
    "gender" character varying(255),
    "email" character varying(255),
    "date_of_birth" date,
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
    "last_sign_in_at" date,
    "current_job_org" character varying(255),
    "active_status" boolean default true,
    "registration_date" timestamp with time zone default (now() AT TIME ZONE 'utc'::text),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "deleted_at" timestamp with time zone
);


alter table "public"."users" enable row level security;

CREATE UNIQUE INDEX apps_pkey ON public.apps USING btree (app_id);

CREATE UNIQUE INDEX audit_logs_pkey ON public.audit_logs USING btree (audit_id);

CREATE UNIQUE INDEX custom_users_pkey ON public.custom_users USING btree (id);

CREATE UNIQUE INDEX departments_pkey ON public.departments USING btree (department_id);

CREATE UNIQUE INDEX employee_hierarchy_pkey ON public.employee_hierarchy USING btree (hierarchy_id);

CREATE UNIQUE INDEX employees_email_key ON public.employees USING btree (email);

CREATE UNIQUE INDEX employees_pkey ON public.employees USING btree (employee_id);

CREATE UNIQUE INDEX ethnicities_pkey ON public.ethnicities USING btree (ethnicity_id);

CREATE INDEX idx_audit_logs_changed_at ON public.audit_logs USING btree (changed_at);

CREATE INDEX idx_audit_logs_changed_by ON public.audit_logs USING btree (changed_by);

CREATE INDEX idx_audit_logs_organization ON public.audit_logs USING btree (organization_id);

CREATE INDEX idx_audit_logs_table_record ON public.audit_logs USING btree (table_name, record_id);

CREATE INDEX idx_departments_organization ON public.departments USING btree (organization_id) WHERE (deleted_at IS NULL);

CREATE INDEX idx_employees_organization ON public.employees USING btree (organization_id) WHERE (deleted_at IS NULL);

CREATE INDEX idx_employees_role ON public.employees USING btree (role_id) WHERE (deleted_at IS NULL);

CREATE INDEX idx_employees_status ON public.employees USING btree (status) WHERE (deleted_at IS NULL);

CREATE INDEX idx_employees_user_id ON public.employees USING btree (employee_id);

CREATE INDEX idx_jobs_created_by ON public.jobs USING btree (created_by) WHERE (deleted_at IS NULL);

CREATE INDEX idx_jobs_location ON public.jobs USING btree (city, state, country) WHERE (deleted_at IS NULL);

CREATE INDEX idx_jobs_organization ON public.jobs USING btree (organization_id) WHERE (deleted_at IS NULL);

CREATE INDEX idx_jobs_posting_date ON public.jobs USING btree (posting_date) WHERE (deleted_at IS NULL);

CREATE INDEX idx_jobs_status ON public.jobs USING btree (status) WHERE (deleted_at IS NULL);

CREATE INDEX idx_organization_apps_org_active ON public.organization_apps USING btree (organization_id, is_active);

CREATE INDEX idx_organizations_active ON public.organizations USING btree (active) WHERE (deleted_at IS NULL);

CREATE INDEX idx_organizations_created_by ON public.organizations USING btree (created_by) WHERE (deleted_at IS NULL);

CREATE INDEX idx_organizations_primary_owner ON public.organizations USING btree (primary_owner) WHERE (deleted_at IS NULL);

CREATE INDEX idx_role_permissions_permission ON public.role_permissions USING btree (permission_name, organization_id);

CREATE INDEX idx_role_permissions_role_org ON public.role_permissions USING btree (role_id, organization_id);

CREATE INDEX idx_roles_organization ON public.roles USING btree (organization_id) WHERE (deleted_at IS NULL);

CREATE INDEX idx_saved_jobs_job ON public.saved_jobs USING btree (job_id);

CREATE INDEX idx_saved_jobs_user ON public.saved_jobs USING btree (user_id);

CREATE INDEX idx_sites_organization ON public.sites USING btree (organization_id) WHERE (deleted_at IS NULL);

CREATE INDEX idx_users_active ON public.users USING btree (active_status) WHERE (deleted_at IS NULL);

CREATE INDEX idx_users_email ON public.users USING btree (email) WHERE (deleted_at IS NULL);

CREATE INDEX idx_users_user_id ON public.users USING btree (user_id);

CREATE UNIQUE INDEX job_categories_pkey ON public.job_categories USING btree (category_id);

CREATE UNIQUE INDEX job_skills_pkey ON public.job_skills USING btree (job_skill_id);

CREATE UNIQUE INDEX job_translations_pkey ON public.job_translations USING btree (job_id, language_code);

CREATE UNIQUE INDEX jobs_pkey ON public.jobs USING btree (job_id);

CREATE UNIQUE INDEX notifications_pkey ON public.notifications USING btree (notification_id);

CREATE UNIQUE INDEX organization_apps_organization_id_app_id_key ON public.organization_apps USING btree (organization_id, app_id);

CREATE UNIQUE INDEX organization_apps_pkey ON public.organization_apps USING btree (organization_app_id);

CREATE UNIQUE INDEX organization_organization_typ_organization_id_organization__key ON public.organization_organization_types USING btree (organization_id, organization_type_id);

CREATE UNIQUE INDEX organization_organization_types_pkey ON public.organization_organization_types USING btree (organization_organization_type_id);

CREATE UNIQUE INDEX organization_plans_organization_id_plan_id_key ON public.organization_plans USING btree (organization_id, plan_id);

CREATE UNIQUE INDEX organization_plans_pkey ON public.organization_plans USING btree (organization_plan_id);

CREATE UNIQUE INDEX organization_types_pkey ON public.organization_types USING btree (organization_type_id);

CREATE UNIQUE INDEX organization_types_type_name_key ON public.organization_types USING btree (type_name);

CREATE UNIQUE INDEX organizations_pkey ON public.organizations USING btree (organization_id);

CREATE UNIQUE INDEX plan_apps_pkey ON public.plan_apps USING btree (plan_app_id);

CREATE UNIQUE INDEX plan_apps_plan_id_app_id_key ON public.plan_apps USING btree (plan_id, app_id);

CREATE UNIQUE INDEX plans_pkey ON public.plans USING btree (plan_id);

CREATE UNIQUE INDEX role_permissions_pkey ON public.role_permissions USING btree (role_permission_id);

CREATE UNIQUE INDEX role_permissions_role_id_organization_id_permission_name_key ON public.role_permissions USING btree (role_id, organization_id, permission_name);

CREATE UNIQUE INDEX roles_pkey ON public.roles USING btree (role_id);

CREATE UNIQUE INDEX roles_role_name_key ON public.roles USING btree (role_name);

CREATE UNIQUE INDEX saved_jobs_pkey ON public.saved_jobs USING btree (saved_job_id);

CREATE UNIQUE INDEX sites_pkey ON public.sites USING btree (site_id);

CREATE UNIQUE INDEX skills_pkey ON public.skills USING btree (skill_id);

CREATE UNIQUE INDEX skills_skill_name_key ON public.skills USING btree (skill_name);

CREATE UNIQUE INDEX super_admins_pkey ON public.super_admins USING btree (super_admin_id);

CREATE UNIQUE INDEX unique_job_skill ON public.job_skills USING btree (job_id, skill_id);

CREATE UNIQUE INDEX unique_organization_app ON public.organization_apps USING btree (organization_id, app_id);

CREATE UNIQUE INDEX unique_plan_app ON public.plan_apps USING btree (plan_id, app_id);

CREATE UNIQUE INDEX unique_role_permission ON public.role_permissions USING btree (role_id, organization_id, permission_name);

CREATE UNIQUE INDEX unique_saved_job ON public.saved_jobs USING btree (user_id, job_id);

CREATE UNIQUE INDEX unique_user_skill ON public.user_skills USING btree (user_id, skill_id);

CREATE UNIQUE INDEX user_education_pkey ON public.user_education USING btree (education_id);

CREATE UNIQUE INDEX user_ethnicities_pkey ON public.user_ethnicities USING btree (user_ethnicity_id);

CREATE UNIQUE INDEX user_ethnicities_user_id_ethnicity_id_key ON public.user_ethnicities USING btree (user_id, ethnicity_id);

CREATE UNIQUE INDEX user_job_history_pkey ON public.user_job_history USING btree (job_history_id);

CREATE UNIQUE INDEX user_languages_pkey ON public.user_languages USING btree (language_id);

CREATE UNIQUE INDEX user_skills_pkey ON public.user_skills USING btree (user_skill_id);

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);

CREATE UNIQUE INDEX users_pkey ON public.users USING btree (user_id);

alter table "public"."apps" add constraint "apps_pkey" PRIMARY KEY using index "apps_pkey";

alter table "public"."audit_logs" add constraint "audit_logs_pkey" PRIMARY KEY using index "audit_logs_pkey";

alter table "public"."custom_users" add constraint "custom_users_pkey" PRIMARY KEY using index "custom_users_pkey";

alter table "public"."departments" add constraint "departments_pkey" PRIMARY KEY using index "departments_pkey";

alter table "public"."employee_hierarchy" add constraint "employee_hierarchy_pkey" PRIMARY KEY using index "employee_hierarchy_pkey";

alter table "public"."employees" add constraint "employees_pkey" PRIMARY KEY using index "employees_pkey";

alter table "public"."ethnicities" add constraint "ethnicities_pkey" PRIMARY KEY using index "ethnicities_pkey";

alter table "public"."job_categories" add constraint "job_categories_pkey" PRIMARY KEY using index "job_categories_pkey";

alter table "public"."job_skills" add constraint "job_skills_pkey" PRIMARY KEY using index "job_skills_pkey";

alter table "public"."job_translations" add constraint "job_translations_pkey" PRIMARY KEY using index "job_translations_pkey";

alter table "public"."jobs" add constraint "jobs_pkey" PRIMARY KEY using index "jobs_pkey";

alter table "public"."notifications" add constraint "notifications_pkey" PRIMARY KEY using index "notifications_pkey";

alter table "public"."organization_apps" add constraint "organization_apps_pkey" PRIMARY KEY using index "organization_apps_pkey";

alter table "public"."organization_organization_types" add constraint "organization_organization_types_pkey" PRIMARY KEY using index "organization_organization_types_pkey";

alter table "public"."organization_plans" add constraint "organization_plans_pkey" PRIMARY KEY using index "organization_plans_pkey";

alter table "public"."organization_types" add constraint "organization_types_pkey" PRIMARY KEY using index "organization_types_pkey";

alter table "public"."organizations" add constraint "organizations_pkey" PRIMARY KEY using index "organizations_pkey";

alter table "public"."plan_apps" add constraint "plan_apps_pkey" PRIMARY KEY using index "plan_apps_pkey";

alter table "public"."plans" add constraint "plans_pkey" PRIMARY KEY using index "plans_pkey";

alter table "public"."role_permissions" add constraint "role_permissions_pkey" PRIMARY KEY using index "role_permissions_pkey";

alter table "public"."roles" add constraint "roles_pkey" PRIMARY KEY using index "roles_pkey";

alter table "public"."saved_jobs" add constraint "saved_jobs_pkey" PRIMARY KEY using index "saved_jobs_pkey";

alter table "public"."sites" add constraint "sites_pkey" PRIMARY KEY using index "sites_pkey";

alter table "public"."skills" add constraint "skills_pkey" PRIMARY KEY using index "skills_pkey";

alter table "public"."super_admins" add constraint "super_admins_pkey" PRIMARY KEY using index "super_admins_pkey";

alter table "public"."user_education" add constraint "user_education_pkey" PRIMARY KEY using index "user_education_pkey";

alter table "public"."user_ethnicities" add constraint "user_ethnicities_pkey" PRIMARY KEY using index "user_ethnicities_pkey";

alter table "public"."user_job_history" add constraint "user_job_history_pkey" PRIMARY KEY using index "user_job_history_pkey";

alter table "public"."user_languages" add constraint "user_languages_pkey" PRIMARY KEY using index "user_languages_pkey";

alter table "public"."user_skills" add constraint "user_skills_pkey" PRIMARY KEY using index "user_skills_pkey";

alter table "public"."users" add constraint "users_pkey" PRIMARY KEY using index "users_pkey";

alter table "public"."audit_logs" add constraint "audit_logs_operation_check" CHECK ((operation = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text]))) not valid;

alter table "public"."audit_logs" validate constraint "audit_logs_operation_check";

alter table "public"."departments" add constraint "departments_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) not valid;

alter table "public"."departments" validate constraint "departments_organization_id_fkey";

alter table "public"."departments" add constraint "departments_status_check" CHECK (((status)::text = ANY (ARRAY[('active'::character varying)::text, ('inactive'::character varying)::text, ('suspended'::character varying)::text]))) not valid;

alter table "public"."departments" validate constraint "departments_status_check";

alter table "public"."departments" add constraint "fk_departments_organization" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) ON DELETE CASCADE not valid;

alter table "public"."departments" validate constraint "fk_departments_organization";

alter table "public"."employee_hierarchy" add constraint "employee_hierarchy_employee_id_fkey" FOREIGN KEY (employee_id) REFERENCES employees(employee_id) not valid;

alter table "public"."employee_hierarchy" validate constraint "employee_hierarchy_employee_id_fkey";

alter table "public"."employee_hierarchy" add constraint "employee_hierarchy_manager_employee_id_fkey" FOREIGN KEY (manager_employee_id) REFERENCES employees(employee_id) not valid;

alter table "public"."employee_hierarchy" validate constraint "employee_hierarchy_manager_employee_id_fkey";

alter table "public"."employee_hierarchy" add constraint "fk_employee_hierarchy_employee" FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE not valid;

alter table "public"."employee_hierarchy" validate constraint "fk_employee_hierarchy_employee";

alter table "public"."employee_hierarchy" add constraint "fk_employee_hierarchy_manager" FOREIGN KEY (manager_employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE not valid;

alter table "public"."employee_hierarchy" validate constraint "fk_employee_hierarchy_manager";

alter table "public"."employees" add constraint "employees_department_id_fkey" FOREIGN KEY (department_id) REFERENCES departments(department_id) not valid;

alter table "public"."employees" validate constraint "employees_department_id_fkey";

alter table "public"."employees" add constraint "employees_email_key" UNIQUE using index "employees_email_key";

alter table "public"."employees" add constraint "employees_gender_check" CHECK (((gender)::text = ANY (ARRAY[('male'::character varying)::text, ('female'::character varying)::text, ('other'::character varying)::text, ('prefer not to say'::character varying)::text]))) not valid;

alter table "public"."employees" validate constraint "employees_gender_check";

alter table "public"."employees" add constraint "employees_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) not valid;

alter table "public"."employees" validate constraint "employees_organization_id_fkey";

alter table "public"."employees" add constraint "employees_role_id_fkey" FOREIGN KEY (role_id) REFERENCES roles(role_id) not valid;

alter table "public"."employees" validate constraint "employees_role_id_fkey";

alter table "public"."employees" add constraint "employees_site_id_fkey" FOREIGN KEY (site_id) REFERENCES sites(site_id) not valid;

alter table "public"."employees" validate constraint "employees_site_id_fkey";

alter table "public"."employees" add constraint "employees_status_check" CHECK (((status)::text = ANY (ARRAY[('active'::character varying)::text, ('pendingStart'::character varying)::text, ('suspended'::character varying)::text, ('onNotice'::character varying)::text, ('resigned'::character varying)::text, ('terminated'::character varying)::text, ('dismissed'::character varying)::text, ('noShow'::character varying)::text, ('onLeave'::character varying)::text, ('retired'::character varying)::text]))) not valid;

alter table "public"."employees" validate constraint "employees_status_check";

alter table "public"."employees" add constraint "fk_employee_user" FOREIGN KEY (employee_id) REFERENCES users(user_id) ON DELETE CASCADE not valid;

alter table "public"."employees" validate constraint "fk_employee_user";

alter table "public"."employees" add constraint "fk_employees_department" FOREIGN KEY (department_id) REFERENCES departments(department_id) not valid;

alter table "public"."employees" validate constraint "fk_employees_department";

alter table "public"."employees" add constraint "fk_employees_organization" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) not valid;

alter table "public"."employees" validate constraint "fk_employees_organization";

alter table "public"."employees" add constraint "fk_employees_role" FOREIGN KEY (role_id) REFERENCES roles(role_id) not valid;

alter table "public"."employees" validate constraint "fk_employees_role";

alter table "public"."employees" add constraint "fk_employees_site" FOREIGN KEY (site_id) REFERENCES sites(site_id) not valid;

alter table "public"."employees" validate constraint "fk_employees_site";

alter table "public"."job_categories" add constraint "fk_job_categories_organization" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) ON DELETE CASCADE not valid;

alter table "public"."job_categories" validate constraint "fk_job_categories_organization";

alter table "public"."job_categories" add constraint "job_categories_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) not valid;

alter table "public"."job_categories" validate constraint "job_categories_organization_id_fkey";

alter table "public"."job_skills" add constraint "fk_job_skills_job" FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE not valid;

alter table "public"."job_skills" validate constraint "fk_job_skills_job";

alter table "public"."job_skills" add constraint "fk_job_skills_skill" FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE not valid;

alter table "public"."job_skills" validate constraint "fk_job_skills_skill";

alter table "public"."job_skills" add constraint "job_skills_job_id_fkey" FOREIGN KEY (job_id) REFERENCES jobs(job_id) not valid;

alter table "public"."job_skills" validate constraint "job_skills_job_id_fkey";

alter table "public"."job_skills" add constraint "job_skills_skill_id_fkey" FOREIGN KEY (skill_id) REFERENCES skills(skill_id) not valid;

alter table "public"."job_skills" validate constraint "job_skills_skill_id_fkey";

alter table "public"."job_skills" add constraint "unique_job_skill" UNIQUE using index "unique_job_skill";

alter table "public"."job_translations" add constraint "job_translations_job_id_fkey" FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE not valid;

alter table "public"."job_translations" validate constraint "job_translations_job_id_fkey";

alter table "public"."jobs" add constraint "check_application_deadline" CHECK (((application_deadline IS NULL) OR (application_deadline >= (posting_date)::date))) not valid;

alter table "public"."jobs" validate constraint "check_application_deadline";

alter table "public"."jobs" add constraint "check_salary_range" CHECK (((salary_range_min IS NULL) OR (salary_range_max IS NULL) OR (salary_range_min <= salary_range_max))) not valid;

alter table "public"."jobs" validate constraint "check_salary_range";

alter table "public"."jobs" add constraint "fk_jobs_approved_by" FOREIGN KEY (approved_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."jobs" validate constraint "fk_jobs_approved_by";

alter table "public"."jobs" add constraint "fk_jobs_category" FOREIGN KEY (job_category) REFERENCES job_categories(category_id) ON DELETE SET NULL not valid;

alter table "public"."jobs" validate constraint "fk_jobs_category";

alter table "public"."jobs" add constraint "fk_jobs_created_by" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."jobs" validate constraint "fk_jobs_created_by";

alter table "public"."jobs" add constraint "fk_jobs_department" FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL not valid;

alter table "public"."jobs" validate constraint "fk_jobs_department";

alter table "public"."jobs" add constraint "fk_jobs_organization" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) ON DELETE CASCADE not valid;

alter table "public"."jobs" validate constraint "fk_jobs_organization";

alter table "public"."jobs" add constraint "fk_jobs_site" FOREIGN KEY (site_id) REFERENCES sites(site_id) ON DELETE SET NULL not valid;

alter table "public"."jobs" validate constraint "fk_jobs_site";

alter table "public"."jobs" add constraint "jobs_approved_by_fkey" FOREIGN KEY (approved_by) REFERENCES users(user_id) not valid;

alter table "public"."jobs" validate constraint "jobs_approved_by_fkey";

alter table "public"."jobs" add constraint "jobs_created_by_fkey" FOREIGN KEY (created_by) REFERENCES users(user_id) not valid;

alter table "public"."jobs" validate constraint "jobs_created_by_fkey";

alter table "public"."jobs" add constraint "jobs_department_id_fkey" FOREIGN KEY (department_id) REFERENCES departments(department_id) not valid;

alter table "public"."jobs" validate constraint "jobs_department_id_fkey";

alter table "public"."jobs" add constraint "jobs_job_category_fkey" FOREIGN KEY (job_category) REFERENCES job_categories(category_id) not valid;

alter table "public"."jobs" validate constraint "jobs_job_category_fkey";

alter table "public"."jobs" add constraint "jobs_job_type_check" CHECK (((job_type)::text = ANY (ARRAY[('full-time'::character varying)::text, ('part-time'::character varying)::text, ('contract'::character varying)::text, ('internship'::character varying)::text, ('temporary'::character varying)::text]))) not valid;

alter table "public"."jobs" validate constraint "jobs_job_type_check";

alter table "public"."jobs" add constraint "jobs_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) not valid;

alter table "public"."jobs" validate constraint "jobs_organization_id_fkey";

alter table "public"."jobs" add constraint "jobs_organization_type_id_fkey" FOREIGN KEY (organization_type_id) REFERENCES organization_types(organization_type_id) not valid;

alter table "public"."jobs" validate constraint "jobs_organization_type_id_fkey";

alter table "public"."jobs" add constraint "jobs_site_id_fkey" FOREIGN KEY (site_id) REFERENCES sites(site_id) not valid;

alter table "public"."jobs" validate constraint "jobs_site_id_fkey";

alter table "public"."jobs" add constraint "jobs_status_check" CHECK (((status)::text = ANY (ARRAY[('open'::character varying)::text, ('closed'::character varying)::text, ('filled'::character varying)::text, ('draft'::character varying)::text]))) not valid;

alter table "public"."jobs" validate constraint "jobs_status_check";

alter table "public"."notifications" add constraint "fk_notifications_user" FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE not valid;

alter table "public"."notifications" validate constraint "fk_notifications_user";

alter table "public"."notifications" add constraint "notifications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(user_id) not valid;

alter table "public"."notifications" validate constraint "notifications_user_id_fkey";

alter table "public"."organization_apps" add constraint "fk_org_apps_app" FOREIGN KEY (app_id) REFERENCES apps(app_id) not valid;

alter table "public"."organization_apps" validate constraint "fk_org_apps_app";

alter table "public"."organization_apps" add constraint "fk_org_apps_organization" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) not valid;

alter table "public"."organization_apps" validate constraint "fk_org_apps_organization";

alter table "public"."organization_apps" add constraint "fk_org_apps_plan" FOREIGN KEY (organization_plan_id) REFERENCES organization_plans(organization_plan_id) not valid;

alter table "public"."organization_apps" validate constraint "fk_org_apps_plan";

alter table "public"."organization_apps" add constraint "fk_organization_apps_app" FOREIGN KEY (app_id) REFERENCES apps(app_id) ON DELETE CASCADE not valid;

alter table "public"."organization_apps" validate constraint "fk_organization_apps_app";

alter table "public"."organization_apps" add constraint "fk_organization_apps_organization" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) ON DELETE CASCADE not valid;

alter table "public"."organization_apps" validate constraint "fk_organization_apps_organization";

alter table "public"."organization_apps" add constraint "fk_organization_apps_plan" FOREIGN KEY (organization_plan_id) REFERENCES organization_plans(organization_plan_id) ON DELETE SET NULL not valid;

alter table "public"."organization_apps" validate constraint "fk_organization_apps_plan";

alter table "public"."organization_apps" add constraint "organization_apps_app_id_fkey" FOREIGN KEY (app_id) REFERENCES apps(app_id) not valid;

alter table "public"."organization_apps" validate constraint "organization_apps_app_id_fkey";

alter table "public"."organization_apps" add constraint "organization_apps_organization_id_app_id_key" UNIQUE using index "organization_apps_organization_id_app_id_key";

alter table "public"."organization_apps" add constraint "organization_apps_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) not valid;

alter table "public"."organization_apps" validate constraint "organization_apps_organization_id_fkey";

alter table "public"."organization_apps" add constraint "organization_apps_organization_plan_id_fkey" FOREIGN KEY (organization_plan_id) REFERENCES organization_plans(organization_plan_id) not valid;

alter table "public"."organization_apps" validate constraint "organization_apps_organization_plan_id_fkey";

alter table "public"."organization_apps" add constraint "unique_organization_app" UNIQUE using index "unique_organization_app";

alter table "public"."organization_organization_types" add constraint "fk_org_org_types_organization" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) ON DELETE CASCADE not valid;

alter table "public"."organization_organization_types" validate constraint "fk_org_org_types_organization";

alter table "public"."organization_organization_types" add constraint "fk_org_org_types_type" FOREIGN KEY (organization_type_id) REFERENCES organization_types(organization_type_id) ON DELETE CASCADE not valid;

alter table "public"."organization_organization_types" validate constraint "fk_org_org_types_type";

alter table "public"."organization_organization_types" add constraint "organization_organization_typ_organization_id_organization__key" UNIQUE using index "organization_organization_typ_organization_id_organization__key";

alter table "public"."organization_organization_types" add constraint "organization_organization_types_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) not valid;

alter table "public"."organization_organization_types" validate constraint "organization_organization_types_organization_id_fkey";

alter table "public"."organization_organization_types" add constraint "organization_organization_types_organization_type_id_fkey" FOREIGN KEY (organization_type_id) REFERENCES organization_types(organization_type_id) not valid;

alter table "public"."organization_organization_types" validate constraint "organization_organization_types_organization_type_id_fkey";

alter table "public"."organization_plans" add constraint "check_organization_plan_dates" CHECK ((start_date <= end_date)) not valid;

alter table "public"."organization_plans" validate constraint "check_organization_plan_dates";

alter table "public"."organization_plans" add constraint "fk_org_plans_organization" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) not valid;

alter table "public"."organization_plans" validate constraint "fk_org_plans_organization";

alter table "public"."organization_plans" add constraint "fk_org_plans_plan" FOREIGN KEY (plan_id) REFERENCES plans(plan_id) not valid;

alter table "public"."organization_plans" validate constraint "fk_org_plans_plan";

alter table "public"."organization_plans" add constraint "fk_organization_plans_organization" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) ON DELETE CASCADE not valid;

alter table "public"."organization_plans" validate constraint "fk_organization_plans_organization";

alter table "public"."organization_plans" add constraint "fk_organization_plans_plan" FOREIGN KEY (plan_id) REFERENCES plans(plan_id) ON DELETE RESTRICT not valid;

alter table "public"."organization_plans" validate constraint "fk_organization_plans_plan";

alter table "public"."organization_plans" add constraint "organization_plans_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) not valid;

alter table "public"."organization_plans" validate constraint "organization_plans_organization_id_fkey";

alter table "public"."organization_plans" add constraint "organization_plans_organization_id_plan_id_key" UNIQUE using index "organization_plans_organization_id_plan_id_key";

alter table "public"."organization_plans" add constraint "organization_plans_payment_status_check" CHECK (((payment_status)::text = ANY (ARRAY[('pending'::character varying)::text, ('paid'::character varying)::text, ('failed'::character varying)::text, ('refunded'::character varying)::text, ('freetrail'::character varying)::text]))) not valid;

alter table "public"."organization_plans" validate constraint "organization_plans_payment_status_check";

alter table "public"."organization_plans" add constraint "organization_plans_plan_id_fkey" FOREIGN KEY (plan_id) REFERENCES plans(plan_id) not valid;

alter table "public"."organization_plans" validate constraint "organization_plans_plan_id_fkey";

alter table "public"."organization_types" add constraint "organization_types_type_name_key" UNIQUE using index "organization_types_type_name_key";

alter table "public"."organizations" add constraint "fk_organizations_created_by" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."organizations" validate constraint "fk_organizations_created_by";

alter table "public"."organizations" add constraint "fk_organizations_primary_owner" FOREIGN KEY (primary_owner) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."organizations" validate constraint "fk_organizations_primary_owner";

alter table "public"."organizations" add constraint "fk_organizations_secondary_owner" FOREIGN KEY (secondary_owner) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."organizations" validate constraint "fk_organizations_secondary_owner";

alter table "public"."organizations" add constraint "fk_primary_owner_user" FOREIGN KEY (primary_owner) REFERENCES users(user_id) ON DELETE SET NULL not valid;

alter table "public"."organizations" validate constraint "fk_primary_owner_user";

alter table "public"."organizations" add constraint "fk_secondary_owner_user" FOREIGN KEY (secondary_owner) REFERENCES users(user_id) ON DELETE SET NULL not valid;

alter table "public"."organizations" validate constraint "fk_secondary_owner_user";

alter table "public"."organizations" add constraint "organizations_account_status_check" CHECK (((account_status)::text = ANY (ARRAY[('active'::character varying)::text, ('inactive'::character varying)::text, ('suspended'::character varying)::text]))) not valid;

alter table "public"."organizations" validate constraint "organizations_account_status_check";

alter table "public"."organizations" add constraint "organizations_created_by_fkey" FOREIGN KEY (created_by) REFERENCES users(user_id) not valid;

alter table "public"."organizations" validate constraint "organizations_created_by_fkey";

alter table "public"."organizations" add constraint "organizations_primary_owner_fkey" FOREIGN KEY (primary_owner) REFERENCES users(user_id) not valid;

alter table "public"."organizations" validate constraint "organizations_primary_owner_fkey";

alter table "public"."organizations" add constraint "organizations_secondary_owner_fkey" FOREIGN KEY (secondary_owner) REFERENCES users(user_id) not valid;

alter table "public"."organizations" validate constraint "organizations_secondary_owner_fkey";

alter table "public"."plan_apps" add constraint "fk_plan_apps_app" FOREIGN KEY (app_id) REFERENCES apps(app_id) ON DELETE CASCADE not valid;

alter table "public"."plan_apps" validate constraint "fk_plan_apps_app";

alter table "public"."plan_apps" add constraint "fk_plan_apps_plan" FOREIGN KEY (plan_id) REFERENCES plans(plan_id) ON DELETE CASCADE not valid;

alter table "public"."plan_apps" validate constraint "fk_plan_apps_plan";

alter table "public"."plan_apps" add constraint "plan_apps_app_id_fkey" FOREIGN KEY (app_id) REFERENCES apps(app_id) not valid;

alter table "public"."plan_apps" validate constraint "plan_apps_app_id_fkey";

alter table "public"."plan_apps" add constraint "plan_apps_plan_id_app_id_key" UNIQUE using index "plan_apps_plan_id_app_id_key";

alter table "public"."plan_apps" add constraint "plan_apps_plan_id_fkey" FOREIGN KEY (plan_id) REFERENCES plans(plan_id) not valid;

alter table "public"."plan_apps" validate constraint "plan_apps_plan_id_fkey";

alter table "public"."plan_apps" add constraint "unique_plan_app" UNIQUE using index "unique_plan_app";

alter table "public"."role_permissions" add constraint "fk_role_permissions_organization" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) ON DELETE CASCADE not valid;

alter table "public"."role_permissions" validate constraint "fk_role_permissions_organization";

alter table "public"."role_permissions" add constraint "fk_role_permissions_role" FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE not valid;

alter table "public"."role_permissions" validate constraint "fk_role_permissions_role";

alter table "public"."role_permissions" add constraint "role_permissions_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) not valid;

alter table "public"."role_permissions" validate constraint "role_permissions_organization_id_fkey";

alter table "public"."role_permissions" add constraint "role_permissions_role_id_fkey" FOREIGN KEY (role_id) REFERENCES roles(role_id) not valid;

alter table "public"."role_permissions" validate constraint "role_permissions_role_id_fkey";

alter table "public"."role_permissions" add constraint "role_permissions_role_id_organization_id_permission_name_key" UNIQUE using index "role_permissions_role_id_organization_id_permission_name_key";

alter table "public"."role_permissions" add constraint "unique_role_permission" UNIQUE using index "unique_role_permission";

alter table "public"."roles" add constraint "fk_roles_organization" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) ON DELETE CASCADE not valid;

alter table "public"."roles" validate constraint "fk_roles_organization";

alter table "public"."roles" add constraint "roles_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) not valid;

alter table "public"."roles" validate constraint "roles_organization_id_fkey";

alter table "public"."roles" add constraint "roles_role_name_key" UNIQUE using index "roles_role_name_key";

alter table "public"."saved_jobs" add constraint "fk_saved_jobs_job" FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE not valid;

alter table "public"."saved_jobs" validate constraint "fk_saved_jobs_job";

alter table "public"."saved_jobs" add constraint "fk_saved_jobs_user" FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE not valid;

alter table "public"."saved_jobs" validate constraint "fk_saved_jobs_user";

alter table "public"."saved_jobs" add constraint "saved_jobs_job_id_fkey" FOREIGN KEY (job_id) REFERENCES jobs(job_id) not valid;

alter table "public"."saved_jobs" validate constraint "saved_jobs_job_id_fkey";

alter table "public"."saved_jobs" add constraint "saved_jobs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(user_id) not valid;

alter table "public"."saved_jobs" validate constraint "saved_jobs_user_id_fkey";

alter table "public"."saved_jobs" add constraint "unique_saved_job" UNIQUE using index "unique_saved_job";

alter table "public"."sites" add constraint "fk_sites_organization" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) ON DELETE CASCADE not valid;

alter table "public"."sites" validate constraint "fk_sites_organization";

alter table "public"."sites" add constraint "sites_organization_id_fkey" FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) not valid;

alter table "public"."sites" validate constraint "sites_organization_id_fkey";

alter table "public"."sites" add constraint "sites_status_check" CHECK (((status)::text = ANY (ARRAY[('active'::character varying)::text, ('inactive'::character varying)::text, ('suspended'::character varying)::text]))) not valid;

alter table "public"."sites" validate constraint "sites_status_check";

alter table "public"."skills" add constraint "skills_skill_name_key" UNIQUE using index "skills_skill_name_key";

alter table "public"."super_admins" add constraint "fk_super_admins_created_by" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."super_admins" validate constraint "fk_super_admins_created_by";

alter table "public"."super_admins" add constraint "fk_super_admins_user" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."super_admins" validate constraint "fk_super_admins_user";

alter table "public"."super_admins" add constraint "super_admins_created_by_fkey" FOREIGN KEY (created_by) REFERENCES users(user_id) not valid;

alter table "public"."super_admins" validate constraint "super_admins_created_by_fkey";

alter table "public"."super_admins" add constraint "super_admins_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(user_id) not valid;

alter table "public"."super_admins" validate constraint "super_admins_user_id_fkey";

alter table "public"."user_education" add constraint "check_education_dates" CHECK (((start_date IS NULL) OR (end_date IS NULL) OR (start_date <= end_date))) not valid;

alter table "public"."user_education" validate constraint "check_education_dates";

alter table "public"."user_education" add constraint "fk_user_education_user" FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE not valid;

alter table "public"."user_education" validate constraint "fk_user_education_user";

alter table "public"."user_education" add constraint "user_education_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(user_id) not valid;

alter table "public"."user_education" validate constraint "user_education_user_id_fkey";

alter table "public"."user_ethnicities" add constraint "fk_user_ethnicities_ethnicity" FOREIGN KEY (ethnicity_id) REFERENCES ethnicities(ethnicity_id) ON DELETE CASCADE not valid;

alter table "public"."user_ethnicities" validate constraint "fk_user_ethnicities_ethnicity";

alter table "public"."user_ethnicities" add constraint "fk_user_ethnicities_user" FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE not valid;

alter table "public"."user_ethnicities" validate constraint "fk_user_ethnicities_user";

alter table "public"."user_ethnicities" add constraint "user_ethnicities_ethnicity_id_fkey" FOREIGN KEY (ethnicity_id) REFERENCES ethnicities(ethnicity_id) not valid;

alter table "public"."user_ethnicities" validate constraint "user_ethnicities_ethnicity_id_fkey";

alter table "public"."user_ethnicities" add constraint "user_ethnicities_user_id_ethnicity_id_key" UNIQUE using index "user_ethnicities_user_id_ethnicity_id_key";

alter table "public"."user_ethnicities" add constraint "user_ethnicities_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(user_id) not valid;

alter table "public"."user_ethnicities" validate constraint "user_ethnicities_user_id_fkey";

alter table "public"."user_job_history" add constraint "check_job_history_dates" CHECK (((start_date IS NULL) OR (end_date IS NULL) OR (start_date <= end_date))) not valid;

alter table "public"."user_job_history" validate constraint "check_job_history_dates";

alter table "public"."user_job_history" add constraint "fk_user_job_history_user" FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE not valid;

alter table "public"."user_job_history" validate constraint "fk_user_job_history_user";

alter table "public"."user_job_history" add constraint "user_job_history_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(user_id) not valid;

alter table "public"."user_job_history" validate constraint "user_job_history_user_id_fkey";

alter table "public"."user_languages" add constraint "fk_user_languages_user" FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE not valid;

alter table "public"."user_languages" validate constraint "fk_user_languages_user";

alter table "public"."user_languages" add constraint "user_languages_proficiency_check" CHECK (((proficiency)::text = ANY (ARRAY[('basic'::character varying)::text, ('conversational'::character varying)::text, ('fluent'::character varying)::text, ('native'::character varying)::text]))) not valid;

alter table "public"."user_languages" validate constraint "user_languages_proficiency_check";

alter table "public"."user_languages" add constraint "user_languages_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(user_id) not valid;

alter table "public"."user_languages" validate constraint "user_languages_user_id_fkey";

alter table "public"."user_skills" add constraint "fk_user_skills_skill" FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE not valid;

alter table "public"."user_skills" validate constraint "fk_user_skills_skill";

alter table "public"."user_skills" add constraint "fk_user_skills_user" FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE not valid;

alter table "public"."user_skills" validate constraint "fk_user_skills_user";

alter table "public"."user_skills" add constraint "unique_user_skill" UNIQUE using index "unique_user_skill";

alter table "public"."user_skills" add constraint "user_skills_skill_id_fkey" FOREIGN KEY (skill_id) REFERENCES skills(skill_id) not valid;

alter table "public"."user_skills" validate constraint "user_skills_skill_id_fkey";

alter table "public"."user_skills" add constraint "user_skills_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(user_id) not valid;

alter table "public"."user_skills" validate constraint "user_skills_user_id_fkey";

alter table "public"."users" add constraint "fk_user_auth" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."users" validate constraint "fk_user_auth";

alter table "public"."users" add constraint "users_email_key" UNIQUE using index "users_email_key";

alter table "public"."users" add constraint "users_gender_check" CHECK (((gender)::text = ANY (ARRAY[('male'::character varying)::text, ('female'::character varying)::text, ('other'::character varying)::text, ('prefer not to say'::character varying)::text]))) not valid;

alter table "public"."users" validate constraint "users_gender_check";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.add_super_admin(p_email text, p_admin_user_id uuid DEFAULT NULL::uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.check_max_organizations_per_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_user_organization_ids(p_user_id uuid DEFAULT auth.uid())
 RETURNS uuid[]
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
  SELECT ARRAY_AGG(DISTINCT organization_id)
  FROM public.employees 
  WHERE employee_id = p_user_id 
    AND deleted_at IS NULL;
$function$
;

CREATE OR REPLACE FUNCTION public.get_user_role_in_org(p_user_id uuid, p_organization_id uuid)
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
  SELECT r.role_name
  FROM public.employees e
  JOIN public.roles r ON e.role_id = r.role_id
  WHERE e.employee_id = p_user_id 
    AND e.organization_id = p_organization_id 
    AND e.deleted_at IS NULL
    AND r.deleted_at IS NULL
  LIMIT 1;
$function$
;

CREATE OR REPLACE FUNCTION public.has_job_translation_permission(p_user_id uuid, p_job_id uuid, p_permission_name character varying)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.has_jobs_app_permission(org_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.has_permission_in_org(p_user_id uuid, p_organization_id uuid, p_permission_name character varying)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.is_org_owner(p_user_id uuid, p_organization_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
  SELECT EXISTS (
    SELECT 1 
    FROM public.organizations 
    WHERE organization_id = p_organization_id
      AND (primary_owner = p_user_id OR secondary_owner = p_user_id)
      AND deleted_at IS NULL
  );
$function$
;

CREATE OR REPLACE FUNCTION public.is_super_admin(p_user_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM super_admins
        WHERE user_id = p_user_id
    );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.remove_super_admin(p_email text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.set_organization_status(p_organization_id uuid, p_active boolean)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.setup_org_admin_permissions(p_organization_id uuid, p_role_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.setup_org_admin_role(p_organization_id uuid, p_user_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.trigger_setup_org_admin()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
    -- Only setup admin role for INSERT operations and when primary_owner is set
    IF TG_OP = 'INSERT' AND NEW.primary_owner IS NOT NULL THEN
        -- Call setup_org_admin_role function with explicit schema
        PERFORM public.setup_org_admin_role(NEW.organization_id, NEW.primary_owner);
    END IF;
    
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.user_belongs_to_org(p_user_id uuid, p_organization_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
  SELECT EXISTS (
    SELECT 1 
    FROM public.employees 
    WHERE employee_id = p_user_id 
      AND organization_id = p_organization_id 
      AND deleted_at IS NULL
  );
$function$
;

grant delete on table "public"."apps" to "anon";

grant insert on table "public"."apps" to "anon";

grant references on table "public"."apps" to "anon";

grant select on table "public"."apps" to "anon";

grant trigger on table "public"."apps" to "anon";

grant truncate on table "public"."apps" to "anon";

grant update on table "public"."apps" to "anon";

grant delete on table "public"."apps" to "authenticated";

grant insert on table "public"."apps" to "authenticated";

grant references on table "public"."apps" to "authenticated";

grant select on table "public"."apps" to "authenticated";

grant trigger on table "public"."apps" to "authenticated";

grant truncate on table "public"."apps" to "authenticated";

grant update on table "public"."apps" to "authenticated";

grant delete on table "public"."apps" to "service_role";

grant insert on table "public"."apps" to "service_role";

grant references on table "public"."apps" to "service_role";

grant select on table "public"."apps" to "service_role";

grant trigger on table "public"."apps" to "service_role";

grant truncate on table "public"."apps" to "service_role";

grant update on table "public"."apps" to "service_role";

grant delete on table "public"."audit_logs" to "anon";

grant insert on table "public"."audit_logs" to "anon";

grant references on table "public"."audit_logs" to "anon";

grant select on table "public"."audit_logs" to "anon";

grant trigger on table "public"."audit_logs" to "anon";

grant truncate on table "public"."audit_logs" to "anon";

grant update on table "public"."audit_logs" to "anon";

grant delete on table "public"."audit_logs" to "authenticated";

grant insert on table "public"."audit_logs" to "authenticated";

grant references on table "public"."audit_logs" to "authenticated";

grant select on table "public"."audit_logs" to "authenticated";

grant trigger on table "public"."audit_logs" to "authenticated";

grant truncate on table "public"."audit_logs" to "authenticated";

grant update on table "public"."audit_logs" to "authenticated";

grant delete on table "public"."audit_logs" to "service_role";

grant insert on table "public"."audit_logs" to "service_role";

grant references on table "public"."audit_logs" to "service_role";

grant select on table "public"."audit_logs" to "service_role";

grant trigger on table "public"."audit_logs" to "service_role";

grant truncate on table "public"."audit_logs" to "service_role";

grant update on table "public"."audit_logs" to "service_role";

grant delete on table "public"."custom_users" to "anon";

grant insert on table "public"."custom_users" to "anon";

grant references on table "public"."custom_users" to "anon";

grant select on table "public"."custom_users" to "anon";

grant trigger on table "public"."custom_users" to "anon";

grant truncate on table "public"."custom_users" to "anon";

grant update on table "public"."custom_users" to "anon";

grant delete on table "public"."custom_users" to "authenticated";

grant insert on table "public"."custom_users" to "authenticated";

grant references on table "public"."custom_users" to "authenticated";

grant select on table "public"."custom_users" to "authenticated";

grant trigger on table "public"."custom_users" to "authenticated";

grant truncate on table "public"."custom_users" to "authenticated";

grant update on table "public"."custom_users" to "authenticated";

grant delete on table "public"."custom_users" to "service_role";

grant insert on table "public"."custom_users" to "service_role";

grant references on table "public"."custom_users" to "service_role";

grant select on table "public"."custom_users" to "service_role";

grant trigger on table "public"."custom_users" to "service_role";

grant truncate on table "public"."custom_users" to "service_role";

grant update on table "public"."custom_users" to "service_role";

grant delete on table "public"."departments" to "anon";

grant insert on table "public"."departments" to "anon";

grant references on table "public"."departments" to "anon";

grant select on table "public"."departments" to "anon";

grant trigger on table "public"."departments" to "anon";

grant truncate on table "public"."departments" to "anon";

grant update on table "public"."departments" to "anon";

grant delete on table "public"."departments" to "authenticated";

grant insert on table "public"."departments" to "authenticated";

grant references on table "public"."departments" to "authenticated";

grant select on table "public"."departments" to "authenticated";

grant trigger on table "public"."departments" to "authenticated";

grant truncate on table "public"."departments" to "authenticated";

grant update on table "public"."departments" to "authenticated";

grant delete on table "public"."departments" to "service_role";

grant insert on table "public"."departments" to "service_role";

grant references on table "public"."departments" to "service_role";

grant select on table "public"."departments" to "service_role";

grant trigger on table "public"."departments" to "service_role";

grant truncate on table "public"."departments" to "service_role";

grant update on table "public"."departments" to "service_role";

grant delete on table "public"."employee_hierarchy" to "anon";

grant insert on table "public"."employee_hierarchy" to "anon";

grant references on table "public"."employee_hierarchy" to "anon";

grant select on table "public"."employee_hierarchy" to "anon";

grant trigger on table "public"."employee_hierarchy" to "anon";

grant truncate on table "public"."employee_hierarchy" to "anon";

grant update on table "public"."employee_hierarchy" to "anon";

grant delete on table "public"."employee_hierarchy" to "authenticated";

grant insert on table "public"."employee_hierarchy" to "authenticated";

grant references on table "public"."employee_hierarchy" to "authenticated";

grant select on table "public"."employee_hierarchy" to "authenticated";

grant trigger on table "public"."employee_hierarchy" to "authenticated";

grant truncate on table "public"."employee_hierarchy" to "authenticated";

grant update on table "public"."employee_hierarchy" to "authenticated";

grant delete on table "public"."employee_hierarchy" to "service_role";

grant insert on table "public"."employee_hierarchy" to "service_role";

grant references on table "public"."employee_hierarchy" to "service_role";

grant select on table "public"."employee_hierarchy" to "service_role";

grant trigger on table "public"."employee_hierarchy" to "service_role";

grant truncate on table "public"."employee_hierarchy" to "service_role";

grant update on table "public"."employee_hierarchy" to "service_role";

grant delete on table "public"."employees" to "anon";

grant insert on table "public"."employees" to "anon";

grant references on table "public"."employees" to "anon";

grant select on table "public"."employees" to "anon";

grant trigger on table "public"."employees" to "anon";

grant truncate on table "public"."employees" to "anon";

grant update on table "public"."employees" to "anon";

grant delete on table "public"."employees" to "authenticated";

grant insert on table "public"."employees" to "authenticated";

grant references on table "public"."employees" to "authenticated";

grant select on table "public"."employees" to "authenticated";

grant trigger on table "public"."employees" to "authenticated";

grant truncate on table "public"."employees" to "authenticated";

grant update on table "public"."employees" to "authenticated";

grant delete on table "public"."employees" to "service_role";

grant insert on table "public"."employees" to "service_role";

grant references on table "public"."employees" to "service_role";

grant select on table "public"."employees" to "service_role";

grant trigger on table "public"."employees" to "service_role";

grant truncate on table "public"."employees" to "service_role";

grant update on table "public"."employees" to "service_role";

grant delete on table "public"."ethnicities" to "anon";

grant insert on table "public"."ethnicities" to "anon";

grant references on table "public"."ethnicities" to "anon";

grant select on table "public"."ethnicities" to "anon";

grant trigger on table "public"."ethnicities" to "anon";

grant truncate on table "public"."ethnicities" to "anon";

grant update on table "public"."ethnicities" to "anon";

grant delete on table "public"."ethnicities" to "authenticated";

grant insert on table "public"."ethnicities" to "authenticated";

grant references on table "public"."ethnicities" to "authenticated";

grant select on table "public"."ethnicities" to "authenticated";

grant trigger on table "public"."ethnicities" to "authenticated";

grant truncate on table "public"."ethnicities" to "authenticated";

grant update on table "public"."ethnicities" to "authenticated";

grant delete on table "public"."ethnicities" to "service_role";

grant insert on table "public"."ethnicities" to "service_role";

grant references on table "public"."ethnicities" to "service_role";

grant select on table "public"."ethnicities" to "service_role";

grant trigger on table "public"."ethnicities" to "service_role";

grant truncate on table "public"."ethnicities" to "service_role";

grant update on table "public"."ethnicities" to "service_role";

grant delete on table "public"."job_categories" to "anon";

grant insert on table "public"."job_categories" to "anon";

grant references on table "public"."job_categories" to "anon";

grant select on table "public"."job_categories" to "anon";

grant trigger on table "public"."job_categories" to "anon";

grant truncate on table "public"."job_categories" to "anon";

grant update on table "public"."job_categories" to "anon";

grant delete on table "public"."job_categories" to "authenticated";

grant insert on table "public"."job_categories" to "authenticated";

grant references on table "public"."job_categories" to "authenticated";

grant select on table "public"."job_categories" to "authenticated";

grant trigger on table "public"."job_categories" to "authenticated";

grant truncate on table "public"."job_categories" to "authenticated";

grant update on table "public"."job_categories" to "authenticated";

grant delete on table "public"."job_categories" to "service_role";

grant insert on table "public"."job_categories" to "service_role";

grant references on table "public"."job_categories" to "service_role";

grant select on table "public"."job_categories" to "service_role";

grant trigger on table "public"."job_categories" to "service_role";

grant truncate on table "public"."job_categories" to "service_role";

grant update on table "public"."job_categories" to "service_role";

grant delete on table "public"."job_skills" to "anon";

grant insert on table "public"."job_skills" to "anon";

grant references on table "public"."job_skills" to "anon";

grant select on table "public"."job_skills" to "anon";

grant trigger on table "public"."job_skills" to "anon";

grant truncate on table "public"."job_skills" to "anon";

grant update on table "public"."job_skills" to "anon";

grant delete on table "public"."job_skills" to "authenticated";

grant insert on table "public"."job_skills" to "authenticated";

grant references on table "public"."job_skills" to "authenticated";

grant select on table "public"."job_skills" to "authenticated";

grant trigger on table "public"."job_skills" to "authenticated";

grant truncate on table "public"."job_skills" to "authenticated";

grant update on table "public"."job_skills" to "authenticated";

grant delete on table "public"."job_skills" to "service_role";

grant insert on table "public"."job_skills" to "service_role";

grant references on table "public"."job_skills" to "service_role";

grant select on table "public"."job_skills" to "service_role";

grant trigger on table "public"."job_skills" to "service_role";

grant truncate on table "public"."job_skills" to "service_role";

grant update on table "public"."job_skills" to "service_role";

grant delete on table "public"."job_translations" to "anon";

grant insert on table "public"."job_translations" to "anon";

grant references on table "public"."job_translations" to "anon";

grant select on table "public"."job_translations" to "anon";

grant trigger on table "public"."job_translations" to "anon";

grant truncate on table "public"."job_translations" to "anon";

grant update on table "public"."job_translations" to "anon";

grant delete on table "public"."job_translations" to "authenticated";

grant insert on table "public"."job_translations" to "authenticated";

grant references on table "public"."job_translations" to "authenticated";

grant select on table "public"."job_translations" to "authenticated";

grant trigger on table "public"."job_translations" to "authenticated";

grant truncate on table "public"."job_translations" to "authenticated";

grant update on table "public"."job_translations" to "authenticated";

grant delete on table "public"."job_translations" to "service_role";

grant insert on table "public"."job_translations" to "service_role";

grant references on table "public"."job_translations" to "service_role";

grant select on table "public"."job_translations" to "service_role";

grant trigger on table "public"."job_translations" to "service_role";

grant truncate on table "public"."job_translations" to "service_role";

grant update on table "public"."job_translations" to "service_role";

grant delete on table "public"."jobs" to "anon";

grant insert on table "public"."jobs" to "anon";

grant references on table "public"."jobs" to "anon";

grant select on table "public"."jobs" to "anon";

grant trigger on table "public"."jobs" to "anon";

grant truncate on table "public"."jobs" to "anon";

grant update on table "public"."jobs" to "anon";

grant delete on table "public"."jobs" to "authenticated";

grant insert on table "public"."jobs" to "authenticated";

grant references on table "public"."jobs" to "authenticated";

grant select on table "public"."jobs" to "authenticated";

grant trigger on table "public"."jobs" to "authenticated";

grant truncate on table "public"."jobs" to "authenticated";

grant update on table "public"."jobs" to "authenticated";

grant delete on table "public"."jobs" to "service_role";

grant insert on table "public"."jobs" to "service_role";

grant references on table "public"."jobs" to "service_role";

grant select on table "public"."jobs" to "service_role";

grant trigger on table "public"."jobs" to "service_role";

grant truncate on table "public"."jobs" to "service_role";

grant update on table "public"."jobs" to "service_role";

grant delete on table "public"."notifications" to "anon";

grant insert on table "public"."notifications" to "anon";

grant references on table "public"."notifications" to "anon";

grant select on table "public"."notifications" to "anon";

grant trigger on table "public"."notifications" to "anon";

grant truncate on table "public"."notifications" to "anon";

grant update on table "public"."notifications" to "anon";

grant delete on table "public"."notifications" to "authenticated";

grant insert on table "public"."notifications" to "authenticated";

grant references on table "public"."notifications" to "authenticated";

grant select on table "public"."notifications" to "authenticated";

grant trigger on table "public"."notifications" to "authenticated";

grant truncate on table "public"."notifications" to "authenticated";

grant update on table "public"."notifications" to "authenticated";

grant delete on table "public"."notifications" to "service_role";

grant insert on table "public"."notifications" to "service_role";

grant references on table "public"."notifications" to "service_role";

grant select on table "public"."notifications" to "service_role";

grant trigger on table "public"."notifications" to "service_role";

grant truncate on table "public"."notifications" to "service_role";

grant update on table "public"."notifications" to "service_role";

grant delete on table "public"."organization_apps" to "anon";

grant insert on table "public"."organization_apps" to "anon";

grant references on table "public"."organization_apps" to "anon";

grant select on table "public"."organization_apps" to "anon";

grant trigger on table "public"."organization_apps" to "anon";

grant truncate on table "public"."organization_apps" to "anon";

grant update on table "public"."organization_apps" to "anon";

grant delete on table "public"."organization_apps" to "authenticated";

grant insert on table "public"."organization_apps" to "authenticated";

grant references on table "public"."organization_apps" to "authenticated";

grant select on table "public"."organization_apps" to "authenticated";

grant trigger on table "public"."organization_apps" to "authenticated";

grant truncate on table "public"."organization_apps" to "authenticated";

grant update on table "public"."organization_apps" to "authenticated";

grant delete on table "public"."organization_apps" to "service_role";

grant insert on table "public"."organization_apps" to "service_role";

grant references on table "public"."organization_apps" to "service_role";

grant select on table "public"."organization_apps" to "service_role";

grant trigger on table "public"."organization_apps" to "service_role";

grant truncate on table "public"."organization_apps" to "service_role";

grant update on table "public"."organization_apps" to "service_role";

grant delete on table "public"."organization_organization_types" to "anon";

grant insert on table "public"."organization_organization_types" to "anon";

grant references on table "public"."organization_organization_types" to "anon";

grant select on table "public"."organization_organization_types" to "anon";

grant trigger on table "public"."organization_organization_types" to "anon";

grant truncate on table "public"."organization_organization_types" to "anon";

grant update on table "public"."organization_organization_types" to "anon";

grant delete on table "public"."organization_organization_types" to "authenticated";

grant insert on table "public"."organization_organization_types" to "authenticated";

grant references on table "public"."organization_organization_types" to "authenticated";

grant select on table "public"."organization_organization_types" to "authenticated";

grant trigger on table "public"."organization_organization_types" to "authenticated";

grant truncate on table "public"."organization_organization_types" to "authenticated";

grant update on table "public"."organization_organization_types" to "authenticated";

grant delete on table "public"."organization_organization_types" to "service_role";

grant insert on table "public"."organization_organization_types" to "service_role";

grant references on table "public"."organization_organization_types" to "service_role";

grant select on table "public"."organization_organization_types" to "service_role";

grant trigger on table "public"."organization_organization_types" to "service_role";

grant truncate on table "public"."organization_organization_types" to "service_role";

grant update on table "public"."organization_organization_types" to "service_role";

grant delete on table "public"."organization_plans" to "anon";

grant insert on table "public"."organization_plans" to "anon";

grant references on table "public"."organization_plans" to "anon";

grant select on table "public"."organization_plans" to "anon";

grant trigger on table "public"."organization_plans" to "anon";

grant truncate on table "public"."organization_plans" to "anon";

grant update on table "public"."organization_plans" to "anon";

grant delete on table "public"."organization_plans" to "authenticated";

grant insert on table "public"."organization_plans" to "authenticated";

grant references on table "public"."organization_plans" to "authenticated";

grant select on table "public"."organization_plans" to "authenticated";

grant trigger on table "public"."organization_plans" to "authenticated";

grant truncate on table "public"."organization_plans" to "authenticated";

grant update on table "public"."organization_plans" to "authenticated";

grant delete on table "public"."organization_plans" to "service_role";

grant insert on table "public"."organization_plans" to "service_role";

grant references on table "public"."organization_plans" to "service_role";

grant select on table "public"."organization_plans" to "service_role";

grant trigger on table "public"."organization_plans" to "service_role";

grant truncate on table "public"."organization_plans" to "service_role";

grant update on table "public"."organization_plans" to "service_role";

grant delete on table "public"."organization_types" to "anon";

grant insert on table "public"."organization_types" to "anon";

grant references on table "public"."organization_types" to "anon";

grant select on table "public"."organization_types" to "anon";

grant trigger on table "public"."organization_types" to "anon";

grant truncate on table "public"."organization_types" to "anon";

grant update on table "public"."organization_types" to "anon";

grant delete on table "public"."organization_types" to "authenticated";

grant insert on table "public"."organization_types" to "authenticated";

grant references on table "public"."organization_types" to "authenticated";

grant select on table "public"."organization_types" to "authenticated";

grant trigger on table "public"."organization_types" to "authenticated";

grant truncate on table "public"."organization_types" to "authenticated";

grant update on table "public"."organization_types" to "authenticated";

grant delete on table "public"."organization_types" to "service_role";

grant insert on table "public"."organization_types" to "service_role";

grant references on table "public"."organization_types" to "service_role";

grant select on table "public"."organization_types" to "service_role";

grant trigger on table "public"."organization_types" to "service_role";

grant truncate on table "public"."organization_types" to "service_role";

grant update on table "public"."organization_types" to "service_role";

grant delete on table "public"."organizations" to "anon";

grant insert on table "public"."organizations" to "anon";

grant references on table "public"."organizations" to "anon";

grant select on table "public"."organizations" to "anon";

grant trigger on table "public"."organizations" to "anon";

grant truncate on table "public"."organizations" to "anon";

grant update on table "public"."organizations" to "anon";

grant delete on table "public"."organizations" to "authenticated";

grant insert on table "public"."organizations" to "authenticated";

grant references on table "public"."organizations" to "authenticated";

grant select on table "public"."organizations" to "authenticated";

grant trigger on table "public"."organizations" to "authenticated";

grant truncate on table "public"."organizations" to "authenticated";

grant update on table "public"."organizations" to "authenticated";

grant delete on table "public"."organizations" to "service_role";

grant insert on table "public"."organizations" to "service_role";

grant references on table "public"."organizations" to "service_role";

grant select on table "public"."organizations" to "service_role";

grant trigger on table "public"."organizations" to "service_role";

grant truncate on table "public"."organizations" to "service_role";

grant update on table "public"."organizations" to "service_role";

grant delete on table "public"."plan_apps" to "anon";

grant insert on table "public"."plan_apps" to "anon";

grant references on table "public"."plan_apps" to "anon";

grant select on table "public"."plan_apps" to "anon";

grant trigger on table "public"."plan_apps" to "anon";

grant truncate on table "public"."plan_apps" to "anon";

grant update on table "public"."plan_apps" to "anon";

grant delete on table "public"."plan_apps" to "authenticated";

grant insert on table "public"."plan_apps" to "authenticated";

grant references on table "public"."plan_apps" to "authenticated";

grant select on table "public"."plan_apps" to "authenticated";

grant trigger on table "public"."plan_apps" to "authenticated";

grant truncate on table "public"."plan_apps" to "authenticated";

grant update on table "public"."plan_apps" to "authenticated";

grant delete on table "public"."plan_apps" to "service_role";

grant insert on table "public"."plan_apps" to "service_role";

grant references on table "public"."plan_apps" to "service_role";

grant select on table "public"."plan_apps" to "service_role";

grant trigger on table "public"."plan_apps" to "service_role";

grant truncate on table "public"."plan_apps" to "service_role";

grant update on table "public"."plan_apps" to "service_role";

grant delete on table "public"."plans" to "anon";

grant insert on table "public"."plans" to "anon";

grant references on table "public"."plans" to "anon";

grant select on table "public"."plans" to "anon";

grant trigger on table "public"."plans" to "anon";

grant truncate on table "public"."plans" to "anon";

grant update on table "public"."plans" to "anon";

grant delete on table "public"."plans" to "authenticated";

grant insert on table "public"."plans" to "authenticated";

grant references on table "public"."plans" to "authenticated";

grant select on table "public"."plans" to "authenticated";

grant trigger on table "public"."plans" to "authenticated";

grant truncate on table "public"."plans" to "authenticated";

grant update on table "public"."plans" to "authenticated";

grant delete on table "public"."plans" to "service_role";

grant insert on table "public"."plans" to "service_role";

grant references on table "public"."plans" to "service_role";

grant select on table "public"."plans" to "service_role";

grant trigger on table "public"."plans" to "service_role";

grant truncate on table "public"."plans" to "service_role";

grant update on table "public"."plans" to "service_role";

grant delete on table "public"."role_permissions" to "anon";

grant insert on table "public"."role_permissions" to "anon";

grant references on table "public"."role_permissions" to "anon";

grant select on table "public"."role_permissions" to "anon";

grant trigger on table "public"."role_permissions" to "anon";

grant truncate on table "public"."role_permissions" to "anon";

grant update on table "public"."role_permissions" to "anon";

grant delete on table "public"."role_permissions" to "authenticated";

grant insert on table "public"."role_permissions" to "authenticated";

grant references on table "public"."role_permissions" to "authenticated";

grant select on table "public"."role_permissions" to "authenticated";

grant trigger on table "public"."role_permissions" to "authenticated";

grant truncate on table "public"."role_permissions" to "authenticated";

grant update on table "public"."role_permissions" to "authenticated";

grant delete on table "public"."role_permissions" to "service_role";

grant insert on table "public"."role_permissions" to "service_role";

grant references on table "public"."role_permissions" to "service_role";

grant select on table "public"."role_permissions" to "service_role";

grant trigger on table "public"."role_permissions" to "service_role";

grant truncate on table "public"."role_permissions" to "service_role";

grant update on table "public"."role_permissions" to "service_role";

grant delete on table "public"."roles" to "anon";

grant insert on table "public"."roles" to "anon";

grant references on table "public"."roles" to "anon";

grant select on table "public"."roles" to "anon";

grant trigger on table "public"."roles" to "anon";

grant truncate on table "public"."roles" to "anon";

grant update on table "public"."roles" to "anon";

grant delete on table "public"."roles" to "authenticated";

grant insert on table "public"."roles" to "authenticated";

grant references on table "public"."roles" to "authenticated";

grant select on table "public"."roles" to "authenticated";

grant trigger on table "public"."roles" to "authenticated";

grant truncate on table "public"."roles" to "authenticated";

grant update on table "public"."roles" to "authenticated";

grant delete on table "public"."roles" to "service_role";

grant insert on table "public"."roles" to "service_role";

grant references on table "public"."roles" to "service_role";

grant select on table "public"."roles" to "service_role";

grant trigger on table "public"."roles" to "service_role";

grant truncate on table "public"."roles" to "service_role";

grant update on table "public"."roles" to "service_role";

grant delete on table "public"."saved_jobs" to "anon";

grant insert on table "public"."saved_jobs" to "anon";

grant references on table "public"."saved_jobs" to "anon";

grant select on table "public"."saved_jobs" to "anon";

grant trigger on table "public"."saved_jobs" to "anon";

grant truncate on table "public"."saved_jobs" to "anon";

grant update on table "public"."saved_jobs" to "anon";

grant delete on table "public"."saved_jobs" to "authenticated";

grant insert on table "public"."saved_jobs" to "authenticated";

grant references on table "public"."saved_jobs" to "authenticated";

grant select on table "public"."saved_jobs" to "authenticated";

grant trigger on table "public"."saved_jobs" to "authenticated";

grant truncate on table "public"."saved_jobs" to "authenticated";

grant update on table "public"."saved_jobs" to "authenticated";

grant delete on table "public"."saved_jobs" to "service_role";

grant insert on table "public"."saved_jobs" to "service_role";

grant references on table "public"."saved_jobs" to "service_role";

grant select on table "public"."saved_jobs" to "service_role";

grant trigger on table "public"."saved_jobs" to "service_role";

grant truncate on table "public"."saved_jobs" to "service_role";

grant update on table "public"."saved_jobs" to "service_role";

grant delete on table "public"."sites" to "anon";

grant insert on table "public"."sites" to "anon";

grant references on table "public"."sites" to "anon";

grant select on table "public"."sites" to "anon";

grant trigger on table "public"."sites" to "anon";

grant truncate on table "public"."sites" to "anon";

grant update on table "public"."sites" to "anon";

grant delete on table "public"."sites" to "authenticated";

grant insert on table "public"."sites" to "authenticated";

grant references on table "public"."sites" to "authenticated";

grant select on table "public"."sites" to "authenticated";

grant trigger on table "public"."sites" to "authenticated";

grant truncate on table "public"."sites" to "authenticated";

grant update on table "public"."sites" to "authenticated";

grant delete on table "public"."sites" to "service_role";

grant insert on table "public"."sites" to "service_role";

grant references on table "public"."sites" to "service_role";

grant select on table "public"."sites" to "service_role";

grant trigger on table "public"."sites" to "service_role";

grant truncate on table "public"."sites" to "service_role";

grant update on table "public"."sites" to "service_role";

grant delete on table "public"."skills" to "anon";

grant insert on table "public"."skills" to "anon";

grant references on table "public"."skills" to "anon";

grant select on table "public"."skills" to "anon";

grant trigger on table "public"."skills" to "anon";

grant truncate on table "public"."skills" to "anon";

grant update on table "public"."skills" to "anon";

grant delete on table "public"."skills" to "authenticated";

grant insert on table "public"."skills" to "authenticated";

grant references on table "public"."skills" to "authenticated";

grant select on table "public"."skills" to "authenticated";

grant trigger on table "public"."skills" to "authenticated";

grant truncate on table "public"."skills" to "authenticated";

grant update on table "public"."skills" to "authenticated";

grant delete on table "public"."skills" to "service_role";

grant insert on table "public"."skills" to "service_role";

grant references on table "public"."skills" to "service_role";

grant select on table "public"."skills" to "service_role";

grant trigger on table "public"."skills" to "service_role";

grant truncate on table "public"."skills" to "service_role";

grant update on table "public"."skills" to "service_role";

grant delete on table "public"."super_admins" to "anon";

grant insert on table "public"."super_admins" to "anon";

grant references on table "public"."super_admins" to "anon";

grant select on table "public"."super_admins" to "anon";

grant trigger on table "public"."super_admins" to "anon";

grant truncate on table "public"."super_admins" to "anon";

grant update on table "public"."super_admins" to "anon";

grant delete on table "public"."super_admins" to "authenticated";

grant insert on table "public"."super_admins" to "authenticated";

grant references on table "public"."super_admins" to "authenticated";

grant select on table "public"."super_admins" to "authenticated";

grant trigger on table "public"."super_admins" to "authenticated";

grant truncate on table "public"."super_admins" to "authenticated";

grant update on table "public"."super_admins" to "authenticated";

grant delete on table "public"."super_admins" to "service_role";

grant insert on table "public"."super_admins" to "service_role";

grant references on table "public"."super_admins" to "service_role";

grant select on table "public"."super_admins" to "service_role";

grant trigger on table "public"."super_admins" to "service_role";

grant truncate on table "public"."super_admins" to "service_role";

grant update on table "public"."super_admins" to "service_role";

grant delete on table "public"."user_education" to "anon";

grant insert on table "public"."user_education" to "anon";

grant references on table "public"."user_education" to "anon";

grant select on table "public"."user_education" to "anon";

grant trigger on table "public"."user_education" to "anon";

grant truncate on table "public"."user_education" to "anon";

grant update on table "public"."user_education" to "anon";

grant delete on table "public"."user_education" to "authenticated";

grant insert on table "public"."user_education" to "authenticated";

grant references on table "public"."user_education" to "authenticated";

grant select on table "public"."user_education" to "authenticated";

grant trigger on table "public"."user_education" to "authenticated";

grant truncate on table "public"."user_education" to "authenticated";

grant update on table "public"."user_education" to "authenticated";

grant delete on table "public"."user_education" to "service_role";

grant insert on table "public"."user_education" to "service_role";

grant references on table "public"."user_education" to "service_role";

grant select on table "public"."user_education" to "service_role";

grant trigger on table "public"."user_education" to "service_role";

grant truncate on table "public"."user_education" to "service_role";

grant update on table "public"."user_education" to "service_role";

grant delete on table "public"."user_ethnicities" to "anon";

grant insert on table "public"."user_ethnicities" to "anon";

grant references on table "public"."user_ethnicities" to "anon";

grant select on table "public"."user_ethnicities" to "anon";

grant trigger on table "public"."user_ethnicities" to "anon";

grant truncate on table "public"."user_ethnicities" to "anon";

grant update on table "public"."user_ethnicities" to "anon";

grant delete on table "public"."user_ethnicities" to "authenticated";

grant insert on table "public"."user_ethnicities" to "authenticated";

grant references on table "public"."user_ethnicities" to "authenticated";

grant select on table "public"."user_ethnicities" to "authenticated";

grant trigger on table "public"."user_ethnicities" to "authenticated";

grant truncate on table "public"."user_ethnicities" to "authenticated";

grant update on table "public"."user_ethnicities" to "authenticated";

grant delete on table "public"."user_ethnicities" to "service_role";

grant insert on table "public"."user_ethnicities" to "service_role";

grant references on table "public"."user_ethnicities" to "service_role";

grant select on table "public"."user_ethnicities" to "service_role";

grant trigger on table "public"."user_ethnicities" to "service_role";

grant truncate on table "public"."user_ethnicities" to "service_role";

grant update on table "public"."user_ethnicities" to "service_role";

grant delete on table "public"."user_job_history" to "anon";

grant insert on table "public"."user_job_history" to "anon";

grant references on table "public"."user_job_history" to "anon";

grant select on table "public"."user_job_history" to "anon";

grant trigger on table "public"."user_job_history" to "anon";

grant truncate on table "public"."user_job_history" to "anon";

grant update on table "public"."user_job_history" to "anon";

grant delete on table "public"."user_job_history" to "authenticated";

grant insert on table "public"."user_job_history" to "authenticated";

grant references on table "public"."user_job_history" to "authenticated";

grant select on table "public"."user_job_history" to "authenticated";

grant trigger on table "public"."user_job_history" to "authenticated";

grant truncate on table "public"."user_job_history" to "authenticated";

grant update on table "public"."user_job_history" to "authenticated";

grant delete on table "public"."user_job_history" to "service_role";

grant insert on table "public"."user_job_history" to "service_role";

grant references on table "public"."user_job_history" to "service_role";

grant select on table "public"."user_job_history" to "service_role";

grant trigger on table "public"."user_job_history" to "service_role";

grant truncate on table "public"."user_job_history" to "service_role";

grant update on table "public"."user_job_history" to "service_role";

grant delete on table "public"."user_languages" to "anon";

grant insert on table "public"."user_languages" to "anon";

grant references on table "public"."user_languages" to "anon";

grant select on table "public"."user_languages" to "anon";

grant trigger on table "public"."user_languages" to "anon";

grant truncate on table "public"."user_languages" to "anon";

grant update on table "public"."user_languages" to "anon";

grant delete on table "public"."user_languages" to "authenticated";

grant insert on table "public"."user_languages" to "authenticated";

grant references on table "public"."user_languages" to "authenticated";

grant select on table "public"."user_languages" to "authenticated";

grant trigger on table "public"."user_languages" to "authenticated";

grant truncate on table "public"."user_languages" to "authenticated";

grant update on table "public"."user_languages" to "authenticated";

grant delete on table "public"."user_languages" to "service_role";

grant insert on table "public"."user_languages" to "service_role";

grant references on table "public"."user_languages" to "service_role";

grant select on table "public"."user_languages" to "service_role";

grant trigger on table "public"."user_languages" to "service_role";

grant truncate on table "public"."user_languages" to "service_role";

grant update on table "public"."user_languages" to "service_role";

grant delete on table "public"."user_skills" to "anon";

grant insert on table "public"."user_skills" to "anon";

grant references on table "public"."user_skills" to "anon";

grant select on table "public"."user_skills" to "anon";

grant trigger on table "public"."user_skills" to "anon";

grant truncate on table "public"."user_skills" to "anon";

grant update on table "public"."user_skills" to "anon";

grant delete on table "public"."user_skills" to "authenticated";

grant insert on table "public"."user_skills" to "authenticated";

grant references on table "public"."user_skills" to "authenticated";

grant select on table "public"."user_skills" to "authenticated";

grant trigger on table "public"."user_skills" to "authenticated";

grant truncate on table "public"."user_skills" to "authenticated";

grant update on table "public"."user_skills" to "authenticated";

grant delete on table "public"."user_skills" to "service_role";

grant insert on table "public"."user_skills" to "service_role";

grant references on table "public"."user_skills" to "service_role";

grant select on table "public"."user_skills" to "service_role";

grant trigger on table "public"."user_skills" to "service_role";

grant truncate on table "public"."user_skills" to "service_role";

grant update on table "public"."user_skills" to "service_role";

grant delete on table "public"."users" to "anon";

grant insert on table "public"."users" to "anon";

grant references on table "public"."users" to "anon";

grant select on table "public"."users" to "anon";

grant trigger on table "public"."users" to "anon";

grant truncate on table "public"."users" to "anon";

grant update on table "public"."users" to "anon";

grant delete on table "public"."users" to "authenticated";

grant insert on table "public"."users" to "authenticated";

grant references on table "public"."users" to "authenticated";

grant select on table "public"."users" to "authenticated";

grant trigger on table "public"."users" to "authenticated";

grant truncate on table "public"."users" to "authenticated";

grant update on table "public"."users" to "authenticated";

grant delete on table "public"."users" to "service_role";

grant insert on table "public"."users" to "service_role";

grant references on table "public"."users" to "service_role";

grant select on table "public"."users" to "service_role";

grant trigger on table "public"."users" to "service_role";

grant truncate on table "public"."users" to "service_role";

grant update on table "public"."users" to "service_role";

create policy "Anyone can view active apps"
on "public"."apps"
as permissive
for select
to public
using (((is_active = true) AND (deleted_at IS NULL)));


create policy "Org admins can view their org audit logs"
on "public"."audit_logs"
as permissive
for select
to public
using (((organization_id IS NOT NULL) AND user_belongs_to_org(auth.uid(), organization_id) AND has_permission_in_org(auth.uid(), organization_id, 'view_audit_logs'::character varying)));


create policy "Enable users to view their own data only"
on "public"."custom_users"
as permissive
for select
to authenticated
using ((id = auth.uid()));


create policy "Org admins can manage departments"
on "public"."departments"
as permissive
for all
to public
using ((is_super_admin(auth.uid()) OR has_permission_in_org(auth.uid(), organization_id, 'manage_departments'::character varying) OR is_org_owner(auth.uid(), organization_id)));


create policy "Users can view departments in their orgs"
on "public"."departments"
as permissive
for select
to public
using ((is_super_admin(auth.uid()) OR user_belongs_to_org(auth.uid(), organization_id)));


create policy "Employees can update their own profile"
on "public"."employees"
as permissive
for update
to public
using (((employee_id = ( SELECT auth.uid() AS uid)) OR ( SELECT is_super_admin(( SELECT auth.uid() AS uid)) AS is_super_admin)))
with check (((employee_id = ( SELECT auth.uid() AS uid)) OR ( SELECT is_super_admin(( SELECT auth.uid() AS uid)) AS is_super_admin)));


create policy "Org admins can manage employees"
on "public"."employees"
as permissive
for all
to public
using ((is_super_admin(auth.uid()) OR has_permission_in_org(auth.uid(), organization_id, 'manage_employees'::character varying) OR is_org_owner(auth.uid(), organization_id)));


create policy "Users can view employees in their orgs"
on "public"."employees"
as permissive
for select
to public
using ((is_super_admin(auth.uid()) OR user_belongs_to_org(auth.uid(), organization_id) OR (employee_id = auth.uid())));


create policy "Org admins can manage job categories"
on "public"."job_categories"
as permissive
for all
to public
using ((is_super_admin(auth.uid()) OR has_permission_in_org(auth.uid(), organization_id, 'manage_jobs'::character varying) OR is_org_owner(auth.uid(), organization_id)));


create policy "Job managers can manage job skills"
on "public"."job_skills"
as permissive
for all
to public
using ((is_super_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM jobs j
  WHERE ((j.job_id = job_skills.job_id) AND has_permission_in_org(auth.uid(), j.organization_id, 'manage_jobs'::character varying))))));


create policy "Users can view job skills"
on "public"."job_skills"
as permissive
for select
to public
using (true);


create policy "create_job_translation_policy"
on "public"."job_translations"
as permissive
for insert
to public
with check (has_job_translation_permission(COALESCE((NULLIF(( SELECT current_setting('app.current_user_id'::text, true) AS current_setting), ''::text))::uuid, ( SELECT auth.uid() AS uid)), job_id, 'create_job'::character varying));


create policy "delete_job_translation_policy"
on "public"."job_translations"
as permissive
for delete
to public
using (has_job_translation_permission(COALESCE((NULLIF(( SELECT current_setting('app.current_user_id'::text, true) AS current_setting), ''::text))::uuid, ( SELECT auth.uid() AS uid)), job_id, 'delete_job'::character varying));


create policy "update_job_translation_policy"
on "public"."job_translations"
as permissive
for update
to public
using (has_job_translation_permission(COALESCE((NULLIF(( SELECT current_setting('app.current_user_id'::text, true) AS current_setting), ''::text))::uuid, ( SELECT auth.uid() AS uid)), job_id, 'update_job'::character varying))
with check (has_job_translation_permission(COALESCE((NULLIF(( SELECT current_setting('app.current_user_id'::text, true) AS current_setting), ''::text))::uuid, ( SELECT auth.uid() AS uid)), job_id, 'update_job'::character varying));


create policy "Users can view jobs in their orgs"
on "public"."jobs"
as permissive
for select
to public
using ((((status)::text = 'published'::text) OR is_super_admin(auth.uid()) OR user_belongs_to_org(auth.uid(), organization_id)));


create policy "create_job_policy"
on "public"."jobs"
as permissive
for insert
to public
with check ((has_permission_in_org(COALESCE((NULLIF(current_setting('app.current_user_id'::text, true), ''::text))::uuid, auth.uid()), organization_id, 'create_job'::character varying) AND (created_by = COALESCE((NULLIF(current_setting('app.current_user_id'::text, true), ''::text))::uuid, auth.uid()))));


create policy "delete_job_policy"
on "public"."jobs"
as permissive
for delete
to public
using (has_permission_in_org(COALESCE((NULLIF(current_setting('app.current_user_id'::text, true), ''::text))::uuid, auth.uid()), organization_id, 'delete_job'::character varying));


create policy "update_job_policy"
on "public"."jobs"
as permissive
for update
to public
using (has_permission_in_org(COALESCE((NULLIF(( SELECT current_setting('app.current_user_id'::text, true) AS current_setting), ''::text))::uuid, ( SELECT auth.uid() AS uid)), organization_id, 'update_job'::character varying))
with check (has_permission_in_org(COALESCE((NULLIF(( SELECT current_setting('app.current_user_id'::text, true) AS current_setting), ''::text))::uuid, ( SELECT auth.uid() AS uid)), organization_id, 'update_job'::character varying));


create policy "Users can view their org apps"
on "public"."organization_apps"
as permissive
for select
to public
using ((is_super_admin(auth.uid()) OR user_belongs_to_org(auth.uid(), organization_id)));


create policy "Users can view their org plans"
on "public"."organization_plans"
as permissive
for select
to public
using ((is_super_admin(auth.uid()) OR user_belongs_to_org(auth.uid(), organization_id)));


create policy "Org owners can update their orgs"
on "public"."organizations"
as permissive
for update
to public
using ((is_super_admin(auth.uid()) OR is_org_owner(auth.uid(), organization_id)));


create policy "Users can create organizations"
on "public"."organizations"
as permissive
for insert
to public
with check (((primary_owner = auth.uid()) OR (created_by = auth.uid())));


create policy "Users can view orgs they belong to"
on "public"."organizations"
as permissive
for select
to public
using ((is_super_admin(auth.uid()) OR user_belongs_to_org(auth.uid(), organization_id) OR (primary_owner = auth.uid()) OR (secondary_owner = auth.uid())));


create policy "Anyone can view active plans"
on "public"."plans"
as permissive
for select
to public
using (((is_active = true) AND (deleted_at IS NULL)));


create policy "Org admins can manage role permissions"
on "public"."role_permissions"
as permissive
for all
to public
using ((is_super_admin(auth.uid()) OR has_permission_in_org(auth.uid(), organization_id, 'manage_roles'::character varying) OR is_org_owner(auth.uid(), organization_id)));


create policy "Users can view role permissions in their orgs"
on "public"."role_permissions"
as permissive
for select
to public
using ((is_super_admin(auth.uid()) OR user_belongs_to_org(auth.uid(), organization_id)));


create policy "Org admins can manage roles"
on "public"."roles"
as permissive
for all
to public
using ((is_super_admin(auth.uid()) OR has_permission_in_org(auth.uid(), organization_id, 'manage_roles'::character varying) OR is_org_owner(auth.uid(), organization_id)));


create policy "Users can view roles in their orgs"
on "public"."roles"
as permissive
for select
to public
using ((is_super_admin(auth.uid()) OR user_belongs_to_org(auth.uid(), organization_id)));


create policy "Users can manage their own saved jobs"
on "public"."saved_jobs"
as permissive
for all
to public
using ((user_id = auth.uid()));


create policy "Org admins can manage sites"
on "public"."sites"
as permissive
for all
to public
using ((is_super_admin(auth.uid()) OR has_permission_in_org(auth.uid(), organization_id, 'manage_sites'::character varying) OR is_org_owner(auth.uid(), organization_id)));


create policy "Users can view sites in their orgs"
on "public"."sites"
as permissive
for select
to public
using ((is_super_admin(auth.uid()) OR user_belongs_to_org(auth.uid(), organization_id)));


create policy "Anyone can view skills"
on "public"."skills"
as permissive
for select
to public
using (true);


create policy "Super admins can manage skills"
on "public"."skills"
as permissive
for all
to public
using (is_super_admin(auth.uid()));


create policy "Users can manage their own education"
on "public"."user_education"
as permissive
for all
to public
using ((user_id = auth.uid()));


create policy "Users can manage their own job history"
on "public"."user_job_history"
as permissive
for all
to public
using ((user_id = auth.uid()));


create policy "Users can manage their own skills"
on "public"."user_skills"
as permissive
for all
to public
using ((user_id = auth.uid()));


create policy "Users can only update their own record"
on "public"."users"
as permissive
for update
to public
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));


create policy "Users can update their own profile"
on "public"."users"
as permissive
for update
to public
using ((user_id = ( SELECT auth.uid() AS uid)))
with check ((user_id = ( SELECT auth.uid() AS uid)));


CREATE TRIGGER update_apps_updated_at BEFORE UPDATE ON public.apps FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_departments_updated_at BEFORE UPDATE ON public.departments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER audit_employees_trigger AFTER INSERT OR DELETE OR UPDATE ON public.employees FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON public.employees FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER audit_jobs_trigger AFTER INSERT OR DELETE OR UPDATE ON public.jobs FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON public.jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER audit_organizations_trigger AFTER INSERT OR DELETE OR UPDATE ON public.organizations FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER auto_setup_org_admin AFTER INSERT ON public.organizations FOR EACH ROW EXECUTE FUNCTION trigger_setup_org_admin();

CREATE TRIGGER enforce_max_organizations_per_user BEFORE INSERT OR UPDATE ON public.organizations FOR EACH ROW EXECUTE FUNCTION check_max_organizations_per_user();

CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON public.organizations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_plans_updated_at BEFORE UPDATE ON public.plans FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER audit_role_permissions_trigger AFTER INSERT OR DELETE OR UPDATE ON public.role_permissions FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_roles_trigger AFTER INSERT OR DELETE OR UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER update_roles_updated_at BEFORE UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sites_updated_at BEFORE UPDATE ON public.sites FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


