-- Bronze Layer Billing Events Table
-- Description: Raw billing events data from source systems
-- Source: RAW.BILLING_EVENTS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='event_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'dbt_user', 0, 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'dbt_user', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_BILLING_EVENTS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS'"
) }}

-- Source data with null filtering for primary key
WITH source_data AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'billing_events') }}
    WHERE event_id IS NOT NULL    -- Filter out null primary keys
      AND user_id IS NOT NULL     -- Filter out null user_id
      AND event_type IS NOT NULL  -- Filter out null event_type
      AND amount IS NOT NULL      -- Filter out null amount
      AND event_date IS NOT NULL  -- Filter out null event_date
),

-- Data cleaning and validation
cleaned_data AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        TRY_CAST(amount AS NUMBER(10,2)) AS amount,  -- Handle string to number conversion
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM source_data
),

-- Deduplication based on event_id (keeping latest record)
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY COALESCE(update_timestamp, load_timestamp) DESC) AS rn
    FROM cleaned_data
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    event_id,
    user_id,
    event_type,
    amount,
    event_date,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run time
    source_system
FROM deduped_data
WHERE rn = 1
