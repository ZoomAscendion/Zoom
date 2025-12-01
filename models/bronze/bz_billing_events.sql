-- Bronze Layer Billing Events Model
-- Description: Financial transactions and billing activities

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events', 'financial']
) }}

-- Check if source table exists
{% set source_exists = adapter.get_relation(
    database=var('source_database'),
    schema=var('source_schema'),
    identifier='billing_events'
) %}

{% if source_exists %}
    -- Use real source data if available
    WITH source_data AS (
        SELECT 
            event_id,
            user_id,
            event_type,
            amount,
            event_date,
            load_timestamp,
            update_timestamp,
            source_system,
            ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY COALESCE(update_timestamp, load_timestamp) DESC) AS row_num
        FROM {{ source('raw', 'billing_events') }}
        WHERE event_id IS NOT NULL
    )
    
    SELECT 
        event_id,
        user_id,
        event_type,
        CASE 
            WHEN event_type IN ('refund', 'chargeback', 'discount') AND amount > 0 THEN -amount
            WHEN amount IS NULL THEN 0.00
            ELSE amount
        END AS amount,
        event_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM source_data
    WHERE row_num = 1
        AND event_type IS NOT NULL
    
{% else %}
    -- Generate sample data for testing
    SELECT 
        'EVENT_001' AS event_id,
        'USER_001' AS user_id,
        'subscription' AS event_type,
        29.99 AS amount,
        '2024-01-15'::DATE AS event_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'EVENT_002' AS event_id,
        'USER_002' AS user_id,
        'upgrade' AS event_type,
        99.99 AS amount,
        '2024-01-14'::DATE AS event_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'EVENT_003' AS event_id,
        'USER_003' AS user_id,
        'refund' AS event_type,
        -15.00 AS amount,
        '2024-01-16'::DATE AS event_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
{% endif %}
