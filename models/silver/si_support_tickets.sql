{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

/* Silver Support Tickets Table - Cleaned and standardized customer support requests */

WITH bronze_support_tickets AS (
    SELECT *
    FROM {{ source('bronze', 'bz_support_tickets') }}
),

data_quality_checks AS (
    SELECT 
        bst.*,
        /* Data Quality Score Calculation */
        (
            CASE WHEN bst.TICKET_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN bst.USER_ID IS NOT NULL THEN 25 ELSE 0 END +
            CASE WHEN bst.TICKET_TYPE IS NOT NULL AND LENGTH(TRIM(bst.TICKET_TYPE)) > 0 THEN 20 ELSE 0 END +
            CASE WHEN bst.RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 15 ELSE 0 END +
            CASE WHEN bst.OPEN_DATE IS NOT NULL AND bst.OPEN_DATE <= CURRENT_DATE() THEN 15 ELSE 0 END
        ) AS DATA_QUALITY_SCORE,
        
        /* Validation Status */
        CASE 
            WHEN bst.TICKET_ID IS NULL OR bst.USER_ID IS NULL THEN 'FAILED'
            WHEN bst.TICKET_TYPE IS NULL OR LENGTH(TRIM(bst.TICKET_TYPE)) = 0 THEN 'FAILED'
            WHEN bst.RESOLUTION_STATUS NOT IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 'FAILED'
            WHEN bst.OPEN_DATE IS NULL OR bst.OPEN_DATE > CURRENT_DATE() THEN 'FAILED'
            ELSE 'PASSED'
        END AS VALIDATION_STATUS
    FROM bronze_support_tickets bst
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID 
            ORDER BY UPDATE_TIMESTAMP DESC NULLS LAST, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM data_quality_checks
    WHERE TICKET_ID IS NOT NULL
),

final_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        UPPER(TRIM(TICKET_TYPE)) AS TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        DATA_QUALITY_SCORE,
        VALIDATION_STATUS
    FROM deduplication
    WHERE row_num = 1
      AND VALIDATION_STATUS != 'FAILED'
)

SELECT * FROM final_support_tickets
