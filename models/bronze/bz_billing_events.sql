-- Bronze Layer Billing Events Table
-- Description: Raw billing events data from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ target.schema }}.bz_data_audit (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_USER', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ target.schema }}.bz_data_audit (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_USER', 10, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- CTE to select and filter raw data
WITH raw_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        CASE 
            WHEN amount IS NULL OR amount = '' THEN 0.00
            ELSE TRY_CAST(amount AS NUMBER(10,2))
        END AS amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'billing_events') }}
    WHERE event_id IS NOT NULL    -- Filter out NULL primary keys
      AND user_id IS NOT NULL     -- Filter out NULL user_id
      AND event_type IS NOT NULL  -- Filter out NULL event_type
      AND event_date IS NOT NULL  -- Filter out NULL event_date
),

-- CTE for deduplication based on primary key
deduped_billing_events AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY load_timestamp DESC) as rn
    FROM raw_billing_events
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    event_id,
    user_id,
    event_type,
    amount,
    event_date,
    CURRENT_TIMESTAMP() AS load_timestamp,    -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run time
    source_system
FROM deduped_billing_events
WHERE rn = 1  -- Keep only the most recent record per event_id
