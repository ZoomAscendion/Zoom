-- Bronze Layer Licenses Model
-- Description: Transforms raw license data to bronze layer with data quality checks and audit logging
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'licenses'],
    pre_hook="{% if this.name != 'bz_data_audit' %}INSERT INTO {{ target.schema }}.bz_data_audit (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 0, 'STARTED'){% endif %}",
    post_hook="{% if this.name != 'bz_data_audit' %}INSERT INTO {{ target.schema }}.bz_data_audit (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 1, 'COMPLETED'){% endif %}"
) }}

-- CTE to filter out null primary keys and prepare raw data
WITH raw_licenses_filtered AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        -- Convert END_DATE from VARCHAR to DATE if not null
        CASE 
            WHEN END_DATE IS NOT NULL AND END_DATE != '' 
            THEN TRY_TO_DATE(END_DATE)
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
