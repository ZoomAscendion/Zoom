{{
  config(
    materialized='table',
    cluster_by=['MEETING_KEY'],
    tags=['dimension', 'gold']
  )
}}

-- Meeting Dimension Transformation
WITH meeting_data AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['MEETING_ID']) }} AS MEETING_KEY,
        ROW_NUMBER() OVER (ORDER BY MEETING_ID) AS MEETING_ID,
        'Standard Meeting' AS MEETING_TYPE,
        CASE 
            WHEN COALESCE(DURATION_MINUTES, 0) <= 15 THEN 'Quick Sync'
            WHEN COALESCE(DURATION_MINUTES, 0) <= 60 THEN 'Standard Meeting'
            WHEN COALESCE(DURATION_MINUTES, 0) <= 120 THEN 'Extended Meeting'
            ELSE 'Long Session'
        END AS MEETING_CATEGORY,
        CASE 
            WHEN COALESCE(DURATION_MINUTES, 0) <= 15 THEN 'Brief'
            WHEN COALESCE(DURATION_MINUTES, 0) <= 60 THEN 'Standard'
            WHEN COALESCE(DURATION_MINUTES, 0) <= 120 THEN 'Extended'
            ELSE 'Long'
        END AS DURATION_CATEGORY,
        'Unknown' AS PARTICIPANT_SIZE_CATEGORY,
        CASE 
            WHEN START_TIME IS NOT NULL THEN
                CASE 
                    WHEN HOUR(START_TIME) BETWEEN 6 AND 11 THEN 'Morning'
                    WHEN HOUR(START_TIME) BETWEEN 12 AND 17 THEN 'Afternoon'
                    WHEN HOUR(START_TIME) BETWEEN 18 AND 21 THEN 'Evening'
                    ELSE 'Night'
                END
            ELSE 'Unknown'
        END AS TIME_OF_DAY_CATEGORY,
        CASE 
            WHEN START_TIME IS NOT NULL THEN DAYNAME(START_TIME)
            ELSE 'Unknown'
        END AS DAY_OF_WEEK,
        CASE 
            WHEN START_TIME IS NOT NULL AND DAYOFWEEK(START_TIME) IN (1, 7) THEN TRUE 
            ELSE FALSE 
        END AS IS_WEEKEND,
        FALSE AS IS_RECURRING,
        CASE 
            WHEN COALESCE(DATA_QUALITY_SCORE, 0) >= 90 THEN 9.0
            WHEN COALESCE(DATA_QUALITY_SCORE, 0) >= 80 THEN 8.0
            WHEN COALESCE(DATA_QUALITY_SCORE, 0) >= 70 THEN 7.0
            ELSE 6.0
        END AS MEETING_QUALITY_SCORE,
        'Unknown' AS TYPICAL_FEATURES_USED,
        'Business Meeting' AS BUSINESS_PURPOSE,
        CURRENT_DATE() AS LOAD_DATE,
        CURRENT_DATE() AS UPDATE_DATE,
        COALESCE(SOURCE_SYSTEM, 'SILVER') AS SOURCE_SYSTEM
    FROM {{ source('silver', 'si_meetings') }}
    WHERE COALESCE(VALIDATION_STATUS, '') = 'PASSED'
      AND MEETING_ID IS NOT NULL
)

SELECT * FROM meeting_data
