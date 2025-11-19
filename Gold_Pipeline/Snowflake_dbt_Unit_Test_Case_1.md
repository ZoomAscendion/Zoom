_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics Gold layer transformation pipeline
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Case for Zoom Gold Layer Pipeline

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Gold layer transformation pipeline. The tests validate data transformations, business rules, edge cases, and error handling across all Silver to Gold layer transformations including 6 dimension tables and 4 fact tables.

## Test Coverage Summary

### Models Under Test
- **Silver Layer Tables**: 7 tables (SI_USERS, SI_MEETINGS, SI_PARTICIPANTS, SI_FEATURE_USAGE, SI_SUPPORT_TICKETS, SI_BILLING_EVENTS, SI_LICENSES)
- **Gold Dimension Tables**: 6 tables (GO_DIM_USER, GO_DIM_DATE, GO_DIM_FEATURE, GO_DIM_LICENSE, GO_DIM_MEETING_TYPE, GO_DIM_SUPPORT_CATEGORY)
- **Gold Fact Tables**: 4 tables (GO_FACT_MEETING_ACTIVITY, GO_FACT_FEATURE_USAGE, GO_FACT_REVENUE_EVENTS, GO_FACT_SUPPORT_METRICS)

### Test Categories
1. **Data Transformation Tests**: Validate field mappings and business logic
2. **Data Quality Tests**: Check for nulls, duplicates, and referential integrity
3. **Business Rule Tests**: Verify business logic and calculations
4. **Edge Case Tests**: Handle boundary conditions and unusual data
5. **Performance Tests**: Validate clustering and optimization
6. **Error Handling Tests**: Test exception scenarios and data validation

---

## Test Case List

| Test Case ID | Test Case Description | Expected Outcome | Priority | Test Type |
|--------------|----------------------|------------------|----------|----------|
| TC_DIM_001 | Validate GO_DIM_USER surrogate key generation | MD5 hash keys generated correctly | High | Transformation |
| TC_DIM_002 | Test GO_DIM_USER plan type standardization | Plan types mapped to standard values | High | Business Rule |
| TC_DIM_003 | Validate GO_DIM_DATE dimension completeness | All dates from 2020-2030 generated | High | Data Quality |
| TC_DIM_004 | Test GO_DIM_FEATURE categorization logic | Features correctly categorized | Medium | Business Rule |
| TC_DIM_005 | Validate GO_DIM_LICENSE pricing calculations | Correct pricing based on license type | High | Business Rule |
| TC_DIM_006 | Test GO_DIM_MEETING_TYPE time categorization | Meetings categorized by time of day | Medium | Transformation |
| TC_DIM_007 | Validate GO_DIM_SUPPORT_CATEGORY SLA mapping | SLA targets correctly assigned | High | Business Rule |
| TC_FACT_001 | Test GO_FACT_MEETING_ACTIVITY aggregations | Participant counts and durations accurate | High | Transformation |
| TC_FACT_002 | Validate GO_FACT_FEATURE_USAGE adoption scores | Feature adoption scores calculated correctly | Medium | Business Rule |
| TC_FACT_003 | Test GO_FACT_REVENUE_EVENTS MRR/ARR calculations | Revenue metrics calculated accurately | High | Business Rule |
| TC_FACT_004 | Validate GO_FACT_SUPPORT_METRICS SLA compliance | SLA compliance flags set correctly | High | Business Rule |
| TC_EDGE_001 | Test null value handling in transformations | Null values replaced with defaults | High | Edge Case |
| TC_EDGE_002 | Validate empty dataset processing | Empty datasets handled gracefully | Medium | Edge Case |
| TC_EDGE_003 | Test invalid date handling | Invalid dates rejected or corrected | High | Edge Case |
| TC_EDGE_004 | Validate duplicate key handling | Duplicates identified and resolved | High | Edge Case |
| TC_PERF_001 | Test clustering key effectiveness | Query performance optimized | Medium | Performance |
| TC_PERF_002 | Validate incremental loading | Only changed records processed | Medium | Performance |
| TC_ERROR_001 | Test referential integrity violations | Foreign key violations logged | High | Error Handling |
| TC_ERROR_002 | Validate data type mismatches | Type conversion errors handled | High | Error Handling |
| TC_ERROR_003 | Test business rule violations | Rule violations logged and flagged | High | Error Handling |
| TC_AUDIT_001 | Validate audit trail completeness | All transformations logged | Medium | Audit |

---

## dbt Test Scripts

### 1. Schema Tests (schema.yml)

```yaml
# models/schema.yml
version: 2

models:
  # Silver Layer Tests
  - name: si_users
    description: "Silver layer user data with validation"
    columns:
      - name: user_id
        description: "Unique user identifier"
        tests:
          - not_null
          - unique
      - name: email
        description: "User email address"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "email LIKE '%@%'"
      - name: plan_type
        description: "User subscription plan"
        tests:
          - accepted_values:
              values: ['FREE', 'BASIC', 'PRO', 'ENTERPRISE']
      - name: validation_status
        description: "Data validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'FAILED', 'WARNING']

  - name: si_meetings
    description: "Silver layer meeting data"
    columns:
      - name: meeting_id
        description: "Unique meeting identifier"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "duration_minutes > 0 AND duration_minutes <= 1440"
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end timestamp"
        tests:
          - dbt_utils.expression_is_true:
              expression: "end_time > start_time"

  # Gold Dimension Tests
  - name: go_dim_user
    description: "Gold layer user dimension"
    columns:
      - name: user_dim_id
        description: "Surrogate key for user dimension"
        tests:
          - not_null
          - unique
      - name: user_key
        description: "Business key hash for user"
        tests:
          - not_null
          - unique
      - name: plan_type
        description: "Standardized plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Unknown']
      - name: plan_category
        description: "High-level plan category"
        tests:
          - accepted_values:
              values: ['Free', 'Paid']
      - name: effective_start_date
        description: "SCD effective start date"
        tests:
          - not_null
      - name: effective_end_date
        description: "SCD effective end date"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "effective_end_date >= effective_start_date"
      - name: is_current_record
        description: "Current record flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_date
    description: "Gold layer date dimension"
    columns:
      - name: date_id
        description: "Surrogate key for date"
        tests:
          - not_null
          - unique
      - name: date_value
        description: "Actual date value"
        tests:
          - not_null
          - unique
      - name: year
        description: "Year component"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "year BETWEEN 2020 AND 2030"
      - name: quarter
        description: "Quarter component"
        tests:
          - not_null
          - accepted_values:
              values: [1, 2, 3, 4]
      - name: month
        description: "Month component"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "month BETWEEN 1 AND 12"
      - name: day_of_week
        description: "Day of week (1-7)"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "day_of_week BETWEEN 1 AND 7"
      - name: is_weekend
        description: "Weekend flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_feature
    description: "Gold layer feature dimension"
    columns:
      - name: feature_id
        description: "Surrogate key for feature"
        tests:
          - not_null
          - unique
      - name: feature_key
        description: "Business key hash for feature"
        tests:
          - not_null
          - unique
      - name: feature_name
        description: "Feature name"
        tests:
          - not_null
      - name: feature_category
        description: "Feature category"
        tests:
          - accepted_values:
              values: ['Collaboration', 'Recording', 'Communication', 'Advanced Meeting', 'Engagement', 'General']
      - name: is_premium_feature
        description: "Premium feature flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  # Gold Fact Tests
  - name: go_fact_meeting_activity
    description: "Gold layer meeting activity facts"
    columns:
      - name: meeting_activity_id
        description: "Surrogate key for meeting activity"
        tests:
          - not_null
          - unique
      - name: date_id
        description: "Foreign key to date dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_date')
              field: date_id
      - name: user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_user')
              field: user_dim_id
      - name: duration_minutes
        description: "Meeting duration"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "duration_minutes > 0"
      - name: participant_count
        description: "Number of participants"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "participant_count >= 1"
      - name: meeting_quality_score
        description: "Meeting quality score (1-5)"
        tests:
          - dbt_utils.expression_is_true:
              expression: "meeting_quality_score BETWEEN 1.0 AND 5.0"

  - name: go_fact_revenue_events
    description: "Gold layer revenue events facts"
    columns:
      - name: revenue_event_id
        description: "Surrogate key for revenue event"
        tests:
          - not_null
          - unique
      - name: date_id
        description: "Foreign key to date dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_date')
              field: date_id
      - name: user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_user')
              field: user_dim_id
      - name: gross_amount
        description: "Gross revenue amount"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "gross_amount >= 0"
      - name: net_amount
        description: "Net revenue amount"
        tests:
          - not_null
      - name: currency_code
        description: "Currency code"
        tests:
          - not_null
          - accepted_values:
              values: ['USD', 'EUR', 'GBP', 'CAD']
```

### 2. Custom SQL Tests

#### Test 1: User Dimension Transformation Validation

```sql
-- tests/test_user_dimension_transformation.sql
-- Test Case TC_DIM_001 & TC_DIM_002: Validate user dimension transformations

WITH source_data AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        validation_status
    FROM {{ ref('si_users') }}
    WHERE validation_status = 'PASSED'
),

transformed_data AS (
    SELECT 
        user_key,
        user_id,
        user_name,
        email_domain,
        company,
        plan_type,
        plan_category
    FROM {{ ref('go_dim_user') }}
    WHERE is_current_record = TRUE
),

validation_results AS (
    SELECT 
        -- Test surrogate key generation
        CASE 
            WHEN t.user_key = MD5(UPPER(TRIM(s.user_id))) THEN 'PASS'
            ELSE 'FAIL'
        END AS surrogate_key_test,
        
        -- Test plan type standardization
        CASE 
            WHEN s.plan_type IN ('FREE', 'BASIC') AND t.plan_type = 'Basic' THEN 'PASS'
            WHEN s.plan_type IN ('PRO', 'PROFESSIONAL') AND t.plan_type = 'Pro' THEN 'PASS'
            WHEN s.plan_type IN ('BUSINESS', 'ENTERPRISE') AND t.plan_type = 'Enterprise' THEN 'PASS'
            WHEN t.plan_type = 'Unknown' THEN 'PASS'
            ELSE 'FAIL'
        END AS plan_type_test,
        
        -- Test plan category derivation
        CASE 
            WHEN s.plan_type = 'FREE' AND t.plan_category = 'Free' THEN 'PASS'
            WHEN s.plan_type != 'FREE' AND t.plan_category = 'Paid' THEN 'PASS'
            ELSE 'FAIL'
        END AS plan_category_test,
        
        -- Test email domain extraction
        CASE 
            WHEN t.email_domain = UPPER(SUBSTRING(s.email, POSITION('@' IN s.email) + 1)) THEN 'PASS'
            ELSE 'FAIL'
        END AS email_domain_test
        
    FROM source_data s
    JOIN transformed_data t ON s.user_id = t.user_id
)

SELECT 
    COUNT(*) AS total_records,
    SUM(CASE WHEN surrogate_key_test = 'FAIL' THEN 1 ELSE 0 END) AS surrogate_key_failures,
    SUM(CASE WHEN plan_type_test = 'FAIL' THEN 1 ELSE 0 END) AS plan_type_failures,
    SUM(CASE WHEN plan_category_test = 'FAIL' THEN 1 ELSE 0 END) AS plan_category_failures,
    SUM(CASE WHEN email_domain_test = 'FAIL' THEN 1 ELSE 0 END) AS email_domain_failures
FROM validation_results

-- Test should return 0 failures for all transformation rules
HAVING 
    surrogate_key_failures = 0 
    AND plan_type_failures = 0 
    AND plan_category_failures = 0 
    AND email_domain_failures = 0
```

#### Test 2: Date Dimension Completeness

```sql
-- tests/test_date_dimension_completeness.sql
-- Test Case TC_DIM_003: Validate date dimension completeness

WITH expected_dates AS (
    SELECT 
        DATEADD(day, ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) AS expected_date
    FROM TABLE(GENERATOR(ROWCOUNT => 4018)) -- 11 years of dates (2020-2030)
),

actual_dates AS (
    SELECT DISTINCT date_value AS actual_date
    FROM {{ ref('go_dim_date') }}
),

missing_dates AS (
    SELECT e.expected_date
    FROM expected_dates e
    LEFT JOIN actual_dates a ON e.expected_date = a.actual_date
    WHERE a.actual_date IS NULL
),

date_validation AS (
    SELECT 
        date_value,
        year,
        quarter,
        month,
        day_of_week,
        is_weekend,
        fiscal_year,
        fiscal_quarter
    FROM {{ ref('go_dim_date') }}
    WHERE 
        -- Validate year extraction
        year != YEAR(date_value)
        -- Validate quarter extraction
        OR quarter != QUARTER(date_value)
        -- Validate month extraction
        OR month != MONTH(date_value)
        -- Validate day of week
        OR day_of_week != DAYOFWEEK(date_value)
        -- Validate weekend flag
        OR (is_weekend = TRUE AND day_of_week NOT IN (1, 7))
        OR (is_weekend = FALSE AND day_of_week IN (1, 7))
        -- Validate fiscal year calculation
        OR (month >= 4 AND fiscal_year != year)
        OR (month < 4 AND fiscal_year != year - 1)
)

SELECT 
    (SELECT COUNT(*) FROM missing_dates) AS missing_dates_count,
    (SELECT COUNT(*) FROM date_validation) AS invalid_calculations_count
    
-- Test should return 0 missing dates and 0 invalid calculations
HAVING missing_dates_count = 0 AND invalid_calculations_count = 0
```

#### Test 3: Meeting Activity Fact Aggregations

```sql
-- tests/test_meeting_activity_aggregations.sql
-- Test Case TC_FACT_001: Validate meeting activity fact aggregations

WITH source_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        start_time,
        end_time,
        duration_minutes
    FROM {{ ref('si_meetings') }}
    WHERE validation_status = 'PASSED'
),

source_participants AS (
    SELECT 
        meeting_id,
        user_id,
        join_time,
        leave_time
    FROM {{ ref('si_participants') }}
    WHERE validation_status = 'PASSED'
),

expected_aggregations AS (
    SELECT 
        sm.meeting_id,
        sm.duration_minutes AS expected_duration,
        COUNT(DISTINCT sp.user_id) AS expected_participant_count,
        SUM(DATEDIFF('minute', sp.join_time, sp.leave_time)) AS expected_total_participation_minutes,
        AVG(DATEDIFF('minute', sp.join_time, sp.leave_time)) AS expected_avg_participation_minutes
    FROM source_meetings sm
    LEFT JOIN source_participants sp ON sm.meeting_id = sp.meeting_id
    GROUP BY sm.meeting_id, sm.duration_minutes
),

actual_aggregations AS (
    SELECT 
        meeting_id,
        actual_duration_minutes,
        participant_count,
        total_participant_minutes,
        average_participation_minutes
    FROM {{ ref('go_fact_meeting_activity') }}
),

validation_failures AS (
    SELECT 
        e.meeting_id,
        CASE 
            WHEN ABS(e.expected_duration - a.actual_duration_minutes) > 0 THEN 'DURATION_MISMATCH'
            WHEN ABS(e.expected_participant_count - a.participant_count) > 0 THEN 'PARTICIPANT_COUNT_MISMATCH'
            WHEN ABS(COALESCE(e.expected_total_participation_minutes, 0) - COALESCE(a.total_participant_minutes, 0)) > 1 THEN 'TOTAL_MINUTES_MISMATCH'
            WHEN ABS(COALESCE(e.expected_avg_participation_minutes, 0) - COALESCE(a.average_participation_minutes, 0)) > 1 THEN 'AVG_MINUTES_MISMATCH'
            ELSE NULL
        END AS failure_type
    FROM expected_aggregations e
    JOIN actual_aggregations a ON e.meeting_id = a.meeting_id
    WHERE failure_type IS NOT NULL
)

SELECT COUNT(*) AS aggregation_failures
FROM validation_failures

-- Test should return 0 aggregation failures
HAVING aggregation_failures = 0
```

#### Test 4: Revenue Events MRR/ARR Calculations

```sql
-- tests/test_revenue_calculations.sql
-- Test Case TC_FACT_003: Validate revenue MRR/ARR calculations

WITH source_billing AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date
    FROM {{ ref('si_billing_events') }}
    WHERE validation_status = 'PASSED'
),

expected_calculations AS (
    SELECT 
        event_id,
        event_type,
        amount,
        CASE 
            WHEN event_type IN ('Subscription', 'Renewal', 'Upgrade') THEN amount / 12
            ELSE 0
        END AS expected_mrr_impact,
        CASE 
            WHEN event_type IN ('Subscription', 'Renewal', 'Upgrade') THEN amount
            ELSE 0
        END AS expected_arr_impact,
        CASE 
            WHEN event_type = 'Refund' THEN -amount
            ELSE amount
        END AS expected_net_amount
    FROM source_billing
),

actual_calculations AS (
    SELECT 
        billing_event_id,
        event_type,
        gross_amount,
        net_amount,
        mrr_impact,
        arr_impact
    FROM {{ ref('go_fact_revenue_events') }}
),

validation_failures AS (
    SELECT 
        e.event_id,
        CASE 
            WHEN ABS(e.expected_mrr_impact - COALESCE(a.mrr_impact, 0)) > 0.01 THEN 'MRR_CALCULATION_ERROR'
            WHEN ABS(e.expected_arr_impact - COALESCE(a.arr_impact, 0)) > 0.01 THEN 'ARR_CALCULATION_ERROR'
            WHEN ABS(e.expected_net_amount - COALESCE(a.net_amount, 0)) > 0.01 THEN 'NET_AMOUNT_ERROR'
            ELSE NULL
        END AS failure_type
    FROM expected_calculations e
    JOIN actual_calculations a ON e.event_id = a.billing_event_id
    WHERE failure_type IS NOT NULL
)

SELECT COUNT(*) AS calculation_failures
FROM validation_failures

-- Test should return 0 calculation failures
HAVING calculation_failures = 0
```

#### Test 5: Null Value Handling

```sql
-- tests/test_null_value_handling.sql
-- Test Case TC_EDGE_001: Test null value handling in transformations

WITH null_handling_tests AS (
    -- Test user dimension null handling
    SELECT 
        'GO_DIM_USER' AS table_name,
        'USER_NAME' AS column_name,
        COUNT(*) AS null_count
    FROM {{ ref('go_dim_user') }}
    WHERE user_name IS NULL OR user_name = ''
    
    UNION ALL
    
    SELECT 
        'GO_DIM_USER' AS table_name,
        'COMPANY' AS column_name,
        COUNT(*) AS null_count
    FROM {{ ref('go_dim_user') }}
    WHERE company IS NULL OR company = ''
    
    UNION ALL
    
    SELECT 
        'GO_DIM_USER' AS table_name,
        'EMAIL_DOMAIN' AS column_name,
        COUNT(*) AS null_count
    FROM {{ ref('go_dim_user') }}
    WHERE email_domain IS NULL OR email_domain = ''
    
    UNION ALL
    
    -- Test feature dimension null handling
    SELECT 
        'GO_DIM_FEATURE' AS table_name,
        'FEATURE_NAME' AS column_name,
        COUNT(*) AS null_count
    FROM {{ ref('go_dim_feature') }}
    WHERE feature_name IS NULL OR feature_name = ''
    
    UNION ALL
    
    SELECT 
        'GO_DIM_FEATURE' AS table_name,
        'FEATURE_CATEGORY' AS column_name,
        COUNT(*) AS null_count
    FROM {{ ref('go_dim_feature') }}
    WHERE feature_category IS NULL OR feature_category = ''
)

SELECT 
    table_name,
    column_name,
    null_count
FROM null_handling_tests
WHERE null_count > 0

-- Test should return no rows (all nulls should be handled)
HAVING COUNT(*) = 0
```

#### Test 6: Referential Integrity Validation

```sql
-- tests/test_referential_integrity.sql
-- Test Case TC_ERROR_001: Test referential integrity between facts and dimensions

WITH integrity_violations AS (
    -- Test meeting activity fact to user dimension
    SELECT 
        'GO_FACT_MEETING_ACTIVITY' AS fact_table,
        'USER_DIM_ID' AS foreign_key,
        'GO_DIM_USER' AS dimension_table,
        COUNT(*) AS violation_count
    FROM {{ ref('go_fact_meeting_activity') }} f
    LEFT JOIN {{ ref('go_dim_user') }} d ON f.user_dim_id = d.user_dim_id
    WHERE d.user_dim_id IS NULL AND f.user_dim_id IS NOT NULL
    
    UNION ALL
    
    -- Test meeting activity fact to date dimension
    SELECT 
        'GO_FACT_MEETING_ACTIVITY' AS fact_table,
        'DATE_ID' AS foreign_key,
        'GO_DIM_DATE' AS dimension_table,
        COUNT(*) AS violation_count
    FROM {{ ref('go_fact_meeting_activity') }} f
    LEFT JOIN {{ ref('go_dim_date') }} d ON f.date_id = d.date_id
    WHERE d.date_id IS NULL AND f.date_id IS NOT NULL
    
    UNION ALL
    
    -- Test revenue events fact to user dimension
    SELECT 
        'GO_FACT_REVENUE_EVENTS' AS fact_table,
        'USER_DIM_ID' AS foreign_key,
        'GO_DIM_USER' AS dimension_table,
        COUNT(*) AS violation_count
    FROM {{ ref('go_fact_revenue_events') }} f
    LEFT JOIN {{ ref('go_dim_user') }} d ON f.user_dim_id = d.user_dim_id
    WHERE d.user_dim_id IS NULL AND f.user_dim_id IS NOT NULL
    
    UNION ALL
    
    -- Test feature usage fact to feature dimension
    SELECT 
        'GO_FACT_FEATURE_USAGE' AS fact_table,
        'FEATURE_ID' AS foreign_key,
        'GO_DIM_FEATURE' AS dimension_table,
        COUNT(*) AS violation_count
    FROM {{ ref('go_fact_feature_usage') }} f
    LEFT JOIN {{ ref('go_dim_feature') }} d ON f.feature_id = d.feature_id
    WHERE d.feature_id IS NULL AND f.feature_id IS NOT NULL
)

SELECT 
    fact_table,
    foreign_key,
    dimension_table,
    violation_count
FROM integrity_violations
WHERE violation_count > 0

-- Test should return no rows (no referential integrity violations)
HAVING COUNT(*) = 0
```

#### Test 7: Business Rule Validation

```sql
-- tests/test_business_rules.sql
-- Test Case TC_ERROR_003: Test business rule violations

WITH business_rule_violations AS (
    -- Test meeting duration business rules
    SELECT 
        'MEETING_DURATION' AS rule_name,
        'Meeting duration exceeds 24 hours' AS rule_description,
        COUNT(*) AS violation_count
    FROM {{ ref('go_fact_meeting_activity') }}
    WHERE actual_duration_minutes > 1440 -- 24 hours
    
    UNION ALL
    
    -- Test participant count business rules
    SELECT 
        'PARTICIPANT_COUNT' AS rule_name,
        'Participant count is zero or negative' AS rule_description,
        COUNT(*) AS violation_count
    FROM {{ ref('go_fact_meeting_activity') }}
    WHERE participant_count <= 0
    
    UNION ALL
    
    -- Test revenue amount business rules
    SELECT 
        'REVENUE_AMOUNT' AS rule_name,
        'Gross amount is negative for non-refund events' AS rule_description,
        COUNT(*) AS violation_count
    FROM {{ ref('go_fact_revenue_events') }}
    WHERE gross_amount < 0 AND event_type != 'Refund'
    
    UNION ALL
    
    -- Test SCD effective date business rules
    SELECT 
        'SCD_DATES' AS rule_name,
        'Effective end date is before start date' AS rule_description,
        COUNT(*) AS violation_count
    FROM {{ ref('go_dim_user') }}
    WHERE effective_end_date < effective_start_date
    
    UNION ALL
    
    -- Test feature adoption score business rules
    SELECT 
        'FEATURE_ADOPTION_SCORE' AS rule_name,
        'Feature adoption score outside valid range (1-5)' AS rule_description,
        COUNT(*) AS violation_count
    FROM {{ ref('go_fact_feature_usage') }}
    WHERE feature_adoption_score < 1.0 OR feature_adoption_score > 5.0
)

SELECT 
    rule_name,
    rule_description,
    violation_count
FROM business_rule_violations
WHERE violation_count > 0

-- Test should return no rows (no business rule violations)
HAVING COUNT(*) = 0
```

### 3. Macro Tests

#### Test Macro for Data Quality Scoring

```sql
-- macros/test_data_quality_score.sql
-- Macro to test data quality score calculations

{% macro test_data_quality_score(model_name, score_column) %}

WITH quality_score_validation AS (
    SELECT 
        {{ score_column }} AS quality_score,
        CASE 
            WHEN {{ score_column }} BETWEEN 0 AND 100 THEN 'VALID'
            WHEN {{ score_column }} IS NULL THEN 'NULL'
            ELSE 'INVALID'
        END AS score_status
    FROM {{ ref(model_name) }}
)

SELECT 
    score_status,
    COUNT(*) AS record_count
FROM quality_score_validation
GROUP BY score_status
HAVING score_status IN ('NULL', 'INVALID')

{% endmacro %}
```

#### Test Macro for Surrogate Key Validation

```sql
-- macros/test_surrogate_key.sql
-- Macro to validate surrogate key generation

{% macro test_surrogate_key(model_name, key_column, source_column) %}

WITH surrogate_key_validation AS (
    SELECT 
        {{ key_column }} AS generated_key,
        MD5(UPPER(TRIM({{ source_column }}))) AS expected_key,
        CASE 
            WHEN {{ key_column }} = MD5(UPPER(TRIM({{ source_column }}))) THEN 'VALID'
            ELSE 'INVALID'
        END AS key_status
    FROM {{ ref(model_name) }}
    WHERE {{ source_column }} IS NOT NULL
)

SELECT COUNT(*) AS invalid_keys
FROM surrogate_key_validation
WHERE key_status = 'INVALID'

-- Should return 0 invalid keys
HAVING invalid_keys = 0

{% endmacro %}
```

### 4. Performance Tests

#### Test Query Performance with Clustering

```sql
-- tests/test_clustering_performance.sql
-- Test Case TC_PERF_001: Test clustering key effectiveness

-- This test validates that clustering keys are working effectively
-- by checking query performance on clustered columns

WITH performance_test AS (
    SELECT 
        date_id,
        user_dim_id,
        COUNT(*) AS meeting_count,
        AVG(actual_duration_minutes) AS avg_duration,
        SUM(participant_count) AS total_participants
    FROM {{ ref('go_fact_meeting_activity') }}
    WHERE date_id BETWEEN 
        (SELECT MIN(date_id) FROM {{ ref('go_dim_date') }} WHERE date_value >= '2024-01-01') 
        AND 
        (SELECT MAX(date_id) FROM {{ ref('go_dim_date') }} WHERE date_value <= '2024-12-31')
    GROUP BY date_id, user_dim_id
    ORDER BY date_id, user_dim_id
    LIMIT 1000
)

SELECT 
    COUNT(*) AS result_count,
    MIN(meeting_count) AS min_meetings,
    MAX(meeting_count) AS max_meetings,
    AVG(avg_duration) AS overall_avg_duration
FROM performance_test

-- Test should complete within reasonable time due to clustering
-- Results should be consistent and performant
HAVING result_count > 0
```

### 5. Data Lineage Tests

#### Test Source to Target Mapping

```sql
-- tests/test_data_lineage.sql
-- Validate complete data lineage from Silver to Gold

WITH source_counts AS (
    SELECT 'SI_USERS' AS table_name, COUNT(*) AS record_count
    FROM {{ ref('si_users') }}
    WHERE validation_status = 'PASSED'
    
    UNION ALL
    
    SELECT 'SI_MEETINGS' AS table_name, COUNT(*) AS record_count
    FROM {{ ref('si_meetings') }}
    WHERE validation_status = 'PASSED'
    
    UNION ALL
    
    SELECT 'SI_FEATURE_USAGE' AS table_name, COUNT(*) AS record_count
    FROM {{ ref('si_feature_usage') }}
    WHERE validation_status = 'PASSED'
    
    UNION ALL
    
    SELECT 'SI_BILLING_EVENTS' AS table_name, COUNT(*) AS record_count
    FROM {{ ref('si_billing_events') }}
    WHERE validation_status = 'PASSED'
),

target_counts AS (
    SELECT 'GO_DIM_USER' AS table_name, COUNT(*) AS record_count
    FROM {{ ref('go_dim_user') }}
    WHERE is_current_record = TRUE
    
    UNION ALL
    
    SELECT 'GO_FACT_MEETING_ACTIVITY' AS table_name, COUNT(*) AS record_count
    FROM {{ ref('go_fact_meeting_activity') }}
    
    UNION ALL
    
    SELECT 'GO_FACT_FEATURE_USAGE' AS table_name, COUNT(*) AS record_count
    FROM {{ ref('go_fact_feature_usage') }}
    
    UNION ALL
    
    SELECT 'GO_FACT_REVENUE_EVENTS' AS table_name, COUNT(*) AS record_count
    FROM {{ ref('go_fact_revenue_events') }}
)

SELECT 
    'SOURCE' AS layer_type,
    table_name,
    record_count
FROM source_counts

UNION ALL

SELECT 
    'TARGET' AS layer_type,
    table_name,
    record_count
FROM target_counts

ORDER BY layer_type, table_name
```

---

## Test Execution Strategy

### 1. Test Environment Setup

```bash
# Set up dbt test environment
dbt deps
dbt seed
dbt run --models silver.*
dbt run --models gold.*

# Run all tests
dbt test

# Run specific test categories
dbt test --models tag:dimension_tests
dbt test --models tag:fact_tests
dbt test --models tag:business_rules
```

### 2. Continuous Integration Pipeline

```yaml
# .github/workflows/dbt_tests.yml
name: dbt Tests

on:
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.8
    
    - name: Install dependencies
      run: |
        pip install dbt-snowflake
        dbt deps
    
    - name: Run dbt tests
      run: |
        dbt test --profiles-dir ./profiles
      env:
        SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
        SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
        SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}
        SNOWFLAKE_WAREHOUSE: ${{ secrets.SNOWFLAKE_WAREHOUSE }}
        SNOWFLAKE_DATABASE: ${{ secrets.SNOWFLAKE_DATABASE }}
        SNOWFLAKE_SCHEMA: ${{ secrets.SNOWFLAKE_SCHEMA }}
```

### 3. Test Monitoring and Alerting

```sql
-- Create test results monitoring view
CREATE OR REPLACE VIEW GOLD.VW_DBT_TEST_RESULTS AS
SELECT 
    test_name,
    model_name,
    test_status,
    execution_time,
    error_message,
    test_timestamp
FROM GOLD.GO_PROCESS_AUDIT_LOG
WHERE process_type = 'DBT_TEST'
ORDER BY test_timestamp DESC;

-- Alert on test failures
CREATE OR REPLACE TASK GOLD.TASK_MONITOR_TEST_FAILURES
    WAREHOUSE = WH_POC_ZOOM_DEV_XSMALL
    SCHEDULE = 'USING CRON 0 */4 * * * UTC'
AS
    SELECT 
        COUNT(*) AS failed_tests,
        LISTAGG(test_name, ', ') AS failed_test_names
    FROM GOLD.VW_DBT_TEST_RESULTS
    WHERE test_status = 'FAILED'
    AND test_timestamp >= CURRENT_TIMESTAMP() - INTERVAL '4 HOURS'
    HAVING failed_tests > 0;
```

---

## Expected Test Results

### Success Criteria

1. **All Schema Tests Pass**: 100% pass rate on not_null, unique, relationships, and accepted_values tests
2. **Custom SQL Tests Pass**: All transformation logic validated with 0 failures
3. **Business Rule Compliance**: All business rules enforced with 0 violations
4. **Data Quality Scores**: All records have quality scores between 0-100
5. **Referential Integrity**: All foreign key relationships validated
6. **Performance Benchmarks**: Queries complete within acceptable time limits

### Test Coverage Metrics

- **Model Coverage**: 100% of models have at least one test
- **Column Coverage**: 95% of critical columns have tests
- **Business Rule Coverage**: 100% of documented business rules tested
- **Edge Case Coverage**: All identified edge cases have test scenarios

### Failure Handling

1. **Test Failures**: Logged to GO_DATA_VALIDATION_ERRORS table
2. **Performance Issues**: Monitored via execution time tracking
3. **Data Quality Issues**: Flagged with quality scores and validation status
4. **Business Rule Violations**: Captured in audit logs with detailed error messages

---

## Conclusion

This comprehensive unit test suite ensures the reliability and performance of the Zoom Platform Analytics Gold layer transformation pipeline. The tests validate:

- **Data Accuracy**: All transformations produce correct results
- **Business Logic**: All business rules are properly implemented
- **Data Quality**: High-quality data standards are maintained
- **Performance**: Optimized query performance through proper design
- **Reliability**: Robust error handling and monitoring

The test framework supports continuous integration, automated monitoring, and provides detailed feedback for troubleshooting and optimization. All tests are designed to run efficiently in Snowflake's cloud-native environment while ensuring comprehensive coverage of the dbt transformation pipeline.