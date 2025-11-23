-- Bronze Layer Billing Events Table
-- Description: Raw billing events data from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='event_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_BILLING_EVENTS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS'"
) }}

WITH source_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        TRY_CAST(AMOUNT AS NUMBER(10,2)) as AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP as raw_load_timestamp,
        UPDATE_TIMESTAMP as raw_update_timestamp,
        SOURCE_SYSTEM
    FROM {{ source('raw_schema', 'billing_events') }}
    WHERE EVENT_ID IS NOT NULL    -- Filter out NULL primary keys
      AND USER_ID IS NOT NULL     -- Filter out NULL foreign keys
      AND EVENT_TYPE IS NOT NULL  -- Filter out NULL required fields
      AND AMOUNT IS NOT NULL      -- Filter out NULL required fields
      AND EVENT_DATE IS NOT NULL  -- Filter out NULL required fields
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY COALESCE(raw_update_timestamp, raw_load_timestamp) DESC
        ) as row_num
    FROM source_data
),

-- Handle null values and apply business rules
cleaned_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Bronze timestamp overwrite
        CURRENT_TIMESTAMP() AS update_timestamp,  -- Bronze timestamp overwrite
        SOURCE_SYSTEM
    FROM deduped_data
    WHERE row_num = 1
)

SELECT * FROM cleaned_data
