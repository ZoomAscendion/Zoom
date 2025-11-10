{{ config(
    materialized='table',
    cluster_by=['TRANSACTION_DATE', 'REVENUE_TYPE'],
    tags=['fact', 'revenue']
) }}

-- Revenue events fact table capturing financial transactions and metrics
-- Implements proper revenue recognition and business calculations

WITH source_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system,
        validation_status,
        data_quality_score
    FROM {{ source('silver', 'si_billing_events') }}
    WHERE validation_status = {{ var('validation_status_filter') }}
        AND data_quality_score >= {{ var('data_quality_threshold') }}
        AND amount > 0
),

user_context AS (
    SELECT 
        user_id,
        plan_type,
        company
    FROM {{ source('silver', 'si_users') }}
    WHERE validation_status = {{ var('validation_status_filter') }}
        AND data_quality_score >= {{ var('data_quality_threshold') }}
),

license_context AS (
    SELECT 
        assigned_to_user_id,
        license_type,
        start_date,
        end_date
    FROM {{ source('silver', 'si_licenses') }}
    WHERE validation_status = {{ var('validation_status_filter') }}
        AND data_quality_score >= {{ var('data_quality_threshold') }}
),

revenue_calculations AS (
    SELECT 
        be.event_id,
        be.event_date AS transaction_date,
        CURRENT_TIMESTAMP() AS transaction_timestamp,
        be.event_type,
        
        -- Revenue type classification
        CASE 
            WHEN UPPER(be.event_type) LIKE '%SUBSCRIPTION%' OR UPPER(be.event_type) LIKE '%RENEWAL%' THEN 'Recurring'
            WHEN UPPER(be.event_type) LIKE '%UPGRADE%' OR UPPER(be.event_type) LIKE '%UPSELL%' THEN 'Expansion'
            WHEN UPPER(be.event_type) LIKE '%ADDON%' OR UPPER(be.event_type) LIKE '%ADD-ON%' THEN 'Add-on'
            WHEN UPPER(be.event_type) LIKE '%SETUP%' OR UPPER(be.event_type) LIKE '%ONETIME%' THEN 'One-time'
            ELSE 'Other'
        END AS revenue_type,
        
        be.amount AS gross_amount,
        
        -- Tax calculation (8% standard rate)
        be.amount * 0.08 AS tax_amount,
        
        -- Discount calculation based on plan type
        CASE 
            WHEN UPPER(COALESCE(uc.plan_type, '')) = 'ENTERPRISE' THEN be.amount * 0.15
            WHEN UPPER(COALESCE(uc.plan_type, '')) = 'BUSINESS' THEN be.amount * 0.12
            WHEN UPPER(COALESCE(uc.plan_type, '')) = 'PRO' THEN be.amount * 0.08
            WHEN UPPER(COALESCE(uc.plan_type, '')) = 'BASIC' THEN be.amount * 0.05
            ELSE 0
        END AS discount_amount,
        
        -- Net amount calculation
        be.amount - (be.amount * 0.08) - 
        CASE 
            WHEN UPPER(COALESCE(uc.plan_type, '')) = 'ENTERPRISE' THEN be.amount * 0.15
            WHEN UPPER(COALESCE(uc.plan_type, '')) = 'BUSINESS' THEN be.amount * 0.12
            WHEN UPPER(COALESCE(uc.plan_type, '')) = 'PRO' THEN be.amount * 0.08
            WHEN UPPER(COALESCE(uc.plan_type, '')) = 'BASIC' THEN be.amount * 0.05
            ELSE 0
        END AS net_amount,
        
        'USD' AS currency_code,
        1.0 AS exchange_rate,
        be.amount AS usd_amount,
        
        -- Payment method estimation based on amount
        CASE 
            WHEN be.amount >= 5000 THEN 'Wire Transfer'
            WHEN be.amount >= 1000 THEN 'ACH'
            WHEN be.amount >= 100 THEN 'Credit Card'
            ELSE 'PayPal'
        END AS payment_method,
        
        'Completed' AS payment_status,
        
        -- Subscription period determination
        CASE 
            WHEN UPPER(COALESCE(lc.license_type, '')) LIKE '%ANNUAL%' THEN 12
            WHEN UPPER(COALESCE(lc.license_type, '')) LIKE '%QUARTERLY%' THEN 3
            WHEN UPPER(COALESCE(lc.license_type, '')) LIKE '%MONTHLY%' THEN 1
            WHEN UPPER(be.event_type) LIKE '%ANNUAL%' THEN 12
            WHEN UPPER(be.event_type) LIKE '%MONTHLY%' THEN 1
            ELSE 12  -- Default to annual
        END AS subscription_period_months,
        
        -- Recurring revenue flag
        CASE 
            WHEN UPPER(be.event_type) LIKE '%SUBSCRIPTION%' 
                OR UPPER(be.event_type) LIKE '%RENEWAL%' 
                OR UPPER(be.event_type) LIKE '%RECURRING%' THEN TRUE
            ELSE FALSE
        END AS is_recurring_revenue,
        
        -- Customer Lifetime Value calculation
        CASE 
            WHEN UPPER(COALESCE(uc.plan_type, '')) = 'ENTERPRISE' THEN be.amount * 36
            WHEN UPPER(COALESCE(uc.plan_type, '')) = 'BUSINESS' THEN be.amount * 24
            WHEN UPPER(COALESCE(uc.plan_type, '')) = 'PRO' THEN be.amount * 18
            WHEN UPPER(COALESCE(uc.plan_type, '')) = 'BASIC' THEN be.amount * 12
            ELSE be.amount * 6
        END AS customer_lifetime_value,
        
        -- MRR Impact calculation
        CASE 
            WHEN (UPPER(be.event_type) LIKE '%SUBSCRIPTION%' OR UPPER(be.event_type) LIKE '%RENEWAL%') 
                AND UPPER(COALESCE(lc.license_type, '')) LIKE '%MONTHLY%' THEN be.amount
            WHEN (UPPER(be.event_type) LIKE '%SUBSCRIPTION%' OR UPPER(be.event_type) LIKE '%RENEWAL%') 
                AND UPPER(COALESCE(lc.license_type, '')) LIKE '%ANNUAL%' THEN be.amount / 12
            WHEN (UPPER(be.event_type) LIKE '%SUBSCRIPTION%' OR UPPER(be.event_type) LIKE '%RENEWAL%') 
                AND UPPER(COALESCE(lc.license_type, '')) LIKE '%QUARTERLY%' THEN be.amount / 3
            WHEN UPPER(be.event_type) LIKE '%UPGRADE%' OR UPPER(be.event_type) LIKE '%EXPANSION%' THEN be.amount
            ELSE 0
        END AS mrr_impact,
        
        -- ARR Impact calculation
        CASE 
            WHEN UPPER(be.event_type) LIKE '%SUBSCRIPTION%' OR UPPER(be.event_type) LIKE '%RENEWAL%' THEN 
                CASE 
                    WHEN UPPER(COALESCE(lc.license_type, '')) LIKE '%MONTHLY%' THEN be.amount * 12
                    WHEN UPPER(COALESCE(lc.license_type, '')) LIKE '%QUARTERLY%' THEN be.amount * 4
                    ELSE be.amount
                END
            WHEN UPPER(be.event_type) LIKE '%UPGRADE%' OR UPPER(be.event_type) LIKE '%EXPANSION%' THEN be.amount * 12
            ELSE 0
        END AS arr_impact,
        
        -- Commission calculation (5% standard rate)
        be.amount * 0.05 AS commission_amount,
        
        be.source_system
        
    FROM source_billing_events be
    LEFT JOIN user_context uc ON be.user_id = uc.user_id
    LEFT JOIN license_context lc ON be.user_id = lc.assigned_to_user_id
        AND be.event_date BETWEEN lc.start_date AND COALESCE(lc.end_date, '9999-12-31')
),

final_fact AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY transaction_date DESC, transaction_timestamp DESC) AS revenue_event_id,
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
        
        -- Standard metadata columns
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        source_system
        
    FROM revenue_calculations
)

SELECT * FROM final_fact
ORDER BY transaction_date DESC, revenue_type
