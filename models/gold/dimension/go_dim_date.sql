{{ config(
    materialized='table',
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} SELECT {{ dbt_utils.generate_surrogate_key(['\"GO_DIM_DATE\"', 'CURRENT_TIMESTAMP()']) }} AS audit_log_id, 'GO_DIM_DATE' AS process_name, 'DIMENSION_LOAD' AS process_type, CURRENT_TIMESTAMP() AS execution_start_timestamp, NULL AS execution_end_timestamp, NULL AS execution_duration_seconds, 'RUNNING' AS execution_status, 'SYSTEM_GENERATED' AS source_table_name, 'GO_DIM_DATE' AS target_table_name, 0 AS records_read, 0 AS records_processed, 0 AS records_inserted, 0 AS records_updated, 0 AS records_failed, 100.0 AS data_quality_score, 0 AS error_count, 0 AS warning_count, 'DBT_RUN' AS process_trigger, 'DBT_SYSTEM' AS executed_by, 'DBT_SERVER' AS server_name, '1.0.0' AS process_version, PARSE_JSON('{}') AS configuration_parameters, PARSE_JSON('{}') AS performance_metrics, CURRENT_DATE() AS load_date, CURRENT_DATE() AS update_date, 'DBT_GOLD_PIPELINE' AS source_system",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET execution_end_timestamp = CURRENT_TIMESTAMP(), execution_status = 'SUCCESS', records_processed = (SELECT COUNT(*) FROM {{ this }}), execution_duration_seconds = DATEDIFF('second', execution_start_timestamp, CURRENT_TIMESTAMP()) WHERE process_name = 'GO_DIM_DATE' AND execution_status = 'RUNNING'"
) }}

WITH date_series AS (
    SELECT DATEADD(day, ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 4018))
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY date_value) AS date_id,
    date_value AS date_key,
    date_value AS date_value,
    YEAR(date_value) AS year,
    QUARTER(date_value) AS quarter,
    MONTH(date_value) AS month,
    MONTHNAME(date_value) AS month_name,
    DAY(date_value) AS day_of_month,
    DAYOFWEEK(date_value) AS day_of_week,
    DAYNAME(date_value) AS day_name,
    CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
    FALSE AS is_holiday,
    CASE 
        WHEN MONTH(date_value) >= 4 THEN YEAR(date_value)
        ELSE YEAR(date_value) - 1
    END AS fiscal_year,
    CASE 
        WHEN MONTH(date_value) IN (4, 5, 6) THEN 1
        WHEN MONTH(date_value) IN (7, 8, 9) THEN 2
        WHEN MONTH(date_value) IN (10, 11, 12) THEN 3
        ELSE 4
    END AS fiscal_quarter,
    WEEKOFYEAR(date_value) AS week_of_year,
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    'SYSTEM_GENERATED' AS source_system
FROM date_series
