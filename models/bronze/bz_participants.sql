-- Bronze Layer Participants Model
-- Description: Meeting participants and their session details
-- Source: RAW.PARTICIPANTS
-- Target: BRONZE.BZ_PARTICIPANTS

{{ config(
    materialized='incremental',
    unique_key='participant_id',
    on_schema_change='append_new_columns',
    tags=['bronze', 'participants'],
    pre_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status)
            SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 'STARTED'
        {% endif %}
    ",
    post_hook="
        {% if target.name != 'audit' %}
            INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status)
            SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_BRONZE_PIPELINE', 
                   DATEDIFF('seconds', 
                           (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_PARTICIPANTS' AND status = 'STARTED'),
                           CURRENT_TIMESTAMP()), 
                   'SUCCESS'
        {% endif %}
    "
) }}

WITH source_data AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Add row number for deduplication
        ROW_NUMBER() OVER (
            PARTITION BY participant_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC
        ) AS row_num
    FROM {{ source('raw', 'participants') }}
    WHERE participant_id IS NOT NULL  -- Filter out records with null primary keys
        AND meeting_id IS NOT NULL     -- Required field validation
        AND user_id IS NOT NULL        -- Required field validation
    
    {% if is_incremental() %}
        AND COALESCE(update_timestamp, load_timestamp) > (
            SELECT COALESCE(MAX(update_timestamp), '1900-01-01') 
            FROM {{ this }}
        )
    {% endif %}
),

validated_data AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system
    FROM source_data
    WHERE row_num = 1  -- Keep only the most recent record per participant_id
        AND (join_time IS NULL OR leave_time IS NULL OR join_time <= leave_time)  -- Time validation
)

SELECT 
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time,
    -- Override timestamps as per Bronze layer requirements
    CURRENT_TIMESTAMP() AS load_timestamp,
    CURRENT_TIMESTAMP() AS update_timestamp,
    COALESCE(source_system, 'UNKNOWN') AS source_system
FROM validated_data
