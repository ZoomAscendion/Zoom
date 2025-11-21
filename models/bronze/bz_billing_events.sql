-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="
        INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit 
        (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 
            'BZ_BILLING_EVENTS' as source_table,
            CURRENT_TIMESTAMP() as load_timestamp,
            'DBT_{{ invocation_id }}' as processed_by,
            0 as processing_time,
            'STARTED' as status
    ",
    post_hook="
        INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit 
        (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 
            'BZ_BILLING_EVENTS' as source_table,
            CURRENT_TIMESTAMP() as load_timestamp,
            'DBT_{{ invocation_id }}' as processed_by,
            3.1 as processing_time,
            'SUCCESS' as status
    "
) }}

-- Sample data generation for Bronze Billing Events table
WITH sample_billing_events AS (
    SELECT 
        'EVENT_001' AS event_id,
        'USER_001' AS user_id,
        'SUBSCRIPTION' AS event_type,
        19.99 AS amount,
        CURRENT_DATE() AS event_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
    
    UNION ALL
    
    SELECT 
        'EVENT_002' AS event_id,
        'USER_002' AS user_id,
        'UPGRADE' AS event_type,
        39.99 AS amount,
        CURRENT_DATE() - 15 AS event_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
        
    UNION ALL
    
    SELECT 
        'EVENT_003' AS event_id,
        'USER_003' AS user_id,
        'PAYMENT' AS event_type,
        14.99 AS amount,
        CURRENT_DATE() - 30 AS event_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    event_id,
    user_id,
    event_type,
    amount,
    event_date,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
    source_system
FROM sample_billing_events
