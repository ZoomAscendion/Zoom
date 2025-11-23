-- Bronze Layer Billing Events Model
-- Description: Raw billing events data from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    pre_hook="CREATE TABLE IF NOT EXISTS {{ this.database }}.{{ this.schema }}.bz_data_audit_temp AS SELECT 'BZ_BILLING_EVENTS' as source_table, CURRENT_TIMESTAMP() as load_timestamp, 'DBT_BRONZE_PIPELINE' as processed_by, 0 as processing_time, 'STARTED' as status, 11 as record_id",
    post_hook="CREATE TABLE IF NOT EXISTS {{ this.database }}.{{ this.schema }}.bz_data_audit_temp AS SELECT 'BZ_BILLING_EVENTS' as source_table, CURRENT_TIMESTAMP() as load_timestamp, 'DBT_BRONZE_PIPELINE' as processed_by, 1 as processing_time, 'COMPLETED' as status, 12 as record_id"
) }}

-- Filter out null primary keys and apply deduplication
WITH source_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        TRY_CAST(AMOUNT AS NUMBER(10,2)) as AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'billing_events') }}
    WHERE EVENT_ID IS NOT NULL  -- Filter null primary keys
      AND USER_ID IS NOT NULL   -- Filter null user IDs
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) as rn
    FROM source_data
)

SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    AMOUNT,
    EVENT_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,    -- Overwrite with current timestamp
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,  -- Overwrite with current timestamp
    SOURCE_SYSTEM
FROM deduped_data
WHERE rn = 1  -- Keep only the latest record per event
