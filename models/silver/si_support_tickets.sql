{{ config(
    materialized='table',
    tags=['silver', 'support']
) }}

WITH source_support_tickets AS (
    SELECT
        TICKET_ID,
        USER_ID,
        TICKET_TYPE,
        RESOLUTION_STATUS,
        OPEN_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM {{ source('bronze', 'bz_support_tickets') }}
    WHERE TICKET_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND OPEN_DATE IS NOT NULL
),

validated_users AS (
    SELECT USER_ID
    FROM {{ ref('si_users') }}
),

validated_support_tickets AS (
    SELECT
        sst.TICKET_ID,
        sst.USER_ID,
        CASE
            WHEN UPPER(TRIM(sst.TICKET_TYPE)) IN ('TECHNICAL', 'BILLING', 'FEATURE REQUEST', 'BUG REPORT')
            THEN INITCAP(TRIM(sst.TICKET_TYPE))
            ELSE 'Technical'
        END AS TICKET_TYPE,
        CASE
            WHEN UPPER(sst.TICKET_TYPE) = 'BUG REPORT' THEN 'High'
            WHEN UPPER(sst.TICKET_TYPE) = 'TECHNICAL' THEN 'Medium'
            ELSE 'Low'
        END AS PRIORITY_LEVEL,
        sst.OPEN_DATE,
        CASE
            WHEN UPPER(sst.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED')
            THEN DATEADD('day', 3, sst.OPEN_DATE)
            ELSE NULL
        END AS CLOSE_DATE,
        CASE
            WHEN UPPER(TRIM(sst.RESOLUTION_STATUS)) IN ('OPEN', 'IN PROGRESS', 'RESOLVED', 'CLOSED')
            THEN INITCAP(TRIM(sst.RESOLUTION_STATUS))
            ELSE 'Open'
        END AS RESOLUTION_STATUS,
        'Issue description' AS ISSUE_DESCRIPTION,
        'Resolution notes' AS RESOLUTION_NOTES,
        CASE
            WHEN UPPER(sst.RESOLUTION_STATUS) IN ('RESOLVED', 'CLOSED')
            THEN DATEDIFF('hour', sst.OPEN_DATE, DATEADD('day', 3, sst.OPEN_DATE))
            ELSE NULL
        END AS RESOLUTION_TIME_HOURS,
        sst.LOAD_TIMESTAMP,
        sst.UPDATE_TIMESTAMP,
        sst.SOURCE_SYSTEM
    FROM source_support_tickets sst
    INNER JOIN validated_users vu ON sst.USER_ID = vu.USER_ID
),

quality_scored_tickets AS (
    SELECT
        *,
        (
            CASE WHEN TICKET_TYPE IN ('Technical', 'Billing', 'Feature Request', 'Bug Report') THEN 0.20 ELSE 0 END +
            CASE WHEN PRIORITY_LEVEL IN ('Low', 'Medium', 'High', 'Critical') THEN 0.20 ELSE 0 END +
            CASE WHEN OPEN_DATE IS NOT NULL AND OPEN_DATE <= CURRENT_DATE() THEN 0.20 ELSE 0 END +
            CASE WHEN RESOLUTION_STATUS IN ('Open', 'In Progress', 'Resolved', 'Closed') THEN 0.20 ELSE 0 END +
            CASE WHEN CLOSE_DATE IS NULL OR CLOSE_DATE >= OPEN_DATE THEN 0.20 ELSE 0 END
        ) AS DATA_QUALITY_SCORE
    FROM validated_support_tickets
),

deduped_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY TICKET_ID ORDER BY UPDATE_TIMESTAMP DESC) AS row_num
    FROM quality_scored_tickets
)

SELECT
    TICKET_ID,
    USER_ID,
    TICKET_TYPE,
    PRIORITY_LEVEL,
    OPEN_DATE,
    CLOSE_DATE,
    RESOLUTION_STATUS,
    ISSUE_DESCRIPTION,
    RESOLUTION_NOTES,
    RESOLUTION_TIME_HOURS,
    LOAD_TIMESTAMP,
    UPDATE_TIMESTAMP,
    SOURCE_SYSTEM,
    DATA_QUALITY_SCORE,
    DATE(LOAD_TIMESTAMP) AS LOAD_DATE,
    DATE(UPDATE_TIMESTAMP) AS UPDATE_DATE
FROM deduped_tickets
WHERE row_num = 1
  AND DATA_QUALITY_SCORE >= 0.60
