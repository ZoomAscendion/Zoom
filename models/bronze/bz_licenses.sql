-- Bronze Layer Licenses Model
-- Description: Transforms raw license data to bronze layer with data quality checks
-- Author: Data Engineering Team

{{ config(
    materialized='table',
    tags=['bronze', 'licenses']
) }}

-- CTE to filter out null primary keys and prepare raw data
WITH raw_licenses_filtered AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        -- Handle END_DATE conversion safely
        CASE 
            WHEN END_DATE IS NOT NULL AND TRIM(END_DATE) != '' 
            THEN TRY_CAST(END_DATE AS DATE)
            ELSE NULL 
        END as END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'licenses') }}
    WHERE LICENSE_ID IS NOT NULL  -- Filter out records with null primary key
),

-- CTE for deduplication based on primary key and latest timestamp
deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM raw_licenses_filtered
)

-- Final selection with 1-1 mapping from raw to bronze
SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_licenses
WHERE rn = 1  -- Keep only the most recent record for each license
