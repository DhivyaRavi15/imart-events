-- Temporarily disable audit triggers during seeding
SET session_replication_role = replica;

INSERT INTO
    organization_types (type_name, description)
VALUES
    ('retail', 'Retail businesses and stores'),
    ('restaurant', 'Food service establishments'),
    ('education', 'Educational institutions'),
    ('healthcare', 'Medical and healthcare facilities'),
    ('media', 'Modeling, TV Channels, Ad agency,'),
    (
        'petrol_bunk',
        'Fuel stations and service centers'
    );

INSERT INTO
    ethnicities (ethnicity_name, country_code)
VALUES
    ('North Indian', 'IND'),
    ('South Indian', 'IND'),
    ('East Indian', 'IND'),
    ('West Indian', 'IND');

INSERT INTO
    plans (
        plan_name,
        description,
        price,
        currency,
        is_free_trial_avail,
        duration_days,
        is_active
    )
VALUES
    (
        'Trial',
        'Trial plan with essential features',
        1.00,
        'INR',
        true,
        365,
        true
    ),
    (
        'Basic',
        'Basic plan with essential features',
        499.00,
        'INR',
        false,
        30,
        true
    ),
    (
        'Professional',
        'Professional plan with advanced features',
        999.00,
        'INR',
        false,
        30,
        true
    ),
    (
        'Enterprise',
        'Enterprise plan with all features',
        1999.99,
        'INR',
        false,
        30,
        true
    );

INSERT INTO
    apps (
        app_name,
        app_description,
        app_version,
        app_icon_url,
        is_active, -- This has a DEFAULT, but explicitly including for clarity
        app_category,
        developer,
        release_date,
        required_permissions,
        external_url,
        app_settings_schema
    )
VALUES
    (
        'jobs', -- app_name
        'An application to manage job listings and applications.', -- app_description
        '1.0.0', -- app_version
        '', -- app_icon_url
        TRUE,
        'Productivity',
        'focuspax',
        '2025-07-10',
        '{}',
        '',
        '{}'
    );

INSERT INTO
    skills (skill_name)
VALUES
    ('Customer Service Excellence'),
    ('Sales Techniques'),
    ('Inventory Management'),
    ('Point-of-Sale (POS) Operations'),
    ('Merchandising'),
    ('Product Knowledge'),
    ('Loss Prevention'),
    ('Returns Processing'),
    ('Cashiering'),
    ('Visual Merchandising'),
    ('Food Preparation'),
    ('Cooking Techniques'),
    ('Food Safety & Hygiene'),
    ('Order Taking'),
    ('Table Service'),
    ('Bartending'),
    ('Kitchen Management'),
    ('Menu Knowledge'),
    ('Waste Reduction'),
    ('Restaurant Inventory Management'),
    ('Teaching Methods'),
    ('Curriculum Development'),
    ('Classroom Management'),
    ('Student Assessment'),
    ('Lesson Planning'),
    ('Educational Technology'),
    ('Child Psychology'),
    ('Parent Communication'),
    ('Special Education Support'),
    ('Tutoring'),
    ('Patient Care'),
    ('Medical Terminology'),
    ('First Aid'),
    ('Vital Signs Monitoring'),
    ('Medical Record Keeping'),
    ('HIPAA Compliance'),
    ('Infection Control'),
    ('Diagnostic Procedures'),
    ('Patient Education'),
    ('Sterile Technique'),
    ('Content Creation'),
    ('Video Editing'),
    ('Photography'),
    ('Graphic Design'),
    ('Digital Marketing'),
    ('Social Media Management'),
    ('Public Relations'),
    ('Copywriting'),
    ('Scriptwriting'),
    ('Broadcasting Operations'),
    ('Fuel Dispensing'),
    ('Forecourt Management'),
    ('Vehicle Fluid Checks'),
    ('Basic Vehicle Maintenance Advice'),
    ('Site Safety Procedures');

-- Create a super_admin role if it doesn't exist
INSERT INTO
    public.roles (
        role_id,
        organization_id,
        role_name,
        role_description
    )
SELECT
    gen_random_uuid (),
    NULL, -- NULL organization_id indicates this is a system-wide role
    'Super Admin',
    'System-wide administrator with access to all organizations'
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            public.roles
        WHERE
            role_name = 'Super Admin'
            AND organization_id IS NULL
    ) RETURNING role_id;

-- Re-enable audit triggers after seeding
SET session_replication_role = DEFAULT;