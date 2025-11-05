{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Bronze to Silver transformation for Licenses
-- Implements data quality checks and calculated fields

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
      AND TRIM(LICENSE_ID) != ''
),

data_quality_checks AS (
    SELECT 
        bl.*,
        -- Calculate license status
        CASE 
            WHEN bl.END_DATE < CURRENT_DATE() THEN 'EXPIRED'
            WHEN bl.END_DATE <= DATEADD('day', 30, CURRENT_DATE()) THEN 'EXPIRING_SOON'
            WHEN bl.START_DATE > CURRENT_DATE() THEN 'FUTURE'
            ELSE 'ACTIVE'
        END AS calculated_license_status,
        
        -- Calculate days to expiry
        CASE 
            WHEN bl.END_DATE >= CURRENT_DATE() 
            THEN DATEDIFF('day', CURRENT_DATE(), bl.END_DATE)
            ELSE 0
        END AS calculated_days_to_expiry,
        
        -- Validation checks
        CASE 
            WHEN bl.START_DATE IS NULL OR bl.END_DATE IS NULL THEN 'MISSING_DATES'
            WHEN bl.END_DATE < bl.START_DATE THEN 'INVALID_DATE_RANGE'
            WHEN bl.ASSIGNED_TO_USER_ID IS NULL THEN 'MISSING_USER_ID'
            WHEN bl.LICENSE_TYPE IS NULL OR TRIM(bl.LICENSE_TYPE) = '' THEN 'MISSING_LICENSE_TYPE'
            ELSE 'VALID'
        END AS validation_status
    FROM bronze_licenses bl
),

valid_records AS (
    SELECT 
        dqc.LICENSE_ID,
        UPPER(TRIM(dqc.LICENSE_TYPE)) AS LICENSE_TYPE,
        dqc.ASSIGNED_TO_USER_ID,
        dqc.START_DATE,
        dqc.END_DATE,
        dqc.calculated_license_status AS LICENSE_STATUS,
        dqc.calculated_days_to_expiry AS DAYS_TO_EXPIRY,
        DATE(dqc.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(dqc.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        dqc.SOURCE_SYSTEM,
        dqc.LOAD_TIMESTAMP,
        dqc.UPDATE_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY dqc.LICENSE_ID ORDER BY dqc.UPDATE_TIMESTAMP DESC) AS rn
    FROM data_quality_checks dqc
    INNER JOIN {{ ref('si_users') }} u ON dqc.ASSIGNED_TO_USER_ID = u.USER_ID
    WHERE dqc.validation_status = 'VALID'
)

SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    LICENSE_STATUS,
    DAYS_TO_EXPIRY,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM valid_records
WHERE rn = 1
