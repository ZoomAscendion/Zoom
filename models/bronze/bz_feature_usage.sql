-- Bronze Layer Feature Usage Model
-- Transforms raw feature usage data from RAW.FEATURE_USAGE to BRONZE.BZ_FEATURE_USAGE
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    pre_hook="""
        {% if not is_incremental() %}
            INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, PROCESS_START_TIME, STATUS, PROCESSED_BY)
            SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SYSTEM'
            WHERE EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'BZ_AUDIT_LOG')
        {% endif %}
    """,
    post_hook="""
        INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, PROCESS_START_TIME, PROCESS_END_TIME, STATUS, RECORD_COUNT, PROCESSED_BY)
        SELECT 
            'BZ_FEATURE_USAGE',
            CURRENT_TIMESTAMP() - INTERVAL '1 MINUTE',
            CURRENT_TIMESTAMP(),
            'SUCCESS',
            (SELECT COUNT(*) FROM {{ this }}),
            'DBT_SYSTEM'
        WHERE EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'BZ_AUDIT_LOG')
    """
) }}

-- CTE for data validation and cleansing
WITH source_data AS (
    SELECT 
        -- Business columns from source (1:1 mapping)
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality flags
        CASE 
            WHEN USAGE_ID IS NULL THEN 'MISSING_USAGE_ID'
            WHEN MEETING_ID IS NULL THEN 'MISSING_MEETING_ID'
            WHEN FEATURE_NAME IS NULL THEN 'MISSING_FEATURE_NAME'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw', 'feature_usage') }}
),

-- CTE for final data selection
final_data AS (
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
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_data
