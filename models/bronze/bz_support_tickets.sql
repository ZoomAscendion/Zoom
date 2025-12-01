-- Bronze Layer Support Tickets Model
-- Description: Customer support requests and resolution tracking

{{ config(
    materialized='table',
    tags=['bronze', 'support_tickets']
) }}

-- Check if source table exists
{% set source_exists = adapter.get_relation(
    database=var('source_database'),
    schema=var('source_schema'),
    identifier='support_tickets'
) %}

{% if source_exists %}
    -- Use real source data if available
    WITH source_data AS (
        SELECT 
            ticket_id,
            user_id,
            ticket_type,
            resolution_status,
            open_date,
            load_timestamp,
            update_timestamp,
            source_system,
            ROW_NUMBER() OVER (PARTITION BY ticket_id ORDER BY COALESCE(update_timestamp, load_timestamp) DESC) AS row_num
        FROM {{ source('raw', 'support_tickets') }}
        WHERE ticket_id IS NOT NULL
    )
    
    SELECT 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(source_system, 'UNKNOWN') AS source_system
    FROM source_data
    WHERE row_num = 1
        AND user_id IS NOT NULL
        AND (open_date IS NULL OR open_date <= CURRENT_DATE())
    
{% else %}
    -- Generate sample data for testing
    SELECT 
        'TICKET_001' AS ticket_id,
        'USER_001' AS user_id,
        'Technical' AS ticket_type,
        'Open' AS resolution_status,
        '2024-01-15'::DATE AS open_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'TICKET_002' AS ticket_id,
        'USER_002' AS user_id,
        'Billing' AS ticket_type,
        'Resolved' AS resolution_status,
        '2024-01-14'::DATE AS open_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
    
    UNION ALL
    
    SELECT 
        'TICKET_003' AS ticket_id,
        'USER_003' AS user_id,
        'General' AS ticket_type,
        'In Progress' AS resolution_status,
        '2024-01-16'::DATE AS open_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_DATA' AS source_system
{% endif %}
