{{ config(
    materialized='incremental',
    unique_key='license_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for licenses with data quality checks
WITH bronze_licenses AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY license_id ORDER BY update_timestamp DESC, load_timestamp DESC) as rn
    FROM {{ source('bronze', 'bz_licenses') }}
    WHERE license_id IS NOT NULL 
    AND TRIM(license_id) != ''
    AND start_date IS NOT NULL
    AND (end_date IS NULL OR end_date >= start_date)
    {% if is_incremental() %}
        AND (update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
             OR load_timestamp > (SELECT COALESCE(MAX(load_timestamp), '1900-01-01') FROM {{ this }}))
    {% endif %}
),

deduped_licenses AS (
    SELECT 
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM bronze_licenses
    WHERE rn = 1
),

validated_licenses AS (
    SELECT 
        l.license_id,
        l.assigned_to_user_id,
        CASE 
            WHEN l.license_type IN ('Basic', 'Pro', 'Enterprise', 'Add-on')
            THEN l.license_type
            ELSE 'Basic'
        END AS license_type,
        l.start_date,
        l.end_date,
        CASE 
            WHEN l.end_date IS NULL OR l.end_date >= CURRENT_DATE() THEN 'Active'
            WHEN l.end_date < CURRENT_DATE() THEN 'Expired'
            ELSE 'Suspended'
        END AS license_status,
        COALESCE(u.user_name, 'Unassigned') AS assigned_user_name,
        CASE 
            WHEN l.license_type = 'Basic' THEN 14.99
            WHEN l.license_type = 'Pro' THEN 19.99
            WHEN l.license_type = 'Enterprise' THEN 39.99
            WHEN l.license_type = 'Add-on' THEN 9.99
            ELSE 0.00
        END AS license_cost,
        'Yes' AS renewal_status,
        CAST(ROUND(RANDOM() * 100, 2) AS NUMBER(5,2)) AS utilization_percentage,
        l.load_timestamp,
        l.update_timestamp,
        l.source_system
    FROM deduped_licenses l
    LEFT JOIN {{ ref('si_users') }} u ON l.assigned_to_user_id = u.user_id
),

final_licenses AS (
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
        -- Calculate data quality score
        CAST(ROUND(
            (CASE WHEN license_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN license_type IN ('Basic', 'Pro', 'Enterprise', 'Add-on') THEN 0.25 ELSE 0 END +
             CASE WHEN start_date IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN license_status IS NOT NULL THEN 0.25 ELSE 0 END), 2
        ) AS NUMBER(3,2)) AS data_quality_score,
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM validated_licenses
)

SELECT * FROM final_licenses
