{{ config(
    materialized='incremental',
    unique_key='execution_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver Layer Pipeline Audit Model
-- This model must run first to create the audit table before other models

WITH audit_base AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['RECORD_ID', 'SOURCE_TABLE', 'LOAD_TIMESTAMP']) }} AS execution_id,
        COALESCE(SOURCE_TABLE, 'UNKNOWN') AS pipeline_name,
        LOAD_TIMESTAMP AS start_time,
        DATEADD('second', COALESCE(PROCESSING_TIME, 0), LOAD_TIMESTAMP) AS end_time,
        CASE 
            WHEN STATUS = 'SUCCESS' THEN 'Success'
            WHEN STATUS = 'FAILED' THEN 'Failed'
            WHEN STATUS = 'PARTIAL' THEN 'Partial Success'
            ELSE 'Unknown'
        END AS status,
        ERROR_MESSAGE AS error_message,
        COALESCE(PROCESSING_TIME, 0) AS execution_duration_seconds,
        SOURCE_TABLE AS source_tables_processed,
        CONCAT('SILVER.SI_', UPPER(REPLACE(SOURCE_TABLE, 'BZ_', ''))) AS target_tables_updated,
        COALESCE(RECORD_COUNT, 0) AS records_processed,
        COALESCE(RECORD_COUNT, 0) AS records_inserted,
        0 AS records_updated,
        0 AS records_rejected,
        COALESCE(PROCESSED_BY, 'DBT_PIPELINE') AS executed_by,
        'PROD' AS execution_environment,
        CONCAT('Bronze to Silver transformation for ', SOURCE_TABLE) AS data_lineage_info,
        DATE(LOAD_TIMESTAMP) AS load_date,
        DATE(LOAD_TIMESTAMP) AS update_date,
        'DBT_AUDIT_SYSTEM' AS source_system
    FROM {{ source('bronze', 'bz_audit_records') }}
    WHERE SOURCE_TABLE IS NOT NULL
    
    {% if is_incremental() %}
        AND LOAD_TIMESTAMP > (SELECT MAX(start_time) FROM {{ this }})
    {% endif %}
)

SELECT 
    execution_id,
    pipeline_name,
    start_time,
    end_time,
    status,
    error_message,
    execution_duration_seconds,
    source_tables_processed,
    target_tables_updated,
    records_processed,
    records_inserted,
    records_updated,
    records_rejected,
    executed_by,
    execution_environment,
    data_lineage_info,
    load_date,
    update_date,
    source_system
FROM audit_base
