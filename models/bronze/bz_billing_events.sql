-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Author: DBT Pipeline Generator
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='event_id',
    pre_hook="INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_PIPELINE', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    -- Select from raw billing_events table with null filtering for primary key
    SELECT 
        event_id,
        user_id,
        event_type,
        TRY_CAST(amount AS NUMBER(10,2)) AS amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_layer', 'billing_events') }}
    WHERE event_id IS NOT NULL  -- Filter out null primary keys
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest update timestamp
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY event_id 
                   ORDER BY update_timestamp DESC, load_timestamp DESC
               ) as rn
        FROM source_data
    )
    WHERE rn = 1
)

-- Final select with 1-1 mapping from raw to bronze
SELECT 
    event_id,
    user_id,
    event_type,
    amount,
    event_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM deduped_data
