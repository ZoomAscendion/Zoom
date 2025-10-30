{{ config(
    materialized='incremental',
    unique_key='usage_id',
    on_schema_change='sync_all_columns'
) }}

-- Silver layer transformation for Feature Usage
WITH bronze_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_feature_usage') }}
    WHERE USAGE_ID IS NOT NULL
        AND MEETING_ID IS NOT NULL
        AND FEATURE_NAME IS NOT NULL
        AND USAGE_COUNT >= 0
        AND USAGE_DATE IS NOT NULL
        AND USAGE_DATE <= CURRENT_DATE()
),

-- Data Quality Checks and Cleansing
cleansed_feature_usage AS (
    SELECT 
        TRIM(USAGE_ID) as USAGE_ID,
        TRIM(MEETING_ID) as MEETING_ID,
        TRIM(FEATURE_NAME) as FEATURE_NAME,
        USAGE_COUNT,
        GREATEST(USAGE_COUNT * 0.5, 0) as USAGE_DURATION,
        CASE 
            WHEN LOWER(FEATURE_NAME) LIKE '%audio%' OR LOWER(FEATURE_NAME) LIKE '%mic%' THEN 'Audio'
            WHEN LOWER(FEATURE_NAME) LIKE '%video%' OR LOWER(FEATURE_NAME) LIKE '%camera%' THEN 'Video'
            WHEN LOWER(FEATURE_NAME) LIKE '%chat%' OR LOWER(FEATURE_NAME) LIKE '%share%' THEN 'Collaboration'
            WHEN LOWER(FEATURE_NAME) LIKE '%security%' OR LOWER(FEATURE_NAME) LIKE '%password%' THEN 'Security'
            ELSE 'Other'
        END as FEATURE_CATEGORY,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM bronze_feature_usage
),

-- Remove duplicates
deduped_feature_usage AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY USAGE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM cleansed_feature_usage
),

-- Calculate data quality score
final_feature_usage AS (
    SELECT 
        USAGE_ID,
        MEETING_ID,
        FEATURE_NAME,
        USAGE_COUNT,
        USAGE_DURATION,
        FEATURE_CATEGORY,
        USAGE_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Calculate data quality score
        ROUND(
            (CASE WHEN FEATURE_NAME IS NOT NULL THEN 0.3 ELSE 0 END +
             CASE WHEN USAGE_COUNT >= 0 THEN 0.3 ELSE 0 END +
             CASE WHEN FEATURE_CATEGORY != 'Other' THEN 0.2 ELSE 0 END +
             CASE WHEN USAGE_DATE IS NOT NULL THEN 0.2 ELSE 0 END), 2
        ) as DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) as LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) as UPDATE_DATE
    FROM deduped_feature_usage
    WHERE rn = 1
)

SELECT * FROM final_feature_usage

{% if is_incremental() %}
    WHERE UPDATE_TIMESTAMP > (SELECT COALESCE(MAX(UPDATE_TIMESTAMP), '1900-01-01') FROM {{ this }})
{% endif %}
