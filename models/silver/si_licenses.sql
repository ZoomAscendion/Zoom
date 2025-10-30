{{ config(
    materialized='incremental',
    unique_key='license_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Licenses data
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
    
    {% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

user_names AS (
    SELECT 
        user_id,
        user_name
    FROM {{ ref('si_users') }}
),

cleansed_licenses AS (
    SELECT 
        TRIM(bl.LICENSE_ID) AS license_id,
        TRIM(bl.ASSIGNED_TO_USER_ID) AS assigned_to_user_id,
        CASE 
            WHEN UPPER(TRIM(bl.LICENSE_TYPE)) IN ('BASIC', 'PRO', 'ENTERPRISE', 'ADD-ON')
            THEN UPPER(TRIM(bl.LICENSE_TYPE))
            ELSE 'BASIC'
        END AS license_type,
        bl.START_DATE AS start_date,
        bl.END_DATE AS end_date,
        CASE 
            WHEN bl.END_DATE < CURRENT_DATE() THEN 'Expired'
            WHEN bl.START_DATE > CURRENT_DATE() THEN 'Suspended'
            ELSE 'Active'
        END AS license_status,
        COALESCE(un.user_name, 'Unassigned') AS assigned_user_name,
        CASE 
            WHEN UPPER(bl.LICENSE_TYPE) = 'BASIC' THEN 14.99
            WHEN UPPER(bl.LICENSE_TYPE) = 'PRO' THEN 19.99
            WHEN UPPER(bl.LICENSE_TYPE) = 'ENTERPRISE' THEN 39.99
            ELSE 9.99
        END AS license_cost,
        'Yes' AS renewal_status,
        75.0 AS utilization_percentage,  -- Default utilization
        bl.LOAD_TIMESTAMP AS load_timestamp,
        bl.UPDATE_TIMESTAMP AS update_timestamp,
        bl.SOURCE_SYSTEM AS source_system,
        CASE 
            WHEN bl.LICENSE_ID IS NOT NULL AND bl.LICENSE_TYPE IS NOT NULL AND bl.START_DATE IS NOT NULL
            THEN 1.00
            ELSE 0.60
        END AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_licenses bl
    LEFT JOIN user_names un ON bl.ASSIGNED_TO_USER_ID = un.user_id
    WHERE bl.LICENSE_ID IS NOT NULL
),

deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY license_id 
            ORDER BY update_timestamp DESC
        ) AS row_num
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
WHERE row_num = 1
