-- Bronze Layer Licenses Model
-- Description: Transforms raw license data into bronze layer with audit capabilities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='license_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_LICENSES', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 'COMPLETED' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH raw_licenses AS (
    -- Select from raw licenses table with null filtering for primary keys
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        END_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'licenses') }}
    WHERE LICENSE_ID IS NOT NULL
      AND LICENSE_TYPE IS NOT NULL
      AND START_DATE IS NOT NULL
),

deduped_licenses AS (
    -- Apply deduplication based on license_id, keeping the latest record
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY LICENSE_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC) as rn
        FROM raw_licenses
    )
    WHERE rn = 1
),

final_licenses AS (
    -- Final transformation with data type conversion
    SELECT 
        LICENSE_ID,
        LICENSE_TYPE,
        ASSIGNED_TO_USER_ID,
        START_DATE,
        TRY_CAST(END_DATE AS DATE) AS END_DATE,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'unknown') AS SOURCE_SYSTEM
    FROM deduped_licenses
)

SELECT * FROM final_licenses
