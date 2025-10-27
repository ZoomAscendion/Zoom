{{
  config(
    materialized='incremental',
    unique_key='support_ticket_id',
    on_schema_change='sync_all_columns',
    incremental_strategy='merge'
  )
}}

-- Silver Support Tickets Table Transformation
-- Transforms bronze support ticket data with SLA calculations and categorization

WITH bronze_support_tickets AS (
    SELECT 
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('bronze', 'bz_support_tickets') }}
    WHERE user_id IS NOT NULL 
      AND ticket_type IS NOT NULL
      AND resolution_status IS NOT NULL
      AND open_date IS NOT NULL
      AND open_date <= CURRENT_DATE()
),

deduped_support_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, ticket_type, open_date 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM bronze_support_tickets
),

transformed_support_tickets AS (
    SELECT 
        -- Primary Key Generation
        {{ dbt_utils.generate_surrogate_key(['user_id', 'ticket_type', 'open_date']) }} AS support_ticket_id,
        
        -- Direct Mappings
        user_id,
        
        -- Standardized Ticket Types
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TECH%' OR UPPER(ticket_type) LIKE '%BUG%' THEN 'Technical'
            WHEN UPPER(ticket_type) LIKE '%BILL%' OR UPPER(ticket_type) LIKE '%PAY%' THEN 'Billing'
            WHEN UPPER(ticket_type) LIKE '%FEATURE%' OR UPPER(ticket_type) LIKE '%REQUEST%' THEN 'Feature Request'
            ELSE 'General'
        END AS ticket_type,
        
        'No description provided' AS issue_description,
        
        -- Derived Priority Level
        CASE 
            WHEN UPPER(ticket_type) LIKE '%TECH%' OR UPPER(ticket_type) LIKE '%BUG%' THEN 'High'
            WHEN UPPER(ticket_type) LIKE '%BILL%' THEN 'Medium'
            ELSE 'Low'
        END AS priority_level,
        
        -- Standardized Resolution Status
        CASE 
            WHEN UPPER(resolution_status) IN ('OPEN', 'NEW', 'CREATED') THEN 'Open'
            WHEN UPPER(resolution_status) IN ('PROGRESS', 'WORKING', 'ASSIGNED') THEN 'In Progress'
            WHEN UPPER(resolution_status) IN ('RESOLVED', 'FIXED', 'COMPLETED') THEN 'Resolved'
            WHEN UPPER(resolution_status) IN ('CLOSED', 'DONE') THEN 'Closed'
            ELSE 'Open'
        END AS resolution_status,
        
        open_date,
        
        CASE 
            WHEN UPPER(resolution_status) IN ('RESOLVED', 'FIXED', 'COMPLETED', 'CLOSED', 'DONE') 
            THEN DATEADD(day, 2, open_date)  -- Estimated close date
            ELSE NULL
        END AS close_date,
        
        -- Calculated Resolution Time
        CASE 
            WHEN UPPER(resolution_status) IN ('RESOLVED', 'FIXED', 'COMPLETED', 'CLOSED', 'DONE') 
            THEN DATEDIFF(hour, open_date, DATEADD(day, 2, open_date))
            ELSE NULL
        END AS resolution_time_hours,
        
        24 AS first_response_time_hours,  -- Default SLA
        
        FALSE AS escalation_flag,
        FALSE AS sla_breach_flag,
        
        -- Audit Fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system,
        load_timestamp,
        update_timestamp,
        
        -- Data Quality Score Calculation
        ROUND(
            (CASE WHEN user_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN ticket_type IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN resolution_status IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN open_date IS NOT NULL AND open_date <= CURRENT_DATE() THEN 0.25 ELSE 0 END), 2
        ) AS data_quality_score
        
    FROM deduped_support_tickets
    WHERE row_num = 1
)

SELECT * FROM transformed_support_tickets

{% if is_incremental() %}
  WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
{% endif %}
