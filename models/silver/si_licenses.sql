{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Licenses transformation with data quality checks
WITH bronze_licenses AS (
    SELECT *
    FROM {{ ref('bz_licenses') }}
    WHERE LICENSE_ID IS NOT NULL
      AND TRIM(LICENSE_ID) != ''
      AND LICENSE_TYPE IS NOT NULL
      AND START_DATE IS NOT NULL
      AND END_DATE IS NOT NULL
      AND START_DATE < END_DATE
),

valid_users AS (
    SELECT DISTINCT USER_ID
    FROM {{ ref('si_users') }}
),

filtered_licenses AS (
    SELECT bl.*
    FROM bronze_licenses bl
    LEFT JOIN valid_users vu ON bl.ASSIGNED_TO_USER_ID = vu.USER_ID
    WHERE bl.ASSIGNED_TO_USER_ID IS NULL OR vu.USER_ID IS NOT NULL
),

deduped_licenses AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM filtered_licenses
),

final_licenses AS (
    SELECT 
        LICENSE_ID,
        UPPER(TRIM(LICENSE_TYPE)) AS LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        CASE 
            WHEN END_DATE < CURRENT_DATE THEN 'EXPIRED'
            WHEN END_DATE <= DATEADD('day', 30, CURRENT_DATE) THEN 'EXPIRING_SOON'
            WHEN START_DATE > CURRENT_DATE THEN 'FUTURE'
            ELSE 'ACTIVE'
        END AS LICENSE_STATUS,
        CASE 
            WHEN END_DATE >= CURRENT_DATE 
            THEN DATEDIFF('day', CURRENT_DATE, END_DATE)
            ELSE 0
        END AS DAYS_TO_EXPIRY,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM deduped_licenses
    WHERE rn = 1
)

SELECT * FROM final_licenses
