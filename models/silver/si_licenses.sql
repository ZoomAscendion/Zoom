{{
  config(
    materialized='incremental',
    unique_key='license_id',
    on_schema_change='sync_all_columns',
    incremental_strategy='merge'
  )
}}

-- Silver Licenses Table Transformation
-- Transforms bronze license data with validation and derived attributes

WITH bronze_licenses AS (
    SELECT 
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system
    FROM {{ source('bronze', 'bz_licenses') }}
    WHERE license_type IS NOT NULL 
      AND assigned_to_user_id IS NOT NULL
      AND start_date IS NOT NULL
      AND license_type IN ('Basic', 'Pro', 'Enterprise', 'Add-on')
      AND (end_date IS NULL OR end_date >= start_date)
),

deduped_licenses AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY license_type, assigned_to_user_id, start_date 
            ORDER BY update_timestamp DESC, load_timestamp DESC
        ) AS row_num
    FROM bronze_licenses
),

transformed_licenses AS (
    SELECT 
        -- Primary Key Generation
        {{ dbt_utils.generate_surrogate_key(['license_type', 'assigned_to_user_id', 'start_date']) }} AS license_id,
        
        -- Direct Mappings
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        
        -- Derived Attributes
        CASE 
            WHEN end_date IS NULL OR end_date >= CURRENT_DATE() THEN 'Active'
            WHEN end_date < CURRENT_DATE() THEN 'Expired'
            ELSE 'Suspended'
        END AS license_status,
        
        COALESCE(DATEDIFF(day, start_date, COALESCE(end_date, CURRENT_DATE())), 0) AS license_duration_days,
        
        FALSE AS renewal_flag,  -- Simplified for now
        
        -- Audit Fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system,
        load_timestamp,
        update_timestamp,
        
        -- Data Quality Score Calculation
        ROUND(
            (CASE WHEN license_type IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN assigned_to_user_id IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN start_date IS NOT NULL THEN 0.25 ELSE 0 END +
             CASE WHEN end_date IS NULL OR end_date >= start_date THEN 0.25 ELSE 0 END), 2
        ) AS data_quality_score
        
    FROM deduped_licenses
    WHERE row_num = 1
)

SELECT * FROM transformed_licenses

{% if is_incremental() %}
  WHERE update_timestamp > (SELECT COALESCE(MAX(update_timestamp), '1900-01-01') FROM {{ this }})
{% endif %}
