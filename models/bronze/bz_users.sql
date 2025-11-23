{{
  config(
    materialized='table',
    tags=['bronze', 'users'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_USERS', CURRENT_TIMESTAMP(), 'DBT_JOB', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="UPDATE {{ ref('bz_data_audit') }} SET processing_time = DATEDIFF('second', load_timestamp, CURRENT_TIMESTAMP()), status = 'SUCCESS' WHERE source_table = 'BZ_USERS' AND status = 'STARTED' AND '{{ this.name }}' != 'bz_data_audit'"
  )
}}

-- Bronze layer transformation for USERS table
-- Applies data cleaning, validation, and deduplication
-- Maps raw user data to bronze layer with audit information

WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'users') }}
    WHERE user_id IS NOT NULL  -- Filter out records with null primary key
      AND email IS NOT NULL   -- Filter out records with null email (unique constraint)
),

-- Apply deduplication based on primary key, keeping the most recent record
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY load_timestamp DESC) as rn
    FROM source_data
),

-- Final transformation with data quality enhancements
final_data AS (
    SELECT
        user_id,
        COALESCE(user_name, 'Unknown User') AS user_name,
        CASE 
            WHEN email IS NULL OR email = '' THEN user_name || '@gmail.com'
            ELSE email 
        END AS email,
        company,
        COALESCE(plan_type, 'Basic') AS plan_type,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current timestamp
        CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current timestamp
        source_system
    FROM deduped_data
    WHERE rn = 1  -- Keep only the most recent record per user_id
)

SELECT * FROM final_data
