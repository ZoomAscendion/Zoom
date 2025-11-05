{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Silver Support Tickets transformation with data quality checks
WITH bronze_support_tickets AS (
    SELECT *
    FROM {{ source('bronze', 'bz_support_tickets') }}
    WHERE TICKET_ID IS NOT NULL
      AND TRIM(TICKET_ID) != ''
      AND USER_ID IS NOT NULL
      AND TICKET_TYPE IS NOT NULL
      AND RESOLUTION_STATUS IS NOT NULL
      AND OPEN_DATE IS NOT NULL
      AND OPEN_DATE >= '2020-01-01'
      AND OPEN_DATE <= CURRENT_DATE
),

valid_users AS (
    SELECT DISTINCT USER_ID
    FROM {{ ref('si_users') }}
),

filtered_support_tickets AS (
    SELECT bst.*
    FROM bronze_support_tickets bst
    INNER JOIN valid_users vu ON bst.USER_ID = vu.USER_ID
    WHERE UPPER(TRIM(bst.TICKET_TYPE)) IN ('TECHNICAL', 'BILLING', 'FEATURE_REQUEST', 'ACCOUNT', 'GENERAL')
      AND UPPER(TRIM(bst.RESOLUTION_STATUS)) IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')
),

deduped_support_tickets AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
    FROM filtered_support_tickets
),

final_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
        UPPER(TRIM(RESOLUTION_STATUS)) AS RESOLUTION_STATUS,
        OPEN_DATE,
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('RESOLVED', 'CLOSED') 
            THEN DATEDIFF('hour', OPEN_DATE, CURRENT_DATE) * 24.0
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        SOURCE_SYSTEM,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP
    FROM deduped_support_tickets
    WHERE rn = 1
)

SELECT * FROM final_support_tickets
