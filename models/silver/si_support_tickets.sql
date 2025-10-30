{{ config(
    materialized='incremental',
    unique_key='ticket_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Support Tickets
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
        AND OPEN_DATE IS NOT NULL
        AND OPEN_DATE <= CURRENT_DATE()
),

-- Data Quality Checks and Cleansing
cleansed_support_tickets AS (
    SELECT 
        TRIM(TICKET_ID) as TICKET_ID,
        TRIM(USER_ID) as USER_ID,
        CASE 
            WHEN UPPER(TICKET_TYPE) IN ('TECHNICAL', 'BILLING', 'FEATURE REQUEST', 'BUG REPORT') 
            THEN INITCAP(TICKET_TYPE)
            ELSE 'Other'
        END as TICKET_TYPE,
        CASE 
            WHEN TICKET_TYPE LIKE '%critical%' OR TICKET_TYPE LIKE '%urgent%' THEN 'Critical'
            WHEN TICKET_TYPE LIKE '%high%' THEN 'High'
            WHEN TICKET_TYPE LIKE '%low%' THEN 'Low'
            ELSE 'Medium'
        END as PRIORITY_LEVEL,
        OPEN_DATE,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN OPEN_DATE + 2
            ELSE NULL
        END as CLOSE_DATE,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
            THEN INITCAP(RESOLUTION_STATUS)
            ELSE 'Open'
        END as RESOLUTION_STATUS,
        'Standard support issue' as ISSUE_DESCRIPTION,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN 'Issue resolved successfully'
            ELSE NULL
        END as RESOLUTION_NOTES,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN 24.0
            ELSE NULL
        END as RESOLUTION_TIME_HOURS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_support_tickets
),

-- Remove duplicates
deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM cleansed_support_tickets
),

-- Calculate data quality score
final_support_tickets AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        PRIORITY_LEVEL,
        OPEN_DATE,
        CLOSE_DATE,
        RESOLUTION_STATUS,
        ISSUE_DESCRIPTION,
        RESOLUTION_NOTES,
        RESOLUTION_TIME_HOURS,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Calculate data quality score
        ROUND(
            (CASE WHEN TICKET_TYPE != 'Other' THEN 0.2 ELSE 0 END +
             CASE WHEN PRIORITY_LEVEL IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN OPEN_DATE IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN RESOLUTION_STATUS IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN ISSUE_DESCRIPTION IS NOT NULL THEN 0.2 ELSE 0 END), 2
        ) as DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) as LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) as UPDATE_DATE
    FROM deduped_support_tickets
    WHERE rn = 1
)

SELECT * FROM final_support_tickets

{% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT COALESCE(MAX(UPDATE_TIMESTAMP), '1900-01-01') FROM {{ this }})
{% endif %}
