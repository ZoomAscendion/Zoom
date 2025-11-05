{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (AUDIT_ID, PIPELINE_NAME, PIPELINE_RUN_ID, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, PROCESSED_BY, PROCESSING_MODE, EXECUTION_STATUS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_LICENSES', UUID_STRING(), 'BZ_LICENSES', 'SI_LICENSES', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 'INCREMENTAL', 'STARTED', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_ETL_PROCESS' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE TARGET_TABLE = 'SI_LICENSES' AND EXECUTION_STATUS = 'STARTED' AND DATE(EXECUTION_START_TIME) = CURRENT_DATE() AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Licenses transformation with data quality checks
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
      AND START_DATE < END_DATE
),

validated_licenses AS (
    SELECT 
        bl.LICENSE_ID,
        UPPER(TRIM(bl.LICENSE_TYPE)) AS LICENSE_TYPE,
        bl.ASSIGNED_TO_USER_ID,
        bl.START_DATE,
        bl.END_DATE,
        -- Calculate license status
        CASE 
            WHEN bl.END_DATE < CURRENT_DATE() THEN 'EXPIRED'
            WHEN bl.END_DATE <= DATEADD('day', 30, CURRENT_DATE()) THEN 'EXPIRING_SOON'
            WHEN bl.START_DATE > CURRENT_DATE() THEN 'FUTURE'
            ELSE 'ACTIVE'
        END AS LICENSE_STATUS,
        -- Calculate days to expiry
        CASE 
            WHEN bl.END_DATE >= CURRENT_DATE() 
            THEN DATEDIFF('day', CURRENT_DATE(), bl.END_DATE)
            ELSE 0
        END AS DAYS_TO_EXPIRY,
        DATE(bl.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bl.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        bl.SOURCE_SYSTEM,
        bl.LOAD_TIMESTAMP,
        bl.UPDATE_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY bl.LICENSE_ID ORDER BY bl.UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_licenses bl
    LEFT JOIN {{ ref('si_users') }} u ON bl.ASSIGNED_TO_USER_ID = u.USER_ID
    WHERE bl.ASSIGNED_TO_USER_ID IS NULL OR u.USER_ID IS NOT NULL  -- Allow null or valid user references
),

deduped_licenses AS (
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
    FROM validated_licenses
    WHERE rn = 1
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
FROM deduped_licenses
