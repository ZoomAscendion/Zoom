-- Bronze Layer Meetings Table
-- Description: Raw meeting information and session details from source systems
-- Source: RAW.MEETINGS
-- Target: BRONZE.BZ_MEETINGS
-- Transformation: 1-1 mapping with audit metadata

{{ config(
    materialized='table',
    tags=['bronze', 'meetings'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT (SELECT COALESCE(MAX(RECORD_ID), 0) + 1 FROM {{ ref('bz_data_audit') }}), CAST('BZ_MEETINGS' AS VARCHAR(255)), CURRENT_TIMESTAMP(), CAST('DBT_BRONZE_PIPELINE' AS VARCHAR(255)), CAST(0.0 AS NUMBER(38,3)), CAST('STARTED' AS VARCHAR(50)) WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (RECORD_ID, SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT (SELECT COALESCE(MAX(RECORD_ID), 0) + 1 FROM {{ ref('bz_data_audit') }}), CAST('BZ_MEETINGS' AS VARCHAR(255)), CURRENT_TIMESTAMP(), CAST('DBT_BRONZE_PIPELINE' AS VARCHAR(255)), CAST(DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_MEETINGS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()) AS NUMBER(38,3)), CAST('COMPLETED' AS VARCHAR(50)) WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Source data extraction with data quality checks and deduplication
WITH source_data AS (
    SELECT 
        -- Primary identifier
        MEETING_ID,
        
        -- Meeting details
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        
        -- System metadata
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Add row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY MEETING_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
        
    FROM {{ source('raw', 'meetings') }}
    WHERE MEETING_ID IS NOT NULL  -- Basic data quality check
),

-- Data validation and cleansing with deduplication
validated_data AS (
    SELECT 
        MEETING_ID,
        HOST_ID,
        MEETING_TOPIC,
        START_TIME,
        END_TIME,
        DURATION_MINUTES,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM source_data
    WHERE rn = 1  -- Keep only the most recent record per MEETING_ID
)

-- Final selection for Bronze layer
SELECT 
    MEETING_ID,
    HOST_ID,
    MEETING_TOPIC,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM validated_data
