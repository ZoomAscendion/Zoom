-- Bronze Layer Support Tickets Table
-- Description: Manages customer support requests and resolution tracking
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='ticket_id'
) }}

-- Create sample support tickets data
WITH sample_support_tickets AS (
    SELECT 
        'TICK001' as ticket_id,
        'USER001' as user_id,
        'technical' as ticket_type,
        'open' as resolution_status,
        CURRENT_DATE() as open_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
    
    UNION ALL
    
    SELECT 
        'TICK002' as ticket_id,
        'USER002' as user_id,
        'billing' as ticket_type,
        'resolved' as resolution_status,
        CURRENT_DATE() - 1 as open_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
        
    UNION ALL
    
    SELECT 
        'TICK003' as ticket_id,
        'USER003' as user_id,
        'account' as ticket_type,
        'in_progress' as resolution_status,
        CURRENT_DATE() - 2 as open_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
)

SELECT 
    ticket_id,
    user_id,
    ticket_type,
    resolution_status,
    open_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM sample_support_tickets
