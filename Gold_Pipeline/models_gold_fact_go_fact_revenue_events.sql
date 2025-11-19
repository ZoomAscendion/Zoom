{{ config(
    materialized='table',
    schema='gold',
    database='DB_POC_ZOOM',
    tags=['fact', 'revenue_events']
) }}

-- Revenue events fact table
-- Comprehensive financial analytics with subscription and billing metrics

WITH source_billing_events AS (
    SELECT 
        be.event_id,
        be.user_id,
        be.event_type,
        be.amount,
        be.event_date,
        be.load_timestamp,
        be.update_timestamp,
        be.source_system,
        be.load_date,
        be.update_date,
        be.data_quality_score,
        be.validation_status
    FROM {{ source('silver_layer', 'si_billing_events') }} be
    WHERE be.validation_status = 'VALID'
      AND be.data_quality_score >= {{ var('data_quality_threshold') }}
      AND be.amount IS NOT NULL
),

license_context AS (
    SELECT 
        l.license_id,
        l.license_type,
        l.assigned_to_user_id,
        l.start_date,
        l.end_date,
        dl.monthly_price,
        dl.annual_price,
        dl.license_category
    FROM {{ source('silver_layer', 'si_licenses') }} l
    LEFT JOIN {{ ref('go_dim_license') }} dl ON l.license_id = dl.license_id 
        AND dl.is_current_record = TRUE
    WHERE l.validation_status = 'VALID'
),

user_context AS (
    SELECT 
        u.user_id,
        u.plan_type,
        u.company,
        du.geographic_region,
        du.industry_sector,
        du.user_dim_id
    FROM {{ source('silver_layer', 'si_users') }} u
    LEFT JOIN {{ ref('go_dim_user') }} du ON u.user_id = du.user_id 
        AND du.is_current_record = TRUE
    WHERE u.validation_status = 'VALID'
),

revenue_events_enriched AS (
    SELECT 
        be.event_id,
        be.user_id,
        be.event_type,
        be.amount,
        be.event_date,
        be.load_timestamp AS transaction_timestamp,
        
        -- Dimension keys
        dd.date_id,
        lc.license_id,
        uc.user_dim_id,
        
        -- Transaction details
        DATE(be.event_date) AS transaction_date,
        
        -- Revenue type classification
        CASE 
            WHEN UPPER(be.event_type) LIKE '%SUBSCRIPTION%' OR UPPER(be.event_type) LIKE '%RECURRING%' THEN 'Subscription'
            WHEN UPPER(be.event_type) LIKE '%UPGRADE%' OR UPPER(be.event_type) LIKE '%UPSELL%' THEN 'Upgrade'
            WHEN UPPER(be.event_type) LIKE '%ONETIME%' OR UPPER(be.event_type) LIKE '%PURCHASE%' THEN 'One-time'
            WHEN UPPER(be.event_type) LIKE '%REFUND%' OR UPPER(be.event_type) LIKE '%CHARGEBACK%' THEN 'Refund'
            WHEN UPPER(be.event_type) LIKE '%TRIAL%' THEN 'Trial'
            ELSE 'Other'
        END AS revenue_type,
        
        -- Financial calculations
        be.amount AS gross_amount,
        
        -- Tax amount (estimated at 8%)
        ROUND(be.amount * 0.08, 2) AS tax_amount,
        
        -- Discount amount (estimated based on event type)
        CASE 
            WHEN UPPER(be.event_type) LIKE '%DISCOUNT%' OR UPPER(be.event_type) LIKE '%PROMO%' 
            THEN ROUND(be.amount * 0.15, 2)
            WHEN UPPER(be.event_type) LIKE '%ANNUAL%' THEN ROUND(be.amount * 0.10, 2)
            ELSE 0.00
        END AS discount_amount,
        
        -- Net amount calculation
        be.amount - ROUND(be.amount * 0.08, 2) - 
        CASE 
            WHEN UPPER(be.event_type) LIKE '%DISCOUNT%' OR UPPER(be.event_type) LIKE '%PROMO%' 
            THEN ROUND(be.amount * 0.15, 2)
            WHEN UPPER(be.event_type) LIKE '%ANNUAL%' THEN ROUND(be.amount * 0.10, 2)
            ELSE 0.00
        END AS net_amount,
        
        -- Currency and exchange
        'USD' AS currency_code,
        1.00 AS exchange_rate,
        be.amount AS usd_amount,
        
        -- Payment method (estimated)
        CASE 
            WHEN be.amount >= 100 THEN 'Credit Card'
            WHEN be.amount >= 50 THEN 'Bank Transfer'
            ELSE 'PayPal'
        END AS payment_method,
        
        -- Subscription period
        CASE 
            WHEN UPPER(be.event_type) LIKE '%ANNUAL%' OR UPPER(be.event_type) LIKE '%YEARLY%' THEN 12
            WHEN UPPER(be.event_type) LIKE '%QUARTERLY%' THEN 3
            WHEN UPPER(be.event_type) LIKE '%MONTHLY%' OR UPPER(be.event_type) LIKE '%SUBSCRIPTION%' THEN 1
            ELSE 1
        END AS subscription_period_months,
        
        -- License quantity (estimated)
        CASE 
            WHEN uc.plan_type = 'Enterprise' THEN FLOOR(be.amount / 19.99)
            WHEN uc.plan_type = 'Pro' THEN FLOOR(be.amount / 14.99)
            ELSE 1
        END AS license_quantity,
        
        -- Proration amount (estimated)
        CASE 
            WHEN UPPER(be.event_type) LIKE '%UPGRADE%' OR UPPER(be.event_type) LIKE '%PRORATE%' 
            THEN ROUND(be.amount * 0.20, 2)
            ELSE 0.00
        END AS proration_amount,
        
        -- Commission amount (estimated at 5%)
        ROUND(be.amount * 0.05, 2) AS commission_amount,
        
        -- MRR and ARR impact
        CASE 
            WHEN UPPER(be.event_type) LIKE '%SUBSCRIPTION%' OR UPPER(be.event_type) LIKE '%MONTHLY%' 
            THEN be.amount
            WHEN UPPER(be.event_type) LIKE '%ANNUAL%' THEN ROUND(be.amount / 12, 2)
            WHEN UPPER(be.event_type) LIKE '%REFUND%' THEN -be.amount
            ELSE 0.00
        END AS mrr_impact,
        
        CASE 
            WHEN UPPER(be.event_type) LIKE '%SUBSCRIPTION%' OR UPPER(be.event_type) LIKE '%MONTHLY%' 
            THEN be.amount * 12
            WHEN UPPER(be.event_type) LIKE '%ANNUAL%' THEN be.amount
            WHEN UPPER(be.event_type) LIKE '%REFUND%' THEN -be.amount * 12
            ELSE 0.00
        END AS arr_impact,
        
        -- Customer lifetime value (estimated)
        CASE 
            WHEN uc.plan_type = 'Enterprise' THEN be.amount * 24
            WHEN uc.plan_type = 'Pro' THEN be.amount * 18
            WHEN uc.plan_type = 'Basic' THEN be.amount * 12
            ELSE be.amount * 6
        END AS customer_lifetime_value,
        
        -- Churn risk score (estimated)
        CASE 
            WHEN UPPER(be.event_type) LIKE '%REFUND%' OR UPPER(be.event_type) LIKE '%CANCEL%' THEN 90
            WHEN UPPER(be.event_type) LIKE '%DOWNGRADE%' THEN 70
            WHEN UPPER(be.event_type) LIKE '%TRIAL%' THEN 50
            WHEN UPPER(be.event_type) LIKE '%UPGRADE%' THEN 10
            ELSE 30
        END AS churn_risk_score,
        
        -- Payment status
        CASE 
            WHEN UPPER(be.event_type) LIKE '%REFUND%' OR UPPER(be.event_type) LIKE '%FAILED%' THEN 'Failed'
            WHEN UPPER(be.event_type) LIKE '%PENDING%' THEN 'Pending'
            ELSE 'Completed'
        END AS payment_status,
        
        -- Refund reason
        CASE 
            WHEN UPPER(be.event_type) LIKE '%REFUND%' THEN 'Customer Request'
            WHEN UPPER(be.event_type) LIKE '%CHARGEBACK%' THEN 'Chargeback'
            WHEN UPPER(be.event_type) LIKE '%FAILED%' THEN 'Payment Failed'
            ELSE NULL
        END AS refund_reason,
        
        -- Sales channel (estimated)
        CASE 
            WHEN uc.industry_sector = 'Technology' THEN 'Direct Sales'
            WHEN uc.industry_sector = 'Education' THEN 'Education Channel'
            WHEN be.amount >= 100 THEN 'Enterprise Sales'
            ELSE 'Online Self-Service'
        END AS sales_channel,
        
        -- Promotion code (estimated)
        CASE 
            WHEN UPPER(be.event_type) LIKE '%DISCOUNT%' OR UPPER(be.event_type) LIKE '%PROMO%' 
            THEN 'PROMO2024'
            WHEN UPPER(be.event_type) LIKE '%ANNUAL%' THEN 'ANNUAL20'
            ELSE NULL
        END AS promotion_code,
        
        -- Audit fields
        be.load_date,
        be.update_date,
        be.source_system
        
    FROM source_billing_events be
    LEFT JOIN license_context lc ON be.user_id = lc.assigned_to_user_id
    LEFT JOIN user_context uc ON be.user_id = uc.user_id
    LEFT JOIN {{ ref('go_dim_date') }} dd ON be.event_date = dd.date_value
)

SELECT 
    MD5(CONCAT(event_id, '_', transaction_timestamp::STRING)) AS revenue_event_id,
    date_id,
    license_id,
    user_dim_id,
    event_id AS billing_event_id,
    transaction_date,
    transaction_timestamp,
    event_type,
    revenue_type,
    gross_amount,
    tax_amount,
    discount_amount,
    net_amount,
    currency_code,
    exchange_rate,
    usd_amount,
    payment_method,
    subscription_period_months,
    license_quantity,
    proration_amount,
    commission_amount,
    mrr_impact,
    arr_impact,
    customer_lifetime_value,
    churn_risk_score,
    payment_status,
    refund_reason,
    sales_channel,
    promotion_code,
    load_date,
    update_date,
    source_system
FROM revenue_events_enriched
WHERE date_id IS NOT NULL
ORDER BY transaction_date DESC, transaction_timestamp DESC