{{ config(
    materialized='incremental',
    unique_key='license_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Licenses
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
        AND START_DATE IS NOT NULL
        AND END_DATE IS NOT NULL
        AND END_DATE >= START_DATE
),

-- Get user names for assigned users
user_info AS (
    SELECT 
        USER_ID,
        USER_NAME as ASSIGNED_USER_NAME
    FROM {{ ref('si_users') }}
),

-- Data Quality Checks and Cleansing
cleansed_licenses AS (
    SELECT 
        TRIM(l.LICENSE_ID) as LICENSE_ID,
        TRIM(l.ASSIGNED_TO_USER_ID) as ASSIGNED_TO_USER_ID,
        CASE 
            WHEN UPPER(l.LICENSE_TYPE) IN ('BASIC', 'PRO', 'ENTERPRISE', 'ADD-ON') 
            THEN UPPER(l.LICENSE_TYPE)
            ELSE 'UNKNOWN'
        END as LICENSE_TYPE,
        l.START_DATE,
        l.END_DATE,
        CASE 
            WHEN CURRENT_DATE() BETWEEN l.START_DATE AND l.END_DATE THEN 'Active'
            WHEN CURRENT_DATE() > l.END_DATE THEN 'Expired'
            ELSE 'Suspended'
        END as LICENSE_STATUS,
        COALESCE(u.ASSIGNED_USER_NAME, 'Unassigned') as ASSIGNED_USER_NAME,
        CASE 
            WHEN UPPER(l.LICENSE_TYPE) = 'BASIC' THEN 14.99
            WHEN UPPER(l.LICENSE_TYPE) = 'PRO' THEN 19.99
            WHEN UPPER(l.LICENSE_TYPE) = 'ENTERPRISE' THEN 39.99
            WHEN UPPER(l.LICENSE_TYPE) = 'ADD-ON' THEN 9.99
            ELSE 0.00
        END as LICENSE_COST,
        'Yes' as RENEWAL_STATUS,
        75.0 as UTILIZATION_PERCENTAGE,
        l.LOAD_TIMESTAMP,
        l.UPDATE_TIMESTAMP,
        l.SOURCE_SYSTEM
    FROM bronze_licenses l
    LEFT JOIN user_info u ON l.ASSIGNED_TO_USER_ID = u.USER_ID
),

-- Remove duplicates
deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM cleansed_licenses
),

-- Calculate data quality score
final_licenses AS (
    SELECT 
        LICENSE_ID,
        ASSIGNED_TO_USER_ID,
        LICENSE_TYPE,
        START_DATE,
        END_DATE,
        LICENSE_STATUS,
        ASSIGNED_USER_NAME,
        LICENSE_COST,
        RENEWAL_STATUS,
        UTILIZATION_PERCENTAGE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Calculate data quality score
        ROUND(
            (CASE WHEN LICENSE_TYPE != 'UNKNOWN' THEN 0.25 ELSE 0 END +
             CASE WHEN START_DATE IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN END_DATE IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN ASSIGNED_USER_NAME != 'Unassigned' THEN 0.2 ELSE 0 END +
             CASE WHEN LICENSE_COST >= 0 THEN 0.15 ELSE 0 END), 2
        ) as DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) as LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) as UPDATE_DATE
    FROM deduped_licenses
    WHERE rn = 1
)

SELECT * FROM final_licenses

{% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT COALESCE(MAX(UPDATE_TIMESTAMP), '1900-01-01') FROM {{ this }})
{% endif %}
