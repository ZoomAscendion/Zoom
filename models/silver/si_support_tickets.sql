{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_audit_log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_SUPPORT_TICKETS', 'PROCESS_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'si_audit_log'",
    post_hook="INSERT INTO {{ ref('si_audit_log') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), 'SI_SUPPORT_TICKETS', 'PROCESS_END', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'si_audit_log'"
) }}

-- Silver Layer Support Tickets Table
-- Purpose: Clean and standardized customer support requests
-- Source: Bronze BZ_SUPPORT_TICKETS table

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
    FROM {{ source('bronze', 'bz_support_tickets') }}
    WHERE TICKET_ID IS NOT NULL
),

cleaned_data AS (
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
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM source_data
),

validated_data AS (
    SELECT 
        *,
        -- Data Quality Score
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed')
                AND OPEN_DATE IS NOT NULL
                AND OPEN_DATE <= CURRENT_DATE()
            THEN 100
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL AND TICKET_TYPE IS NOT NULL
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        
        -- Validation Status
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                AND USER_ID IS NOT NULL 
                AND TICKET_TYPE IS NOT NULL 
                AND RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed')
                AND OPEN_DATE IS NOT NULL
                AND OPEN_DATE <= CURRENT_DATE()
            THEN 'PASSED'
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL AND TICKET_TYPE IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_data
),

deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM validated_data
)

SELECT 
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    RESOLUTION_STATUS,
    OPEN_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    DATA_QUALITY_SCORE,
    VALIDATION_STATUS
FROM deduped_data
WHERE rn = 1
    AND VALIDATION_STATUS IN ('PASSED', 'WARNING')
