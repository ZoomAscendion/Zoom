/*
  Bronze Layer Audit Log Model
  Purpose: Track all data processing activities and provide audit trail
  Author: Data Engineering Team
  Created: {{ run_started_at }}
*/

{{ config(
    materialized='table',
    pre_hook="
      {% if this.name != 'bz_audit_log' %}
        INSERT INTO {{ ref('bz_audit_log') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS)
        VALUES ('{{ this.name }}', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED')
      {% endif %}
    ",
    post_hook="
      {% if this.name != 'bz_audit_log' %}
        UPDATE {{ ref('bz_audit_log') }} 
        SET PROCESSING_TIME = DATEDIFF('seconds', LOAD_TIMESTAMP, CURRENT_TIMESTAMP()),
            STATUS = 'COMPLETED'
        WHERE SOURCE_TABLE = '{{ this.name }}' 
        AND STATUS = 'STARTED'
        AND LOAD_TIMESTAMP = (SELECT MAX(LOAD_TIMESTAMP) FROM {{ ref('bz_audit_log') }} WHERE SOURCE_TABLE = '{{ this.name }}' AND STATUS = 'STARTED')
      {% endif %}
    "
) }}

-- Create audit log table structure
WITH audit_structure AS (
    SELECT 
        CAST(NULL AS NUMBER) AS RECORD_ID,
        CAST(NULL AS VARCHAR(255)) AS SOURCE_TABLE,
        CAST(NULL AS TIMESTAMP_NTZ) AS LOAD_TIMESTAMP,
        CAST(NULL AS VARCHAR(100)) AS PROCESSED_BY,
        CAST(NULL AS NUMBER) AS PROCESSING_TIME,
        CAST(NULL AS VARCHAR(50)) AS STATUS
    WHERE 1=0  -- This ensures no data is selected, only structure is created
)

SELECT * FROM audit_structure
