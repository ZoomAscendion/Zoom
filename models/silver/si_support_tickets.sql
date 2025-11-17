{{ config(
    materialized='table',
    pre_hook="
        INSERT INTO {{ ref('si_audit_log') }} (
            EXECUTION_ID, PIPELINE_NAME, EXECUTION_START_TIME, EXECUTION_STATUS, 
            SOURCE_TABLE, TARGET_TABLE, EXECUTED_BY, LOAD_TIMESTAMP
        )
        VALUES (
            '{{ invocation_id }}', 
            'si_support_tickets', 
            CURRENT_TIMESTAMP(), 
            'RUNNING', 
            'BRONZE.BZ_SUPPORT_TICKETS', 
            'SILVER.SI_SUPPORT_TICKETS', 
            'DBT_SILVER_PIPELINE', 
            CURRENT_TIMESTAMP()
        )",
    post_hook="
        UPDATE {{ ref('si_audit_log') }} 
        SET EXECUTION_END_TIME = CURRENT_TIMESTAMP(),
            EXECUTION_STATUS = 'SUCCESS',
            RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}),
            RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }})
        WHERE EXECUTION_ID = '{{ invocation_id }}' 
        AND TARGET_TABLE = 'SILVER.SI_SUPPORT_TICKETS'"
) }}

-- Silver layer support tickets table with status standardization
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
    FROM {{ source('bronze', 'bz_support_tickets') }}
    WHERE TICKET_ID IS NOT NULL
      AND USER_ID IS NOT NULL
),

cleansed_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TRIM(UPPER(TICKET_TYPE)) AS TICKET_TYPE,
        -- Standardize resolution status
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
                THEN UPPER(TRIM(RESOLUTION_STATUS))
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) LIKE '%OPEN%' THEN 'OPEN'
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) LIKE '%PROGRESS%' THEN 'IN PROGRESS'
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) LIKE '%RESOLVED%' THEN 'RESOLVED'
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) LIKE '%CLOSED%' THEN 'CLOSED'
            ELSE 'UNKNOWN'
        END AS RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM bronze_support_tickets
    WHERE OPEN_DATE <= CURRENT_DATE()  -- Remove future dates
      AND TICKET_TYPE IS NOT NULL
      AND RESOLUTION_STATUS IS NOT NULL
),

validated_support_tickets AS (
    SELECT 
        st.TICKET_ID,
        st.USER_ID,
        st.TICKET_TYPE,
        st.RESOLUTION_STATUS,
        st.OPEN_DATE,
        st.LOAD_TIMESTAMP,
        st.UPDATE_TIMESTAMP,
        st.SOURCE_SYSTEM,
        -- Additional Silver layer metadata
        DATE(st.LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(st.UPDATE_TIMESTAMP) AS UPDATE_DATE,
        -- Data quality scoring
        CASE 
            WHEN st.RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
                 AND st.OPEN_DATE <= CURRENT_DATE() 
                 AND u.USER_ID IS NOT NULL THEN 100
            WHEN st.RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
                 AND st.OPEN_DATE <= CURRENT_DATE() THEN 80
            WHEN st.RESOLUTION_STATUS != 'UNKNOWN' THEN 60
            ELSE 40
        END AS DATA_QUALITY_SCORE,
        CASE 
            WHEN st.RESOLUTION_STATUS IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
                 AND st.OPEN_DATE <= CURRENT_DATE() 
                 AND u.USER_ID IS NOT NULL THEN 'PASSED'
            WHEN u.USER_ID IS NULL THEN 'FAILED'
            WHEN st.OPEN_DATE > CURRENT_DATE() THEN 'FAILED'
            WHEN st.RESOLUTION_STATUS = 'UNKNOWN' THEN 'FAILED'
            ELSE 'WARNING'
        END AS VALIDATION_STATUS
    FROM cleansed_support_tickets st
    LEFT JOIN {{ ref('si_users') }} u ON st.USER_ID = u.USER_ID
    WHERE st.rn = 1
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
