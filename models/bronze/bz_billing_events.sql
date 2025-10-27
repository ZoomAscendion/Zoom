-- Bronze Layer Billing Events Model
-- Description: Transforms raw billing events data to bronze layer with data quality checks
-- Source: RAW.BILLING_EVENTS
-- Target: BRONZE.bz_billing_events
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

WITH raw_billing_events AS (
    SELECT 
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'BILLING_EVENTS') }}
),

-- Data quality and cleansing transformations
cleansed_billing_events AS (
    SELECT 
        -- 1-1 mapping from raw to bronze as per mapping specification
        TRIM(USER_ID) as user_id,
        TRIM(UPPER(EVENT_TYPE)) as event_type,
        CASE 
            WHEN AMOUNT IS NULL THEN 0.00
            WHEN AMOUNT < 0 THEN 0.00
            ELSE AMOUNT 
        END as amount,
        EVENT_DATE as event_date,
        LOAD_TIMESTAMP as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) as update_timestamp,
        TRIM(UPPER(SOURCE_SYSTEM)) as source_system,
        
        -- Audit fields for bronze layer
        CURRENT_TIMESTAMP() as bronze_created_at,
        'SUCCESS' as process_status
        
    FROM raw_billing_events
    WHERE USER_ID IS NOT NULL
      AND EVENT_TYPE IS NOT NULL
      AND EVENT_DATE IS NOT NULL
      AND LOAD_TIMESTAMP IS NOT NULL
      AND SOURCE_SYSTEM IS NOT NULL
),

-- Error handling for invalid records
error_records AS (
    SELECT 
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        'FAILED_VALIDATION' as process_status,
        CASE 
            WHEN USER_ID IS NULL THEN 'USER_ID_NULL'
            WHEN EVENT_TYPE IS NULL THEN 'EVENT_TYPE_NULL'
            WHEN EVENT_DATE IS NULL THEN 'EVENT_DATE_NULL'
            WHEN LOAD_TIMESTAMP IS NULL THEN 'LOAD_TIMESTAMP_NULL'
            WHEN SOURCE_SYSTEM IS NULL THEN 'SOURCE_SYSTEM_NULL'
            ELSE 'UNKNOWN_ERROR'
        END as error_reason
    FROM raw_billing_events
    WHERE USER_ID IS NULL
       OR EVENT_TYPE IS NULL
       OR EVENT_DATE IS NULL
       OR LOAD_TIMESTAMP IS NULL
       OR SOURCE_SYSTEM IS NULL
)

-- Final select for bronze layer
SELECT 
    user_id,
    event_type,
    amount,
    event_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM cleansed_billing_events

-- Log error records count for monitoring
-- Error records: {{ error_records | length if error_records else 0 }}
