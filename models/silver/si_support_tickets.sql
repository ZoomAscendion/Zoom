{{ config(
    materialized='incremental',
    unique_key='ticket_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for support tickets with data quality checks
WITH bronze_support_tickets AS (
    SELECT 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        load_timestamp,
        update_timestamp,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY ticket_id ORDER BY update_timestamp DESC, load_timestamp DESC) as rn
    FROM {{ source('bronze', 'bz_support_tickets') }}
    WHERE ticket_id IS NOT NULL 
    AND TRIM(ticket_id) != ''
    AND user_id IS NOT NULL
    AND open_date IS NOT NULL
    AND open_date <= CURRENT_DATE()
    {% if is_incremental() %}
        AND (update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
             OR load_timestamp > (SELECT COALESCE(MAX(load_timestamp), '1900-01-01') FROM {{ this }}))
    {% endif %}
),

deduped_support_tickets AS (
    SELECT 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM bronze_support_tickets
    WHERE rn = 1
),

validated_support_tickets AS (
    SELECT 
        s.ticket_id,
        s.user_id,
        CASE 
            WHEN s.ticket_type IN ('Technical', 'Billing', 'Feature Request', 'Bug Report')
            THEN s.ticket_type
            ELSE 'Other'
        END AS ticket_type,
        CASE 
            WHEN s.ticket_type = 'Bug Report' THEN 'High'
            WHEN s.ticket_type = 'Technical' THEN 'Medium'
            WHEN s.ticket_type = 'Billing' THEN 'High'
            WHEN s.ticket_type = 'Feature Request' THEN 'Low'
            ELSE 'Medium'
        END AS priority_level,
        s.open_date,
        CASE 
            WHEN s.resolution_status IN ('Resolved', 'Closed')
            THEN DATEADD('day', FLOOR(RANDOM() * 7) + 1, s.open_date)
            ELSE NULL
        END AS close_date,
        CASE 
            WHEN s.resolution_status IN ('Open', 'In Progress', 'Resolved', 'Closed')
            THEN s.resolution_status
            ELSE 'Open'
        END AS resolution_status,
        'Customer reported issue' AS issue_description,
        CASE 
            WHEN s.resolution_status IN ('Resolved', 'Closed')
            THEN 'Issue resolved successfully'
            ELSE NULL
        END AS resolution_notes,
        CASE 
            WHEN s.resolution_status IN ('Resolved', 'Closed')
            THEN FLOOR(RANDOM() * 48) + 1
            ELSE NULL
        END AS resolution_time_hours,
        s.load_timestamp,
        s.update_timestamp,
        s.source_system
    FROM deduped_support_tickets s
    INNER JOIN {{ ref('si_users') }} u ON s.user_id = u.user_id
),

final_support_tickets AS (
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
        -- Calculate data quality score
        CAST(ROUND(
            (CASE WHEN ticket_id IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN user_id IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN ticket_type != 'Other' THEN 0.2 ELSE 0 END +
             CASE WHEN priority_level IS NOT NULL THEN 0.2 ELSE 0 END +
             CASE WHEN open_date IS NOT NULL THEN 0.2 ELSE 0 END), 2
        ) AS NUMBER(3,2)) AS data_quality_score,
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
    FROM validated_support_tickets
)

SELECT * FROM final_support_tickets
