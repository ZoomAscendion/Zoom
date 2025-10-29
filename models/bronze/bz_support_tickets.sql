-- Bronze Layer Support Tickets Model
-- Transforms raw support ticket data from RAW.SUPPORT_TICKETS to BRONZE.BZ_SUPPORT_TICKETS
-- Author: Data Engineering Team
-- Created: 2024-12-19

{{ config(
    materialized='table',
    pre_hook="""
        {% if not is_incremental() %}
            INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, PROCESS_START_TIME, STATUS, PROCESSED_BY)
            SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'STARTED', 'DBT_SYSTEM'
            WHERE EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'BZ_AUDIT_LOG')
        {% endif %}
    """,
    post_hook="""
        INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, PROCESS_START_TIME, PROCESS_END_TIME, STATUS, RECORD_COUNT, PROCESSED_BY)
        SELECT 
            'BZ_SUPPORT_TICKETS',
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
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality flags
        CASE 
            WHEN TICKET_ID IS NULL THEN 'MISSING_TICKET_ID'
            WHEN USER_ID IS NULL THEN 'MISSING_USER_ID'
            WHEN TICKET_TYPE IS NULL THEN 'MISSING_TICKET_TYPE'
            ELSE 'VALID'
        END AS data_quality_flag
        
    FROM {{ source('raw', 'support_tickets') }}
),

-- CTE for final data selection
final_data AS (
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE data_quality_flag = 'VALID'
)

SELECT * FROM final_data
