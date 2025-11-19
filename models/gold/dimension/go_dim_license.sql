{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (process_name, source_table, target_table, process_status, start_time, load_date, source_system) VALUES ('go_dim_license', 'SI_LICENSES', 'go_dim_license', 'STARTED', CURRENT_TIMESTAMP(), CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET process_status = 'COMPLETED', end_time = CURRENT_TIMESTAMP() WHERE target_table = 'go_dim_license' AND process_status = 'STARTED'"
) }}

-- License dimension with pricing information
WITH source_licenses AS (
    SELECT DISTINCT
        COALESCE(TRIM(license_type), 'Unknown License') AS license_type,
        start_date,
        end_date,
        source_system
    FROM {{ source('silver', 'si_licenses') }}
    WHERE license_type IS NOT NULL
),

transformed_licenses AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY license_type) AS license_id,
        INITCAP(license_type) AS license_type,
        CASE 
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 'Standard'
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 'Professional'
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 'Enterprise'
            ELSE 'Other'
        END AS license_category,
        CASE 
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 'Tier 1'
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 'Tier 2'
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 'Tier 3'
            ELSE 'Tier 0'
        END AS license_tier,
        CASE 
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 100
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 500
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 1000
            ELSE 50
        END AS max_participants,
        CASE 
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 5
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 100
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 1000
            ELSE 1
        END AS storage_limit_gb,
        CASE 
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 40
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 100
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 500
            ELSE 0
        END AS recording_limit_hours,
        CASE 
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN TRUE
            ELSE FALSE
        END AS admin_features_included,
        CASE 
            WHEN UPPER(license_type) LIKE '%PRO%' OR UPPER(license_type) LIKE '%ENTERPRISE%' THEN TRUE
            ELSE FALSE
        END AS api_access_included,
        CASE 
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN TRUE
            ELSE FALSE
        END AS sso_support_included,
        CASE 
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 14.99
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 19.99
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 39.99
            ELSE 0.00
        END AS monthly_price,
        CASE 
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 149.90
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 199.90
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 399.90
            ELSE 0.00
        END AS annual_price,
        'Standard license benefits for ' || license_type AS license_benefits,
        COALESCE(start_date, '1900-01-01'::DATE) AS effective_start_date,
        COALESCE(end_date, '9999-12-31'::DATE) AS effective_end_date,
        TRUE AS is_current_record,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
    FROM source_licenses
)

SELECT * FROM transformed_licenses
