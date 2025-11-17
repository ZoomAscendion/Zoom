-- =====================================================
-- BRONZE LAYER - LICENSES TABLE
-- Purpose: Raw to Bronze transformation for license data
-- Source: RAW.LICENSES
-- Target: BRONZE.BZ_LICENSES
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}
-- =====================================================

{{ config(
    materialized='table'
) }}

WITH source_data AS (
    -- Extract raw data from source table
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Add row number for deduplication based on LICENSE_ID and UPDATE_TIMESTAMP
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM {{ source('raw', 'licenses') }}
),

deduped_data AS (
    -- Apply deduplication logic
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
    WHERE row_num = 1
        AND LICENSE_ID IS NOT NULL  -- Data quality check
),

final_data AS (
    -- Final transformation with audit columns
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
)

SELECT * FROM final_data
