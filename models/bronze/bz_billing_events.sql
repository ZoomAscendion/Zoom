-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT', 'STARTED') WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT', DATEDIFF('seconds', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_BILLING_EVENTS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS') WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Raw data extraction and deduplication
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
    FROM {{ source('raw', 'billing_events') }}
),

-- Apply deduplication based on EVENT_ID and UPDATE_TIMESTAMP
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM source_data
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
FROM deduped_data
WHERE row_num = 1
