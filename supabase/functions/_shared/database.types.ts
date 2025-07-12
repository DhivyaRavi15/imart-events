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

type PublicSchema = Database[Extract<keyof Database, "public">]

export type Tables<
  PublicTableNameOrOptions extends
    | keyof (PublicSchema["Tables"] & PublicSchema["Views"])
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof (Database[PublicTableNameOrOptions["schema"]]["Tables"] &
        Database[PublicTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? (Database[PublicTableNameOrOptions["schema"]]["Tables"] &
      Database[PublicTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : PublicTableNameOrOptions extends keyof (PublicSchema["Tables"] &
        PublicSchema["Views"])
    ? (PublicSchema["Tables"] &
        PublicSchema["Views"])[PublicTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  PublicTableNameOrOptions extends
    | keyof PublicSchema["Tables"]
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? Database[PublicTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : PublicTableNameOrOptions extends keyof PublicSchema["Tables"]
    ? PublicSchema["Tables"][PublicTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  PublicTableNameOrOptions extends
    | keyof PublicSchema["Tables"]
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? Database[PublicTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : PublicTableNameOrOptions extends keyof PublicSchema["Tables"]
    ? PublicSchema["Tables"][PublicTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  PublicEnumNameOrOptions extends
    | keyof PublicSchema["Enums"]
    | { schema: keyof Database },
  EnumName extends PublicEnumNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = PublicEnumNameOrOptions extends { schema: keyof Database }
  ? Database[PublicEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : PublicEnumNameOrOptions extends keyof PublicSchema["Enums"]
    ? PublicSchema["Enums"][PublicEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof PublicSchema["CompositeTypes"]
    | { schema: keyof Database },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends { schema: keyof Database }
  ? Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof PublicSchema["CompositeTypes"]
    ? PublicSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never