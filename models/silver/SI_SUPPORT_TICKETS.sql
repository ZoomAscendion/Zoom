{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_START_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_SUPPORT_TICKETS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'RUNNING', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', 'DBT_PIPELINE', CURRENT_TIMESTAMP()",
    post_hook="INSERT INTO {{ ref('SI_Audit_Log') }} (EXECUTION_ID, PIPELINE_NAME, PIPELINE_TYPE, EXECUTION_END_TIME, EXECUTION_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, RECORDS_SUCCESS, EXECUTED_BY, UPDATE_TIMESTAMP) SELECT UUID_STRING(), 'BRONZE_TO_SILVER_SUPPORT_TICKETS', 'BRONZE_TO_SILVER', CURRENT_TIMESTAMP(), 'SUCCESS', 'BZ_SUPPORT_TICKETS', 'SI_SUPPORT_TICKETS', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', CURRENT_TIMESTAMP()"
) }}

-- Silver Layer Support Tickets Table
-- Transforms and cleanses support ticket data from Bronze layer
-- Applies data quality validations and business rules

WITH bronze_support_tickets AS (
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
),

-- Data Quality and Validation Layer
validated_support_tickets AS (
    SELECT 
        *,
        -- Null checks
        CASE WHEN TICKET_ID IS NULL THEN 0 ELSE 1 END AS ticket_id_valid,
        CASE WHEN USER_ID IS NULL THEN 0 ELSE 1 END AS user_id_valid,
        CASE WHEN TICKET_TYPE IS NULL THEN 0 ELSE 1 END AS ticket_type_valid,
        CASE WHEN RESOLUTION_STATUS IS NULL THEN 0 ELSE 1 END AS resolution_status_valid,
        CASE WHEN OPEN_DATE IS NULL THEN 0 ELSE 1 END AS open_date_valid,
        
        -- Business logic validation
        CASE WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 1 ELSE 0 END AS status_values_valid,
        CASE WHEN OPEN_DATE <= CURRENT_DATE() THEN 1 ELSE 0 END AS open_date_logic_valid,
        CASE WHEN LENGTH(TICKET_TYPE) <= 100 THEN 1 ELSE 0 END AS ticket_type_length_valid,
        
        -- Calculate data quality score
        ROUND((
            CASE WHEN TICKET_ID IS NULL THEN 0 ELSE 20 END +
            CASE WHEN USER_ID IS NULL THEN 0 ELSE 20 END +
            CASE WHEN TICKET_TYPE IS NULL THEN 0 ELSE 15 END +
            CASE WHEN RESOLUTION_STATUS IS NULL THEN 0 ELSE 15 END +
            CASE WHEN OPEN_DATE IS NULL THEN 0 ELSE 15 END +
            CASE WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 10 ELSE 0 END +
            CASE WHEN OPEN_DATE <= CURRENT_DATE() THEN 5 ELSE 0 END
        ), 0) AS data_quality_score
    FROM bronze_support_tickets
),

-- Deduplication layer using ROW_NUMBER to keep latest record
deduped_support_tickets AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) AS row_num
    FROM validated_support_tickets
    WHERE TICKET_ID IS NOT NULL  -- Remove null ticket IDs
),

-- Final transformation layer
final_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
        CASE 
            WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN RESOLUTION_STATUS
            ELSE 'Open'
        END AS RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        data_quality_score AS DATA_QUALITY_SCORE,
        CASE 
            WHEN data_quality_score >= 90 THEN 'PASSED'
            WHEN data_quality_score >= 70 THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM deduped_support_tickets
    WHERE row_num = 1  -- Keep only the latest record per ticket
    AND data_quality_score >= 70  -- Only pass records with acceptable quality
    AND OPEN_DATE <= CURRENT_DATE()  -- Ensure valid open dates
)

SELECT * FROM final_support_tickets
