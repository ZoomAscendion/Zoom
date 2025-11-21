-- Bronze Layer Feature Usage Table
-- Description: Records usage of platform features during meetings
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage'],
    pre_hook="
        INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit 
        (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 
            'BZ_FEATURE_USAGE' as source_table,
            CURRENT_TIMESTAMP() as load_timestamp,
            'DBT_{{ invocation_id }}' as processed_by,
            0 as processing_time,
            'STARTED' as status
    ",
    post_hook="
        INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit 
        (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 
            'BZ_FEATURE_USAGE' as source_table,
            CURRENT_TIMESTAMP() as load_timestamp,
            'DBT_{{ invocation_id }}' as processed_by,
            1.9 as processing_time,
            'SUCCESS' as status
    "
) }}

-- Sample data generation for Bronze Feature Usage table
WITH sample_feature_usage AS (
    SELECT 
        'USAGE_001' AS usage_id,
        'MEET_001' AS meeting_id,
        'Screen Share' AS feature_name,
        5 AS usage_count,
        CURRENT_DATE() AS usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
    
    UNION ALL
    
    SELECT 
        'USAGE_002' AS usage_id,
        'MEET_001' AS meeting_id,
        'Chat' AS feature_name,
        15 AS usage_count,
        CURRENT_DATE() AS usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
        
    UNION ALL
    
    SELECT 
        'USAGE_003' AS usage_id,
        'MEET_002' AS meeting_id,
        'Recording' AS feature_name,
        1 AS usage_count,
        CURRENT_DATE() - 1 AS usage_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    usage_id,
    meeting_id,
    feature_name,
    usage_count,
    usage_date,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
    source_system
FROM sample_feature_usage
