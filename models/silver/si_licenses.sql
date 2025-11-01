{{ config(
    materialized='table',
    tags=['silver', 'licenses']
) }}

WITH source_licenses AS (
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
      AND ASSIGNED_TO_USER_ID IS NOT NULL
      AND START_DATE IS NOT NULL
      AND END_DATE IS NOT NULL
      AND END_DATE >= START_DATE
),

validated_users AS (
    SELECT USER_ID, USER_NAME
    FROM {{ ref('si_users') }}
),

validated_licenses AS (
    SELECT
        sl.LICENSE_ID,
        sl.ASSIGNED_TO_USER_ID,
        CASE
            WHEN UPPER(TRIM(sl.LICENSE_TYPE)) IN ('BASIC', 'PRO', 'ENTERPRISE', 'ADD-ON')
            THEN INITCAP(TRIM(sl.LICENSE_TYPE))
            ELSE 'Basic'
        END AS LICENSE_TYPE,
        sl.START_DATE,
        sl.END_DATE,
        CASE
            WHEN sl.END_DATE < CURRENT_DATE() THEN 'Expired'
            WHEN sl.START_DATE <= CURRENT_DATE() AND sl.END_DATE >= CURRENT_DATE() THEN 'Active'
            ELSE 'Suspended'
        END AS LICENSE_STATUS,
        COALESCE(vu.USER_NAME, 'Unknown User') AS ASSIGNED_USER_NAME,
        CASE
            WHEN UPPER(TRIM(sl.LICENSE_TYPE)) = 'BASIC' THEN 10.00
            WHEN UPPER(TRIM(sl.LICENSE_TYPE)) = 'PRO' THEN 20.00
            WHEN UPPER(TRIM(sl.LICENSE_TYPE)) = 'ENTERPRISE' THEN 50.00
            ELSE 5.00
        END AS LICENSE_COST,
        'Yes' AS RENEWAL_STATUS,
        75.00 AS UTILIZATION_PERCENTAGE,
        sl.LOAD_TIMESTAMP,
        sl.UPDATE_TIMESTAMP,
        sl.SOURCE_SYSTEM
    FROM source_licenses sl
    LEFT JOIN validated_users vu ON sl.ASSIGNED_TO_USER_ID = vu.USER_ID
    WHERE vu.USER_ID IS NOT NULL
),

quality_scored_licenses AS (
    SELECT
        *,
        (
            CASE WHEN LICENSE_TYPE IN ('Basic', 'Pro', 'Enterprise', 'Add-On') THEN 0.20 ELSE 0 END +
            CASE WHEN START_DATE IS NOT NULL AND START_DATE <= CURRENT_DATE() THEN 0.20 ELSE 0 END +
            CASE WHEN END_DATE >= START_DATE THEN 0.20 ELSE 0 END +
            CASE WHEN LICENSE_STATUS IN ('Active', 'Expired', 'Suspended') THEN 0.20 ELSE 0 END +
            CASE WHEN LICENSE_COST >= 0 THEN 0.20 ELSE 0 END
        ) AS DATA_QUALITY_SCORE
    FROM validated_licenses
),

deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC) AS row_num
    FROM quality_scored_licenses
)

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
    DATA_QUALITY_SCORE,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_licenses
WHERE row_num = 1
  AND DATA_QUALITY_SCORE >= 0.60
