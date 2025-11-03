{{ config(materialized='table') }}

WITH source_data AS (
    SELECT 
        l.LICENSE_ID,
        l.LICENSE_TYPE,
        l.ASSIGNED_TO_USER_ID,
        l.START_DATE,
        l.END_DATE,
        l.LOAD_TIMESTAMP,
        l.UPDATE_TIMESTAMP,
        l.SOURCE_SYSTEM,
        u.USER_NAME AS ASSIGNED_USER_NAME
    FROM {{ ref('bz_licenses') }} l
    LEFT JOIN {{ ref('bz_users') }} u ON l.ASSIGNED_TO_USER_ID = u.USER_ID
    WHERE l.LICENSE_ID IS NOT NULL
        AND l.ASSIGNED_TO_USER_ID IS NOT NULL
),

cleaned_data AS (
    SELECT 
        LICENSE_ID,
        ASSIGNED_TO_USER_ID,
        CASE 
            WHEN LICENSE_TYPE IN ('Basic', 'Pro', 'Enterprise', 'Add-on') THEN LICENSE_TYPE
            ELSE 'Basic'
        END AS LICENSE_TYPE,
        CASE 
            WHEN END_DATE < START_DATE THEN END_DATE
            ELSE START_DATE
        END AS START_DATE,
        CASE 
            WHEN END_DATE < START_DATE THEN START_DATE
            ELSE END_DATE
        END AS END_DATE,
        CASE 
            WHEN CURRENT_DATE() BETWEEN START_DATE AND END_DATE THEN 'Active'
            WHEN CURRENT_DATE() > END_DATE THEN 'Expired'
            ELSE 'Suspended'
        END AS LICENSE_STATUS,
        COALESCE(ASSIGNED_USER_NAME, 'Unknown User') AS ASSIGNED_USER_NAME,
        CASE 
            WHEN LICENSE_TYPE = 'Basic' THEN 10.00
            WHEN LICENSE_TYPE = 'Pro' THEN 20.00
            WHEN LICENSE_TYPE = 'Enterprise' THEN 50.00
            WHEN LICENSE_TYPE = 'Add-on' THEN 5.00
            ELSE 10.00
        END AS LICENSE_COST,
        CASE 
            WHEN DATEDIFF('day', CURRENT_DATE(), END_DATE) <= 30 THEN 'Yes'
            ELSE 'No'
        END AS RENEWAL_STATUS,
        CASE 
            WHEN LICENSE_TYPE = 'Basic' THEN 75.0
            WHEN LICENSE_TYPE = 'Pro' THEN 85.0
            WHEN LICENSE_TYPE = 'Enterprise' THEN 95.0
            ELSE 60.0
        END AS UTILIZATION_PERCENTAGE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        1.00 AS DATA_QUALITY_SCORE,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
    FROM source_data
    WHERE START_DATE IS NOT NULL
        AND END_DATE IS NOT NULL
),

deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
)

SELECT 
    LICENSE_ID,
    ASSIGNED_TO_USER_ID,
    LICENSE_TYPE,
    START_DATE,
    END_DATE,
    LICENSE_STATUS,
    ASSIGNED_USER_NAME,
    LICENSE_COST,
    RENEWAL_STATUS,
    UTILIZATION_PERCENTAGE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE
FROM deduplicated
