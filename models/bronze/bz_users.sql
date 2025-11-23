-- Bronze Layer Users Model
-- Description: Transforms raw user data into bronze layer with audit capabilities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    unique_key='user_id',
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_{{ invocation_id }}', 'COMPLETED' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH raw_users AS (
    -- Select from raw users table with null filtering for primary key
    SELECT 
        USER_ID,
        USER_NAME,
        EMAIL,
        COMPANY,
        PLAN_TYPE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'users') }}
    WHERE USER_ID IS NOT NULL
),

deduped_users AS (
    -- Apply deduplication based on user_id, keeping the latest record
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC) as rn
        FROM raw_users
    )
    WHERE rn = 1
),

final_users AS (
    -- Final transformation with data quality improvements
    SELECT 
        USER_ID,
        COALESCE(USER_NAME, 'Unknown User') AS USER_NAME,
        CASE 
            WHEN EMAIL IS NULL OR EMAIL = '' THEN USER_NAME || '@gmail.com'
            ELSE EMAIL 
        END AS EMAIL,
        COMPANY,
        COALESCE(PLAN_TYPE, 'Basic') AS PLAN_TYPE,
        CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
        CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
        COALESCE(SOURCE_SYSTEM, 'unknown') AS SOURCE_SYSTEM
    FROM deduped_users
)

SELECT * FROM final_users
