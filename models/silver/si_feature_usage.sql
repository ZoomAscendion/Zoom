{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (AUDIT_ID, PIPELINE_NAME, PIPELINE_RUN_ID, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, PROCESSED_BY, PROCESSING_MODE, EXECUTION_STATUS, LOAD_DATE, UPDATE_DATE, SOURCE_SYSTEM) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_FEATURE_USAGE', UUID_STRING(), 'BZ_FEATURE_USAGE', 'SI_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 'INCREMENTAL', 'STARTED', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_ETL_PROCESS' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_INSERTED = (SELECT COUNT(*) FROM {{ this }}) WHERE TARGET_TABLE = 'SI_FEATURE_USAGE' AND EXECUTION_STATUS = 'STARTED' AND DATE(EXECUTION_START_TIME) = CURRENT_DATE() AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Feature usage transformation with data quality checks
WITH bronze_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_feature_usage') }}
    WHERE USAGE_ID IS NOT NULL 
      AND TRIM(USAGE_ID) != ''
      AND USAGE_COUNT >= 0
),

validated_feature_usage AS (
    SELECT 
        bfu.USAGE_ID,
        bfu.MEETING_ID,
        -- Standardize feature names
        CASE 
            WHEN UPPER(TRIM(bfu.FEATURE_NAME)) IN ('SCREEN_SHARE', 'CHAT', 'RECORDING', 'BREAKOUT_ROOMS', 'WHITEBOARD')
            THEN UPPER(TRIM(bfu.FEATURE_NAME))
            ELSE 'OTHER'
        END AS FEATURE_NAME,
        bfu.USAGE_COUNT,
        bfu.USAGE_DATE,
        DATE(bfu.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(bfu.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        bfu.SOURCE_SYSTEM,
        bfu.LOAD_TIMESTAMP,
        bfu.UPDATE_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY bfu.USAGE_ID ORDER BY bfu.UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_feature_usage bfu
    INNER JOIN {{ ref('si_meetings') }} m ON bfu.MEETING_ID = m.MEETING_ID
    WHERE bfu.USAGE_DATE >= '2020-01-01'
      AND bfu.USAGE_DATE <= DATEADD('day', 1, CURRENT_DATE())
),

deduped_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_DATE,
        UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM validated_feature_usage
    WHERE rn = 1
)

SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM deduped_feature_usage
