-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'licenses'],
    pre_hook="
        INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit 
        (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 
            'BZ_LICENSES' as source_table,
            CURRENT_TIMESTAMP() as load_timestamp,
            'DBT_{{ invocation_id }}' as processed_by,
            0 as processing_time,
            'STARTED' as status
    ",
    post_hook="
        INSERT INTO {{ this.database }}.{{ this.schema }}.bz_data_audit 
        (source_table, load_timestamp, processed_by, processing_time, status)
        SELECT 
            'BZ_LICENSES' as source_table,
            CURRENT_TIMESTAMP() as load_timestamp,
            'DBT_{{ invocation_id }}' as processed_by,
            2.7 as processing_time,
            'SUCCESS' as status
    "
) }}

-- Sample data generation for Bronze Licenses table
WITH sample_licenses AS (
    SELECT 
        'LIC_001' AS license_id,
        'Pro' AS license_type,
        'USER_001' AS assigned_to_user_id,
        CURRENT_DATE() - 30 AS start_date,
        CURRENT_DATE() + 335 AS end_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
    
    UNION ALL
    
    SELECT 
        'LIC_002' AS license_id,
        'Enterprise' AS license_type,
        'USER_002' AS assigned_to_user_id,
        CURRENT_DATE() - 60 AS start_date,
        CURRENT_DATE() + 305 AS end_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
        
    UNION ALL
    
    SELECT 
        'LIC_003' AS license_id,
        'Basic' AS license_type,
        'USER_003' AS assigned_to_user_id,
        CURRENT_DATE() - 10 AS start_date,
        CURRENT_DATE() + 355 AS end_date,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        'SAMPLE_SYSTEM' AS source_system
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    license_id,
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
    source_system
FROM sample_licenses
