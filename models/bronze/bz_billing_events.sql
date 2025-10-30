-- Bronze Layer Billing Events Model
-- Transforms raw billing event data from RAW.BILLING_EVENTS to Bronze layer
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- CTE for raw data extraction
WITH raw_billing_events AS (
    SELECT 
        -- Business columns from source
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'billing_events') }}
),

-- CTE for data validation and cleansing
validated_billing_events AS (
    SELECT 
        -- Apply data quality checks and preserve original structure
        COALESCE(EVENT_ID, 'UNKNOWN') as EVENT_ID,
        COALESCE(USER_ID, 'UNKNOWN') as USER_ID,
        COALESCE(EVENT_TYPE, 'UNKNOWN') as EVENT_TYPE,
        COALESCE(AMOUNT, 0.00) as AMOUNT,
        EVENT_DATE,
        
        -- Metadata preservation
        COALESCE(LOAD_TIMESTAMP, CURRENT_TIMESTAMP()) as LOAD_TIMESTAMP,
        COALESCE(UPDATE_TIMESTAMP, CURRENT_TIMESTAMP()) as UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'ZOOM_PLATFORM') as SOURCE_SYSTEM
        
    FROM raw_billing_events
)

-- Final selection for Bronze layer
SELECT 
    EVENT_ID,
    USER_ID,
    EVENT_TYPE,
    AMOUNT,
    EVENT_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_billing_events
