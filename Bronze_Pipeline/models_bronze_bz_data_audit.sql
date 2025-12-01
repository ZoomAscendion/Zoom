{{ config(
    materialized='incremental',
    unique_key='record_id',
    on_schema_change='fail',
    tags=['bronze', 'audit']
) }}

/*
    Bronze Layer Audit Model
    Purpose: Track all data operations in the Bronze layer
    Author: AAVA
    Created: {{ run_started_at }}
*/

WITH audit_records AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['source_table', 'load_timestamp', 'processed_by']) }} AS record_id,
        source_table,
        load_timestamp,
        processed_by,
        processing_time,
        status,
        CURRENT_TIMESTAMP() AS created_at
    FROM (
        VALUES
            ('BZ_USERS', CURRENT_TIMESTAMP(), '{{ this.name }}', 0.0, 'INITIALIZED'),
            ('BZ_MEETINGS', CURRENT_TIMESTAMP(), '{{ this.name }}', 0.0, 'INITIALIZED'),
            ('BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), '{{ this.name }}', 0.0, 'INITIALIZED'),
            ('BZ_FEATURE_USAGE', CURRENT_TIMESTAMP(), '{{ this.name }}', 0.0, 'INITIALIZED'),
            ('BZ_SUPPORT_TICKETS', CURRENT_TIMESTAMP(), '{{ this.name }}', 0.0, 'INITIALIZED'),
            ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), '{{ this.name }}', 0.0, 'INITIALIZED'),
            ('BZ_LICENSES', CURRENT_TIMESTAMP(), '{{ this.name }}', 0.0, 'INITIALIZED')
    ) AS t(source_table, load_timestamp, processed_by, processing_time, status)
)

SELECT
    record_id,
    source_table,
    load_timestamp,
    processed_by,
    processing_time,
    status,
    created_at
FROM audit_records

{% if is_incremental() %}
    WHERE load_timestamp > (SELECT MAX(load_timestamp) FROM {{ this }})
{% endif %}