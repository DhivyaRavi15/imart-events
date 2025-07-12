export type Json
  = | string
    | number
    | boolean
    | null
    | { [key: string]: Json | undefined }
    | Json[]

export interface Database {
  public: {
    Tables: {
      apps: {
        Row: {
          app_category: string | null
          app_description: string | null
          app_icon_url: string | null
          app_id: string
          app_name: string
          app_settings_schema: Json | null
          app_version: string | null
          created_at: string | null
          developer: string | null
          external_url: string | null
          is_active: boolean | null
          release_date: string | null
          required_permissions: Json | null
          updated_at: string | null
        }
        Insert: {
          app_category?: string | null
          app_description?: string | null
          app_icon_url?: string | null
          app_id?: string
          app_name: string
          app_settings_schema?: Json | null
          app_version?: string | null
          created_at?: string | null
          developer?: string | null
          external_url?: string | null
          is_active?: boolean | null
          release_date?: string | null
          required_permissions?: Json | null
          updated_at?: string | null
        }
        Update: {
          app_category?: string | null
          app_description?: string | null
          app_icon_url?: string | null
          app_id?: string
          app_name?: string
          app_settings_schema?: Json | null
          app_version?: string | null
          created_at?: string | null
          developer?: string | null
          external_url?: string | null
          is_active?: boolean | null
          release_date?: string | null
          required_permissions?: Json | null
          updated_at?: string | null
        }
        Relationships: []
      }
      departments: {
        Row: {
          created_at: string | null
          department_description: string | null
          department_id: string
          department_name: string
          organization_id: string | null
          status: string | null
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          department_description?: string | null
          department_id?: string
          department_name: string
          organization_id?: string | null
          status?: string | null
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          department_description?: string | null
          department_id?: string
          department_name?: string
          organization_id?: string | null
          status?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'departments_organization_id_fkey'
            columns: ['organization_id']
            isOneToOne: false
            referencedRelation: 'organizations'
            referencedColumns: ['organization_id']
          },
        ]
      }
      employee_hierarchy: {
        Row: {
          created_at: string | null
          employee_id: string | null
          hierarchy_id: string
          manager_employee_id: string | null
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          employee_id?: string | null
          hierarchy_id?: string
          manager_employee_id?: string | null
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          employee_id?: string | null
          hierarchy_id?: string
          manager_employee_id?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'employee_hierarchy_employee_id_fkey'
            columns: ['employee_id']
            isOneToOne: false
            referencedRelation: 'employees'
            referencedColumns: ['employee_id']
          },
          {
            foreignKeyName: 'employee_hierarchy_manager_employee_id_fkey'
            columns: ['manager_employee_id']
            isOneToOne: false
            referencedRelation: 'employees'
            referencedColumns: ['employee_id']
          },
        ]
      }
      employees: {
        Row: {
          address: string | null
          created_at: string | null
          data_of_birth: string | null
          department_id: string | null
          email: string | null
          employee_id: string
          first_name: string
          gender: string | null
          hire_date: string | null
          image_url: string | null
          job_title: string | null
          last_name: string | null
          linkedin_url: string | null
          organization_id: string | null
          phone: string | null
          role_id: string | null
          site_id: string | null
          status: string | null
          updated_at: string | null
        }
        Insert: {
          address?: string | null
          created_at?: string | null
          data_of_birth?: string | null
          department_id?: string | null
          email?: string | null
          employee_id?: string
          first_name: string
          gender?: string | null
          hire_date?: string | null
          image_url?: string | null
          job_title?: string | null
          last_name?: string | null
          linkedin_url?: string | null
          organization_id?: string | null
          phone?: string | null
          role_id?: string | null
          site_id?: string | null
          status?: string | null
          updated_at?: string | null
        }
        Update: {
          address?: string | null
          created_at?: string | null
          data_of_birth?: string | null
          department_id?: string | null
          email?: string | null
          employee_id?: string
          first_name?: string
          gender?: string | null
          hire_date?: string | null
          image_url?: string | null
          job_title?: string | null
          last_name?: string | null
          linkedin_url?: string | null
          organization_id?: string | null
          phone?: string | null
          role_id?: string | null
          site_id?: string | null
          status?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'employees_department_id_fkey'
            columns: ['department_id']
            isOneToOne: false
            referencedRelation: 'departments'
            referencedColumns: ['department_id']
          },
          {
            foreignKeyName: 'employees_organization_id_fkey'
            columns: ['organization_id']
            isOneToOne: false
            referencedRelation: 'organizations'
            referencedColumns: ['organization_id']
          },
          {
            foreignKeyName: 'employees_role_id_fkey'
            columns: ['role_id']
            isOneToOne: false
            referencedRelation: 'roles'
            referencedColumns: ['role_id']
          },
          {
            foreignKeyName: 'employees_site_id_fkey'
            columns: ['site_id']
            isOneToOne: false
            referencedRelation: 'sites'
            referencedColumns: ['site_id']
          },
        ]
      }
      ethnicities: {
        Row: {
          country_code: string | null
          ethnicity_id: string
          ethnicity_name: string
        }
        Insert: {
          country_code?: string | null
          ethnicity_id?: string
          ethnicity_name: string
        }
        Update: {
          country_code?: string | null
          ethnicity_id?: string
          ethnicity_name?: string
        }
        Relationships: []
      }
      job_categories: {
        Row: {
          category_id: string
          category_name: string | null
          organization_id: string | null
        }
        Insert: {
          category_id: string
          category_name?: string | null
          organization_id?: string | null
        }
        Update: {
          category_id?: string
          category_name?: string | null
          organization_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'job_categories_organization_id_fkey'
            columns: ['organization_id']
            isOneToOne: false
            referencedRelation: 'organizations'
            referencedColumns: ['organization_id']
          },
        ]
      }
      job_skills: {
        Row: {
          job_id: string | null
          job_skill_id: string
          skill_id: string | null
        }
        Insert: {
          job_id?: string | null
          job_skill_id: string
          skill_id?: string | null
        }
        Update: {
          job_id?: string | null
          job_skill_id?: string
          skill_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'job_skills_job_id_fkey'
            columns: ['job_id']
            isOneToOne: false
            referencedRelation: 'jobs'
            referencedColumns: ['job_id']
          },
          {
            foreignKeyName: 'job_skills_skill_id_fkey'
            columns: ['skill_id']
            isOneToOne: false
            referencedRelation: 'skills'
            referencedColumns: ['skill_id']
          },
        ]
      }
      jobs: {
        Row: {
          application_deadline: string | null
          approval_date: string | null
          approved_by: string | null
          city: string | null
          country: string | null
          created_by: string | null
          currency: string | null
          department_id: string | null
          education_required: string | null
          experience_required: string | null
          is_internal: boolean | null
          job_category: string | null
          job_description: string | null
          job_id: string
          job_title: string | null
          job_type: string | null
          location: string | null
          organization_id: string | null
          organization_type_id: string | null
          postal_code: string | null
          posting_date: string | null
          salary_range_max: number | null
          salary_range_min: number | null
          site_id: string | null
          skills_required: string | null
          state: string | null
          status: string | null
        }
        Insert: {
          application_deadline?: string | null
          approval_date?: string | null
          approved_by?: string | null
          city?: string | null
          country?: string | null
          created_by?: string | null
          currency?: string | null
          department_id?: string | null
          education_required?: string | null
          experience_required?: string | null
          is_internal?: boolean | null
          job_category?: string | null
          job_description?: string | null
          job_id: string
          job_title?: string | null
          job_type?: string | null
          location?: string | null
          organization_id?: string | null
          organization_type_id?: string | null
          postal_code?: string | null
          posting_date?: string | null
          salary_range_max?: number | null
          salary_range_min?: number | null
          site_id?: string | null
          skills_required?: string | null
          state?: string | null
          status?: string | null
        }
        Update: {
          application_deadline?: string | null
          approval_date?: string | null
          approved_by?: string | null
          city?: string | null
          country?: string | null
          created_by?: string | null
          currency?: string | null
          department_id?: string | null
          education_required?: string | null
          experience_required?: string | null
          is_internal?: boolean | null
          job_category?: string | null
          job_description?: string | null
          job_id?: string
          job_title?: string | null
          job_type?: string | null
          location?: string | null
          organization_id?: string | null
          organization_type_id?: string | null
          postal_code?: string | null
          posting_date?: string | null
          salary_range_max?: number | null
          salary_range_min?: number | null
          site_id?: string | null
          skills_required?: string | null
          state?: string | null
          status?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'jobs_approved_by_fkey'
            columns: ['approved_by']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['user_id']
          },
          {
            foreignKeyName: 'jobs_created_by_fkey'
            columns: ['created_by']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['user_id']
          },
          {
            foreignKeyName: 'jobs_department_id_fkey'
            columns: ['department_id']
            isOneToOne: false
            referencedRelation: 'departments'
            referencedColumns: ['department_id']
          },
          {
            foreignKeyName: 'jobs_job_category_fkey'
            columns: ['job_category']
            isOneToOne: false
            referencedRelation: 'job_categories'
            referencedColumns: ['category_id']
          },
          {
            foreignKeyName: 'jobs_organization_id_fkey'
            columns: ['organization_id']
            isOneToOne: false
            referencedRelation: 'organizations'
            referencedColumns: ['organization_id']
          },
          {
            foreignKeyName: 'jobs_organization_type_id_fkey'
            columns: ['organization_type_id']
            isOneToOne: false
            referencedRelation: 'organization_types'
            referencedColumns: ['organization_type_id']
          },
          {
            foreignKeyName: 'jobs_site_id_fkey'
            columns: ['site_id']
            isOneToOne: false
            referencedRelation: 'sites'
            referencedColumns: ['site_id']
          },
        ]
      }
      notifications: {
        Row: {
          created_at: string | null
          is_read: boolean | null
          message: string | null
          notification_id: string
          notification_type: string | null
          related_id: string | null
          user_id: string | null
        }
        Insert: {
          created_at?: string | null
          is_read?: boolean | null
          message?: string | null
          notification_id: string
          notification_type?: string | null
          related_id?: string | null
          user_id?: string | null
        }
        Update: {
          created_at?: string | null
          is_read?: boolean | null
          message?: string | null
          notification_id?: string
          notification_type?: string | null
          related_id?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'notifications_user_id_fkey'
            columns: ['user_id']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['user_id']
          },
        ]
      }
      organization_apps: {
        Row: {
          app_id: string | null
          created_at: string | null
          installation_date: string | null
          is_active: boolean | null
          organization_app_id: string
          organization_id: string | null
          organization_plan_id: string | null
          updated_at: string | null
        }
        Insert: {
          app_id?: string | null
          created_at?: string | null
          installation_date?: string | null
          is_active?: boolean | null
          organization_app_id?: string
          organization_id?: string | null
          organization_plan_id?: string | null
          updated_at?: string | null
        }
        Update: {
          app_id?: string | null
          created_at?: string | null
          installation_date?: string | null
          is_active?: boolean | null
          organization_app_id?: string
          organization_id?: string | null
          organization_plan_id?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'organization_apps_app_id_fkey'
            columns: ['app_id']
            isOneToOne: false
            referencedRelation: 'apps'
            referencedColumns: ['app_id']
          },
          {
            foreignKeyName: 'organization_apps_organization_id_fkey'
            columns: ['organization_id']
            isOneToOne: false
            referencedRelation: 'organizations'
            referencedColumns: ['organization_id']
          },
          {
            foreignKeyName: 'organization_apps_organization_plan_id_fkey'
            columns: ['organization_plan_id']
            isOneToOne: false
            referencedRelation: 'organization_plans'
            referencedColumns: ['organization_plan_id']
          },
        ]
      }
      organization_organization_types: {
        Row: {
          created_at: string | null
          organization_id: string | null
          organization_organization_type_id: string
          organization_type_id: string | null
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          organization_id?: string | null
          organization_organization_type_id?: string
          organization_type_id?: string | null
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          organization_id?: string | null
          organization_organization_type_id?: string
          organization_type_id?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'organization_organization_types_organization_id_fkey'
            columns: ['organization_id']
            isOneToOne: false
            referencedRelation: 'organizations'
            referencedColumns: ['organization_id']
          },
          {
            foreignKeyName: 'organization_organization_types_organization_type_id_fkey'
            columns: ['organization_type_id']
            isOneToOne: false
            referencedRelation: 'organization_types'
            referencedColumns: ['organization_type_id']
          },
        ]
      }
      organization_plans: {
        Row: {
          billing_cycle: string | null
          cancelled_at: string | null
          created_at: string | null
          discount_applied: boolean | null
          end_date: string
          ends_at: string | null
          free_trail_ends_at: string | null
          is_active: boolean | null
          notes: string | null
          organization_id: string | null
          organization_plan_id: string
          payment_id: string | null
          payment_method: string | null
          payment_status: string | null
          plan_id: string | null
          quantity: number | null
          renewal_date: string | null
          start_date: string
          trial_end_notification_sent: boolean | null
          updated_at: string | null
        }
        Insert: {
          billing_cycle?: string | null
          cancelled_at?: string | null
          created_at?: string | null
          discount_applied?: boolean | null
          end_date: string
          ends_at?: string | null
          free_trail_ends_at?: string | null
          is_active?: boolean | null
          notes?: string | null
          organization_id?: string | null
          organization_plan_id: string
          payment_id?: string | null
          payment_method?: string | null
          payment_status?: string | null
          plan_id?: string | null
          quantity?: number | null
          renewal_date?: string | null
          start_date: string
          trial_end_notification_sent?: boolean | null
          updated_at?: string | null
        }
        Update: {
          billing_cycle?: string | null
          cancelled_at?: string | null
          created_at?: string | null
          discount_applied?: boolean | null
          end_date?: string
          ends_at?: string | null
          free_trail_ends_at?: string | null
          is_active?: boolean | null
          notes?: string | null
          organization_id?: string | null
          organization_plan_id?: string
          payment_id?: string | null
          payment_method?: string | null
          payment_status?: string | null
          plan_id?: string | null
          quantity?: number | null
          renewal_date?: string | null
          start_date?: string
          trial_end_notification_sent?: boolean | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'organization_plans_organization_id_fkey'
            columns: ['organization_id']
            isOneToOne: false
            referencedRelation: 'organizations'
            referencedColumns: ['organization_id']
          },
          {
            foreignKeyName: 'organization_plans_plan_id_fkey'
            columns: ['plan_id']
            isOneToOne: false
            referencedRelation: 'plans'
            referencedColumns: ['plan_id']
          },
        ]
      }
      organization_types: {
        Row: {
          created_at: string | null
          description: string | null
          organization_type_id: string
          type_name: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          organization_type_id?: string
          type_name: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          description?: string | null
          organization_type_id?: string
          type_name?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      organizations: {
        Row: {
          account_status: string | null
          address: string | null
          city: string | null
          contact_email: string | null
          contact_person: string | null
          contact_phone: string | null
          country: string | null
          created_by: string | null
          description: string | null
          google_business_category: string | null
          google_maps_url: string | null
          google_place_id: string | null
          logo_url: string | null
          organization_description: string | null
          organization_id: string
          organization_name: string
          postal_code: string | null
          primary_owner: string | null
          registration_date: string | null
          secondary_contact_person: string | null
          secondary_contact_phone: string | null
          secondary_owner: string | null
          secondary_phone: string | null
          state: string | null
          website_url: string | null
        }
        Insert: {
          account_status?: string | null
          address?: string | null
          city?: string | null
          contact_email?: string | null
          contact_person?: string | null
          contact_phone?: string | null
          country?: string | null
          created_by?: string | null
          description?: string | null
          google_business_category?: string | null
          google_maps_url?: string | null
          google_place_id?: string | null
          logo_url?: string | null
          organization_description?: string | null
          organization_id?: string
          organization_name: string
          postal_code?: string | null
          primary_owner?: string | null
          registration_date?: string | null
          secondary_contact_person?: string | null
          secondary_contact_phone?: string | null
          secondary_owner?: string | null
          secondary_phone?: string | null
          state?: string | null
          website_url?: string | null
        }
        Update: {
          account_status?: string | null
          address?: string | null
          city?: string | null
          contact_email?: string | null
          contact_person?: string | null
          contact_phone?: string | null
          country?: string | null
          created_by?: string | null
          description?: string | null
          google_business_category?: string | null
          google_maps_url?: string | null
          google_place_id?: string | null
          logo_url?: string | null
          organization_description?: string | null
          organization_id?: string
          organization_name?: string
          postal_code?: string | null
          primary_owner?: string | null
          registration_date?: string | null
          secondary_contact_person?: string | null
          secondary_contact_phone?: string | null
          secondary_owner?: string | null
          secondary_phone?: string | null
          state?: string | null
          website_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'organizations_created_by_fkey'
            columns: ['created_by']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['user_id']
          },
          {
            foreignKeyName: 'organizations_primary_owner_fkey'
            columns: ['primary_owner']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['user_id']
          },
          {
            foreignKeyName: 'organizations_secondary_owner_fkey'
            columns: ['secondary_owner']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['user_id']
          },
        ]
      }
      plan_apps: {
        Row: {
          app_id: string | null
          created_at: string | null
          plan_app_id: string
          plan_id: string | null
          updated_at: string | null
        }
        Insert: {
          app_id?: string | null
          created_at?: string | null
          plan_app_id?: string
          plan_id?: string | null
          updated_at?: string | null
        }
        Update: {
          app_id?: string | null
          created_at?: string | null
          plan_app_id?: string
          plan_id?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'plan_apps_app_id_fkey'
            columns: ['app_id']
            isOneToOne: false
            referencedRelation: 'apps'
            referencedColumns: ['app_id']
          },
          {
            foreignKeyName: 'plan_apps_plan_id_fkey'
            columns: ['plan_id']
            isOneToOne: false
            referencedRelation: 'plans'
            referencedColumns: ['plan_id']
          },
        ]
      }
      plans: {
        Row: {
          created_at: string | null
          currency: string | null
          description: string | null
          duration_days: number | null
          features: Json | null
          free_trail_period: unknown | null
          is_active: boolean | null
          is_free_trail_avail: boolean | null
          plan_id: string
          plan_name: string
          price: number
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          currency?: string | null
          description?: string | null
          duration_days?: number | null
          features?: Json | null
          free_trail_period?: unknown | null
          is_active?: boolean | null
          is_free_trail_avail?: boolean | null
          plan_id: string
          plan_name: string
          price: number
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          currency?: string | null
          description?: string | null
          duration_days?: number | null
          features?: Json | null
          free_trail_period?: unknown | null
          is_active?: boolean | null
          is_free_trail_avail?: boolean | null
          plan_id?: string
          plan_name?: string
          price?: number
          updated_at?: string | null
        }
        Relationships: []
      }
      roles: {
        Row: {
          created_at: string | null
          organization_id: string | null
          role_description: string | null
          role_id: string
          role_name: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          organization_id?: string | null
          role_description?: string | null
          role_id?: string
          role_name: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          organization_id?: string | null
          role_description?: string | null
          role_id?: string
          role_name?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'roles_organization_id_fkey'
            columns: ['organization_id']
            isOneToOne: false
            referencedRelation: 'organizations'
            referencedColumns: ['organization_id']
          },
        ]
      }
      saved_jobs: {
        Row: {
          job_id: string | null
          saved_date: string | null
          saved_job_id: string
          user_id: string | null
        }
        Insert: {
          job_id?: string | null
          saved_date?: string | null
          saved_job_id: string
          user_id?: string | null
        }
        Update: {
          job_id?: string | null
          saved_date?: string | null
          saved_job_id?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'saved_jobs_job_id_fkey'
            columns: ['job_id']
            isOneToOne: false
            referencedRelation: 'jobs'
            referencedColumns: ['job_id']
          },
          {
            foreignKeyName: 'saved_jobs_user_id_fkey'
            columns: ['user_id']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['user_id']
          },
        ]
      }
      sites: {
        Row: {
          address: string | null
          contact_email: string | null
          contact_person: string | null
          contact_phone: string | null
          created_at: string | null
          google_business_information: string | null
          google_location: string | null
          organization_id: string | null
          site_description: string | null
          site_id: string
          site_name: string
          status: string | null
          updated_at: string | null
        }
        Insert: {
          address?: string | null
          contact_email?: string | null
          contact_person?: string | null
          contact_phone?: string | null
          created_at?: string | null
          google_business_information?: string | null
          google_location?: string | null
          organization_id?: string | null
          site_description?: string | null
          site_id?: string
          site_name: string
          status?: string | null
          updated_at?: string | null
        }
        Update: {
          address?: string | null
          contact_email?: string | null
          contact_person?: string | null
          contact_phone?: string | null
          created_at?: string | null
          google_business_information?: string | null
          google_location?: string | null
          organization_id?: string | null
          site_description?: string | null
          site_id?: string
          site_name?: string
          status?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'sites_organization_id_fkey'
            columns: ['organization_id']
            isOneToOne: false
            referencedRelation: 'organizations'
            referencedColumns: ['organization_id']
          },
        ]
      }
      skills: {
        Row: {
          skill_id: string
          skill_name: string | null
        }
        Insert: {
          skill_id: string
          skill_name?: string | null
        }
        Update: {
          skill_id?: string
          skill_name?: string | null
        }
        Relationships: []
      }
      user_education: {
        Row: {
          created_at: string | null
          degree: string | null
          description: string | null
          education_id: string
          end_date: string | null
          field_of_study: string | null
          institution_name: string | null
          start_date: string | null
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          created_at?: string | null
          degree?: string | null
          description?: string | null
          education_id?: string
          end_date?: string | null
          field_of_study?: string | null
          institution_name?: string | null
          start_date?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          created_at?: string | null
          degree?: string | null
          description?: string | null
          education_id?: string
          end_date?: string | null
          field_of_study?: string | null
          institution_name?: string | null
          start_date?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'user_education_user_id_fkey'
            columns: ['user_id']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['user_id']
          },
        ]
      }
      user_ethnicities: {
        Row: {
          ethnicity_id: string | null
          user_ethnicity_id: string
          user_id: string | null
        }
        Insert: {
          ethnicity_id?: string | null
          user_ethnicity_id?: string
          user_id?: string | null
        }
        Update: {
          ethnicity_id?: string | null
          user_ethnicity_id?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'user_ethnicities_ethnicity_id_fkey'
            columns: ['ethnicity_id']
            isOneToOne: false
            referencedRelation: 'ethnicities'
            referencedColumns: ['ethnicity_id']
          },
          {
            foreignKeyName: 'user_ethnicities_user_id_fkey'
            columns: ['user_id']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['user_id']
          },
        ]
      }
      user_job_history: {
        Row: {
          company_name: string | null
          created_at: string | null
          description: string | null
          end_date: string | null
          job_history_id: string
          job_title: string | null
          start_date: string | null
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          company_name?: string | null
          created_at?: string | null
          description?: string | null
          end_date?: string | null
          job_history_id?: string
          job_title?: string | null
          start_date?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          company_name?: string | null
          created_at?: string | null
          description?: string | null
          end_date?: string | null
          job_history_id?: string
          job_title?: string | null
          start_date?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'user_job_history_user_id_fkey'
            columns: ['user_id']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['user_id']
          },
        ]
      }
      user_languages: {
        Row: {
          created_at: string | null
          language_id: string
          language_name: string | null
          proficiency: string | null
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          created_at?: string | null
          language_id?: string
          language_name?: string | null
          proficiency?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          created_at?: string | null
          language_id?: string
          language_name?: string | null
          proficiency?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: 'user_languages_user_id_fkey'
            columns: ['user_id']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['user_id']
          },
        ]
      }
      user_skills: {
        Row: {
          skill_id: string | null
          user_id: string | null
          user_skill_id: string
        }
        Insert: {
          skill_id?: string | null
          user_id?: string | null
          user_skill_id: string
        }
        Update: {
          skill_id?: string | null
          user_id?: string | null
          user_skill_id?: string
        }
        Relationships: [
          {
            foreignKeyName: 'user_skills_skill_id_fkey'
            columns: ['skill_id']
            isOneToOne: false
            referencedRelation: 'skills'
            referencedColumns: ['skill_id']
          },
          {
            foreignKeyName: 'user_skills_user_id_fkey'
            columns: ['user_id']
            isOneToOne: false
            referencedRelation: 'users'
            referencedColumns: ['user_id']
          },
        ]
      }
      users: {
        Row: {
          active_status: boolean | null
          address: string | null
          city: string | null
          country: string | null
          created_at: string | null
          current_job_org: string | null
          current_job_title: string | null
          date_of_birth: string | null
          email: string | null
          first_name: string
          gender: string | null
          image_url: string | null
          last_name: string | null
          last_sign_in_at: string | null
          linkedin_url: string | null
          phone: string | null
          postal_code: string | null
          registration_date: string | null
          resume_url: string | null
          state: string | null
          updated_at: string | null
          user_auth_id: string | null
          user_id: string
        }
        Insert: {
          active_status?: boolean | null
          address?: string | null
          city?: string | null
          country?: string | null
          created_at?: string | null
          current_job_org?: string | null
          current_job_title?: string | null
          date_of_birth?: string | null
          email?: string | null
          first_name: string
          gender?: string | null
          image_url?: string | null
          last_name?: string | null
          last_sign_in_at?: string | null
          linkedin_url?: string | null
          phone?: string | null
          postal_code?: string | null
          registration_date?: string | null
          resume_url?: string | null
          state?: string | null
          updated_at?: string | null
          user_auth_id?: string | null
          user_id?: string
        }
        Update: {
          active_status?: boolean | null
          address?: string | null
          city?: string | null
          country?: string | null
          created_at?: string | null
          current_job_org?: string | null
          current_job_title?: string | null
          date_of_birth?: string | null
          email?: string | null
          first_name?: string
          gender?: string | null
          image_url?: string | null
          last_name?: string | null
          last_sign_in_at?: string | null
          linkedin_url?: string | null
          phone?: string | null
          postal_code?: string | null
          registration_date?: string | null
          resume_url?: string | null
          state?: string | null
          updated_at?: string | null
          user_auth_id?: string | null
          user_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DefaultSchema = Database[Extract<keyof Database, 'public'>]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
  | keyof (DefaultSchema['Tables'] & DefaultSchema['Views'])
  | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof (Database[DefaultSchemaTableNameOrOptions['schema']]['Tables']
      & Database[DefaultSchemaTableNameOrOptions['schema']]['Views'])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database }
  ? (Database[DefaultSchemaTableNameOrOptions['schema']]['Tables']
    & Database[DefaultSchemaTableNameOrOptions['schema']]['Views'])[TableName] extends {
      Row: infer R
    }
      ? R
      : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema['Tables']
    & DefaultSchema['Views'])
    ? (DefaultSchema['Tables']
      & DefaultSchema['Views'])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
        ? R
        : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
  | keyof DefaultSchema['Tables']
  | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[DefaultSchemaTableNameOrOptions['schema']]['Tables']
    : never = never,
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaTableNameOrOptions['schema']]['Tables'][TableName] extends {
    Insert: infer I
  }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema['Tables']
    ? DefaultSchema['Tables'][DefaultSchemaTableNameOrOptions] extends {
      Insert: infer I
    }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
  | keyof DefaultSchema['Tables']
  | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[DefaultSchemaTableNameOrOptions['schema']]['Tables']
    : never = never,
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaTableNameOrOptions['schema']]['Tables'][TableName] extends {
    Update: infer U
  }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema['Tables']
    ? DefaultSchema['Tables'][DefaultSchemaTableNameOrOptions] extends {
      Update: infer U
    }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
  | keyof DefaultSchema['Enums']
  | { schema: keyof Database },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[DefaultSchemaEnumNameOrOptions['schema']]['Enums']
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaEnumNameOrOptions['schema']]['Enums'][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema['Enums']
    ? DefaultSchema['Enums'][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
  | keyof DefaultSchema['CompositeTypes']
  | { schema: keyof Database },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[PublicCompositeTypeNameOrOptions['schema']]['CompositeTypes']
    : never = never,
> = PublicCompositeTypeNameOrOptions extends { schema: keyof Database }
  ? Database[PublicCompositeTypeNameOrOptions['schema']]['CompositeTypes'][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema['CompositeTypes']
    ? DefaultSchema['CompositeTypes'][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
