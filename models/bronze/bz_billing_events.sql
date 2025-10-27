-- Bronze Layer Billing Events Model
-- Description: Transforms raw billing events data to bronze layer with data quality checks
-- Source: RAW.BILLING_EVENTS
-- Target: BRONZE.bz_billing_events
-- Author: DBT Data Engineer

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'bz_billing_events', CURRENT_TIMESTAMP(), 'DBT', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_audit_log'",
    post_hook="INSERT INTO {{ ref('bz_audit_log') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'bz_billing_events', CURRENT_TIMESTAMP(), 'DBT', 1, 'COMPLETED' WHERE '{{ this.name }}' != 'bz_audit_log'"
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
        TRIM(USER_ID)::STRING as user_id,
        TRIM(UPPER(EVENT_TYPE))::STRING as event_type,
        CASE 
            WHEN AMOUNT IS NULL THEN 0.00
            WHEN AMOUNT < 0 THEN 0.00
            ELSE AMOUNT 
        END::NUMBER(10,2) as amount,
        EVENT_DATE::DATE as event_date,
        LOAD_TIMESTAMP::TIMESTAMP_NTZ as load_timestamp,
        COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP)::TIMESTAMP_NTZ as update_timestamp,
        TRIM(UPPER(SOURCE_SYSTEM))::STRING as source_system
        
    FROM raw_billing_events
    WHERE USER_ID IS NOT NULL
      AND EVENT_TYPE IS NOT NULL
      AND EVENT_DATE IS NOT NULL
      AND LOAD_TIMESTAMP IS NOT NULL
      AND SOURCE_SYSTEM IS NOT NULL
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
