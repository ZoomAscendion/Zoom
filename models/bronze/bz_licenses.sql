-- Bronze Layer Licenses Model
-- Transforms raw license data from RAW.LICENSES to BRONZE.BZ_LICENSES
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    pre_hook="""
        {% if not is_incremental() %}
            INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, PROCESS_START_TIME, STATUS, PROCESSED_BY)
            SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SYSTEM'
            WHERE EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'BZ_AUDIT_LOG')
        {% endif %}
    """,
    post_hook="""
        INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, PROCESS_START_TIME, PROCESS_END_TIME, STATUS, RECORD_COUNT, PROCESSED_BY)
        SELECT 
            'BZ_LICENSES',
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
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality flags
        CASE 
            WHEN LICENSE_ID IS NULL THEN 'MISSING_LICENSE_ID'
            WHEN LICENSE_TYPE IS NULL THEN 'MISSING_LICENSE_TYPE'
            WHEN ASSIGNED_TO_USER_ID IS NULL THEN 'MISSING_USER_ID'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw', 'licenses') }}
),

-- CTE for final data selection
final_data AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_data
