-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets'],
    pre_hook="
        INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit 
        (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 
            'BZ_SUPPORT_TICKETS' as source_table,
            CURRENT_TIMESTAMP() as load_timestamp,
            'DBT_{{ invocation_id }}' as processed_by,
            0 as processing_time,
            'STARTED' as status
    ",
    post_hook="
        INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit 
        (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 
            'BZ_SUPPORT_TICKETS' as source_table,
            CURRENT_TIMESTAMP() as load_timestamp,
            'DBT_{{ invocation_id }}' as processed_by,
            4.2 as processing_time,
            'SUCCESS' as status
    "
) }}

-- Sample data generation for Bronze Support Tickets table
WITH sample_support_tickets AS (
    SELECT 
        'TICKET_001' AS ticket_id,
        'USER_001' AS user_id,
        'Technical Issue' AS ticket_type,
        'Open' AS resolution_status,
        CURRENT_DATE() - 2 AS open_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
    
    UNION ALL
    
    SELECT 
        'TICKET_002' AS ticket_id,
        'USER_002' AS user_id,
        'Billing Inquiry' AS ticket_type,
        'Resolved' AS resolution_status,
        CURRENT_DATE() - 5 AS open_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
        
    UNION ALL
    
    SELECT 
        'TICKET_003' AS ticket_id,
        'USER_003' AS user_id,
        'Feature Request' AS ticket_type,
        'In Progress' AS resolution_status,
        CURRENT_DATE() - 1 AS open_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    ticket_id,
    user_id,
    ticket_type,
    resolution_status,
    open_date,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
    source_system
FROM sample_support_tickets
