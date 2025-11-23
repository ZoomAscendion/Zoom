{{
  config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_JOB', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="UPDATE {{ ref('bz_data_audit') }} SET processing_time = DATEDIFF('second', load_timestamp, CURRENT_TIMESTAMP()), status = 'SUCCESS' WHERE source_table = 'BZ_BILLING_EVENTS' AND status = 'STARTED' AND '{{ this.name }}' != 'bz_data_audit'"
  )
}}

-- Bronze layer transformation for BILLING_EVENTS table
-- Applies data cleaning, validation, and deduplication
-- Maps raw billing event data to bronze layer with audit information

WITH source_data AS (
    SELECT *
    FROM {{ source('raw', 'billing_events') }}
    WHERE event_id IS NOT NULL    -- Filter out records with null primary key
      AND user_id IS NOT NULL    -- Filter out records with null user_id
      AND event_type IS NOT NULL -- Filter out records with null event_type
      AND amount IS NOT NULL     -- Filter out records with null amount
      AND event_date IS NOT NULL -- Filter out records with null event_date
),

-- Apply deduplication based on primary key, keeping the most recent record
deduped_data AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY load_timestamp DESC) as rn
    FROM source_data
),

-- Final transformation with data quality enhancements
final_data AS (
    SELECT
        event_id,
        user_id,
        event_type,
        TRY_CAST(amount AS NUMBER(10,2)) AS amount,
        event_date,
        CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current timestamp
        CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current timestamp
        source_system
    FROM deduped_data
    WHERE rn = 1  -- Keep only the most recent record per event_id
)

SELECT * FROM final_data
