-- Bronze Layer Users Table
-- Description: Raw user profile and subscription information from source systems
-- Source: RAW.USERS
-- Target: BRONZE.BZ_USERS
-- Transformation: 1-1 mapping with deduplication

{{ config(
    materialized='table',
    tags=['bronze', 'users'],
    pre_hook="
        {% if not (this.name == 'bz_data_audit') %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), CURRENT_USER(), 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if not (this.name == 'bz_data_audit') %}
        INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
        VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), CURRENT_USER(), 'COMPLETED')
        {% endif %}
    "
) }}

-- CTE for data extraction and deduplication
WITH source_data AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        -- Add row number for deduplication based on latest update timestamp
        ROW_NUMBER() OVER (
            PARTITION BY USER_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) AS rn
    FROM {{ source('raw_schema', 'users') }}
),

-- Final deduplication
deduped_data AS (
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM source_data
    WHERE rn = 1
)

-- Final select with data quality checks
SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM deduped_data
WHERE USER_ID IS NOT NULL  -- Basic data quality check
