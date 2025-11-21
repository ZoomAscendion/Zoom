-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                (SELECT COALESCE(MAX(record_id), 0) + 1 FROM {{ ref('bz_data_audit') }}),
                'BZ_BILLING_EVENTS',
                CURRENT_TIMESTAMP(),
                'DBT_BRONZE_PIPELINE',
                0,
                'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (record_id, source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 
                (SELECT COALESCE(MAX(record_id), 0) + 1 FROM {{ ref('bz_data_audit') }}),
                'BZ_BILLING_EVENTS',
                CURRENT_TIMESTAMP(),
                'DBT_BRONZE_PIPELINE',
                DATEDIFF('seconds', 
                    (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_BILLING_EVENTS' AND status = 'STARTED'),
                    CURRENT_TIMESTAMP()
                ),
                'SUCCESS'
        {% endif %}
    "
) }}

-- Raw data selection with null filtering for primary key
WITH raw_billing_events AS (
    SELECT *
    FROM {{ source('raw', 'billing_events') }}
    WHERE event_id IS NOT NULL  -- Filter out records with null primary key
),

-- Deduplication logic based on primary key and latest timestamp
deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY event_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM raw_billing_events
),

-- Final transformation with data type conversions and bronze timestamp overwrite
final_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        TRY_CAST(amount AS NUMBER(10,2)) AS amount,  -- Convert VARCHAR to NUMBER with precision
        event_date,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run timestamp
        CURRENT_TIMESTAMP() AS update_timestamp,  -- Overwrite with current DBT run timestamp
        source_system
    FROM deduped_billing_events
    WHERE row_num = 1
)

SELECT * FROM final_billing_events
