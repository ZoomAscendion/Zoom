{{ config(
    materialized='incremental',
    unique_key='execution_id',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ this.database }}.{{ this.schema }}.si_pipeline_audit (
            execution_id, pipeline_name, start_time, status, executed_by, execution_environment, source_system
        ) 
        SELECT 
            '{{ invocation_id }}' as execution_id,
            'audit_log_pipeline' as pipeline_name,
            CURRENT_TIMESTAMP() as start_time,
            'RUNNING' as status,
            CURRENT_USER() as executed_by,
            'PROD' as execution_environment,
            'DBT_SILVER_PIPELINE' as source_system
        WHERE '{{ this.name }}' != 'audit_log'
    ",
    post_hook="
        UPDATE {{ this.database }}.{{ this.schema }}.si_pipeline_audit 
        SET 
            end_time = CURRENT_TIMESTAMP(),
            status = 'SUCCESS',
            records_processed = (SELECT COUNT(*) FROM {{ this }}),
            execution_duration_seconds = DATEDIFF('second', start_time, CURRENT_TIMESTAMP())
        WHERE execution_id = '{{ invocation_id }}' 
        AND pipeline_name = 'audit_log_pipeline'
        AND '{{ this.name }}' != 'audit_log'
    "
) }}

-- Create audit log table structure
WITH audit_structure AS (
    SELECT 
        CAST('{{ invocation_id }}' AS VARCHAR(255)) as execution_id,
        CAST('audit_log_initialization' AS VARCHAR(255)) as pipeline_name,
        CURRENT_TIMESTAMP() as start_time,
        CURRENT_TIMESTAMP() as end_time,
        CAST('SUCCESS' AS VARCHAR(255)) as status,
        CAST(NULL AS VARCHAR(16777216)) as error_message,
        0 as execution_duration_seconds,
        CAST('AUDIT_LOG' AS VARCHAR(255)) as source_tables_processed,
        CAST('SI_PIPELINE_AUDIT' AS VARCHAR(255)) as target_tables_updated,
        1 as records_processed,
        1 as records_inserted,
        0 as records_updated,
        0 as records_rejected,
        CURRENT_USER() as executed_by,
        CAST('PROD' AS VARCHAR(255)) as execution_environment,
        CAST('Audit log initialization' AS VARCHAR(16777216)) as data_lineage_info,
        CURRENT_DATE() as load_date,
        CURRENT_DATE() as update_date,
        CAST('DBT_SILVER_PIPELINE' AS VARCHAR(255)) as source_system
)

SELECT * FROM audit_structure

{% if is_incremental() %}
    WHERE execution_id > (SELECT MAX(execution_id) FROM {{ this }})
{% endif %}
