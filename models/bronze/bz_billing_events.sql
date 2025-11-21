-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Source: RAW.BILLING_EVENTS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='event_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_BILLING_EVENTS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- CTE to select and filter raw data
WITH raw_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_schema', 'billing_events') }}
    WHERE event_id IS NOT NULL  -- Filter out records with null primary keys
      AND user_id IS NOT NULL  -- Filter out records with null user_id
),

-- CTE for data cleaning and validation
cleaned_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        TRY_CAST(amount AS NUMBER(10,2)) AS amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system,
        ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY load_timestamp DESC) AS row_num
    FROM raw_billing_events
),

-- CTE for deduplication
deduped_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM cleaned_billing_events
    WHERE row_num = 1  -- Keep only the latest record for each event_id
)

-- Final SELECT with Bronze timestamp overwrite
SELECT 
    event_id::VARCHAR(16777216) AS event_id,
    user_id::VARCHAR(16777216) AS user_id,
    event_type::VARCHAR(16777216) AS event_type,
    amount::NUMBER(10,2) AS amount,
    event_date::DATE AS event_date,
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    source_system::VARCHAR(16777216) AS source_system
FROM deduped_billing_events
