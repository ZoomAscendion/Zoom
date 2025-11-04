{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'SI_PARTICIPANTS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_PARTICIPANTS_ETL', CURRENT_TIMESTAMP(), 'Started', 'BZ_PARTICIPANTS', 'SI_PARTICIPANTS', 'DBT', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT' AND TABLE_TYPE = 'BASE TABLE')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'SI_PARTICIPANTS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_PARTICIPANTS_ETL', CURRENT_TIMESTAMP(), 'Completed', (SELECT COUNT(*) FROM {{ this }}), 'DBT', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT' AND TABLE_TYPE = 'BASE TABLE')"
) }}

-- Silver Layer Participants Table
-- Transforms Bronze participants data with attendance calculations and validations

WITH bronze_participants AS (
    SELECT *
    FROM {{ source('bronze', 'bz_participants') }}
),

-- Data Quality Validations
validated_participants AS (
    SELECT 
        p.*,
        CASE 
            WHEN p.participant_id IS NULL THEN 'CRITICAL_MISSING_ID'
            WHEN p.meeting_id IS NULL THEN 'CRITICAL_MISSING_MEETING_ID'
            WHEN p.user_id IS NULL THEN 'CRITICAL_MISSING_USER_ID'
            WHEN p.join_time IS NULL THEN 'CRITICAL_MISSING_JOIN_TIME'
            WHEN p.leave_time IS NOT NULL AND p.leave_time < p.join_time THEN 'CRITICAL_INVALID_TIME_SEQUENCE'
            ELSE 'VALID'
        END AS data_quality_status,
        
        -- Calculate data quality score
        CASE 
            WHEN p.participant_id IS NOT NULL 
                AND p.meeting_id IS NOT NULL
                AND p.user_id IS NOT NULL
                AND p.join_time IS NOT NULL
                AND (p.leave_time IS NULL OR p.leave_time >= p.join_time)
            THEN 1.00
            ELSE 0.60
        END AS data_quality_score,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY p.participant_id ORDER BY p.update_timestamp DESC, p.load_timestamp DESC) AS rn
    FROM bronze_participants p
    WHERE p.participant_id IS NOT NULL
        AND p.meeting_id IS NOT NULL
        AND p.user_id IS NOT NULL
        AND p.join_time IS NOT NULL
        AND (p.leave_time IS NULL OR p.leave_time >= p.join_time)
),

-- Apply transformations
transformed_participants AS (
    SELECT 
        vp.participant_id,
        vp.meeting_id,
        vp.user_id,
        vp.join_time,
        
        -- Handle missing leave_time
        COALESCE(vp.leave_time, DATEADD('minute', 60, vp.join_time)) AS leave_time,
        
        -- Calculate attendance duration
        CASE 
            WHEN vp.leave_time IS NOT NULL 
            THEN DATEDIFF('minute', vp.join_time, vp.leave_time)
            ELSE 60  -- Default duration for missing leave_time
        END AS attendance_duration,
        
        -- Derive participant role (simplified logic)
        CASE 
            WHEN vp.user_id = (SELECT host_id FROM {{ source('bronze', 'bz_meetings') }} WHERE meeting_id = vp.meeting_id LIMIT 1) 
            THEN 'Host'
            ELSE 'Participant'
        END AS participant_role,
        
        -- Derive connection quality from attendance duration
        CASE 
            WHEN DATEDIFF('minute', vp.join_time, COALESCE(vp.leave_time, DATEADD('minute', 60, vp.join_time))) >= 45 THEN 'Excellent'
            WHEN DATEDIFF('minute', vp.join_time, COALESCE(vp.leave_time, DATEADD('minute', 60, vp.join_time))) >= 30 THEN 'Good'
            WHEN DATEDIFF('minute', vp.join_time, COALESCE(vp.leave_time, DATEADD('minute', 60, vp.join_time))) >= 15 THEN 'Fair'
            ELSE 'Poor'
        END AS connection_quality,
        
        -- Metadata columns
        vp.load_timestamp,
        vp.update_timestamp,
        vp.source_system,
        vp.data_quality_score,
        DATE(vp.load_timestamp) AS load_date,
        DATE(vp.update_timestamp) AS update_date
    FROM validated_participants vp
    WHERE vp.rn = 1
        AND vp.data_quality_status = 'VALID'
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
FROM transformed_participants
