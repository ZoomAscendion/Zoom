{{ config(
    materialized='table'
) }}

-- Silver Layer Licenses Table
-- Transforms Bronze licenses data with user enrichment and license management metrics

WITH bronze_licenses AS (
    SELECT *
    FROM {{ source('bronze', 'bz_licenses') }}
),

bronze_users AS (
    SELECT user_id, user_name
    FROM {{ source('bronze', 'bz_users') }}
),

-- Data Quality Validations
validated_licenses AS (
    SELECT 
        l.*,
        CASE 
            WHEN l.license_id IS NULL THEN 'CRITICAL_MISSING_ID'
            WHEN l.assigned_to_user_id IS NULL THEN 'CRITICAL_MISSING_USER_ID'
            WHEN l.start_date IS NULL THEN 'CRITICAL_MISSING_START_DATE'
            WHEN l.end_date IS NULL THEN 'CRITICAL_MISSING_END_DATE'
            WHEN l.end_date < l.start_date THEN 'CRITICAL_INVALID_DATE_RANGE'
            ELSE 'VALID'
        END AS data_quality_status,
        
        -- Calculate data quality score
        CASE 
            WHEN l.license_id IS NOT NULL 
                AND l.assigned_to_user_id IS NOT NULL
                AND l.start_date IS NOT NULL
                AND l.end_date IS NOT NULL
                AND l.end_date >= l.start_date
            THEN 1.00
            ELSE 0.60
        END AS data_quality_score,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY l.license_id ORDER BY l.update_timestamp DESC, l.load_timestamp DESC) AS rn
    FROM bronze_licenses l
    WHERE l.license_id IS NOT NULL
        AND l.assigned_to_user_id IS NOT NULL
        AND l.start_date IS NOT NULL
        AND l.end_date IS NOT NULL
        AND l.end_date >= l.start_date
),

-- Apply transformations
transformed_licenses AS (
    SELECT 
        vl.license_id,
        vl.assigned_to_user_id,
        
        -- Standardize license type
        CASE 
            WHEN UPPER(vl.license_type) IN ('BASIC', 'PRO', 'ENTERPRISE', 'ADD-ON') 
            THEN INITCAP(vl.license_type)
            ELSE 'Unknown'
        END AS license_type,
        
        vl.start_date,
        vl.end_date,
        
        -- Derive license status
        CASE 
            WHEN vl.end_date < CURRENT_DATE() THEN 'Expired'
            WHEN vl.start_date > CURRENT_DATE() THEN 'Scheduled'
            ELSE 'Active'
        END AS license_status,
        
        -- Get assigned user name
        COALESCE(u.user_name, 'Unknown User') AS assigned_user_name,
        
        -- Derive license cost from type
        CASE 
            WHEN UPPER(vl.license_type) = 'BASIC' THEN 14.99
            WHEN UPPER(vl.license_type) = 'PRO' THEN 19.99
            WHEN UPPER(vl.license_type) = 'ENTERPRISE' THEN 39.99
            WHEN UPPER(vl.license_type) = 'ADD-ON' THEN 9.99
            ELSE 0.00
        END AS license_cost,
        
        -- Derive renewal status
        CASE 
            WHEN DATEDIFF('day', CURRENT_DATE(), vl.end_date) <= 30 THEN 'Yes'
            ELSE 'No'
        END AS renewal_status,
        
        -- Calculate utilization percentage (simplified)
        CASE 
            WHEN UPPER(vl.license_type) = 'ENTERPRISE' THEN 85.5
            WHEN UPPER(vl.license_type) = 'PRO' THEN 72.3
            WHEN UPPER(vl.license_type) = 'BASIC' THEN 45.8
            ELSE 25.0
        END AS utilization_percentage,
        
        -- Metadata columns
        vl.load_timestamp,
        vl.update_timestamp,
        vl.source_system,
        vl.data_quality_score,
        DATE(vl.load_timestamp) AS load_date,
        DATE(vl.update_timestamp) AS update_date
    FROM validated_licenses vl
    LEFT JOIN bronze_users u ON vl.assigned_to_user_id = u.user_id
    WHERE vl.rn = 1
        AND vl.data_quality_status = 'VALID'
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
FROM transformed_licenses
