-- Bronze Layer Billing Events Table
-- Description: Tracks financial transactions and billing activities
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 0, 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (SOURCE_TABLE, LOAD_TIMESTAMP, PROCESSED_BY, PROCESSING_TIME, STATUS) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'DBT_PROCESS', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

WITH source_data AS (
    SELECT 
        'BILL001' as EVENT_ID,
        'USR001' as USER_ID,
        'Subscription' as EVENT_TYPE,
        19.99 as AMOUNT,
        '2024-01-01'::DATE as EVENT_DATE,
        '2024-01-01 09:00:00'::TIMESTAMP_NTZ as LOAD_TIMESTAMP,
        '2024-01-01 09:00:00'::TIMESTAMP_NTZ as UPDATE_TIMESTAMP,
        'BILLING_SYSTEM' as SOURCE_SYSTEM
    UNION ALL
    SELECT 
        'BILL002',
        'USR002',
        'Upgrade',
        49.99,
        '2024-01-01'::DATE,
        '2024-01-01 10:00:00'::TIMESTAMP_NTZ,
        '2024-01-01 10:00:00'::TIMESTAMP_NTZ,
        'BILLING_SYSTEM'
    UNION ALL
    SELECT 
        'BILL003',
        'USR003',
        'Subscription',
        14.99,
        '2024-01-01'::DATE,
        '2024-01-01 11:00:00'::TIMESTAMP_NTZ,
        '2024-01-01 11:00:00'::TIMESTAMP_NTZ,
        'BILLING_SYSTEM'
),

-- Apply deduplication based on EVENT_ID and latest UPDATE_TIMESTAMP
deduped_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EVENT_ID 
            ORDER BY UPDATE_TIMESTAMP DESC, LOAD_TIMESTAMP DESC
        ) as rn
    FROM source_data
),

-- Final transformation with audit columns
final AS (
    SELECT 
        EVENT_ID,
        USER_ID,
        EVENT_TYPE,
        AMOUNT,
        EVENT_DATE,
        LOAD_TIMESTAMP,
        UPDATE_TIMESTAMP,
        SOURCE_SYSTEM
    FROM deduped_data
    WHERE rn = 1
)

SELECT * FROM final
