/*
  go_fact_revenue_events.sql
  Zoom Platform Analytics System - Revenue Events Fact Table
  
  Author: Data Engineering Team
  Description: Fact table capturing all revenue-generating events and financial transactions
  
  This model creates comprehensive revenue facts with financial metrics,
  subscription analysis, and revenue recognition calculations.
*/

{{ config(
    materialized='table',
    tags=['fact', 'revenue_events'],
    cluster_by=['transaction_date']
) }}

-- Base billing events data with quality filters
WITH base_billing_events AS (
    SELECT 
        event_id,
        user_id,
        UPPER(TRIM(COALESCE(event_type, 'UNKNOWN'))) AS event_type,
        amount,
        event_date,
        source_system,
        load_date,
        update_date,
        data_quality_score,
        validation_status
    FROM {{ source('silver', 'si_billing_events') }}
    WHERE validation_status = 'PASSED'
        AND data_quality_score >= {{ var('min_data_quality_score') }}
        AND amount IS NOT NULL
        AND amount > 0
),

-- Get user context for revenue events
user_context AS (
    SELECT 
        user_id,
        plan_type,
        company,
        email
    FROM {{ source('silver', 'si_users') }}
    WHERE validation_status = 'PASSED'
        AND is_current_record = TRUE
),

-- Get license context for subscription analysis
license_context AS (
    SELECT 
        assigned_to_user_id,
        license_type,
        start_date,
        end_date
    FROM {{ source('silver', 'si_licenses') }}
    WHERE validation_status = 'PASSED'
),

-- Revenue events fact with calculated metrics
revenue_events_fact AS (
    SELECT 
        b.event_id,
        b.event_date AS transaction_date,
        
        -- Create transaction timestamp (estimated)
        b.event_date::TIMESTAMP_NTZ + 
        INTERVAL '9 HOUR' + 
        INTERVAL '0 MINUTE' * FLOOR(RANDOM() * 480) AS transaction_timestamp,  -- Random time during business hours
        
        b.event_type,
        
        -- Revenue type classification
        CASE 
            WHEN b.event_type LIKE '%SUBSCRIPTION%' OR b.event_type LIKE '%RECURRING%' THEN 'Subscription Revenue'
            WHEN b.event_type LIKE '%UPGRADE%' OR b.event_type LIKE '%UPSELL%' THEN 'Expansion Revenue'
            WHEN b.event_type LIKE '%SETUP%' OR b.event_type LIKE '%ONETIME%' THEN 'One-time Revenue'
            WHEN b.event_type LIKE '%REFUND%' OR b.event_type LIKE '%CHARGEBACK%' THEN 'Revenue Adjustment'
            WHEN b.event_type LIKE '%TRIAL%' THEN 'Trial Conversion'
            ELSE 'Other Revenue'
        END AS revenue_type,
        
        -- Financial amounts
        b.amount AS gross_amount,
        
        -- Tax calculation (estimated at 8.5%)
        ROUND(b.amount * 0.085, 2) AS tax_amount,
        
        -- Discount calculation (estimated based on event type)
        CASE 
            WHEN b.event_type LIKE '%DISCOUNT%' OR b.event_type LIKE '%PROMO%' THEN ROUND(b.amount * 0.15, 2)
            WHEN b.event_type LIKE '%ANNUAL%' THEN ROUND(b.amount * 0.10, 2)  -- Annual discount
            WHEN b.event_type LIKE '%ENTERPRISE%' THEN ROUND(b.amount * 0.05, 2)  -- Enterprise discount
            ELSE 0.00
        END AS discount_amount,
        
        -- Net amount calculation
        b.amount - 
        CASE 
            WHEN b.event_type LIKE '%DISCOUNT%' OR b.event_type LIKE '%PROMO%' THEN ROUND(b.amount * 0.15, 2)
            WHEN b.event_type LIKE '%ANNUAL%' THEN ROUND(b.amount * 0.10, 2)
            WHEN b.event_type LIKE '%ENTERPRISE%' THEN ROUND(b.amount * 0.05, 2)
            ELSE 0.00
        END AS net_amount,
        
        -- Currency and exchange rate (assuming USD base)
        'USD' AS currency_code,
        1.0000 AS exchange_rate,
        b.amount AS usd_amount,
        
        -- Payment method (estimated based on amount and user type)
        CASE 
            WHEN b.amount >= 1000 THEN 'Wire Transfer'
            WHEN b.amount >= 500 THEN 'ACH'
            WHEN b.amount >= 100 THEN 'Credit Card'
            ELSE 'PayPal'
        END AS payment_method,
        
        -- Payment status (mostly successful for processed events)
        CASE 
            WHEN b.event_type LIKE '%REFUND%' OR b.event_type LIKE '%CHARGEBACK%' THEN 'Refunded'
            WHEN b.event_type LIKE '%FAILED%' OR b.event_type LIKE '%DECLINED%' THEN 'Failed'
            ELSE 'Completed'
        END AS payment_status,
        
        -- Subscription period (estimated based on event type and amount)
        CASE 
            WHEN b.event_type LIKE '%MONTHLY%' THEN 1
            WHEN b.event_type LIKE '%QUARTERLY%' THEN 3
            WHEN b.event_type LIKE '%ANNUAL%' OR b.event_type LIKE '%YEARLY%' THEN 12
            WHEN b.amount >= 500 THEN 12  -- High amounts likely annual
            WHEN b.amount >= 50 THEN 1    -- Medium amounts likely monthly
            ELSE 1
        END AS subscription_period_months,
        
        -- Recurring revenue flag
        CASE 
            WHEN b.event_type LIKE '%SUBSCRIPTION%' OR b.event_type LIKE '%RECURRING%' THEN TRUE
            WHEN b.event_type LIKE '%MONTHLY%' OR b.event_type LIKE '%ANNUAL%' THEN TRUE
            ELSE FALSE
        END AS is_recurring_revenue,
        
        -- Customer lifetime value (estimated based on plan type and amount)
        CASE 
            WHEN COALESCE(u.plan_type, 'BASIC') LIKE '%ENTERPRISE%' THEN b.amount * 24  -- 2 years
            WHEN COALESCE(u.plan_type, 'BASIC') LIKE '%BUSINESS%' THEN b.amount * 18   -- 1.5 years
            WHEN COALESCE(u.plan_type, 'BASIC') LIKE '%PRO%' THEN b.amount * 12       -- 1 year
            ELSE b.amount * 6  -- 6 months for basic
        END AS customer_lifetime_value,
        
        -- MRR (Monthly Recurring Revenue) impact
        CASE 
            WHEN b.event_type LIKE '%SUBSCRIPTION%' OR b.event_type LIKE '%RECURRING%' THEN
                CASE 
                    WHEN b.event_type LIKE '%ANNUAL%' THEN ROUND(b.amount / 12, 2)
                    WHEN b.event_type LIKE '%QUARTERLY%' THEN ROUND(b.amount / 3, 2)
                    ELSE b.amount
                END
            WHEN b.event_type LIKE '%REFUND%' THEN -b.amount
            ELSE 0.00
        END AS mrr_impact,
        
        -- ARR (Annual Recurring Revenue) impact
        CASE 
            WHEN b.event_type LIKE '%SUBSCRIPTION%' OR b.event_type LIKE '%RECURRING%' THEN
                CASE 
                    WHEN b.event_type LIKE '%ANNUAL%' THEN b.amount
                    WHEN b.event_type LIKE '%QUARTERLY%' THEN b.amount * 4
                    ELSE b.amount * 12
                END
            WHEN b.event_type LIKE '%REFUND%' THEN -b.amount * 12
            ELSE 0.00
        END AS arr_impact,
        
        -- Commission calculation (estimated at 5% for sales team)
        CASE 
            WHEN b.event_type LIKE '%SUBSCRIPTION%' OR b.event_type LIKE '%UPGRADE%' THEN
                ROUND(b.amount * 0.05, 2)
            ELSE 0.00
        END AS commission_amount,
        
        -- Metadata
        b.load_date,
        b.update_date,
        b.source_system
        
    FROM base_billing_events b
    LEFT JOIN user_context u ON b.user_id = u.user_id
    LEFT JOIN license_context l ON b.user_id = l.assigned_to_user_id
),

-- Final fact table with surrogate key
final_fact AS (
    SELECT 
        -- Generate surrogate key
        ROW_NUMBER() OVER (ORDER BY transaction_date, transaction_timestamp) AS revenue_event_id,
        
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
        payment_status,
        subscription_period_months,
        is_recurring_revenue,
        customer_lifetime_value,
        mrr_impact,
        arr_impact,
        commission_amount,
        load_date,
        update_date,
        source_system
        
    FROM revenue_events_fact
)

SELECT 
    revenue_event_id,
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
    payment_status,
    subscription_period_months,
    is_recurring_revenue,
    customer_lifetime_value,
    mrr_impact,
    arr_impact,
    commission_amount,
    load_date,
    update_date,
    source_system
FROM final_fact
ORDER BY revenue_event_id