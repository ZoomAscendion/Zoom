-- Bronze Layer Billing Events Model
-- Description: Transforms raw billing event data to bronze layer with data quality checks
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events']
) }}

-- CTE to filter out null primary keys and prepare raw data
WITH raw_billing_events_filtered AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        -- Convert AMOUNT from VARCHAR to NUMBER(10,2) if not null
        CASE 
            WHEN AMOUNT IS NOT NULL AND AMOUNT != '' 
            THEN TRY_TO_NUMBER(AMOUNT, 10, 2)
            ELSE NULL 
        END as AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'billing_events') }}
    WHERE EVENT_ID IS NOT NULL  -- Filter out records with null primary key
),

-- CTE for deduplication based on primary key and latest timestamp
deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM raw_billing_events_filtered
)

-- Final selection with 1-1 mapping from raw to bronze
SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    AMOUNT,
    EVENT_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_billing_events
WHERE rn = 1  -- Keep only the most recent record for each event
