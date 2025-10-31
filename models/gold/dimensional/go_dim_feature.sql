{{ config(
    materialized='table'
) }}

-- Feature Dimension Table
WITH feature_source AS (
    SELECT DISTINCT
        FEATURE_NAME,
        FEATURE_CATEGORY,
        SOURCE_SYSTEM
    FROM DB_POC_ZOOM.SILVER.SI_FEATURE_USAGE
    WHERE COALESCE(DATA_QUALITY_SCORE, 1.0) >= 0.8
      AND FEATURE_NAME IS NOT NULL
),

feature_transformed AS (
    SELECT 
        'DIM_FEATURE_' || MD5(UPPER(TRIM(FEATURE_NAME))) AS DIM_FEATURE_ID,
        UPPER(REPLACE(TRIM(FEATURE_NAME), ' ', '_')) AS FEATURE_KEY,
        INITCAP(TRIM(FEATURE_NAME)) AS FEATURE_NAME,
        UPPER(COALESCE(FEATURE_CATEGORY, 'GENERAL')) AS FEATURE_CATEGORY,
        CASE 
            WHEN UPPER(COALESCE(FEATURE_CATEGORY, 'GENERAL')) = 'AUDIO' THEN 'Audio Controls'
            WHEN UPPER(COALESCE(FEATURE_CATEGORY, 'GENERAL')) = 'VIDEO' THEN 'Video Controls'
            WHEN UPPER(COALESCE(FEATURE_CATEGORY, 'GENERAL')) = 'COLLABORATION' THEN 'Collaboration Tools'
            WHEN UPPER(COALESCE(FEATURE_CATEGORY, 'GENERAL')) = 'SECURITY' THEN 'Security Features'
            ELSE 'General Features'
        END AS FEATURE_SUBCATEGORY,
        CASE 
            WHEN FEATURE_NAME ILIKE '%virtual background%' 
                OR FEATURE_NAME ILIKE '%noise suppression%' 
                OR FEATURE_NAME ILIKE '%cloud recording%' 
                OR FEATURE_NAME ILIKE '%breakout%' 
            THEN TRUE 
            ELSE FALSE 
        END AS IS_PREMIUM_FEATURE,
        '2020-01-01'::DATE AS RELEASE_DATE,
        NULL AS DEPRECATION_DATE,
        TRUE AS IS_ACTIVE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        COALESCE(SOURCE_SYSTEM, 'UNKNOWN') AS SOURCE_SYSTEM
    FROM feature_source
)

SELECT * FROM feature_transformed
