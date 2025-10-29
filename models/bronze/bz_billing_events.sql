-- Bronze Layer Billing Events Model
-- Transforms raw billing event data from RAW.BILLING_EVENTS to BRONZE.BZ_BILLING_EVENTS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(materialized='table') }}

SELECT 
    -- Business columns from source (1:1 mapping)
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
WHERE EVENT_ID IS NOT NULL
