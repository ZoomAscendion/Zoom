{{ config(
    materialized='table'
) }}

-- Pre-hook: Log process start
{% if this.name != 'audit_log' %}
{{ log("Starting transformation for si_participants", info=True) }}
{% endif %}

WITH source_data AS (
    SELECT 
        p.PARTICIPANT_ID,
        p.MEETING_ID,
        p.USER_ID,
        p.JOIN_TIME,
        p.LEAVE_TIME,
        p.LOAD_TIMESTAMP,
        p.UPDATE_TIMESTAMP,
        p.SOURCE_SYSTEM
    FROM {{ ref('bz_participants') }} p
    WHERE p.PARTICIPANT_ID IS NOT NULL
),

data_quality_checks AS (
    SELECT 
        s.*,
        
        -- Time validation
        CASE 
            WHEN s.JOIN_TIME IS NOT NULL AND s.LEAVE_TIME IS NOT NULL 
                 AND s.LEAVE_TIME >= s.JOIN_TIME THEN 1
            ELSE 0
        END AS time_valid,
        
        -- Reference validation
        CASE 
            WHEN s.MEETING_ID IS NOT NULL AND s.USER_ID IS NOT NULL THEN 1
            ELSE 0
        END AS reference_valid,
        
        -- Completeness check
        CASE 
            WHEN s.JOIN_TIME IS NOT NULL THEN 1
            ELSE 0
        END AS join_time_complete
    FROM source_data s
),

cleaned_data AS (
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        
        -- Validate and clean timestamps
        CASE 
            WHEN time_valid = 1 THEN JOIN_TIME
            ELSE NULL
        END AS JOIN_TIME,
        
        CASE 
            WHEN time_valid = 1 THEN LEAVE_TIME
            WHEN JOIN_TIME IS NOT NULL 
            THEN DATEADD('minute', 30, JOIN_TIME)  -- Default 30 min session
            ELSE NULL
        END AS LEAVE_TIME,
        
        -- Calculate attendance duration
        CASE 
            WHEN time_valid = 1 AND JOIN_TIME IS NOT NULL AND LEAVE_TIME IS NOT NULL
            THEN DATEDIFF('minute', JOIN_TIME, LEAVE_TIME)
            ELSE 0
        END AS ATTENDANCE_DURATION,
        
        -- Derive participant role (simplified logic)
        CASE 
            WHEN USER_ID IS NOT NULL THEN 'Participant'
            ELSE 'Observer'
        END AS PARTICIPANT_ROLE,
        
        -- Derive connection quality based on attendance duration
        CASE 
            WHEN ATTENDANCE_DURATION >= 45 THEN 'Excellent'
            WHEN ATTENDANCE_DURATION >= 30 THEN 'Good'
            WHEN ATTENDANCE_DURATION >= 15 THEN 'Fair'
            ELSE 'Poor'
        END AS CONNECTION_QUALITY,
        
        -- Calculate data quality score
        ROUND((time_valid + reference_valid + join_time_complete) / 3.0, 2) AS DATA_QUALITY_SCORE,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
        DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM data_quality_checks
    WHERE PARTICIPANT_ID IS NOT NULL  -- Remove records with null primary key
),

deduplication AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC
        ) AS row_num
    FROM cleaned_data
    QUALIFY row_num = 1
)

-- Final SELECT
SELECT 
    PARTICIPANT_ID,
    MEETING_ID,
    USER_ID,
    JOIN_TIME,
    LEAVE_TIME,
    ATTENDANCE_DURATION,
    PARTICIPANT_ROLE,
    CONNECTION_QUALITY,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    LOAD_DATE,
    UPDATE_DATE,
    created_at,
    updated_at
FROM deduplication

-- Post-hook: Log process completion
{% if this.name != 'audit_log' %}
{{ log("Completed transformation for si_participants", info=True) }}
{% endif %}
