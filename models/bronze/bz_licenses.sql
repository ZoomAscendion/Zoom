-- Bronze Layer Licenses Model
-- Description: Transforms raw license data into bronze layer with audit capabilities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'licenses'],
    pre_hook="{% if this.name != 'bz_data_audit' %}INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_USER', 'STARTED'{% endif %}",
    post_hook="{% if this.name != 'bz_data_audit' %}INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_USER', 1.0, 'SUCCESS'{% endif %}"
) }}

-- CTE to select and filter raw data
WITH raw_licenses AS (
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        TRY_CAST(END_DATE AS DATE) AS END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'licenses') }}
    WHERE LICENSE_ID IS NOT NULL  -- Filter out records with null primary key
),

-- CTE for deduplication based on primary key and latest update timestamp
deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS row_num
    FROM raw_licenses
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
WHERE row_num = 1  -- Keep only the most recent record for each license
