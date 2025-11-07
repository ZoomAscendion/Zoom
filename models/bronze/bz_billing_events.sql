-- Bronze Layer Billing Events Table
-- Description: Raw financial transactions and billing activities from source systems
-- Source: RAW.BILLING_EVENTS
-- Target: BRONZE.BZ_BILLING_EVENTS
-- Transformation: 1-1 mapping with audit metadata

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT (SELECT COALESCE(MAX(RECORD_ID), 0) + 1 FROM {{ ref('bz_data_audit') }}), CAST('BZ_BILLING_EVENTS' AS VARCHAR(255)), CURRENT_TIMESTAMP(), CAST('DBT_BRONZE_PIPELINE' AS VARCHAR(255)), CAST(0.0 AS NUMBER(38,3)), CAST('STARTED' AS VARCHAR(50)) WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT (SELECT COALESCE(MAX(RECORD_ID), 0) + 1 FROM {{ ref('bz_data_audit') }}), CAST('BZ_BILLING_EVENTS' AS VARCHAR(255)), CURRENT_TIMESTAMP(), CAST('DBT_BRONZE_PIPELINE' AS VARCHAR(255)), CAST(DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_BILLING_EVENTS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()) AS NUMBER(38,3)), CAST('COMPLETED' AS VARCHAR(50)) WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Source data extraction with data quality checks and deduplication
WITH source_data AS (
    SELECT 
        -- Primary identifier
        EVENT_ID,
        
        -- Billing details
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        
        -- System metadata
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Add row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY EVENT_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
        
    FROM {{ source('raw', 'billing_events') }}
    WHERE EVENT_ID IS NOT NULL  -- Basic data quality check
),

-- Data validation and cleansing with deduplication
validated_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM source_data
    WHERE rn = 1  -- Keep only the most recent record per EVENT_ID
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
