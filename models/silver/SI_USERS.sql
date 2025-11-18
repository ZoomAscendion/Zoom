{{ config(
    materialized='table'
) }}

/*
 * SI_USERS - Silver Layer Users Table
 * Transforms and cleanses user data from Bronze layer
 */

WITH bronze_users AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM BRONZE.BZ_USERS
    WHERE USER_ID IS NOT NULL
),

cleansed_users AS (
    SELECT 
        USER_ID,
        TRIM(USER_NAME) AS USER_NAME,
        LOWER(TRIM(EMAIL)) AS EMAIL,
        TRIM(COMPANY) AS COMPANY,
        CASE 
            WHEN UPPER(TRIM(PLAN_TYPE)) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN UPPER(TRIM(PLAN_TYPE))
            ELSE 'FREE'
        END AS PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        COALESCE(DATE(UPDATE_TIMESTAMP), DATE(LOAD_TIMESTAMP)) AS UPDATE_DATE
    FROM bronze_users
)

SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    LOAD_DATE,
    UPDATE_DATE,
    
    /* Data Quality Score Calculation */
    CASE 
        WHEN USER_ID IS NOT NULL 
            AND USER_NAME IS NOT NULL 
            AND EMAIL IS NOT NULL 
            AND PLAN_TYPE IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')
        THEN 100
        WHEN USER_ID IS NOT NULL AND EMAIL IS NOT NULL 
        THEN 75
        WHEN USER_ID IS NOT NULL 
        THEN 50
        ELSE 25
    END AS DATA_QUALITY_SCORE,
    
    /* Validation Status */
    CASE 
        WHEN USER_ID IS NOT NULL 
            AND USER_NAME IS NOT NULL 
            AND EMAIL IS NOT NULL 
            AND PLAN_TYPE IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE')
        THEN 'PASSED'
        WHEN USER_ID IS NOT NULL AND EMAIL IS NOT NULL 
        THEN 'WARNING'
        ELSE 'FAILED'
    END AS VALIDATION_STATUS
FROM cleansed_users
