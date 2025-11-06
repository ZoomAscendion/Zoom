-- =====================================================
-- Bronze Layer Billing Events Model
-- =====================================================
-- Description: Raw billing event data from source system with 1:1 mapping
-- Source: RAW.BILLING_EVENTS
-- Target: BRONZE.BZ_BILLING_EVENTS
-- =====================================================

{{ config(
    materialized='table',
    pre_hook="""
        INSERT INTO {{ ref('bz_audit_log') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        SELECT 
            COALESCE((SELECT MAX(RECORD_ID) FROM {{ ref('bz_audit_log') }}), 0) + 1,
            'BZ_BILLING_EVENTS', 
            CURRENT_TIMESTAMP(), 
            'DBT_PROCESS', 
            0, 
            'STARTED'
    """,
    post_hook="""
        INSERT INTO {{ ref('bz_audit_log') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        SELECT 
            COALESCE((SELECT MAX(RECORD_ID) FROM {{ ref('bz_audit_log') }}), 0) + 1,
            'BZ_BILLING_EVENTS', 
            CURRENT_TIMESTAMP(), 
            'DBT_PROCESS', 
            30, 
            'COMPLETED'
    """
) }}

-- Raw data extraction with basic error handling
WITH source_data AS (
    SELECT 
        -- Primary billing event information (1:1 mapping from source)
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        
        -- Metadata columns (1:1 mapping from source)
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'billing_events') }}
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        -- Convert all VARCHAR fields to STRING for consistency
        CAST(EVENT_ID AS STRING) AS EVENT_ID,
        CAST(USER_ID AS STRING) AS USER_ID,
        CAST(EVENT_TYPE AS STRING) AS EVENT_TYPE,
        
        -- Preserve numeric and date values
        AMOUNT,
        EVENT_DATE,
        
        -- Metadata preservation
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        CAST(SOURCE_SYSTEM AS STRING) AS SOURCE_SYSTEM
        
    FROM source_data
    -- Include all records for bronze layer (no filtering)
)

-- Final selection for bronze layer
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
