-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='event_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0.0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0.0, 'COMPLETED' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Filter out NULL primary keys before any processing
WITH source_data AS (
    SELECT *
    FROM {{ source('raw_zoom', 'billing_events') }}
    WHERE event_id IS NOT NULL
),

-- Apply deduplication based on primary key and latest update timestamp
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY event_id 
               ORDER BY update_timestamp DESC, load_timestamp DESC
           ) as row_num
    FROM source_data
)

-- Final selection with 1-1 mapping and data type conversion
SELECT 
    event_id,
    user_id,
    event_type,
    TRY_CAST(amount AS NUMBER(10,2)) as amount,
    event_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM deduped_data
WHERE row_num = 1
