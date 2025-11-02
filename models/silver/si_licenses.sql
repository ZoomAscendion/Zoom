{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_LICENSES_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_LICENSES_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'BZ_LICENSES', 'SI_LICENSES', 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, records_inserted, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_LICENSES_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_LICENSES_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')"
) }}

-- Silver Licenses Model
WITH bronze_licenses AS (
    SELECT * FROM {{ source('bronze', 'bz_licenses') }}
),

silver_users AS (
    SELECT * FROM {{ ref('si_users') }}
),

data_quality_checks AS (
    SELECT 
        *,
        CASE 
            WHEN end_date < start_date THEN 'INVALID_DATE_RANGE'
            WHEN start_date > CURRENT_DATE() + INTERVAL '2' YEAR THEN 'FUTURE_START_DATE'
            ELSE 'VALID'
        END AS date_quality_flag,
        CASE 
            WHEN license_type NOT IN ('Basic', 'Pro', 'Enterprise', 'Add-on') THEN 'INVALID_LICENSE_TYPE'
            ELSE 'VALID'
        END AS type_quality_flag
    FROM bronze_licenses
    WHERE license_id IS NOT NULL
      AND assigned_to_user_id IS NOT NULL
),

cleansed_licenses AS (
    SELECT 
        l.license_id,
        l.assigned_to_user_id,
        CASE 
            WHEN l.type_quality_flag = 'VALID' THEN l.license_type
            ELSE 'Basic'
        END AS license_type,
        CASE 
            WHEN l.date_quality_flag = 'INVALID_DATE_RANGE' THEN l.end_date
            ELSE l.start_date
        END AS start_date,
        CASE 
            WHEN l.date_quality_flag = 'INVALID_DATE_RANGE' THEN l.start_date
            ELSE l.end_date
        END AS end_date,
        CASE 
            WHEN l.end_date < CURRENT_DATE() THEN 'Expired'
            WHEN l.start_date > CURRENT_DATE() THEN 'Pending'
            ELSE 'Active'
        END AS license_status,
        COALESCE(u.user_name, 'Unknown User') AS assigned_user_name,
        CASE 
            WHEN l.license_type = 'Basic' THEN 14.99
            WHEN l.license_type = 'Pro' THEN 19.99
            WHEN l.license_type = 'Enterprise' THEN 39.99
            ELSE 9.99
        END AS license_cost,
        CASE 
            WHEN l.end_date > CURRENT_DATE() + INTERVAL '30' DAY THEN 'Yes'
            ELSE 'No'
        END AS renewal_status,
        75.0 AS utilization_percentage,
        l.load_timestamp,
        l.update_timestamp,
        l.source_system,
        ROUND(
            (CASE WHEN l.date_quality_flag = 'VALID' THEN 0.4 ELSE 0.0 END +
             CASE WHEN l.type_quality_flag = 'VALID' THEN 0.3 ELSE 0.0 END +
             CASE WHEN u.user_id IS NOT NULL THEN 0.2 ELSE 0.0 END +
             CASE WHEN l.license_id IS NOT NULL THEN 0.1 ELSE 0.0 END), 2
        ) AS data_quality_score,
        DATE(l.load_timestamp) AS load_date,
        DATE(l.update_timestamp) AS update_date
    FROM data_quality_checks l
    LEFT JOIN silver_users u ON l.assigned_to_user_id = u.user_id
    WHERE u.user_id IS NOT NULL
),

deduped_licenses AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY license_id ORDER BY update_timestamp DESC) AS rn
    FROM cleansed_licenses
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
FROM deduped_licenses
WHERE rn = 1
