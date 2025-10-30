{{
  config(
    materialized='incremental',
    unique_key='ticket_id',
    on_schema_change='sync_all_columns',
    pre_hook="INSERT INTO {{ ref('audit_log') }} (audit_id, source_table, process_start_time, status, processed_by, load_date, source_system) SELECT '{{ invocation_id }}', 'SI_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'STARTED', 'DBT', CURRENT_DATE(), 'DBT_PIPELINE' WHERE '{{ this.name }}' != 'audit_log'",
    post_hook="UPDATE {{ ref('audit_log') }} SET process_end_time = CURRENT_TIMESTAMP(), status = 'SUCCESS' WHERE audit_id = '{{ invocation_id }}' AND source_table = 'SI_SUPPORT_TICKETS' AND '{{ this.name }}' != 'audit_log'"
  )
}}

WITH bronze_support_tickets AS (
    SELECT *
    FROM {{ ref('bz_support_tickets') }}
    WHERE TICKET_ID IS NOT NULL
        AND USER_ID IS NOT NULL
        AND OPEN_DATE IS NOT NULL
    {% if is_incremental() %}
        AND UPDATE_TIMESTAMP > (SELECT MAX(UPDATE_TIMESTAMP) FROM {{ this }})
    {% endif %}
),

cleaned_support_tickets AS (
    SELECT 
        TICKET_ID AS ticket_id,
        USER_ID AS user_id,
        CASE 
            WHEN UPPER(TRIM(TICKET_TYPE)) IN ('TECHNICAL', 'BILLING', 'FEATURE REQUEST', 'BUG REPORT') 
            THEN UPPER(TRIM(TICKET_TYPE))
            ELSE 'OTHER'
        END AS ticket_type,
        CASE 
            WHEN UPPER(TICKET_TYPE) LIKE '%CRITICAL%' OR UPPER(TICKET_TYPE) LIKE '%URGENT%' THEN 'CRITICAL'
            WHEN UPPER(TICKET_TYPE) LIKE '%HIGH%' THEN 'HIGH'
            WHEN UPPER(TICKET_TYPE) LIKE '%LOW%' THEN 'LOW'
            ELSE 'MEDIUM'
        END AS priority_level,
        OPEN_DATE,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' OR UPPER(RESOLUTION_STATUS) = 'CLOSED' 
            THEN DATEADD('day', 3, OPEN_DATE)
            ELSE NULL
        END AS close_date,
        CASE 
            WHEN UPPER(TRIM(RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED') 
            THEN UPPER(TRIM(RESOLUTION_STATUS))
            ELSE 'OPEN'
        END AS resolution_status,
        'Customer reported issue' AS issue_description,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN 'Issue resolved successfully'
            ELSE NULL
        END AS resolution_notes,
        CASE 
            WHEN UPPER(RESOLUTION_STATUS) = 'RESOLVED' THEN 24
            ELSE NULL
        END AS resolution_time_hours,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        {{ calculate_data_quality_score('si_support_tickets', ['TICKET_ID', 'USER_ID', 'TICKET_TYPE', 'OPEN_DATE']) }} AS data_quality_score,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date
    FROM bronze_support_tickets
),

deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY ticket_id ORDER BY update_timestamp DESC) AS rn
    FROM cleaned_support_tickets
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
WHERE rn = 1
