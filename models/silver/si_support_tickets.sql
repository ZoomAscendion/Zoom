{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (AUDIT_ID, PIPELINE_NAME, SOURCE_TABLE, TARGET_TABLE, EXECUTION_START_TIME, EXECUTION_STATUS, PROCESSED_BY, PROCESSING_MODE, LOAD_DATE, SOURCE_SYSTEM) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_SUPPORT_TICKETS', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'RUNNING', 'DBT_PIPELINE', 'INCREMENTAL', CURRENT_DATE(), 'SILVER_LAYER_PROCESSING' WHERE '{{ this.name }}' != 'si_pipeline_audit'",
    post_hook="UPDATE {{ ref('si_pipeline_audit') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()) WHERE TARGET_TABLE = 'SI_SUPPORT_TICKETS' AND EXECUTION_STATUS = 'RUNNING' AND '{{ this.name }}' != 'si_pipeline_audit'"
) }}

-- Silver Layer Support Tickets Table Transformation
-- Applies data quality checks, standardization, and business rules

WITH bronze_support_tickets AS (
    SELECT *
    FROM {{ source('bronze', 'bz_support_tickets') }}
    WHERE LOAD_TIMESTAMP IS NOT NULL
),

validated_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Data quality validation
        CASE 
            WHEN TICKET_ID IS NULL OR TRIM(TICKET_ID) = '' THEN 'INVALID_TICKET_ID'
            WHEN USER_ID IS NULL OR TRIM(USER_ID) = '' THEN 'INVALID_USER_ID'
            WHEN TICKET_TYPE IS NULL OR TRIM(TICKET_TYPE) = '' THEN 'INVALID_TICKET_TYPE'
            WHEN RESOLUTION_STATUS IS NULL OR TRIM(RESOLUTION_STATUS) = '' THEN 'INVALID_STATUS'
            WHEN OPEN_DATE IS NULL THEN 'INVALID_OPEN_DATE'
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) NOT IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED') THEN 'INVALID_STATUS_VALUE'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM bronze_support_tickets
),

cleansed_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
        UPPER(TRIM(RESOLUTION_STATUS)) AS RESOLUTION_STATUS,
        OPEN_DATE,
        -- Calculate resolution time for closed tickets
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('RESOLVED', 'CLOSED') 
            THEN DATEDIFF('hour', OPEN_DATE, CURRENT_DATE()) * 1.0
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM validated_support_tickets
    WHERE data_quality_flag = 'VALID'
),

deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM cleansed_support_tickets
)

SELECT 
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    RESOLUTION_TIME_HOURS,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP
FROM deduped_support_tickets
WHERE row_num = 1
