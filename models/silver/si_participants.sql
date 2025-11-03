{{ config(
    materialized='table',
    on_schema_change='sync_all_columns',
    pre_hook="
        INSERT INTO {{ ref('si_pipeline_audit') }} (
            execution_id, pipeline_name, start_time, status, 
            source_tables_processed, executed_by, execution_environment,
            load_date, update_date, source_system
        )
        VALUES (
            '{{ invocation_id }}_si_participants', 
            'si_participants', 
            CURRENT_TIMESTAMP(), 
            'STARTED',
            'BZ_PARTICIPANTS',
            '{{ var(\"audit_user\") }}',
            'PRODUCTION',
            CURRENT_DATE(),
            CURRENT_DATE(),
            'DBT_SILVER_PIPELINE'
        )
    ",
    post_hook="
        UPDATE {{ ref('si_pipeline_audit') }}
        SET 
            end_time = CURRENT_TIMESTAMP(),
            status = 'SUCCESS',
            execution_duration_seconds = DATEDIFF('second', start_time, CURRENT_TIMESTAMP()),
            target_tables_updated = 'SI_PARTICIPANTS',
            records_processed = (SELECT COUNT(*) FROM {{ this }}),
            records_inserted = (SELECT COUNT(*) FROM {{ this }}),
            records_updated = 0,
            records_rejected = 0,
            update_date = CURRENT_DATE()
        WHERE execution_id = '{{ invocation_id }}_si_participants'
    "
) }}

-- Silver layer transformation for Participants
WITH bronze_participants AS (
    SELECT *
    FROM {{ source('bronze', 'bz_participants') }}
),

bronze_meetings AS (
    SELECT meeting_id, host_id, start_time, end_time
    FROM {{ source('bronze', 'bz_meetings') }}
),

-- Data Quality Checks and Cleansing
cleansed_participants AS (
    SELECT 
        p.participant_id,
        p.meeting_id,
        p.user_id,
        p.join_time,
        p.leave_time,
        p.load_timestamp,
        p.update_timestamp,
        p.source_system,
        
        -- Data Quality Validations
        CASE 
            WHEN p.participant_id IS NULL THEN 0
            WHEN p.meeting_id IS NULL THEN 0
            WHEN p.user_id IS NULL THEN 0
            WHEN p.join_time IS NULL THEN 0
            WHEN p.leave_time IS NOT NULL AND p.leave_time < p.join_time THEN 0
            ELSE 1
        END AS participant_valid,
        
        -- Corrected leave_time if missing or invalid
        CASE 
            WHEN p.leave_time IS NULL 
            THEN DATEADD('minute', 30, p.join_time)
            WHEN p.leave_time < p.join_time 
            THEN p.join_time
            ELSE p.leave_time
        END AS leave_time_corrected
        
    FROM bronze_participants p
),

-- Remove duplicates
deduped_participants AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY participant_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS rn
    FROM cleansed_participants
    WHERE participant_valid = 1
),

-- Final transformation with derived fields
final_participants AS (
    SELECT 
        p.participant_id,
        p.meeting_id,
        p.user_id,
        p.join_time,
        p.leave_time_corrected AS leave_time,
        
        -- Calculate attendance duration
        DATEDIFF('minute', p.join_time, p.leave_time_corrected) AS attendance_duration,
        
        -- Derive participant role
        CASE 
            WHEN p.user_id = m.host_id THEN 'Host'
            WHEN DATEDIFF('minute', p.join_time, p.leave_time_corrected) > 60 THEN 'Co-host'
            WHEN DATEDIFF('minute', p.join_time, p.leave_time_corrected) > 30 THEN 'Participant'
            ELSE 'Observer'
        END AS participant_role,
        
        -- Derive connection quality based on attendance patterns
        CASE 
            WHEN DATEDIFF('minute', p.join_time, p.leave_time_corrected) >= 90 THEN 'Excellent'
            WHEN DATEDIFF('minute', p.join_time, p.leave_time_corrected) >= 60 THEN 'Good'
            WHEN DATEDIFF('minute', p.join_time, p.leave_time_corrected) >= 30 THEN 'Fair'
            ELSE 'Poor'
        END AS connection_quality,
        
        -- Metadata columns
        p.load_timestamp,
        p.update_timestamp,
        p.source_system,
        
        -- Data quality score
        CASE 
            WHEN p.join_time IS NOT NULL 
                AND p.leave_time_corrected IS NOT NULL 
                AND DATEDIFF('minute', p.join_time, p.leave_time_corrected) >= 0
            THEN 1.00
            ELSE 0.50
        END AS data_quality_score,
        
        DATE(p.load_timestamp) AS load_date,
        DATE(p.update_timestamp) AS update_date
        
    FROM deduped_participants p
    LEFT JOIN bronze_meetings m ON p.meeting_id = m.meeting_id
    WHERE p.rn = 1
)

SELECT 
    participant_id,
    meeting_id,
    user_id,
    join_time,
    leave_time,
    attendance_duration,
    participant_role,
    connection_quality,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    load_date,
    update_date
FROM final_participants
