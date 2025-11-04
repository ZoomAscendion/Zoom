{{ config(
    materialized='table'
) }}

-- Silver Layer Licenses Transformation
-- Source: Bronze.BZ_LICENSES
-- Target: Silver.SI_LICENSES
-- Description: Transforms and validates license assignment and management data

WITH bronze_licenses AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('bronze', 'bz_licenses') }}
    WHERE license_id IS NOT NULL
      AND assigned_to_user_id IS NOT NULL
),

user_info AS (
    SELECT 
        user_id,
        user_name
    FROM {{ ref('si_users') }}
),

-- Data Quality Validation and Cleansing
data_quality_checks AS (
    SELECT 
        bl.license_id,
        bl.assigned_to_user_id,
        
        -- Standardize license type
        CASE 
            WHEN UPPER(bl.license_type) IN ('BASIC', 'PRO', 'ENTERPRISE', 'ADD-ON') THEN UPPER(bl.license_type)
            ELSE 'UNKNOWN'
        END AS license_type_clean,
        
        -- Validate start date
        CASE 
            WHEN bl.start_date IS NULL THEN DATE(bl.load_timestamp)
            ELSE bl.start_date
        END AS start_date_clean,
        
        -- Validate end date
        CASE 
            WHEN bl.end_date IS NULL THEN DATEADD('year', 1, COALESCE(bl.start_date, DATE(bl.load_timestamp)))
            WHEN bl.end_date < bl.start_date THEN DATEADD('year', 1, bl.start_date)
            ELSE bl.end_date
        END AS end_date_clean,
        
        -- Get assigned user name
        COALESCE(ui.user_name, 'Unknown User') AS assigned_user_name,
        
        bl.load_timestamp,
        bl.update_timestamp,
        bl.source_system
    FROM bronze_licenses bl
    LEFT JOIN user_info ui ON bl.assigned_to_user_id = ui.user_id
),

-- Add derived fields
derived_fields AS (
    SELECT 
        *,
        -- Derive license status
        CASE 
            WHEN end_date_clean < CURRENT_DATE() THEN 'Expired'
            WHEN start_date_clean > CURRENT_DATE() THEN 'Pending'
            ELSE 'Active'
        END AS license_status,
        
        -- Derive license cost
        CASE 
            WHEN license_type_clean = 'BASIC' THEN 0.00
            WHEN license_type_clean = 'PRO' THEN 14.99
            WHEN license_type_clean = 'ENTERPRISE' THEN 19.99
            WHEN license_type_clean = 'ADD-ON' THEN 4.99
            ELSE 0.00
        END AS license_cost,
        
        -- Derive renewal status
        CASE 
            WHEN DATEDIFF('day', CURRENT_DATE(), end_date_clean) <= 30 THEN 'Yes'
            ELSE 'No'
        END AS renewal_status,
        
        -- Calculate utilization percentage (simplified)
        CASE 
            WHEN license_type_clean = 'ENTERPRISE' THEN 85.0
            WHEN license_type_clean = 'PRO' THEN 75.0
            WHEN license_type_clean = 'BASIC' THEN 60.0
            ELSE 50.0
        END AS utilization_percentage
    FROM data_quality_checks
),

-- Calculate data quality score
quality_scored AS (
    SELECT 
        *,
        -- Calculate data quality score
        (
            CASE WHEN license_type_clean != 'UNKNOWN' THEN 0.30 ELSE 0 END +
            CASE WHEN assigned_user_name != 'Unknown User' THEN 0.25 ELSE 0 END +
            CASE WHEN start_date_clean IS NOT NULL THEN 0.25 ELSE 0 END +
            CASE WHEN end_date_clean > start_date_clean THEN 0.20 ELSE 0 END
        ) AS data_quality_score
    FROM derived_fields
),

-- Remove duplicates keeping the most recent record
deduped_licenses AS (
    SELECT 
        license_id,
        assigned_to_user_id,
        license_type_clean AS license_type,
        start_date_clean AS start_date,
        end_date_clean AS end_date,
        license_status,
        assigned_user_name,
        license_cost,
        renewal_status,
        utilization_percentage,
        load_timestamp,
        update_timestamp,
        source_system,
        data_quality_score,
        ROW_NUMBER() OVER (PARTITION BY license_id ORDER BY update_timestamp DESC) AS rn
    FROM quality_scored
    WHERE data_quality_score >= {{ var('dq_score_threshold') }}
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
    DATE(load_timestamp) AS load_date,
    DATE(update_timestamp) AS update_date
FROM deduped_licenses
WHERE rn = 1
  AND start_date IS NOT NULL
  AND end_date > start_date
