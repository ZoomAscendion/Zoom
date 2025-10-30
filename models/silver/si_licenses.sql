{{
    config(
        materialized='incremental',
        unique_key='license_id',
        on_schema_change='sync_all_columns'
    )
}}

-- Silver Layer Licenses Transformation
-- Source: Bronze.BZ_LICENSES
-- Target: Silver.SI_LICENSES

WITH bronze_licenses AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_licenses') }}
    WHERE LICENSE_ID IS NOT NULL
    
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(update_timestamp) FROM {{ this }})
    {% endif %}
),

-- Join with Users for Assigned User Information
license_with_user AS (
    SELECT 
        l.*,
        u.user_name AS assigned_user_name
    FROM bronze_licenses l
    LEFT JOIN {{ ref('si_users') }} u ON l.ASSIGNED_TO_USER_ID = u.user_id
),

-- Data Quality and Transformation Layer
data_quality_checks AS (
    SELECT 
        *,
        -- Data Quality Score Calculation
        CASE 
            WHEN LICENSE_ID IS NULL THEN 0.0
            WHEN LICENSE_TYPE NOT IN ('Basic', 'Pro', 'Enterprise', 'Add-on') THEN 0.4
            WHEN START_DATE IS NULL THEN 0.5
            WHEN END_DATE IS NOT NULL AND START_DATE >= END_DATE THEN 0.3
            WHEN START_DATE > CURRENT_DATE() + INTERVAL '1 year' THEN 0.6
            ELSE 1.0
        END AS data_quality_score,
        
        -- Row Number for Deduplication
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM license_with_user
),

-- Final Transformation
transformed_licenses AS (
    SELECT 
        TRIM(LICENSE_ID) AS license_id,
        TRIM(ASSIGNED_TO_USER_ID) AS assigned_to_user_id,
        CASE 
            WHEN LICENSE_TYPE IN ('Basic', 'Pro', 'Enterprise', 'Add-on') THEN LICENSE_TYPE
            ELSE 'Unknown'
        END AS license_type,
        START_DATE AS start_date,
        END_DATE AS end_date,
        CASE 
            WHEN END_DATE IS NULL OR END_DATE >= CURRENT_DATE() THEN 'Active'
            WHEN END_DATE < CURRENT_DATE() THEN 'Expired'
            ELSE 'Unknown'
        END AS license_status,
        COALESCE(assigned_user_name, 'Unassigned') AS assigned_user_name,
        CASE 
            WHEN LICENSE_TYPE = 'Basic' THEN 14.99
            WHEN LICENSE_TYPE = 'Pro' THEN 19.99
            WHEN LICENSE_TYPE = 'Enterprise' THEN 39.99
            WHEN LICENSE_TYPE = 'Add-on' THEN 9.99
            ELSE 0.00
        END AS license_cost,
        'Yes' AS renewal_status,  -- Default value
        FLOOR(RANDOM() * 100) AS utilization_percentage,  -- Random value for demo
        LOAD_TIMESTAMP AS load_timestamp,
        UPDATE_TIMESTAMP AS update_timestamp,
        SOURCE_SYSTEM AS source_system,
        data_quality_score,
        DATE(LOAD_TIMESTAMP) AS load_date,
        DATE(UPDATE_TIMESTAMP) AS update_date
    FROM data_quality_checks
    WHERE rn = 1  -- Remove duplicates
        AND data_quality_score > 0.0  -- Remove records with critical quality issues
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
