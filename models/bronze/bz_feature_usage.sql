-- =====================================================
-- BRONZE LAYER - FEATURE USAGE TABLE
-- Purpose: Raw to Bronze transformation for feature usage data
-- Source: RAW.FEATURE_USAGE
-- Target: BRONZE.BZ_FEATURE_USAGE
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}
-- =====================================================

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_FEATURE_USAGE' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'COMPLETED' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    -- Extract raw data from source table
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Add row number for deduplication based on USAGE_ID and UPDATE_TIMESTAMP
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM {{ source('raw', 'feature_usage') }}
),

deduped_data AS (
    -- Apply deduplication logic
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE row_num = 1
        AND USAGE_ID IS NOT NULL  -- Data quality check
),

final_data AS (
    -- Final transformation with audit columns
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM deduped_data
)

SELECT * FROM final_data
