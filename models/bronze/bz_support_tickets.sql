-- =====================================================
-- BRONZE LAYER - SUPPORT TICKETS TABLE
-- Purpose: Raw to Bronze transformation for support ticket data
-- Source: RAW.SUPPORT_TICKETS
-- Target: BRONZE.BZ_SUPPORT_TICKETS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}
-- =====================================================

{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ this.schema }}.BZ_DATA_AUDIT (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED'",
    post_hook="INSERT INTO {{ this.schema }}.BZ_DATA_AUDIT (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 1.0, 'COMPLETED'"
) }}

WITH source_data AS (
    -- Extract raw data from source table
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Add row number for deduplication based on TICKET_ID and UPDATE_TIMESTAMP
        ROW_NUMBER() OVER (
            PARTITION BY TICKET_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM {{ source('raw', 'support_tickets') }}
),

deduped_data AS (
    -- Apply deduplication logic
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
    WHERE row_num = 1
        AND TICKET_ID IS NOT NULL  -- Data quality check
        AND USER_ID IS NOT NULL
),

final_data AS (
    -- Final transformation with audit columns
    SELECT 
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM deduped_data
)

SELECT * FROM final_data
