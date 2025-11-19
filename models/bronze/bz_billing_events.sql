-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_USER', 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_USER', 1.0, 'SUCCESS')"
) }}

WITH source_data AS (
    -- BZ Pipeline: Extract raw billing event data from source
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
    WHERE EVENT_ID IS NOT NULL  -- Filter out records with null primary key
),

deduped_data AS (
    -- BZ Pipeline: Apply deduplication logic based on primary key and latest timestamp
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) as rn
    FROM source_data
),

final AS (
    -- BZ Pipeline: Select final deduplicated records
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
    WHERE rn = 1
)

SELECT * FROM final
