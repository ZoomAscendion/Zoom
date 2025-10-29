-- Bronze Layer Billing Events Model
-- Transforms raw billing event data from RAW.BILLING_EVENTS to BRONZE.BZ_BILLING_EVENTS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(materialized='table') }}

-- CTE for data validation and cleansing
WITH source_data AS (
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
        SOURCE_SYSTEM,
        
        -- Data quality validation
        CASE 
            WHEN EVENT_ID IS NULL THEN 'INVALID'
            WHEN USER_ID IS NULL THEN 'INVALID'
            WHEN EVENT_TYPE IS NULL THEN 'INVALID'
            ELSE 'VALID'
        END AS data_quality_status
        
    FROM {{ source('raw', 'billing_events') }}
),

-- CTE for final data selection with error handling
final_data AS (
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
    WHERE data_quality_status = 'VALID'
)

SELECT * FROM final_data
