-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'dbt_bronze_pipeline', 'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'dbt_bronze_pipeline', 
               DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_BILLING_EVENTS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 
               'SUCCESS'
        {% endif %}
    "
) }}

WITH source_data AS (
    -- Select from raw billing_events table with null filtering for primary key
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        TRY_CAST(AMOUNT AS NUMBER(10,2)) as AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw_schema', 'billing_events') }}
    WHERE EVENT_ID IS NOT NULL  -- Filter out records with null primary key
),

deduped_data AS (
    -- Apply deduplication based on primary key and latest update timestamp
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY EVENT_ID 
                   ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
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
