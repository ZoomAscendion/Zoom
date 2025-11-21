-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='event_id'
) }}

-- Create sample billing events data
WITH sample_billing_events AS (
    SELECT 
        'BILL001' as event_id,
        'USER001' as user_id,
        'subscription' as event_type,
        19.99 as amount,
        CURRENT_DATE() as event_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
    
    UNION ALL
    
    SELECT 
        'BILL002' as event_id,
        'USER002' as user_id,
        'usage' as event_type,
        39.99 as amount,
        CURRENT_DATE() - 1 as event_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
        
    UNION ALL
    
    SELECT 
        'BILL003' as event_id,
        'USER003' as user_id,
        'refund' as event_type,
        -14.99 as amount,
        CURRENT_DATE() - 3 as event_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' as source_system
)

SELECT 
    event_id,
    user_id,
    event_type,
    amount,
    event_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM sample_billing_events
