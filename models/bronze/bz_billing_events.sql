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
