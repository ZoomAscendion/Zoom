{{ config(
    materialized='table'
) }}

-- Silver Layer Participants Table
-- Transforms Bronze participants data with data quality validations and calculated metrics

WITH bronze_participants AS (
    SELECT *
    FROM {{ source('bronze', 'bz_participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL
        AND MEETING_ID IS NOT NULL
        AND USER_ID IS NOT NULL
),

-- Data Quality Checks and Transformations
participants_cleaned AS (
    SELECT 
        -- Primary identifiers
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        
        -- Timestamp validation and correction
        CASE 
            WHEN JOIN_TIME > CURRENT_TIMESTAMP() + INTERVAL '1 YEAR' 
                THEN CURRENT_TIMESTAMP()
            ELSE JOIN_TIME
        END AS JOIN_TIME,
        
        CASE 
            WHEN LEAVE_TIME IS NULL THEN 
                DATEADD('minute', 60, JOIN_TIME)  -- Default 1 hour if null
            WHEN LEAVE_TIME < JOIN_TIME THEN JOIN_TIME
            WHEN LEAVE_TIME > CURRENT_TIMESTAMP() + INTERVAL '1 YEAR'
                THEN CURRENT_TIMESTAMP()
            ELSE LEAVE_TIME
        END AS LEAVE_TIME,
        
        -- Calculate attendance duration
        CASE 
            WHEN LEAVE_TIME IS NULL THEN 60  -- Default 1 hour
            WHEN LEAVE_TIME < JOIN_TIME THEN 0
            ELSE DATEDIFF('minute', JOIN_TIME, LEAVE_TIME)
        END AS ATTENDANCE_DURATION,
        
        -- Participant role derivation (simplified)
        CASE 
            WHEN USER_ID IN (SELECT HOST_ID FROM {{ source('bronze', 'bz_meetings') }}) THEN 'Host'
            ELSE 'Participant'
        END AS PARTICIPANT_ROLE,
        
        -- Connection quality based on attendance duration
        CASE 
            WHEN DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, DATEADD('minute', 60, JOIN_TIME))) >= 45 THEN 'Excellent'
            WHEN DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, DATEADD('minute', 60, JOIN_TIME))) >= 30 THEN 'Good'
            WHEN DATEDIFF('minute', JOIN_TIME, COALESCE(LEAVE_TIME, DATEADD('minute', 60, JOIN_TIME))) >= 15 THEN 'Fair'
            ELSE 'Poor'
        END AS CONNECTION_QUALITY,
        
        -- Metadata columns
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM,
        
        -- Data quality score calculation
        CASE 
            WHEN PARTICIPANT_ID IS NOT NULL 
                AND MEETING_ID IS NOT NULL
                AND USER_ID IS NOT NULL
                AND JOIN_TIME IS NOT NULL
                AND LEAVE_TIME IS NOT NULL
                AND LEAVE_TIME >= JOIN_TIME
                THEN 1.00
            WHEN PARTICIPANT_ID IS NOT NULL AND MEETING_ID IS NOT NULL AND USER_ID IS NOT NULL
                THEN 0.75
            WHEN PARTICIPANT_ID IS NOT NULL
                THEN 0.50
            ELSE 0.25
        END AS DATA_QUALITY_SCORE,
        
        -- Standard metadata
        LOAD_TIMESTAMP::DATE AS LOAD_DATE,
        UPDATE_TIMESTAMP::DATE AS UPDATE_DATE,
        
        -- Row number for deduplication
        ROW_NUMBER() OVER (PARTITION BY PARTICIPANT_ID ORDER BY UPDATE_TIMESTAMP DESC) AS rn
        
    FROM bronze_participants
),

-- Final selection with data quality filters
participants_final AS (
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
        UPDATE_DATE
    FROM participants_cleaned
    WHERE rn = 1  -- Deduplication
        AND ATTENDANCE_DURATION >= 0  -- Ensure non-negative duration
)

SELECT * FROM participants_final
