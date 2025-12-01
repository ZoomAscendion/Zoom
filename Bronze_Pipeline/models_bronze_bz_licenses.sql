{{ config(
    materialized='incremental',
    unique_key='license_id',
    on_schema_change='fail',
    tags=['bronze', 'licenses'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), '{{ this.name }}', 0.0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_LICENSES', CURRENT_TIMESTAMP(), '{{ this.name }}', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_LICENSES' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

/*
    Bronze Layer Licenses Model
    Purpose: Raw license data from source systems with metadata enrichment
    Author: AAVA
    Created: {{ run_started_at }}
*/

WITH source_data AS (
    SELECT
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'licenses') }}
    
    {% if is_incremental() %}
        WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
    {% endif %}
),

deduped_data AS (
    SELECT
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        COALESCE(load_timestamp, CURRENT_TIMESTAMP()) AS load_timestamp,
        COALESCE(update_timestamp, CURRENT_TIMESTAMP()) AS update_timestamp,
        COALESCE(source_system, 'UNKNOWN') AS source_system,
        ROW_NUMBER() OVER (
            PARTITION BY license_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM source_data
    WHERE license_id IS NOT NULL  -- Primary key validation
),

data_quality_checks AS (
    SELECT
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Data quality validations
        CASE 
            WHEN license_type IS NULL 
            THEN 'MISSING_LICENSE_TYPE'
            WHEN start_date IS NOT NULL AND end_date IS NOT NULL AND start_date > end_date 
            THEN 'INVALID_DATE_RANGE'
            WHEN start_date IS NOT NULL AND start_date > CURRENT_DATE() + INTERVAL '1 YEAR' 
            THEN 'FUTURE_START_DATE'
            WHEN assigned_to_user_id IS NULL 
            THEN 'MISSING_USER_ASSIGNMENT'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM deduped_data
    WHERE row_num = 1
),

final AS (
    SELECT
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM data_quality_checks
    WHERE data_quality_flag = 'VALID'  -- Only include valid records
)

SELECT
    license_id,
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM final

-- Data quality logging
{% if execute %}
    {% set row_count_query %}
        SELECT COUNT(*) as row_count FROM ({{ sql }})
    {% endset %}
    
    {% set results = run_query(row_count_query) %}
    {% if results %}
        {{ log("BZ_LICENSES: Processing " ~ results.columns[0].values()[0] ~ " rows", info=True) }}
    {% endif %}
{% endif %}