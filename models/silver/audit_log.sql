{{ config(
    materialized='table',
    on_schema_change='sync_all_columns'
) }}

-- Audit log table for tracking pipeline execution
WITH max_timestamp AS (
    SELECT COALESCE(MAX(load_timestamp), '1900-01-01'::timestamp) as max_ts
    FROM {{ source('bronze', 'bz_audit_records') }}
),

audit_records AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['record_id', 'source_table', 'load_timestamp']) }} AS execution_id,
        COALESCE(source_table, 'Unknown') AS pipeline_name,
        load_timestamp AS start_time,
        DATEADD('second', COALESCE(processing_time, 0), load_timestamp) AS end_time,
        CASE 
            WHEN status = 'SUCCESS' THEN 'Success'
            WHEN status = 'FAILED' THEN 'Failed'
            WHEN status = 'PARTIAL' THEN 'Partial Success'
            ELSE 'Unknown'
        END AS status,
        COALESCE(error_message, '') AS error_message,
        COALESCE(processing_time, 0) AS execution_duration_seconds,
        COALESCE(source_table, 'Unknown') AS source_tables_processed,
        CASE 
            WHEN source_table LIKE '%USERS%' THEN 'SI_USERS'
            WHEN source_table LIKE '%MEETINGS%' THEN 'SI_MEETINGS'
            WHEN source_table LIKE '%PARTICIPANTS%' THEN 'SI_PARTICIPANTS'
            WHEN source_table LIKE '%FEATURE_USAGE%' THEN 'SI_FEATURE_USAGE'
            WHEN source_table LIKE '%SUPPORT_TICKETS%' THEN 'SI_SUPPORT_TICKETS'
            WHEN source_table LIKE '%BILLING_EVENTS%' THEN 'SI_BILLING_EVENTS'
            WHEN source_table LIKE '%LICENSES%' THEN 'SI_LICENSES'
            WHEN source_table LIKE '%WEBINARS%' THEN 'SI_WEBINARS'
            ELSE 'Unknown'
        END AS target_tables_updated,
        COALESCE(record_count, 0) AS records_processed,
        COALESCE(record_count, 0) AS records_inserted,
        0 AS records_updated,
        0 AS records_rejected,
        COALESCE(processed_by, 'System') AS executed_by,
        'PROD' AS execution_environment,
        CONCAT('Processed ', COALESCE(record_count, 0), ' records from ', COALESCE(source_table, 'Unknown')) AS data_lineage_info,
        DATE(load_timestamp) AS load_date,
        DATE(load_timestamp) AS update_date,
        'Pipeline Audit System' AS source_system
    FROM {{ source('bronze', 'bz_audit_records') }}
    WHERE 1=1
)

SELECT * FROM audit_records
