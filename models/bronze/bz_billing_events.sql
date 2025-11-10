-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Author: DBT Data Engineer
-- Created: {{ run_started_at }}
-- Source: RAW.BILLING_EVENTS -> BRONZE.BZ_BILLING_EVENTS

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0.0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_BILLING_EVENTS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

-- Raw data extraction with 1:1 mapping
WITH source_data AS (
    SELECT 
        -- Unique identifier for each billing event
        EVENT_ID,
        
        -- Reference to user associated with billing event
        USER_ID,
        
        -- Type of billing event
        EVENT_TYPE,
        
        -- Monetary amount for the billing event
        AMOUNT,
        
        -- Date when the billing event occurred
        EVENT_DATE,
        
        -- Timestamp when record was loaded into system
        LOAD_TIMESTAMP,
        
        -- Timestamp when record was last updated
        UPDATE_TIMESTAMP,
        
        -- Source system from which data originated
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'billing_events') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    -- Basic data quality checks
    WHERE EVENT_ID IS NOT NULL
      AND EVENT_TYPE IS NOT NULL
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
FROM validated_data
