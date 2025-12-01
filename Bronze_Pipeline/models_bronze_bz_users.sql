{{ config(
    materialized='incremental',
    unique_key='user_id',
    on_schema_change='fail',
    tags=['bronze', 'users', 'pii'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), '{{ this.name }}', 0.0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), '{{ this.name }}', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_USERS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

/*
    Bronze Layer Users Model
    Purpose: Raw user data from source systems with metadata enrichment
    Author: AAVA
    Created: {{ run_started_at }}
    
    PII Fields: USER_NAME, EMAIL
*/

{% set start_time = modules.datetime.datetime.now() %}

WITH source_data AS (
    SELECT
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'users') }}
    
    {% if is_incremental() %}
        WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
    {% endif %}
),

deduped_data AS (
    SELECT
        user_id,
        user_name,
        email,
        company,
        plan_type,
        COALESCE(load_timestamp, CURRENT_TIMESTAMP()) AS load_timestamp,
        COALESCE(update_timestamp, CURRENT_TIMESTAMP()) AS update_timestamp,
        COALESCE(source_system, 'UNKNOWN') AS source_system,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM source_data
    WHERE user_id IS NOT NULL  -- Primary key validation
),

final AS (
    SELECT
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        update_timestamp,
        source_system
    FROM deduped_data
    WHERE row_num = 1
)

SELECT
    user_id,
    user_name,
    email,
    company,
    plan_type,
    load_timestamp,
    update_timestamp,
    source_system
FROM final

-- Data quality checks
{% if execute %}
    {% set row_count_query %}
        SELECT COUNT(*) as row_count FROM ({{ sql }})
    {% endset %}
    
    {% set results = run_query(row_count_query) %}
    {% if results %}
        {{ log("BZ_USERS: Processing " ~ results.columns[0].values()[0] ~ " rows", info=True) }}
    {% endif %}
{% endif %}