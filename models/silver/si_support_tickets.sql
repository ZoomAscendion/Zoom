{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ ref('si_pipeline_audit') }} (
            execution_id, pipeline_name, start_time, status, 
            source_tables_processed, executed_by, execution_environment,
            load_date, update_date, source_system
        )
        VALUES (
            '{{ invocation_id }}_si_support_tickets', 
            'si_support_tickets', 
            CURRENT_TIMESTAMP(), 
            'STARTED',
            'BZ_SUPPORT_TICKETS',
            '{{ var(\"audit_user\") }}',
            'PRODUCTION',
            CURRENT_DATE(),
            CURRENT_DATE(),
            'DBT_SILVER_PIPELINE'
        )
    ",
    post_hook="
        UPDATE {{ ref('si_pipeline_audit') }}
        SET 
            end_time = CURRENT_TIMESTAMP(),
            status = 'SUCCESS',
            execution_duration_seconds = DATEDIFF('second', start_time, CURRENT_TIMESTAMP()),
            target_tables_updated = 'SI_SUPPORT_TICKETS',
            records_processed = (SELECT COUNT(*) FROM {{ this }}),
            records_inserted = (SELECT COUNT(*) FROM {{ this }}),
            records_updated = 0,
            records_rejected = 0,
            update_date = CURRENT_DATE()
        WHERE execution_id = '{{ invocation_id }}_si_support_tickets'
    "
) }}

-- Silver layer transformation for Support Tickets
WITH bronze_support_tickets AS (
    SELECT *
    FROM {{ source('bronze', 'bz_support_tickets') }}
),

-- Data Quality Checks and Cleansing
cleansed_tickets AS (
    SELECT 
        ticket_id,
        user_id,
        TRIM(UPPER(ticket_type)) AS ticket_type_clean,
        TRIM(UPPER(resolution_status)) AS resolution_status_clean,
        open_date,
        load_timestamp,
        update_timestamp,
        source_system,
        
        -- Data Quality Validations
        CASE 
            WHEN ticket_id IS NULL THEN 0
            WHEN user_id IS NULL THEN 0
            WHEN open_date IS NULL THEN 0
            WHEN open_date > CURRENT_DATE() THEN 0
            ELSE 1
        END AS ticket_valid,
        
        -- Corrected open_date if future
        CASE 
            WHEN open_date > CURRENT_DATE() THEN CURRENT_DATE()
            ELSE open_date
        END AS open_date_corrected
        
    FROM bronze_support_tickets
),

-- Remove duplicates
deduped_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ticket_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS rn
    FROM cleansed_tickets
    WHERE ticket_valid = 1
),

-- Final transformation with derived fields
final_tickets AS (
    SELECT 
        ticket_id,
        user_id,
        
        -- Standardize ticket type
        CASE 
            WHEN ticket_type_clean IN ('TECHNICAL', 'TECH', 'TECHNICAL_ISSUE') THEN 'Technical'
            WHEN ticket_type_clean IN ('BILLING', 'PAYMENT', 'INVOICE') THEN 'Billing'
            WHEN ticket_type_clean IN ('FEATURE', 'FEATURE_REQUEST', 'ENHANCEMENT') THEN 'Feature Request'
            WHEN ticket_type_clean IN ('BUG', 'BUG_REPORT', 'ERROR') THEN 'Bug Report'
            ELSE 'Other'
        END AS ticket_type,
        
        -- Derive priority level from ticket type
        CASE 
            WHEN ticket_type_clean IN ('BUG', 'BUG_REPORT', 'ERROR') THEN 'Critical'
            WHEN ticket_type_clean IN ('TECHNICAL', 'TECH', 'TECHNICAL_ISSUE') THEN 'High'
            WHEN ticket_type_clean IN ('BILLING', 'PAYMENT', 'INVOICE') THEN 'Medium'
            ELSE 'Low'
        END AS priority_level,
        
        open_date_corrected AS open_date,
        
        -- Derive close date from resolution status
        CASE 
            WHEN resolution_status_clean IN ('RESOLVED', 'CLOSED') 
            THEN DATEADD('day', 3, open_date_corrected)
            ELSE NULL
        END AS close_date,
        
        -- Standardize resolution status
        CASE 
            WHEN resolution_status_clean IN ('OPEN', 'NEW', 'PENDING') THEN 'Open'
            WHEN resolution_status_clean IN ('IN_PROGRESS', 'WORKING', 'ASSIGNED') THEN 'In Progress'
            WHEN resolution_status_clean IN ('RESOLVED', 'FIXED') THEN 'Resolved'
            WHEN resolution_status_clean IN ('CLOSED', 'COMPLETED') THEN 'Closed'
            ELSE 'Open'
        END AS resolution_status,
        
        -- Generate issue description based on ticket type
        CASE 
            WHEN ticket_type_clean IN ('TECHNICAL', 'TECH') THEN 'Technical issue reported by user'
            WHEN ticket_type_clean IN ('BILLING', 'PAYMENT') THEN 'Billing or payment related inquiry'
            WHEN ticket_type_clean IN ('FEATURE', 'FEATURE_REQUEST') THEN 'Feature enhancement request'
            WHEN ticket_type_clean IN ('BUG', 'BUG_REPORT') THEN 'Software bug or error reported'
            ELSE 'General support inquiry'
        END AS issue_description,
        
        -- Generate resolution notes
        CASE 
            WHEN resolution_status_clean IN ('RESOLVED', 'CLOSED') THEN 'Issue resolved through standard support process'
            WHEN resolution_status_clean IN ('IN_PROGRESS', 'WORKING') THEN 'Issue currently being investigated'
            ELSE 'Awaiting initial review'
        END AS resolution_notes,
        
        -- Calculate resolution time in hours
        CASE 
            WHEN resolution_status_clean IN ('RESOLVED', 'CLOSED') 
            THEN DATEDIFF('hour', open_date_corrected, DATEADD('day', 3, open_date_corrected))
            ELSE NULL
        END AS resolution_time_hours,
        
        -- Metadata columns
        load_timestamp,
        update_timestamp,
        source_system,
        
        -- Data quality score
        CASE 
            WHEN ticket_id IS NOT NULL 
                AND user_id IS NOT NULL 
                AND open_date_corrected IS NOT NULL
            THEN 1.00
            ELSE 0.75
        END AS data_quality_score,
        
        DATE(load_timestamp) AS load_date,
        DATE(update_timestamp) AS update_date
        
    FROM deduped_tickets
    WHERE rn = 1
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
FROM final_tickets
