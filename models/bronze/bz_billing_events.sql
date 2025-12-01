-- Bronze Layer Billing Events Model
-- Description: Financial transactions and billing activities
-- Source: RAW.BILLING_EVENTS
-- Target: BRONZE.BZ_BILLING_EVENTS

{{ config(
    materialized='incremental',
    unique_key='event_id',
    on_schema_change='append_new_columns',
    tags=['bronze', 'billing_events', 'financial'],
    pre_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status)
            SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 
                   DATEDIFF('seconds', 
                           (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_BILLING_EVENTS' AND status = 'STARTED'),
                           CURRENT_TIMESTAMP()), 
                   'SUCCESS'
        {% endif %}
    "
) }}

WITH source_data AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Add row number for deduplication
        ROW_NUMBER() OVER (
            PARTITION BY event_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC
        ) AS row_num
    FROM {{ source('raw', 'billing_events') }}
    WHERE event_id IS NOT NULL  -- Filter out records with null primary keys
    
    {% if is_incremental() %}
        AND COALESCE(update_timestamp, load_timestamp) > (
            SELECT COALESCE(MAX(update_timestamp), '1900-01-01') 
            FROM {{ this }}
        )
    {% endif %}
),

validated_data AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        -- Validate amount based on event type
        CASE 
            WHEN event_type IN ('refund', 'chargeback', 'discount') AND amount > 0 THEN -amount
            WHEN amount IS NULL THEN 0.00
            ELSE amount
        END AS amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM source_data
    WHERE row_num = 1  -- Keep only the most recent record per event_id
        AND event_type IS NOT NULL  -- Required field validation
)

SELECT 
    event_id,
    user_id,
    event_type,
    amount,
    event_date,
    -- Override timestamps as per Bronze layer requirements
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    COALESCE(source_system, 'UNKNOWN') AS source_system
FROM validated_data
