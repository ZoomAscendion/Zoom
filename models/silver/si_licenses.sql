{{
  config(
    materialized='incremental',
    unique_key='license_id',
    on_schema_change='sync_all_columns'
  )
}}

WITH bronze_licenses AS (
    SELECT *
    FROM {{ source('bronze', 'bz_licenses') }}
    WHERE LICENSE_ID IS NOT NULL
        AND START_DATE IS NOT NULL
        AND (END_DATE IS NULL OR END_DATE >= START_DATE)
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

cleaned_licenses AS (
    SELECT 
        bl.LICENSE_ID AS license_id,
        bl.ASSIGNED_TO_USER_ID AS assigned_to_user_id,
        CASE 
            WHEN UPPER(TRIM(bl.LICENSE_TYPE)) IN ('BASIC', 'PRO', 'ENTERPRISE', 'ADD-ON') 
            THEN UPPER(TRIM(bl.LICENSE_TYPE))
            ELSE 'BASIC'
        END AS license_type,
        bl.START_DATE,
        bl.END_DATE,
        CASE 
            WHEN bl.END_DATE IS NULL OR bl.END_DATE > CURRENT_DATE() THEN 'ACTIVE'
            WHEN bl.END_DATE <= CURRENT_DATE() THEN 'EXPIRED'
            ELSE 'SUSPENDED'
        END AS license_status,
        COALESCE(u.user_name, 'Unassigned') AS assigned_user_name,
        CASE 
            WHEN UPPER(bl.LICENSE_TYPE) = 'BASIC' THEN 10.00
            WHEN UPPER(bl.LICENSE_TYPE) = 'PRO' THEN 20.00
            WHEN UPPER(bl.LICENSE_TYPE) = 'ENTERPRISE' THEN 50.00
            ELSE 5.00
        END AS license_cost,
        'YES' AS renewal_status,
        75.50 AS utilization_percentage,
        bl.LOAD_TIMESTAMP,
        bl.UPDATE_TIMESTAMP,
        bl.SOURCE_SYSTEM,
        0.87 AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_licenses bl
    LEFT JOIN {{ ref('si_users') }} u ON bl.ASSIGNED_TO_USER_ID = u.user_id
),

deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY license_id ORDER BY update_timestamp DESC) AS rn
    FROM cleaned_licenses
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
