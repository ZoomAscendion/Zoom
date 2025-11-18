-- Bronze Layer Licenses Table
-- Description: Manages license assignments and entitlements
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'licenses'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    SELECT 
        'LIC001' as LICENSE_ID,
        'Pro License' as LICENSE_TYPE,
        'USR001' as ASSIGNED_TO_USER_ID,
        '2024-01-01'::DATE as START_DATE,
        '2024-12-31'::DATE as END_DATE,
        '2024-01-01 09:00:00'::TIMESTAMP_NTZ as LOAD_TIMESTAMP,
        '2024-01-01 09:00:00'::TIMESTAMP_NTZ as UPDATE_TIMESTAMP,
        'LICENSE_SYSTEM' as SOURCE_SYSTEM
    UNION ALL
    SELECT 
        'LIC002',
        'Enterprise License',
        'USR002',
        '2024-01-01'::DATE,
        '2024-12-31'::DATE,
        '2024-01-01 10:00:00'::TIMESTAMP_NTZ,
        '2024-01-01 10:00:00'::TIMESTAMP_NTZ,
        'LICENSE_SYSTEM'
    UNION ALL
    SELECT 
        'LIC003',
        'Basic License',
        'USR003',
        '2024-01-01'::DATE,
        '2024-12-31'::DATE,
        '2024-01-01 11:00:00'::TIMESTAMP_NTZ,
        '2024-01-01 11:00:00'::TIMESTAMP_NTZ,
        'LICENSE_SYSTEM'
),

-- Apply deduplication based on LICENSE_ID and latest UPDATE_TIMESTAMP
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM source_data
),

-- Final transformation with audit columns
final AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM deduped_data
    WHERE rn = 1
)

SELECT * FROM final
