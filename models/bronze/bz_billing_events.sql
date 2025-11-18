{{
  config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED' WHERE EXISTS (SELECT 1 FROM {{ ref('bz_data_audit') }} LIMIT 1)",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 1.0, 'SUCCESS' WHERE EXISTS (SELECT 1 FROM {{ ref('bz_data_audit') }} LIMIT 1)"
  )
}}

-- Bronze Layer Billing Events Table
-- 1:1 mapping from RAW.BILLING_EVENTS to BRONZE.BZ_BILLING_EVENTS
-- Includes deduplication logic based on EVENT_ID and LOAD_TIMESTAMP

WITH source_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw_schema', 'billing_events') }}
),

-- Apply deduplication logic - keep latest record per EVENT_ID
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY LOAD_TIMESTAMP DESC, UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM source_data
)

-- Final selection with audit columns
SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    AMOUNT,
    EVENT_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_data
WHERE row_num = 1
