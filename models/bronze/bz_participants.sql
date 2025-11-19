-- Bronze Layer Participants Table
-- Description: Tracks meeting participants and their session details
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'participants'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, STATUS) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_USER', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_PARTICIPANTS', CURRENT_TIMESTAMP(), 'DBT_USER', DATEDIFF('seconds', (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_data_audit') }} WHERE SOURCE_TABLE = 'BZ_PARTICIPANTS' AND STATUS = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    -- BZ Pipeline: Extract raw participant data from source
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        TRY_CAST(JOIN_TIME AS TIMESTAMP_NTZ(9)) as JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('raw', 'participants') }}
    WHERE PARTICIPANT_ID IS NOT NULL  -- Filter out records with null primary key
),

deduped_data AS (
    -- BZ Pipeline: Apply deduplication logic based on primary key and latest timestamp
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY PARTICIPANT_ID 
            ORDER BY COALESCE(UPDATE_TIMESTAMP, LOAD_TIMESTAMP) DESC
        ) as rn
    FROM source_data
),

final AS (
    -- BZ Pipeline: Select final deduplicated records
    SELECT 
        PARTICIPANT_ID,
        MEETING_ID,
        USER_ID,
        JOIN_TIME,
        LEAVE_TIME,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM deduped_data
    WHERE rn = 1
)

SELECT * FROM final
