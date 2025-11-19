-- Bronze Layer Billing Events Model
-- Description: Raw financial transactions and billing activities from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status) VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'dbt_user', 'STARTED') WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'dbt_user', DATEDIFF('seconds', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_BILLING_EVENTS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS') WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Raw data selection with primary key filtering
WITH raw_billing_events AS (
    SELECT *
    FROM {{ source('raw_schema', 'billing_events') }}
    WHERE event_id IS NOT NULL  -- Filter out records with null primary key
),

-- Deduplication logic based on primary key and load timestamp
deduped_billing_events AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY event_id 
               ORDER BY load_timestamp DESC, update_timestamp DESC NULLS LAST
           ) AS row_num
    FROM raw_billing_events
),

-- Final transformation with 1-1 mapping and data type conversion
final_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        TRY_CAST(amount AS NUMBER(10,2)) AS amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM deduped_billing_events
    WHERE row_num = 1
)

SELECT * FROM final_billing_events
