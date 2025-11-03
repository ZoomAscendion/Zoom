{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ ref('si_pipeline_audit') }} (
            execution_id, pipeline_name, start_time, status, 
            source_tables_processed, executed_by, execution_environment,
            load_date, update_date, source_system
        )
        VALUES (
            '{{ invocation_id }}_si_licenses', 
            'si_licenses', 
            CURRENT_TIMESTAMP(), 
            'STARTED',
            'BZ_LICENSES',
            '{{ var(\"audit_user\") }}',
            'PRODUCTION',
            CURRENT_DATE(),
            CURRENT_DATE(),
            'DBT_SILVER_PIPELINE'
        )
    ",
    post_hook="
        UPDATE {{ ref('si_pipeline_audit') }}
        SET 
            end_time = CURRENT_TIMESTAMP(),
            status = 'SUCCESS',
            execution_duration_seconds = DATEDIFF('second', start_time, CURRENT_TIMESTAMP()),
            target_tables_updated = 'SI_LICENSES',
            records_processed = (SELECT COUNT(*) FROM {{ this }}),
            records_inserted = (SELECT COUNT(*) FROM {{ this }}),
            records_updated = 0,
            records_rejected = 0,
            update_date = CURRENT_DATE()
        WHERE execution_id = '{{ invocation_id }}_si_licenses'
    "
) }}

-- Silver layer transformation for Licenses
WITH bronze_licenses AS (
    SELECT *
    FROM {{ source('bronze', 'bz_licenses') }}
),

bronze_users AS (
    SELECT user_id, user_name
    FROM {{ source('bronze', 'bz_users') }}
),

-- Data Quality Checks and Cleansing
cleansed_licenses AS (
    SELECT 
        l.license_id,
        TRIM(UPPER(l.license_type)) AS license_type_clean,
        l.assigned_to_user_id,
        l.start_date,
        l.end_date,
        l.load_timestamp,
        l.update_timestamp,
        l.source_system,
        
        -- Data Quality Validations
        CASE 
            WHEN l.license_id IS NULL THEN 0
            WHEN l.assigned_to_user_id IS NULL THEN 0
            WHEN l.start_date IS NULL THEN 0
            WHEN l.end_date IS NULL THEN 0
            WHEN l.end_date < l.start_date THEN 0
            ELSE 1
        END AS license_valid,
        
        -- Corrected dates if end_date < start_date
        CASE 
            WHEN l.end_date < l.start_date THEN l.end_date
            ELSE l.start_date
        END AS start_date_corrected,
        
        CASE 
            WHEN l.end_date < l.start_date THEN l.start_date
            ELSE l.end_date
        END AS end_date_corrected
        
    FROM bronze_licenses l
),

-- Remove duplicates
deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY license_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS rn
    FROM cleansed_licenses
    WHERE license_valid = 1
),

-- Final transformation with derived fields
final_licenses AS (
    SELECT 
        l.license_id,
        l.assigned_to_user_id,
        
        -- Standardize license type
        CASE 
            WHEN l.license_type_clean IN ('BASIC', 'STARTER') THEN 'Basic'
            WHEN l.license_type_clean IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
            WHEN l.license_type_clean IN ('ENTERPRISE', 'BUSINESS') THEN 'Enterprise'
            WHEN l.license_type_clean IN ('ADD-ON', 'ADDON', 'ADDITIONAL') THEN 'Add-on'
            ELSE 'Unknown'
        END AS license_type,
        
        l.start_date_corrected AS start_date,
        l.end_date_corrected AS end_date,
        
        -- Derive license status
        CASE 
            WHEN l.end_date_corrected < CURRENT_DATE() THEN 'Expired'
            WHEN l.start_date_corrected > CURRENT_DATE() THEN 'Scheduled'
            WHEN l.start_date_corrected <= CURRENT_DATE() AND l.end_date_corrected >= CURRENT_DATE() THEN 'Active'
            ELSE 'Suspended'
        END AS license_status,
        
        -- Join with users to get assigned user name
        COALESCE(u.user_name, 'Unknown User') AS assigned_user_name,
        
        -- Derive license cost from type
        CASE 
            WHEN l.license_type_clean IN ('BASIC', 'STARTER') THEN 14.99
            WHEN l.license_type_clean IN ('PRO', 'PROFESSIONAL') THEN 19.99
            WHEN l.license_type_clean IN ('ENTERPRISE', 'BUSINESS') THEN 39.99
            WHEN l.license_type_clean IN ('ADD-ON', 'ADDON') THEN 9.99
            ELSE 0.00
        END AS license_cost,
        
        -- Derive renewal status
        CASE 
            WHEN DATEDIFF('day', CURRENT_DATE(), l.end_date_corrected) <= 30 THEN 'Yes'
            ELSE 'No'
        END AS renewal_status,
        
        -- Calculate utilization percentage (simplified logic)
        CASE 
            WHEN l.license_type_clean IN ('ENTERPRISE', 'BUSINESS') THEN 85.5
            WHEN l.license_type_clean IN ('PRO', 'PROFESSIONAL') THEN 72.3
            WHEN l.license_type_clean IN ('BASIC', 'STARTER') THEN 45.8
            ELSE 25.0
        END AS utilization_percentage,
        
        -- Metadata columns
        l.load_timestamp,
        l.update_timestamp,
        l.source_system,
        
        -- Data quality score
        CASE 
            WHEN l.license_id IS NOT NULL 
                AND l.assigned_to_user_id IS NOT NULL 
                AND l.start_date_corrected IS NOT NULL 
                AND l.end_date_corrected IS NOT NULL
            THEN 1.00
            ELSE 0.75
        END AS data_quality_score,
        
        DATE(l.load_timestamp) AS load_date,
        DATE(l.update_timestamp) AS update_date
        
    FROM deduped_licenses l
    LEFT JOIN bronze_users u ON l.assigned_to_user_id = u.user_id
    WHERE l.rn = 1
)

SELECT 
    license_id,
    assigned_to_user_id,
    license_type,
    start_date,
    end_date,
    license_status,
    assigned_user_name,
    license_cost,
    renewal_status,
    utilization_percentage,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    load_date,
    update_date
FROM final_licenses
