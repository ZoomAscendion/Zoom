{{ config(
    materialized='table',
    tags=['fact'],
    cluster_by=['TRANSACTION_DATE', 'REVENUE_TYPE']
) }}

-- Revenue events fact table with comprehensive financial metrics
-- Transforms Silver billing data with revenue recognition and KPI calculations

WITH billing_base AS (
    SELECT 
        be.event_id,
        be.user_id,
        be.event_type,
        be.amount,
        be.event_date,
        be.source_system
    FROM {{ source('silver', 'si_billing_events') }} be
    WHERE be.validation_status = 'PASSED'
      AND be.data_quality_score >= 80
      AND be.amount > 0
),

user_context AS (
    SELECT 
        u.user_id,
        u.plan_type
    FROM {{ source('silver', 'si_users') }} u
    WHERE u.validation_status = 'PASSED'
      AND u.data_quality_score >= 80
),

license_context AS (
    SELECT 
        l.assigned_to_user_id,
        l.license_type
    FROM {{ source('silver', 'si_licenses') }} l
    WHERE l.validation_status = 'PASSED'
      AND l.data_quality_score >= 80
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY bb.event_date, bb.event_id) AS revenue_event_id,
    
    -- Date and time dimensions
    bb.event_date AS transaction_date,
    CURRENT_TIMESTAMP() AS transaction_timestamp,
    
    -- Event classification
    bb.event_type,
    
    -- Revenue type classification
    CASE 
        WHEN UPPER(bb.event_type) LIKE '%SUBSCRIPTION%' THEN 'Recurring'
        WHEN UPPER(bb.event_type) LIKE '%UPGRADE%' THEN 'Expansion'
        WHEN UPPER(bb.event_type) LIKE '%ADDON%' THEN 'Add-on'
        ELSE 'One-time'
    END AS revenue_type,
    
    -- Amount calculations
    bb.amount AS gross_amount,
    
    -- Tax calculation (8% standard rate)
    bb.amount * 0.08 AS tax_amount,
    
    -- Discount calculation based on plan type
    CASE 
        WHEN uc.plan_type = 'Enterprise' THEN bb.amount * 0.15
        WHEN uc.plan_type = 'Pro' THEN bb.amount * 0.10
        ELSE 0
    END AS discount_amount,
    
    -- Net amount after tax and discount
    bb.amount - (bb.amount * 0.08) - 
    CASE 
        WHEN uc.plan_type = 'Enterprise' THEN bb.amount * 0.15
        WHEN uc.plan_type = 'Pro' THEN bb.amount * 0.10
        ELSE 0
    END AS net_amount,
    
    -- Currency standardization
    'USD' AS currency_code,
    1.0 AS exchange_rate,
    bb.amount AS usd_amount,
    
    -- Payment method estimation
    CASE 
        WHEN bb.amount > 1000 THEN 'Bank Transfer'
        WHEN bb.amount > 100 THEN 'Credit Card'
        ELSE 'PayPal'
    END AS payment_method,
    
    'Completed' AS payment_status,
    
    -- Subscription period
    CASE 
        WHEN lc.license_type LIKE '%annual%' THEN 12
        WHEN lc.license_type LIKE '%monthly%' THEN 1
        ELSE 12
    END AS subscription_period_months,
    
    -- Recurring revenue flag
    CASE 
        WHEN UPPER(bb.event_type) LIKE '%SUBSCRIPTION%' OR UPPER(bb.event_type) LIKE '%RENEWAL%' THEN TRUE
        ELSE FALSE
    END AS is_recurring_revenue,
    
    -- Customer Lifetime Value calculation
    CASE 
        WHEN uc.plan_type = 'Enterprise' THEN bb.amount * 24
        WHEN uc.plan_type = 'Pro' THEN bb.amount * 18
        WHEN uc.plan_type = 'Basic' THEN bb.amount * 12
        ELSE bb.amount * 6
    END AS customer_lifetime_value,
    
    -- MRR Impact calculation
    CASE 
        WHEN UPPER(bb.event_type) LIKE '%SUBSCRIPTION%' AND lc.license_type LIKE '%monthly%' THEN bb.amount
        WHEN UPPER(bb.event_type) LIKE '%SUBSCRIPTION%' AND lc.license_type LIKE '%annual%' THEN bb.amount / 12
        ELSE 0
    END AS mrr_impact,
    
    -- ARR Impact calculation
    CASE 
        WHEN UPPER(bb.event_type) LIKE '%SUBSCRIPTION%' THEN 
            CASE 
                WHEN lc.license_type LIKE '%monthly%' THEN bb.amount * 12
                ELSE bb.amount
            END
        ELSE 0
    END AS arr_impact,
    
    -- Commission calculation (5% standard)
    bb.amount * 0.05 AS commission_amount,
    
    -- Metadata columns
    CURRENT_DATE() AS load_date,
    CURRENT_DATE() AS update_date,
    bb.source_system
    
FROM billing_base bb
LEFT JOIN user_context uc ON bb.user_id = uc.user_id
LEFT JOIN license_context lc ON bb.user_id = lc.assigned_to_user_id
ORDER BY bb.event_date, bb.event_id
