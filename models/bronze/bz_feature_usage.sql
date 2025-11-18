/*
  Author: Data Engineering Team
  Created: 2024-12-19
  Description: Bronze layer transformation for FEATURE_USAGE table
  Purpose: Clean and deduplicate raw feature usage data with audit trail
*/

{{ config(
    materialized='table',
    tags=['bronze', 'feature_usage'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) VALUES ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) VALUES ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'SUCCESS')"
) }}

WITH source_data AS (
    -- Select raw data from source with null filtering for primary key
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'feature_usage') }}
    WHERE USAGE_ID IS NOT NULL    -- Filter out records with null primary key
      AND MEETING_ID IS NOT NULL  -- Filter out records with null foreign key
),

deduped_data AS (
    -- Apply deduplication logic based on primary key and latest timestamp
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) AS row_num
    FROM source_data
)

-- Final select with audit columns
SELECT 
    USAGE_ID,
    MEETING_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_data
WHERE row_num = 1  -- Keep only the most recent record per USAGE_ID
