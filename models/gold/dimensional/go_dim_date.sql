{{ config(
    materialized='table',
    cluster_by=['DATE_VALUE', 'FISCAL_YEAR'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, PROCESS_TYPE, PROCESS_START_TIMESTAMP, PROCESS_STATUS, SOURCE_TABLE, TARGET_TABLE, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, SOURCE_SYSTEM) VALUES ('{{ dbt_utils.generate_surrogate_key(["'go_dim_date'", "CURRENT_TIMESTAMP()"]) }}', 'GO_DIM_DATE_LOAD', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SYSTEM_GENERATED', 'GO_DIM_DATE', 'DBT_MODEL_RUN', 'DBT_USER', CURRENT_DATE(), 'DBT_GOLD_LAYER')",
    post_hook="UPDATE {{ ref('go_audit_log') }} SET PROCESS_END_TIMESTAMP = CURRENT_TIMESTAMP(), PROCESS_STATUS = 'SUCCESS', RECORDS_PROCESSED = (SELECT COUNT(*) FROM {{ this }}), RECORDS_SUCCESS = (SELECT COUNT(*) FROM {{ this }}), DATA_QUALITY_SCORE = 100.0 WHERE PROCESS_ID = '{{ dbt_utils.generate_surrogate_key(["'go_dim_date'", "CURRENT_TIMESTAMP()"]) }}'"
) }}

-- Date dimension table for time-based analysis
-- Generates dates from 2020-01-01 to 2030-12-31

WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast('2030-12-31' as date)"
    ) }}
),

date_dimension AS (
    SELECT 
        date_day AS DATE_VALUE,
        ROW_NUMBER() OVER (ORDER BY date_day) AS DATE_ID,
        YEAR(date_day) AS YEAR,
        QUARTER(date_day) AS QUARTER,
        MONTH(date_day) AS MONTH,
        MONTHNAME(date_day) AS MONTH_NAME,
        DAY(date_day) AS DAY_OF_MONTH,
        DAYOFWEEK(date_day) AS DAY_OF_WEEK,
        DAYNAME(date_day) AS DAY_NAME,
        CASE WHEN DAYOFWEEK(date_day) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND,
        FALSE AS IS_HOLIDAY,
        CASE 
            WHEN MONTH(date_day) >= 4 THEN YEAR(date_day)
            ELSE YEAR(date_day) - 1
        END AS FISCAL_YEAR,
        CASE 
            WHEN MONTH(date_day) IN (4, 5, 6) THEN 1
            WHEN MONTH(date_day) IN (7, 8, 9) THEN 2
            WHEN MONTH(date_day) IN (10, 11, 12) THEN 3
            ELSE 4
        END AS FISCAL_QUARTER,
        WEEKOFYEAR(date_day) AS WEEK_OF_YEAR,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        'SYSTEM_GENERATED' AS SOURCE_SYSTEM
    FROM date_spine
)

SELECT * FROM date_dimension
