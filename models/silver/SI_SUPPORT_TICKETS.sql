{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTION_TRIGGER, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_SUPPORT_TICKETS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', 'DBT', 'SYSTEM', CURRENT_TIMESTAMP() WHERE '{{ this.name }}' != 'SI_Audit_Log'",
    post_hook="UPDATE {{ ref('SI_Audit_Log') }} SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(), EXECUTION_STATUS = 'SUCCESS', EXECUTION_DURATION_SECONDS = DATEDIFF('second', EXECUTION_START_TIME, CURRENT_TIMESTAMP()), UPDATE_TIMESTAMP = CURRENT_TIMESTAMP() WHERE PIPELINE_NAME = 'BRONZE_TO_SILVER_SUPPORT_TICKETS' AND EXECUTION_STATUS = 'RUNNING' AND '{{ this.name }}' != 'SI_Audit_Log'"
) }}

-- Silver Layer Support Tickets Table
-- Purpose: Clean and standardized customer support requests and resolution tracking
-- Source: Bronze.BZ_SUPPORT_TICKETS

WITH source_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'BZ_SUPPORT_TICKETS') }}
    WHERE TICKET_ID IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        *,
        -- Standardize resolution status
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') THEN UPPER(TRIM(RESOLUTION_STATUS))
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) LIKE '%OPEN%' THEN 'OPEN'
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) LIKE '%PROGRESS%' THEN 'IN PROGRESS'
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) LIKE '%RESOLVED%' THEN 'RESOLVED'
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) LIKE '%CLOSED%' THEN 'CLOSED'
            ELSE 'OPEN'
        END AS standardized_resolution_status,
        
        -- Data quality score calculation
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IS NOT NULL 
                AND OPEN_DATE IS NOT NULL 
                AND OPEN_DATE <= CURRENT_DATE()
            THEN 100
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL AND TICKET_TYPE IS NOT NULL 
            THEN 75
            WHEN TICKET_ID IS NOT NULL 
            THEN 50
            ELSE 25
        END AS data_quality_score,
        
        -- Validation status
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IS NOT NULL 
                AND OPEN_DATE IS NOT NULL 
                AND OPEN_DATE <= CURRENT_DATE()
            THEN 'PASSED'
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL 
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS validation_status
    FROM source_data
),

deduplication AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM data_quality_checks
    WHERE validation_status IN ('PASSED', 'WARNING')
),

final_transformation AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
        standardized_resolution_status AS RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata columns
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        validation_status AS VALIDATION_STATUS,
        CURRENT_TIMESTAMP() AS CREATED_AT,
        CURRENT_TIMESTAMP() AS UPDATED_AT
    FROM deduplication
    WHERE row_num = 1
)

SELECT * FROM final_transformation
