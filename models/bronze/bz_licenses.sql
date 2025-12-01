-- Bronze layer licenses table transformation
-- Author: AAVA Data Engineering Team
-- Created: 2024-12-19
-- Description: Raw to Bronze transformation for licenses data with deduplication

{{ config(
    materialized='table',
    tags=['bronze', 'licenses'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_LICENSES' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    -- Select from raw licenses table with null filtering for primary key
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw_schema', 'licenses') }}
    WHERE LICENSE_ID IS NOT NULL  -- Filter out null primary keys
),

deduped_data AS (
    -- Apply deduplication logic based on LICENSE_ID and latest UPDATE_TIMESTAMP
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC) as rn
    FROM source_data
)

-- Final select with Bronze timestamp overwrite requirement
SELECT 
    LICENSE_ID,
    LICENSE_TYPE,
    ASSIGNED_TO_USER_ID,
    START_DATE,
    END_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP, -- Overwrite with current DBT run time
    SOURCE_SYSTEM
FROM deduped_data
WHERE rn = 1  -- Keep only the latest record for each LICENSE_ID
