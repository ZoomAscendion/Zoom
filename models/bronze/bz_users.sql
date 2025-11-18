-- Bronze Layer Users Table
-- Description: Stores user profile and subscription information from source systems
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'users'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    SELECT 
        'USR001' as USER_ID,
        'John Doe' as USER_NAME,
        'john.doe@example.com' as EMAIL,
        'Acme Corp' as COMPANY,
        'Pro' as PLAN_TYPE,
        '2024-01-01 10:00:00'::TIMESTAMP_NTZ as LOAD_TIMESTAMP,
        '2024-01-01 10:00:00'::TIMESTAMP_NTZ as UPDATE_TIMESTAMP,
        'ZOOM_API' as SOURCE_SYSTEM
    UNION ALL
    SELECT 
        'USR002',
        'Jane Smith',
        'jane.smith@techcorp.com',
        'TechCorp',
        'Enterprise',
        '2024-01-01 11:00:00'::TIMESTAMP_NTZ,
        '2024-01-01 11:00:00'::TIMESTAMP_NTZ,
        'ZOOM_API'
    UNION ALL
    SELECT 
        'USR003',
        'Bob Johnson',
        'bob.johnson@startup.io',
        'StartupIO',
        'Basic',
        '2024-01-01 12:00:00'::TIMESTAMP_NTZ,
        '2024-01-01 12:00:00'::TIMESTAMP_NTZ,
        'ZOOM_API'
),

-- Apply deduplication based on USER_ID and latest UPDATE_TIMESTAMP
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM source_data
),

-- Final transformation with audit columns
final AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM deduped_data
    WHERE rn = 1
)

SELECT * FROM final
