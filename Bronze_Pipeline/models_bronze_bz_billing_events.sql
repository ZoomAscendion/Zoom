{{ config(
    materialized='incremental',
    unique_key='event_id',
    on_schema_change='fail',
    tags=['bronze', 'billing_events', 'financial'],
    pre_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), '{{ this.name }}', 0.0, 'STARTED')",
    post_hook="INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, processing_time, status) VALUES ('BZ_BILLING_EVENTS', CURRENT_TIMESTAMP(), '{{ this.name }}', DATEDIFF('second', (SELECT MAX(load_timestamp) FROM {{ ref('bz_data_audit') }} WHERE source_table = 'BZ_BILLING_EVENTS' AND status = 'STARTED'), CURRENT_TIMESTAMP()), 'SUCCESS')"
) }}

/*
    Bronze Layer Billing Events Model
    Purpose: Raw billing event data from source systems with metadata enrichment
    Author: AAVA
    Created: {{ run_started_at }}
    
    Financial Data: AMOUNT field contains sensitive financial information
*/

WITH source_data AS (
    SELECT
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('raw', 'billing_events') }}
    
    {% if is_incremental() %}
        WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
    {% endif %}
),

deduped_data AS (
    SELECT
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        COALESCE(load_timestamp, CURRENT_TIMESTAMP()) AS load_timestamp,
        COALESCE(update_timestamp, CURRENT_TIMESTAMP()) AS update_timestamp,
        COALESCE(source_system, 'UNKNOWN') AS source_system,
        ROW_NUMBER() OVER (
            PARTITION BY event_id 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM source_data
    WHERE event_id IS NOT NULL  -- Primary key validation
),

data_quality_checks AS (
    SELECT
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system,
        -- Data quality validations
        CASE 
            WHEN user_id IS NULL 
            THEN 'MISSING_USER_ID'
            WHEN event_date IS NOT NULL AND event_date > CURRENT_DATE() 
            THEN 'FUTURE_EVENT_DATE'
            WHEN event_type IS NULL 
            THEN 'MISSING_EVENT_TYPE'
            WHEN amount IS NOT NULL AND amount < 0 AND event_type NOT IN ('REFUND', 'CREDIT', 'ADJUSTMENT') 
            THEN 'INVALID_NEGATIVE_AMOUNT'
            ELSE 'VALID'
        END AS data_quality_flag
    FROM deduped_data
    WHERE row_num = 1
),

final AS (
    SELECT
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM data_quality_checks
    WHERE data_quality_flag = 'VALID'  -- Only include valid records
)

SELECT
    event_id,
    user_id,
    event_type,
    amount,
    event_date,
    load_timestamp,
    update_timestamp,
    source_system
FROM final

-- Data quality logging
{% if execute %}
    {% set row_count_query %}
        SELECT COUNT(*) as row_count FROM ({{ sql }})
    {% endset %}
    
    {% set results = run_query(row_count_query) %}
    {% if results %}
        {{ log("BZ_BILLING_EVENTS: Processing " ~ results.columns[0].values()[0] ~ " rows", info=True) }}
    {% endif %}
{% endif %}