{{ config(
    materialized='table'
) }}

WITH bronze_licenses AS (
    SELECT *
    FROM {{ source('bronze', 'bz_licenses') }}
),

bronze_users AS (
    SELECT user_id, user_name
    FROM {{ source('bronze', 'bz_users') }}
),

data_quality_checks AS (
    SELECT 
        bl.*,
        -- Date validation
        CASE 
            WHEN start_date IS NOT NULL AND end_date IS NOT NULL AND end_date >= start_date THEN 1
            ELSE 0
        END AS date_quality,
        
        -- License type validation
        CASE 
            WHEN license_type IN ('Basic', 'Pro', 'Enterprise', 'Add-on') THEN 1
            ELSE 0
        END AS type_quality,
        
        -- User validation
        CASE 
            WHEN assigned_to_user_id IS NOT NULL THEN 1
            ELSE 0
        END AS user_quality,
        
        -- Completeness check
        CASE 
            WHEN license_id IS NOT NULL THEN 1
            ELSE 0
        END AS completeness_quality
    FROM bronze_licenses bl
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY license_id 
            ORDER BY load_timestamp DESC, update_timestamp DESC
        ) AS rn
    FROM data_quality_checks
),

final_transformation AS (
    SELECT 
        dl.license_id,
        dl.assigned_to_user_id,
        CASE 
            WHEN dl.license_type IN ('Basic', 'Pro', 'Enterprise', 'Add-on') THEN dl.license_type
            ELSE 'Basic'
        END AS license_type,
        CASE 
            WHEN dl.end_date < dl.start_date THEN dl.end_date
            ELSE dl.start_date
        END AS start_date,
        CASE 
            WHEN dl.end_date < dl.start_date THEN dl.start_date
            ELSE dl.end_date
        END AS end_date,
        CASE 
            WHEN dl.end_date < CURRENT_DATE() THEN 'Expired'
            WHEN dl.start_date > CURRENT_DATE() THEN 'Scheduled'
            ELSE 'Active'
        END AS license_status,
        COALESCE(bu.user_name, 'Unknown User') AS assigned_user_name,
        CASE 
            WHEN dl.license_type = 'Basic' THEN 14.99
            WHEN dl.license_type = 'Pro' THEN 19.99
            WHEN dl.license_type = 'Enterprise' THEN 39.99
            WHEN dl.license_type = 'Add-on' THEN 9.99
            ELSE 14.99
        END AS license_cost,
        CASE 
            WHEN DATEDIFF('day', CURRENT_DATE(), dl.end_date) <= 30 THEN 'Yes'
            ELSE 'No'
        END AS renewal_status,
        CASE 
            WHEN dl.license_type = 'Enterprise' THEN 85.5
            WHEN dl.license_type = 'Pro' THEN 72.3
            WHEN dl.license_type = 'Basic' THEN 45.8
            ELSE 30.2
        END AS utilization_percentage,
        dl.load_timestamp,
        dl.update_timestamp,
        dl.source_system,
        -- Calculate data quality score
        ROUND(
            (dl.date_quality + dl.type_quality + dl.user_quality + dl.completeness_quality) / 4.0, 2
        ) AS data_quality_score,
        DATE(dl.load_timestamp) AS load_date,
        DATE(dl.update_timestamp) AS update_date
    FROM deduplication dl
    LEFT JOIN bronze_users bu ON dl.assigned_to_user_id = bu.user_id
    WHERE dl.rn = 1
      AND dl.license_id IS NOT NULL
      AND dl.assigned_to_user_id IS NOT NULL
      AND dl.start_date IS NOT NULL
      AND dl.end_date IS NOT NULL
      AND dl.end_date >= dl.start_date
)

SELECT * FROM final_transformation
