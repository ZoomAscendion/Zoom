-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="
        {% if target.name != 'audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_{{ this.name }}', 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if target.name != 'audit' %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_{{ this.name }}', 
                DATEDIFF('seconds', 
                    (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_BILLING_EVENTS' AND STATUS = 'STARTED'), 
                    CURRENT_TIMESTAMP()), 
                'COMPLETED')
        {% endif %}
    "
) }}

WITH source_data AS (
    -- Select from RAW layer with null filtering for primary keys
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
    WHERE EVENT_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND EVENT_TYPE IS NOT NULL
      AND AMOUNT IS NOT NULL
      AND EVENT_DATE IS NOT NULL
      AND LOAD_TIMESTAMP IS NOT NULL
      AND SOURCE_SYSTEM IS NOT NULL
),

deduped_data AS (
    -- Apply deduplication based on EVENT_ID and LOAD_TIMESTAMP
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY EVENT_ID 
               ORDER BY LOAD_TIMESTAMP DESC, 
                        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
           ) as rn
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
WHERE rn = 1
