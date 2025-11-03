{{ config(
    materialized='table'
) }}

-- Pre-hook: Log process start
{% if this.name != 'audit_log' %}
{{ log("Starting transformation for si_licenses", info=True) }}
{% endif %}

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
),

data_quality_checks AS (
    SELECT 
        s.*,
        
        -- License type validation
        CASE 
            WHEN s.LICENSE_TYPE IN ('Basic', 'Pro', 'Enterprise', 'Add-on') THEN 1
            ELSE 0
        END AS license_type_valid,
        
        -- Date range validation
        CASE 
            WHEN s.START_DATE IS NOT NULL AND s.END_DATE IS NOT NULL 
                 AND s.END_DATE >= s.START_DATE THEN 1
            ELSE 0
        END AS date_range_valid,
        
        -- User assignment validation
        CASE 
            WHEN s.ASSIGNED_TO_USER_ID IS NOT NULL THEN 1
            ELSE 0
        END AS user_assigned
    FROM source_data s
),

cleaned_data AS (
    SELECT 
        LICENSE_ID,
        ASSIGNED_TO_USER_ID,
        
        -- Standardize license type
        CASE 
            WHEN license_type_valid = 1 THEN LICENSE_TYPE
            ELSE 'Basic'
        END AS LICENSE_TYPE,
        
        -- Validate start date
        CASE 
            WHEN date_range_valid = 1 THEN START_DATE
            ELSE CURRENT_DATE()
        END AS START_DATE,
        
        -- Validate end date
        CASE 
            WHEN date_range_valid = 1 THEN END_DATE
            WHEN START_DATE IS NOT NULL 
            THEN DATEADD('year', 1, START_DATE)
            ELSE DATEADD('year', 1, CURRENT_DATE())
        END AS END_DATE,
        
        -- Derive license status
        CASE 
            WHEN END_DATE < CURRENT_DATE() THEN 'Expired'
            WHEN START_DATE > CURRENT_DATE() THEN 'Pending'
            ELSE 'Active'
        END AS LICENSE_STATUS,
        
        -- Assigned user name
        COALESCE(ASSIGNED_USER_NAME, 'UNASSIGNED') AS ASSIGNED_USER_NAME,
        
        -- Derive license cost from type
        CASE 
            WHEN LICENSE_TYPE = 'Basic' THEN 0.00
            WHEN LICENSE_TYPE = 'Pro' THEN 14.99
            WHEN LICENSE_TYPE = 'Enterprise' THEN 19.99
            WHEN LICENSE_TYPE = 'Add-on' THEN 5.99
            ELSE 0.00
        END AS LICENSE_COST,
        
        -- Derive renewal status
        CASE 
            WHEN DATEDIFF('day', CURRENT_DATE(), END_DATE) <= 30 THEN 'Yes'
            ELSE 'No'
        END AS RENEWAL_STATUS,
        
        -- Calculate utilization percentage (simplified)
        CASE 
            WHEN LICENSE_STATUS = 'Active' THEN 85.0
            WHEN LICENSE_STATUS = 'Pending' THEN 0.0
            ELSE 0.0
        END AS UTILIZATION_PERCENTAGE,
        
        -- Calculate data quality score
        ROUND((license_type_valid + date_range_valid + user_assigned) / 3.0, 2) AS DATA_QUALITY_SCORE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM data_quality_checks
    WHERE LICENSE_ID IS NOT NULL  -- Remove records with null primary key
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY LICENSE_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
)

-- Final SELECT
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
    UPDATE_DATE,
    created_at,
    updated_at
FROM deduplication

-- Post-hook: Log process completion
{% if this.name != 'audit_log' %}
{{ log("Completed transformation for si_licenses", info=True) }}
{% endif %}
