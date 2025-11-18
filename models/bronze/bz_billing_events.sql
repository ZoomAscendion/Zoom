-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_SYSTEM', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_SYSTEM', DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_BILLING_EVENTS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
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
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) AS row_num
    FROM source_data
)

SELECT
    -- Unique identifier for each billing event
    EVENT_ID,
    
    -- Reference to user associated with billing event
    USER_ID,
    
    -- Type of billing event
    EVENT_TYPE,
    
    -- Monetary amount for the billing event
    AMOUNT,
    
    -- Date when the billing event occurred
    EVENT_DATE,
    
    -- Timestamp when record was loaded into Bronze layer
    LOAD_TIMESTAMP,
    
    -- Timestamp when record was last updated
    UPDATE_TIMESTAMP,
    
    -- Source system from which data originated
    SOURCE_SYSTEM
    
FROM deduped_data
WHERE row_num = 1
