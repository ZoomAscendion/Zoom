-- Bronze Layer Billing Events Model
-- Transforms raw billing event data from RAW.BILLING_EVENTS to BRONZE.BZ_BILLING_EVENTS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    pre_hook="""
        {% if not is_incremental() %}
            INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, PROCESS_START_TIME, STATUS, PROCESSED_BY)
            SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SYSTEM'
            WHERE EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'BZ_AUDIT_LOG')
        {% endif %}
    """,
    post_hook="""
        INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, PROCESS_START_TIME, PROCESS_END_TIME, STATUS, RECORD_COUNT, PROCESSED_BY)
        SELECT 
            'BZ_BILLING_EVENTS',
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
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality flags
        CASE 
            WHEN EVENT_ID IS NULL THEN 'MISSING_EVENT_ID'
            WHEN USER_ID IS NULL THEN 'MISSING_USER_ID'
            WHEN EVENT_TYPE IS NULL THEN 'MISSING_EVENT_TYPE'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw', 'billing_events') }}
),

-- CTE for final data selection
final_data AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_data
