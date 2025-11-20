-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Create sample data for Bronze Feature Usage table
WITH sample_feature_usage AS (
    SELECT 
        'USAGE001' as USAGE_ID,
        'MEET001' as MEETING_ID,
        'Screen Share' as FEATURE_NAME,
        5 as USAGE_COUNT,
        CURRENT_DATE() as USAGE_DATE,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
    
    UNION ALL
    
    SELECT 
        'USAGE002' as USAGE_ID,
        'MEET001' as MEETING_ID,
        'Chat' as FEATURE_NAME,
        25 as USAGE_COUNT,
        CURRENT_DATE() as USAGE_DATE,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
        
    UNION ALL
    
    SELECT 
        'USAGE003' as USAGE_ID,
        'MEET002' as MEETING_ID,
        'Recording' as FEATURE_NAME,
        1 as USAGE_COUNT,
        CURRENT_DATE() - 1 as USAGE_DATE,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
)

SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM sample_feature_usage
