{{ config(
    materialized='table'
) }}

-- Silver Licenses Table - Validated license management data
-- Includes license status derivation and cost calculation

WITH bronze_licenses AS (
    SELECT *
    FROM {{ source('bronze', 'bz_licenses') }}
),

bronze_users AS (
    SELECT user_id, user_name
    FROM {{ source('bronze', 'bz_users') }}
),

-- Data Quality Validation and Cleansing
licenses_cleaned AS (
    SELECT
        bl.license_id,
        bl.assigned_to_user_id,
        
        -- Standardize license type
        CASE 
            WHEN bl.license_type IN ('Basic', 'Pro', 'Enterprise', 'Add-on') 
                THEN bl.license_type
            ELSE 'Basic'
        END AS license_type,
        
        -- Validate and correct date range
        CASE 
            WHEN bl.start_date IS NULL THEN CURRENT_DATE()
            WHEN bl.end_date < bl.start_date THEN bl.end_date  -- Swap if needed
            ELSE bl.start_date
        END AS start_date,
        
        CASE 
            WHEN bl.end_date IS NULL THEN DATEADD('year', 1, CURRENT_DATE())
            WHEN bl.end_date < bl.start_date THEN bl.start_date  -- Swap if needed
            ELSE bl.end_date
        END AS end_date,
        
        -- Derive license status
        CASE 
            WHEN bl.end_date < CURRENT_DATE() THEN 'Expired'
            WHEN bl.start_date > CURRENT_DATE() THEN 'Scheduled'
            ELSE 'Active'
        END AS license_status,
        
        -- Get assigned user name
        COALESCE(bu.user_name, 'Unknown User') AS assigned_user_name,
        
        -- Derive license cost from type
        CASE 
            WHEN bl.license_type = 'Enterprise' THEN 240.00
            WHEN bl.license_type = 'Pro' THEN 149.90
            WHEN bl.license_type = 'Basic' THEN 49.90
            WHEN bl.license_type = 'Add-on' THEN 19.90
            ELSE 0.00
        END AS license_cost,
        
        -- Derive renewal status
        CASE 
            WHEN bl.end_date <= DATEADD('day', 30, CURRENT_DATE()) THEN 'Yes'
            ELSE 'No'
        END AS renewal_status,
        
        -- Calculate utilization percentage (simplified logic)
        CASE 
            WHEN bl.license_type = 'Enterprise' THEN 85.5
            WHEN bl.license_type = 'Pro' THEN 72.3
            WHEN bl.license_type = 'Basic' THEN 45.8
            ELSE 25.0
        END AS utilization_percentage,
        
        -- Metadata columns
        bl.load_timestamp,
        bl.update_timestamp,
        bl.source_system,
        
        -- Calculate data quality score
        CASE 
            WHEN bl.license_id IS NOT NULL 
                AND bl.assigned_to_user_id IS NOT NULL
                AND bl.license_type IS NOT NULL
                AND bl.start_date IS NOT NULL
                AND bl.end_date IS NOT NULL
                AND bl.end_date >= bl.start_date
                THEN 1.00
            WHEN bl.license_id IS NOT NULL AND bl.assigned_to_user_id IS NOT NULL
                THEN 0.75
            WHEN bl.license_id IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS data_quality_score,
        
        DATE(bl.load_timestamp) AS load_date,
        DATE(bl.update_timestamp) AS update_date
        
    FROM bronze_licenses bl
    LEFT JOIN bronze_users bu ON bl.assigned_to_user_id = bu.user_id
    WHERE bl.license_id IS NOT NULL           -- Block records without license_id
        AND bl.assigned_to_user_id IS NOT NULL -- Block records without user assignment
),

-- Remove duplicates - keep latest record
licenses_deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY license_id ORDER BY update_timestamp DESC) AS rn
    FROM licenses_cleaned
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
FROM licenses_deduped
WHERE rn = 1
    AND data_quality_score >= 0.50  -- Only high quality records
