-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'licenses'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Create sample data for Bronze Licenses table
WITH sample_licenses AS (
    SELECT 
        'LIC001' as LICENSE_ID,
        'Pro' as LICENSE_TYPE,
        'USER001' as ASSIGNED_TO_USER_ID,
        CURRENT_DATE() - 30 as START_DATE,
        CURRENT_DATE() + 335 as END_DATE,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
    
    UNION ALL
    
    SELECT 
        'LIC002' as LICENSE_ID,
        'Enterprise' as LICENSE_TYPE,
        'USER002' as ASSIGNED_TO_USER_ID,
        CURRENT_DATE() - 60 as START_DATE,
        CURRENT_DATE() + 305 as END_DATE,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
        
    UNION ALL
    
    SELECT 
        'LIC003' as LICENSE_ID,
        'Basic' as LICENSE_TYPE,
        'USER003' as ASSIGNED_TO_USER_ID,
        CURRENT_DATE() - 10 as START_DATE,
        CURRENT_DATE() + 355 as END_DATE,
        CURRENT_TIMESTAMP() as LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() as UPDATE_TIMESTAMP,
        'SAMPLE_DATA' as SOURCE_SYSTEM
)

SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM sample_licenses
