{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_PARTICIPANTS_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_PARTICIPANTS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'STARTED', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, records_inserted, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'EXEC_SI_PARTICIPANTS_' || TO_VARCHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_PARTICIPANTS_TRANSFORMATION', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), (SELECT COUNT(*) FROM {{ this }}), 'DBT_PIPELINE', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'DBT_PIPELINE' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT')"
) }}

-- Silver Participants Model
-- Transforms bronze participant data with attendance calculations

WITH bronze_participants AS (
    SELECT * FROM {{ source('bronze', 'bz_participants') }}
),

silver_meetings AS (
    SELECT * FROM {{ ref('si_meetings') }}
),

silver_users AS (
    SELECT * FROM {{ ref('si_users') }}
),

-- Data Quality Validation
data_quality_checks AS (
    SELECT 
        p.*,
        -- Temporal validation
        CASE 
            WHEN p.leave_time < p.join_time THEN 'INVALID_ATTENDANCE_SEQUENCE'
            WHEN p.join_time > CURRENT_TIMESTAMP() + INTERVAL '1' YEAR THEN 'FUTURE_JOIN_TIME'
            ELSE 'VALID'
        END AS temporal_quality_flag
    FROM bronze_participants p
    WHERE p.participant_id IS NOT NULL
      AND p.meeting_id IS NOT NULL
      AND p.user_id IS NOT NULL
),

-- Data Cleansing and Calculation
cleansed_participants AS (
    SELECT 
        p.participant_id,
        p.meeting_id,
        p.user_id,
        
        -- Corrected timestamps
        p.join_time,
        CASE 
            WHEN p.temporal_quality_flag = 'INVALID_ATTENDANCE_SEQUENCE'
            THEN p.join_time + INTERVAL '30' MINUTE  -- Default 30-minute attendance
            WHEN p.leave_time IS NULL
            THEN COALESCE(m.end_time, p.join_time + INTERVAL '60' MINUTE)
            ELSE p.leave_time
        END AS leave_time,
        
        -- Calculated attendance duration
        CASE 
            WHEN p.temporal_quality_flag = 'INVALID_ATTENDANCE_SEQUENCE'
            THEN 30
            WHEN p.leave_time IS NULL
            THEN DATEDIFF('minute', p.join_time, COALESCE(m.end_time, p.join_time + INTERVAL '60' MINUTE))
            ELSE DATEDIFF('minute', p.join_time, p.leave_time)
        END AS attendance_duration,
        
        -- Derived participant role
        CASE 
            WHEN p.user_id = m.host_id THEN 'Host'
            ELSE 'Participant'
        END AS participant_role,
        
        -- Connection quality based on attendance patterns
        CASE 
            WHEN DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, m.end_time)) >= m.duration_minutes * 0.9 THEN 'Excellent'
            WHEN DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, m.end_time)) >= m.duration_minutes * 0.7 THEN 'Good'
            WHEN DATEDIFF('minute', p.join_time, COALESCE(p.leave_time, m.end_time)) >= m.duration_minutes * 0.5 THEN 'Fair'
            ELSE 'Poor'
        END AS connection_quality,
        
        -- Silver layer metadata
        p.load_timestamp,
        p.update_timestamp,
        p.source_system,
        
        -- Data quality score
        ROUND(
            (CASE WHEN p.temporal_quality_flag = 'VALID' THEN 0.4 ELSE 0.0 END +
             CASE WHEN m.meeting_id IS NOT NULL THEN 0.3 ELSE 0.0 END +
             CASE WHEN u.user_id IS NOT NULL THEN 0.2 ELSE 0.0 END +
             CASE WHEN p.join_time IS NOT NULL THEN 0.1 ELSE 0.0 END), 2
        ) AS data_quality_score,
        
        -- Standard metadata
        DATE(p.load_timestamp) AS load_date,
        DATE(p.update_timestamp) AS update_date
        
    FROM data_quality_checks p
    LEFT JOIN silver_meetings m ON p.meeting_id = m.meeting_id
    LEFT JOIN silver_users u ON p.user_id = u.user_id
    WHERE m.meeting_id IS NOT NULL  -- Block orphaned participants
      AND u.user_id IS NOT NULL    -- Block participants with invalid user references
),

-- Deduplication
deduped_participants AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY participant_id ORDER BY update_timestamp DESC) AS rn
    FROM cleansed_participants
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
FROM deduped_participants
WHERE rn = 1
