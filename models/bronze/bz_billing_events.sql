-- Bronze Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Author: AAVA Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table'
) }}

-- Create sample data structure for billing events table
SELECT 
    'EVENT_001' as EVENT_ID,
    'USER_001' as USER_ID,
    'Payment' as EVENT_TYPE,
    29.99 as AMOUNT,
    CURRENT_DATE() as EVENT_DATE,
    CURRENT_TIMESTAMP() AS LOAD_TIMESTAMP,
    CURRENT_TIMESTAMP() AS UPDATE_TIMESTAMP,
    'SAMPLE_SYSTEM' as SOURCE_SYSTEM
WHERE FALSE -- This ensures the table is created but empty initially

UNION ALL

-- Add proper column structure
SELECT 
    CAST(NULL AS VARCHAR(16777216)) as EVENT_ID,
    CAST(NULL AS VARCHAR(16777216)) as USER_ID,
    CAST(NULL AS VARCHAR(16777216)) as EVENT_TYPE,
    CAST(NULL AS NUMBER(10,2)) as AMOUNT,
    CAST(NULL AS DATE) as EVENT_DATE,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS LOAD_TIMESTAMP,
    CAST(NULL AS TIMESTAMP_NTZ(9)) AS UPDATE_TIMESTAMP,
    CAST(NULL AS VARCHAR(16777216)) as SOURCE_SYSTEM
WHERE FALSE
