-- Bronze Pipeline Step 3: Transform raw meetings data to bronze layer
-- Description: 1-1 mapping from RAW.MEETINGS to BRONZE.BZ_MEETINGS with deduplication
-- Author: Data Engineering Team
-- Created: 2024-01-01

{{ config(
    materialized='table',
    tags=['bronze', 'meetings'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_MEETINGS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_MEETINGS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- Bronze Pipeline Step 3.1: Select and filter raw data excluding null primary keys
WITH raw_meetings_filtered AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw_schema', 'meetings') }}
    WHERE meeting_id IS NOT NULL  -- Filter out null primary keys
),

-- Bronze Pipeline Step 3.2: Apply deduplication logic based on primary key and latest timestamp
deduped_meetings AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY meeting_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) as rn
    FROM raw_meetings_filtered
),

-- Bronze Pipeline Step 3.3: Select final deduplicated records
final_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system
    FROM deduped_meetings
    WHERE rn = 1
)

SELECT * FROM final_meetings
