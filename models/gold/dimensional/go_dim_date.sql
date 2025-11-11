{{ config(
    materialized='table',
    tags=['dimension', 'gold'],
    pre_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, PROCESS_TYPE, PROCESS_START_TIME, PROCESS_STATUS, SOURCE_TABLE, TARGET_TABLE, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, SOURCE_SYSTEM) VALUES (UUID_STRING(), 'GO_DIM_DATE_LOAD', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), 'RUNNING', 'SYSTEM_GENERATED', 'GO_DIM_DATE', 'DBT_MODEL_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE')",
    post_hook="INSERT INTO {{ ref('go_audit_log') }} (PROCESS_ID, PROCESS_NAME, PROCESS_TYPE, PROCESS_START_TIME, PROCESS_END_TIME, PROCESS_STATUS, SOURCE_TABLE, TARGET_TABLE, RECORDS_PROCESSED, PROCESS_TRIGGER, EXECUTED_BY, LOAD_DATE, SOURCE_SYSTEM) SELECT UUID_STRING(), 'GO_DIM_DATE_LOAD', 'DIMENSION_LOAD', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP(), 'SUCCESS', 'SYSTEM_GENERATED', 'GO_DIM_DATE', (SELECT COUNT(*) FROM {{ this }}), 'DBT_MODEL_RUN', 'DBT_SYSTEM', CURRENT_DATE(), 'DBT_GOLD_PIPELINE'"
) }}

-- Date dimension generation for time-based analysis
WITH date_series AS (
    SELECT 
        DATEADD(day, ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) AS date_value
    FROM TABLE(GENERATOR(ROWCOUNT => 4018)) -- 11 years of dates (2020-2030)
),

date_attributes AS (
    SELECT 
        date_value AS DATE_KEY,
        date_value AS DATE_VALUE,
        YEAR(date_value) AS YEAR,
        QUARTER(date_value) AS QUARTER,
        MONTH(date_value) AS MONTH,
        MONTHNAME(date_value) AS MONTH_NAME,
        DAY(date_value) AS DAY_OF_MONTH,
        DAYOFWEEK(date_value) AS DAY_OF_WEEK,
        DAYNAME(date_value) AS DAY_NAME,
        CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END AS IS_WEEKEND,
        FALSE AS IS_HOLIDAY, -- To be enhanced with holiday logic
        CASE 
            WHEN MONTH(date_value) >= 4 THEN YEAR(date_value)
            ELSE YEAR(date_value) - 1
        END AS FISCAL_YEAR,
        CASE 
            WHEN MONTH(date_value) IN (4, 5, 6) THEN 1
            WHEN MONTH(date_value) IN (7, 8, 9) THEN 2
            WHEN MONTH(date_value) IN (10, 11, 12) THEN 3
            ELSE 4
        END AS FISCAL_QUARTER,
        WEEKOFYEAR(date_value) AS WEEK_OF_YEAR,
        CURRENT_DATE AS LOAD_DATE,
        CURRENT_DATE AS UPDATE_DATE,
        'SYSTEM_GENERATED' AS SOURCE_SYSTEM
    FROM date_series
)

SELECT 
    DATE_KEY,
    ROW_NUMBER() OVER (ORDER BY DATE_KEY) AS DATE_ID,
    DATE_VALUE,
    YEAR,
    QUARTER,
    MONTH,
    MONTH_NAME,
    DAY_OF_MONTH,
    DAY_OF_WEEK,
    DAY_NAME,
    IS_WEEKEND,
    IS_HOLIDAY,
    FISCAL_YEAR,
    FISCAL_QUARTER,
    WEEK_OF_YEAR,
    LOAD_DATE,
    UPDATE_DATE,
    SOURCE_SYSTEM
FROM date_attributes
