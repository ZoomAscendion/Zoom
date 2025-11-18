{{ config(
    materialized='table',
    tags=['silver', 'support_tickets'],
    pre_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), '{{ this.name }}', 'PRE_HOOK_START', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'",
    post_hook="INSERT INTO {{ ref('SI_AUDIT_LOG') }} (AUDIT_ID, TABLE_NAME, OPERATION_TYPE, AUDIT_TIMESTAMP, PROCESSED_BY) SELECT UUID_STRING(), '{{ this.name }}', 'POST_HOOK_COMPLETE', CURRENT_TIMESTAMP(), 'DBT_SILVER_PIPELINE' WHERE '{{ this.name }}' != 'SI_AUDIT_LOG'"
) }}

WITH bronze_support_tickets AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM {{ source('bronze', 'BZ_SUPPORT_TICKETS') }}
    WHERE TICKET_ID IS NOT NULL
),

cleaned_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
            THEN UPPER(TRIM(RESOLUTION_STATUS))
            ELSE 'OPEN'
        END AS RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM bronze_support_tickets
    WHERE rn = 1
),

validated_support_tickets AS (
    SELECT *,
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                 AND USER_ID IS NOT NULL 
                 AND TICKET_TYPE IS NOT NULL 
                 AND RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED')
                 AND OPEN_DATE IS NOT NULL
                 AND OPEN_DATE <= CURRENT_DATE()
            THEN 95
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL
            THEN 75
            ELSE 50
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN TICKET_ID IS NOT NULL 
                 AND USER_ID IS NOT NULL 
                 AND TICKET_TYPE IS NOT NULL 
                 AND OPEN_DATE <= CURRENT_DATE()
            THEN 'PASSED'
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL
            THEN 'WARNING'
            ELSE 'FAILED'
        END AS VALIDATION_STATUS
    FROM cleaned_support_tickets
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
FROM validated_support_tickets
