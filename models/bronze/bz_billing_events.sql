-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Source: RAW.BILLING_EVENTS
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

WITH source_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        TRY_CAST(AMOUNT AS NUMBER(10,2)) AS AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'billing_events') }}
    WHERE EVENT_ID IS NOT NULL  -- Filter out NULL primary keys
      AND USER_ID IS NOT NULL   -- Filter out NULL foreign keys
),

-- Apply deduplication based on primary key and latest timestamp
deduped_data AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY EVENT_ID 
                   ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
               ) AS row_num
        FROM source_data
    )
    WHERE row_num = 1
),

-- Final transformation with Bronze timestamp overwrite
final_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
        CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
        SOURCE_SYSTEM
    FROM deduped_data
)

SELECT * FROM final_data
