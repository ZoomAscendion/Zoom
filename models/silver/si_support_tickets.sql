{{ config(
    materialized='incremental',
    unique_key='ticket_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Support Tickets data
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
    
    {% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

cleansed_support_tickets AS (
    SELECT 
        TRIM(TICKET_ID) AS ticket_id,
        TRIM(USER_ID) AS user_id,
        CASE 
            WHEN UPPER(TRIM(TICKET_TYPE)) IN ('TECHNICAL', 'BILLING', 'FEATURE REQUEST', 'BUG REPORT')
            THEN INITCAP(TRIM(TICKET_TYPE))
            ELSE 'Technical'
        END AS ticket_type,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 'Critical'
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 'High'
            WHEN UPPER(TICKET_TYPE) LIKE '%LOW%' THEN 'Low'
            ELSE 'Medium'
        END AS priority_level,
        OPEN_DATE AS open_date,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' OR UPPER(RESOLUTION_STATUS) = 'CLOSED'
            THEN OPEN_DATE + INTERVAL '2 DAYS'  -- Estimated close date
            ELSE NULL
        END AS close_date,
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED')
            THEN INITCAP(TRIM(RESOLUTION_STATUS))
            ELSE 'Open'
        END AS resolution_status,
        'Customer reported issue' AS issue_description,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN 'Issue resolved successfully'
            ELSE NULL
        END AS resolution_notes,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN 48  -- Estimated 48 hours
            ELSE NULL
        END AS resolution_time_hours,
        LOAD_TIMESTAMP AS load_timestamp,
        UPDATE_TIMESTAMP AS update_timestamp,
        SOURCE_SYSTEM AS source_system,
        CASE 
            WHEN TICKET_ID IS NOT NULL AND USER_ID IS NOT NULL AND TICKET_TYPE IS NOT NULL
            THEN 1.00
            ELSE 0.60
        END AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_support_tickets
    WHERE TICKET_ID IS NOT NULL
),

deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ticket_id 
            ORDER BY update_timestamp DESC
        ) AS row_num
    FROM cleansed_support_tickets
)

SELECT 
    ticket_id,
    user_id,
    ticket_type,
    priority_level,
    open_date,
    close_date,
    resolution_status,
    issue_description,
    resolution_notes,
    resolution_time_hours,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    load_date,
    update_date
FROM deduped_support_tickets
WHERE row_num = 1
