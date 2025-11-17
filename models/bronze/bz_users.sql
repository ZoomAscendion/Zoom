-- Bronze Layer Users Table
-- Description: Stores user profile and subscription information from source systems
-- Source: RAW.USERS
-- Target: BRONZE.BZ_USERS
-- Transformation: 1-1 mapping with deduplication

{{ config(
    materialized='table',
    unique_key='user_id',
    pre_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS)
            VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), '{{ var(\"audit_user\") }}', 'STARTED')
        {% endif %}
    ",
    post_hook="
        {% if this.name != 'bz_data_audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
            VALUES ('BZ_USERS', CURRENT_TIMESTAMP(), '{{ var(\"audit_user\") }}', 
                    DATEDIFF('seconds', 
                        (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_USERS' AND STATUS = 'STARTED'), 
                        CURRENT_TIMESTAMP()), 
                    'COMPLETED')
        {% endif %}
    "
) }}

-- Raw data extraction with deduplication
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
        ) as rn
    FROM {{ source('raw', 'users') }}
),

-- Apply data quality checks and transformations
cleaned_data AS (
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
    WHERE rn = 1  -- Keep only the latest record per user
        AND USER_ID IS NOT NULL  -- Ensure primary key is not null
)

-- Final selection for Bronze layer
SELECT 
    USER_ID,
    USER_NAME,
    EMAIL,
    COMPANY,
    PLAN_TYPE,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM
FROM cleaned_data
