-- Bronze Layer Billing Events Model
-- Description: Raw billing events data from source systems
-- Source: RAW.BILLING_EVENTS
-- Author: Data Engineering Team
-- Created: {{ run_started_at }}

{{ config(
    materialized='table',
    tags=['bronze', 'billing_events'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'dbt_user', 'STARTED' WHERE '{{ this.name }}' != 'bz_data_audit'",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) SELECT 'BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), 'dbt_user', 1.0, 'SUCCESS' WHERE '{{ this.name }}' != 'bz_data_audit'"
) }}

-- CTE to select and filter raw data
WITH raw_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        CASE 
            WHEN amount IS NOT NULL AND amount != '' 
            THEN TRY_CAST(amount AS NUMBER(10,2))
            ELSE NULL 
        END AS amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'billing_events') }}
    WHERE event_id IS NOT NULL  -- Filter out NULL primary keys
      AND user_id IS NOT NULL  -- Filter out NULL required fields
),

-- CTE for deduplication based on primary key and latest timestamp
deduped_billing_events AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY event_id 
            ORDER BY COALESCE(update_timestamp, load_timestamp) DESC
        ) AS row_num
    FROM raw_billing_events
)

-- Final selection with Bronze timestamp overwrite
SELECT 
    event_id,
    user_id,
    event_type,
    amount,
    event_date,
    CURRENT_TIMESTAMP() AS load_timestamp,  -- Overwrite with current DBT run time
    CURRENT_TIMESTAMP() AS update_timestamp, -- Overwrite with current DBT run time
    source_system
FROM deduped_billing_events
WHERE row_num = 1
