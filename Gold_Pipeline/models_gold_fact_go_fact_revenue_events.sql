{{ config(
    materialized='table',
    schema='gold',
    tags=['fact', 'revenue_events'],
    unique_key='revenue_event_id'
) }}

-- Revenue events fact table for Gold layer
-- Contains comprehensive billing and revenue analytics

WITH source_billing_events AS (
    SELECT 
        be.EVENT_ID,
        be.USER_ID,
        be.EVENT_TYPE,
        be.AMOUNT,
        be.EVENT_DATE,
        be.LOAD_TIMESTAMP,
        be.UPDATE_TIMESTAMP,
        be.SOURCE_SYSTEM,
        be.LOAD_DATE,
        be.UPDATE_DATE,
        be.DATA_QUALITY_SCORE,
        be.VALIDATION_STATUS
    FROM {{ source('silver', 'SI_BILLING_EVENTS') }} be
    WHERE be.VALIDATION_STATUS = 'VALID'
        AND be.DATA_QUALITY_SCORE >= 0.7
),

user_license_context AS (
    SELECT 
        l.ASSIGNED_TO_USER_ID,
        l.LICENSE_ID,
        l.LICENSE_TYPE,
        l.START_DATE,
        l.END_DATE,
        ROW_NUMBER() OVER (PARTITION BY l.ASSIGNED_TO_USER_ID ORDER BY l.START_DATE DESC) as rn
    FROM {{ source('silver', 'SI_LICENSES') }} l
    WHERE l.VALIDATION_STATUS = 'VALID'
        AND l.DATA_QUALITY_SCORE >= 0.7
),

revenue_events_transformations AS (
    SELECT 
        -- Generate surrogate key for fact table
        {{ dbt_utils.generate_surrogate_key(['be.EVENT_ID']) }} AS revenue_event_id,
        
        -- Dimension keys
        dd.date_id,
        dl.license_id,
        du.user_dim_id,
        
        -- Original IDs
        be.EVENT_ID AS billing_event_id,
        
        -- Date and time fields
        be.EVENT_DATE AS transaction_date,
        COALESCE(be.LOAD_TIMESTAMP, be.EVENT_DATE::TIMESTAMP) AS transaction_timestamp,
        
        -- Event classification
        UPPER(TRIM(be.EVENT_TYPE)) AS event_type,
        
        -- Revenue type classification
        CASE 
            WHEN UPPER(be.EVENT_TYPE) LIKE '%SUBSCRIPTION%' OR UPPER(be.EVENT_TYPE) LIKE '%RECURRING%' THEN 'Subscription'
            WHEN UPPER(be.EVENT_TYPE) LIKE '%UPGRADE%' OR UPPER(be.EVENT_TYPE) LIKE '%UPSELL%' THEN 'Upgrade'
            WHEN UPPER(be.EVENT_TYPE) LIKE '%DOWNGRADE%' THEN 'Downgrade'
            WHEN UPPER(be.EVENT_TYPE) LIKE '%REFUND%' THEN 'Refund'
            WHEN UPPER(be.EVENT_TYPE) LIKE '%CREDIT%' THEN 'Credit'
            WHEN UPPER(be.EVENT_TYPE) LIKE '%PAYMENT%' THEN 'Payment'
            WHEN UPPER(be.EVENT_TYPE) LIKE '%SETUP%' OR UPPER(be.EVENT_TYPE) LIKE '%ONETIME%' THEN 'One-time'
            ELSE 'Other'
        END AS revenue_type,
        
        -- Amount calculations
        be.AMOUNT AS gross_amount,
        
        -- Tax amount (estimated at 8% for taxable transactions)
        CASE 
            WHEN UPPER(be.EVENT_TYPE) NOT LIKE '%REFUND%' AND UPPER(be.EVENT_TYPE) NOT LIKE '%CREDIT%' 
            THEN ROUND(be.AMOUNT * 0.08, 2)
            ELSE 0.00
        END AS tax_amount,
        
        -- Discount amount (estimated based on event type)
        CASE 
            WHEN UPPER(be.EVENT_TYPE) LIKE '%DISCOUNT%' OR UPPER(be.EVENT_TYPE) LIKE '%PROMO%' 
            THEN ROUND(be.AMOUNT * 0.15, 2)
            WHEN UPPER(be.EVENT_TYPE) LIKE '%UPGRADE%' 
            THEN ROUND(be.AMOUNT * 0.05, 2)
            ELSE 0.00
        END AS discount_amount,
        
        -- Net amount calculation
        CASE 
            WHEN UPPER(be.EVENT_TYPE) LIKE '%REFUND%' OR UPPER(be.EVENT_TYPE) LIKE '%CREDIT%' 
            THEN -1 * be.AMOUNT
            ELSE be.AMOUNT - 
                CASE 
                    WHEN UPPER(be.EVENT_TYPE) LIKE '%DISCOUNT%' OR UPPER(be.EVENT_TYPE) LIKE '%PROMO%' 
                    THEN ROUND(be.AMOUNT * 0.15, 2)
                    WHEN UPPER(be.EVENT_TYPE) LIKE '%UPGRADE%' 
                    THEN ROUND(be.AMOUNT * 0.05, 2)
                    ELSE 0.00
                END
        END AS net_amount,
        
        -- Currency and exchange rate
        'USD' AS currency_code,
        1.00 AS exchange_rate,
        
        -- USD amount (same as net_amount since we're assuming USD)
        CASE 
            WHEN UPPER(be.EVENT_TYPE) LIKE '%REFUND%' OR UPPER(be.EVENT_TYPE) LIKE '%CREDIT%' 
            THEN -1 * be.AMOUNT
            ELSE be.AMOUNT - 
                CASE 
                    WHEN UPPER(be.EVENT_TYPE) LIKE '%DISCOUNT%' OR UPPER(be.EVENT_TYPE) LIKE '%PROMO%' 
                    THEN ROUND(be.AMOUNT * 0.15, 2)
                    WHEN UPPER(be.EVENT_TYPE) LIKE '%UPGRADE%' 
                    THEN ROUND(be.AMOUNT * 0.05, 2)
                    ELSE 0.00
                END
        END AS usd_amount,
        
        -- Payment method (estimated based on amount ranges)
        CASE 
            WHEN be.AMOUNT >= 1000 THEN 'Wire Transfer'
            WHEN be.AMOUNT >= 100 THEN 'Credit Card'
            WHEN be.AMOUNT >= 10 THEN 'PayPal'
            ELSE 'Other'
        END AS payment_method,
        
        -- Subscription period (estimated based on license type and amount)
        CASE 
            WHEN UPPER(be.EVENT_TYPE) LIKE '%ANNUAL%' OR be.AMOUNT >= 100 THEN 12
            WHEN UPPER(be.EVENT_TYPE) LIKE '%QUARTERLY%' THEN 3
            ELSE 1
        END AS subscription_period_months,
        
        -- License quantity (estimated)
        CASE 
            WHEN be.AMOUNT >= 500 THEN CEIL(be.AMOUNT / 20)  -- Assume $20 per license for bulk
            WHEN be.AMOUNT >= 50 THEN CEIL(be.AMOUNT / 15)   -- Assume $15 per license for medium
            ELSE 1
        END AS license_quantity,
        
        -- Proration amount (for mid-cycle changes)
        CASE 
            WHEN UPPER(be.EVENT_TYPE) LIKE '%UPGRADE%' OR UPPER(be.EVENT_TYPE) LIKE '%DOWNGRADE%' 
            THEN ROUND(be.AMOUNT * 0.3, 2)  -- Assume 30% is proration
            ELSE 0.00
        END AS proration_amount,
        
        -- Commission amount (estimated at 5% for sales)
        CASE 
            WHEN UPPER(be.EVENT_TYPE) LIKE '%SUBSCRIPTION%' OR UPPER(be.EVENT_TYPE) LIKE '%UPGRADE%' 
            THEN ROUND(be.AMOUNT * 0.05, 2)
            ELSE 0.00
        END AS commission_amount,
        
        -- MRR (Monthly Recurring Revenue) impact
        CASE 
            WHEN UPPER(be.EVENT_TYPE) LIKE '%SUBSCRIPTION%' THEN 
                CASE 
                    WHEN UPPER(be.EVENT_TYPE) LIKE '%ANNUAL%' OR be.AMOUNT >= 100 THEN be.AMOUNT / 12
                    ELSE be.AMOUNT
                END
            WHEN UPPER(be.EVENT_TYPE) LIKE '%UPGRADE%' THEN be.AMOUNT * 0.8  -- Net positive impact
            WHEN UPPER(be.EVENT_TYPE) LIKE '%DOWNGRADE%' THEN be.AMOUNT * -0.5  -- Net negative impact
            WHEN UPPER(be.EVENT_TYPE) LIKE '%REFUND%' THEN -1 * be.AMOUNT
            ELSE 0.00
        END AS mrr_impact,
        
        -- ARR (Annual Recurring Revenue) impact
        CASE 
            WHEN UPPER(be.EVENT_TYPE) LIKE '%SUBSCRIPTION%' THEN be.AMOUNT * 12
            WHEN UPPER(be.EVENT_TYPE) LIKE '%UPGRADE%' THEN be.AMOUNT * 9.6  -- Net positive impact
            WHEN UPPER(be.EVENT_TYPE) LIKE '%DOWNGRADE%' THEN be.AMOUNT * -6  -- Net negative impact
            WHEN UPPER(be.EVENT_TYPE) LIKE '%REFUND%' THEN -1 * be.AMOUNT * 12
            ELSE 0.00
        END AS arr_impact,
        
        -- Customer Lifetime Value (estimated)
        CASE 
            WHEN UPPER(be.EVENT_TYPE) LIKE '%SUBSCRIPTION%' THEN be.AMOUNT * 24  -- 2 years average
            WHEN UPPER(be.EVENT_TYPE) LIKE '%UPGRADE%' THEN be.AMOUNT * 18
            ELSE be.AMOUNT * 6
        END AS customer_lifetime_value,
        
        -- Churn risk score (0-100, higher = more risk)
        CASE 
            WHEN UPPER(be.EVENT_TYPE) LIKE '%DOWNGRADE%' THEN 75
            WHEN UPPER(be.EVENT_TYPE) LIKE '%REFUND%' THEN 90
            WHEN UPPER(be.EVENT_TYPE) LIKE '%CREDIT%' THEN 60
            WHEN be.AMOUNT < 10 THEN 40
            ELSE 20
        END AS churn_risk_score,
        
        -- Payment status
        CASE 
            WHEN UPPER(be.EVENT_TYPE) LIKE '%REFUND%' THEN 'Refunded'
            WHEN UPPER(be.EVENT_TYPE) LIKE '%FAILED%' THEN 'Failed'
            WHEN be.DATA_QUALITY_SCORE >= 0.9 THEN 'Completed'
            ELSE 'Pending'
        END AS payment_status,
        
        -- Refund reason (for refund events)
        CASE 
            WHEN UPPER(be.EVENT_TYPE) LIKE '%REFUND%' THEN 
                CASE 
                    WHEN be.AMOUNT > 100 THEN 'Service Dissatisfaction'
                    WHEN be.AMOUNT > 50 THEN 'Technical Issues'
                    ELSE 'Billing Error'
                END
            ELSE NULL
        END AS refund_reason,
        
        -- Sales channel
        CASE 
            WHEN be.AMOUNT >= 1000 THEN 'Enterprise Sales'
            WHEN be.AMOUNT >= 100 THEN 'Inside Sales'
            ELSE 'Self-Service'
        END AS sales_channel,
        
        -- Promotion code (estimated)
        CASE 
            WHEN UPPER(be.EVENT_TYPE) LIKE '%DISCOUNT%' OR UPPER(be.EVENT_TYPE) LIKE '%PROMO%' 
            THEN 'PROMO2024'
            ELSE NULL
        END AS promotion_code,
        
        -- Audit fields
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        be.SOURCE_SYSTEM AS source_system
        
    FROM source_billing_events be
    LEFT JOIN user_license_context ulc ON be.USER_ID = ulc.ASSIGNED_TO_USER_ID AND ulc.rn = 1
    
    -- Join with dimension tables
    LEFT JOIN {{ ref('go_dim_date') }} dd ON be.EVENT_DATE = dd.date_value
    LEFT JOIN {{ ref('go_dim_license') }} dl ON ulc.LICENSE_ID = dl.license_id
    LEFT JOIN {{ ref('go_dim_user') }} du ON be.USER_ID = du.user_id AND du.is_current_record = TRUE
)

SELECT 
    revenue_event_id,
    date_id,
    license_id,
    user_dim_id,
    billing_event_id,
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
FROM revenue_events_transformations
ORDER BY transaction_date DESC, transaction_timestamp DESC