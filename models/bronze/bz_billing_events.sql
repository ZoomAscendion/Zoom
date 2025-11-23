-- Bronze Layer Billing Events Model
-- Description: Raw billing events data from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='event_id'
) }}

-- Filter out NULL primary keys and apply deduplication
WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'billing_events') }}
    WHERE event_id IS NOT NULL  -- Filter NULL primary keys
),

-- Apply deduplication based on primary key and load timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY event_id 
               ORDER BY load_timestamp DESC
           ) as rn
    FROM source_data
),

-- Final transformation with data type conversion
final AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        -- Convert VARCHAR amount to NUMBER
        CASE 
            WHEN amount IS NOT NULL AND TRIM(amount) != ''
            THEN TRY_TO_NUMBER(amount, 10, 2)
            ELSE NULL
        END as amount,
        event_date,
        -- Overwrite timestamps with current DBT run time
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        source_system
    FROM deduped_data
    WHERE rn = 1  -- Keep only the most recent record per event_id
)

SELECT * FROM final
