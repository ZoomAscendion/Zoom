-- Bronze Layer Billing Events Model
-- Description: Tracks financial transactions and billing activities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="
        {% if target.name != 'audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if target.name != 'audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 
               DATEDIFF('seconds', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_BILLING_EVENTS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 
               'COMPLETED'
        {% endif %}
    "
) }}

WITH source_data AS (
    -- Select from RAW layer with null filtering for primary key
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
    -- Apply deduplication based on primary key and latest timestamp
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY EVENT_ID 
                   ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
               ) as rn
        FROM source_data
    )
    WHERE rn = 1
)

-- Final select with 1-1 mapping from raw to bronze
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
