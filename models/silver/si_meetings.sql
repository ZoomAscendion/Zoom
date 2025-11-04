{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, start_time, status, source_tables_processed, target_tables_updated, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'SI_MEETINGS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_MEETINGS_ETL', CURRENT_TIMESTAMP(), 'Started', 'BZ_MEETINGS,BZ_USERS,BZ_PARTICIPANTS', 'SI_MEETINGS', 'DBT', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT' AND TABLE_TYPE = 'BASE TABLE')",
    post_hook="INSERT INTO {{ ref('si_pipeline_audit') }} (execution_id, pipeline_name, end_time, status, records_processed, executed_by, execution_environment, load_date, update_date, source_system) SELECT 'SI_MEETINGS_' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS'), 'SI_MEETINGS_ETL', CURRENT_TIMESTAMP(), 'Completed', (SELECT COUNT(*) FROM {{ this }}), 'DBT', 'PRODUCTION', CURRENT_DATE(), CURRENT_DATE(), 'SILVER_LAYER' WHERE NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = CURRENT_SCHEMA() AND TABLE_NAME = 'SI_PIPELINE_AUDIT' AND TABLE_TYPE = 'BASE TABLE')"
) }}

-- Silver Layer Meetings Table
-- Transforms Bronze meetings data with enrichment and data quality validations

WITH bronze_meetings AS (
    SELECT *
    FROM {{ source('bronze', 'bz_meetings') }}
),

bronze_users AS (
    SELECT user_id, user_name
    FROM {{ source('bronze', 'bz_users') }}
),

participant_counts AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT user_id) AS participant_count
    FROM {{ source('bronze', 'bz_participants') }}
    GROUP BY meeting_id
),

-- Data Quality Validations
validated_meetings AS (
    SELECT 
        m.*,
        CASE 
            WHEN m.meeting_id IS NULL THEN 'CRITICAL_MISSING_ID'
            WHEN m.host_id IS NULL THEN 'CRITICAL_MISSING_HOST'
            WHEN m.start_time IS NULL THEN 'CRITICAL_MISSING_START_TIME'
            WHEN m.end_time IS NOT NULL AND m.end_time < m.start_time THEN 'CRITICAL_INVALID_TIME_SEQUENCE'
            WHEN m.duration_minutes IS NOT NULL AND m.duration_minutes < 0 THEN 'CRITICAL_NEGATIVE_DURATION'
            ELSE 'VALID'
        END AS data_quality_status,
        
        -- Calculate data quality score
        CASE 
            WHEN m.meeting_id IS NOT NULL 
                AND m.host_id IS NOT NULL
                AND m.start_time IS NOT NULL
                AND (m.end_time IS NULL OR m.end_time >= m.start_time)
                AND (m.duration_minutes IS NULL OR m.duration_minutes >= 0)
            THEN 1.00
            ELSE 0.50
        END AS data_quality_score,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY m.meeting_id ORDER BY m.update_timestamp DESC, m.load_timestamp DESC) AS rn
    FROM bronze_meetings m
    WHERE m.meeting_id IS NOT NULL
        AND m.host_id IS NOT NULL
        AND m.start_time IS NOT NULL
        AND (m.end_time IS NULL OR m.end_time >= m.start_time)
        AND (m.duration_minutes IS NULL OR m.duration_minutes >= 0)
),

-- Apply transformations and enrichments
transformed_meetings AS (
    SELECT 
        vm.meeting_id,
        vm.host_id,
        TRIM(vm.meeting_topic) AS meeting_topic,
        
        -- Derive meeting type from duration
        CASE 
            WHEN vm.duration_minutes <= 30 THEN 'Instant'
            WHEN vm.duration_minutes <= 60 THEN 'Scheduled'
            WHEN vm.duration_minutes > 60 THEN 'Webinar'
            ELSE 'Personal'
        END AS meeting_type,
        
        vm.start_time,
        COALESCE(vm.end_time, DATEADD('minute', COALESCE(vm.duration_minutes, 60), vm.start_time)) AS end_time,
        
        -- Recalculate duration if needed
        CASE 
            WHEN vm.duration_minutes IS NOT NULL AND vm.duration_minutes > 0 THEN vm.duration_minutes
            WHEN vm.end_time IS NOT NULL THEN DATEDIFF('minute', vm.start_time, vm.end_time)
            ELSE 60  -- Default duration
        END AS duration_minutes,
        
        -- Get host name from users table
        COALESCE(u.user_name, 'Unknown Host') AS host_name,
        
        -- Derive meeting status
        CASE 
            WHEN vm.end_time IS NULL OR vm.end_time > CURRENT_TIMESTAMP() THEN 'Scheduled'
            WHEN vm.start_time <= CURRENT_TIMESTAMP() AND vm.end_time > CURRENT_TIMESTAMP() THEN 'In Progress'
            WHEN vm.end_time <= CURRENT_TIMESTAMP() THEN 'Completed'
            ELSE 'Cancelled'
        END AS meeting_status,
        
        -- Derive recording status (simplified logic)
        CASE 
            WHEN vm.duration_minutes > 30 THEN 'Yes'
            ELSE 'No'
        END AS recording_status,
        
        -- Get participant count
        COALESCE(pc.participant_count, 0) AS participant_count,
        
        -- Metadata columns
        vm.load_timestamp,
        vm.update_timestamp,
        vm.source_system,
        vm.data_quality_score,
        DATE(vm.load_timestamp) AS load_date,
        DATE(vm.update_timestamp) AS update_date
    FROM validated_meetings vm
    LEFT JOIN bronze_users u ON vm.host_id = u.user_id
    LEFT JOIN participant_counts pc ON vm.meeting_id = pc.meeting_id
    WHERE vm.rn = 1
        AND vm.data_quality_status = 'VALID'
)

SELECT 
    meeting_id,
    host_id,
    meeting_topic,
    meeting_type,
    start_time,
    end_time,
    duration_minutes,
    host_name,
    meeting_status,
    recording_status,
    participant_count,
    load_timestamp,
    update_timestamp,
    source_system,
    data_quality_score,
    load_date,
    update_date
FROM transformed_meetings
