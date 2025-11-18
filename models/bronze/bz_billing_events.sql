-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ({{ range(1, 1000000) | random }}, 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0.0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ({{ range(1, 1000000) | random }}, 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0.0, 'COMPLETED')"
) }}

WITH source_data AS (
    -- Select from RAW layer with null filtering for primary key
    SELECT *
    FROM {{ source('raw', 'billing_events') }}
    WHERE EVENT_ID IS NOT NULL
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest timestamp
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY EVENT_ID 
               ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
           ) AS row_num
    FROM source_data
),

transformed_data AS (
    -- Handle data type conversions for Bronze layer
    SELECT
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        -- Convert AMOUNT from VARCHAR to NUMBER if not null
        CASE 
            WHEN AMOUNT IS NOT NULL AND AMOUNT != '' 
            THEN TRY_TO_NUMBER(AMOUNT, 10, 2)
            ELSE NULL 
        END AS AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        row_num
    FROM deduped_data
)

-- Final selection with 1-1 mapping from RAW to Bronze
SELECT
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    AMOUNT,
    EVENT_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM transformed_data
WHERE row_num = 1
