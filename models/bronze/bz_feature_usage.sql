-- Bronze Layer Feature Usage Table
-- Description: Raw usage of platform features during meetings from source systems
-- Source: RAW.FEATURE_USAGE
-- Target: BRONZE.BZ_FEATURE_USAGE
-- Transformation: 1-1 mapping with audit metadata

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT CAST('BZ_FEATURE_USAGE' AS VARCHAR(255)), CURRENT_TIMESTAMP(), CAST('DBT_BRONZE_PIPELINE' AS VARCHAR(255)), CAST(0.0 AS NUMBER(38,3)), CAST('STARTED' AS VARCHAR(50)) WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT CAST('BZ_FEATURE_USAGE' AS VARCHAR(255)), CURRENT_TIMESTAMP(), CAST('DBT_BRONZE_PIPELINE' AS VARCHAR(255)), CAST(DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_FEATURE_USAGE' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()) AS NUMBER(38,3)), CAST('COMPLETED' AS VARCHAR(50)) WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Source data extraction with data quality checks
WITH source_data AS (
    SELECT 
        -- Primary identifier
        USAGE_ID,
        
        -- Usage details
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        
        -- System metadata
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
        
    FROM {{ source('raw', 'feature_usage') }}
    WHERE USAGE_ID IS NOT NULL  -- Basic data quality check
),

-- Data validation and cleansing
validated_data AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM source_data
)

-- Final selection for Bronze layer
SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_data
