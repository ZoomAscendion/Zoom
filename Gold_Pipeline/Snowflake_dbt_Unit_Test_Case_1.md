_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Gold Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Gold Layer

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Gold Layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and high-quality data pipelines.

## Test Coverage Summary

### Models Under Test
- **Dimension Tables**: GO_DIM_USER, GO_DIM_DATE, GO_DIM_FEATURE, GO_DIM_LICENSE, GO_DIM_MEETING_TYPE, GO_DIM_SUPPORT_CATEGORY
- **Fact Tables**: GO_FACT_MEETING_ACTIVITY, GO_FACT_FEATURE_USAGE, GO_FACT_REVENUE_EVENTS, GO_FACT_SUPPORT_METRICS
- **Audit Tables**: GO_AUDIT_LOG, GO_DATA_VALIDATION_ERRORS

### Test Categories
1. **Data Quality Tests**: Uniqueness, not-null constraints, accepted values
2. **Business Logic Tests**: Transformation rules, calculations, derivations
3. **Edge Case Tests**: Null handling, boundary conditions, invalid data
4. **Performance Tests**: Query execution time, resource utilization
5. **Integration Tests**: Cross-model relationships, referential integrity

---

## Test Case List

### 1. Dimension Table Tests

#### 1.1 GO_DIM_USER Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| DIM_USER_001 | Verify USER_DIM_ID uniqueness and auto-increment | All USER_DIM_ID values are unique and sequential |
| DIM_USER_002 | Validate USER_NAME standardization (INITCAP) | All USER_NAME values follow proper case format |
| DIM_USER_003 | Test EMAIL_DOMAIN extraction logic | EMAIL_DOMAIN correctly extracted from EMAIL field |
| DIM_USER_004 | Verify PLAN_TYPE categorization mapping | PLAN_TYPE values mapped to 'Basic', 'Pro', 'Enterprise', 'Unknown' |
| DIM_USER_005 | Test GEOGRAPHIC_REGION derivation from email domain | Regions correctly assigned based on email domain patterns |
| DIM_USER_006 | Validate SCD Type 2 implementation | IS_CURRENT_RECORD and effective dates properly maintained |
| DIM_USER_007 | Test null handling for optional fields | NULL values replaced with appropriate defaults |
| DIM_USER_008 | Verify data quality filtering | Only records with VALIDATION_STATUS = 'PASSED' included |
| DIM_USER_009 | Test INDUSTRY_SECTOR derivation logic | Industry sectors correctly derived from company names |
| DIM_USER_010 | Validate ACCOUNT_TYPE business rule | ACCOUNT_TYPE correctly assigned based on PLAN_TYPE |

#### 1.2 GO_DIM_DATE Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| DIM_DATE_001 | Verify date range coverage (2020-2030) | All dates from 2020-01-01 to 2030-12-31 present |
| DIM_DATE_002 | Test fiscal year calculation | FISCAL_YEAR correctly calculated with April 1st start |
| DIM_DATE_003 | Validate weekend flag logic | IS_WEEKEND correctly identifies Saturday and Sunday |
| DIM_DATE_004 | Test fiscal quarter mapping | FISCAL_QUARTER correctly mapped to fiscal year periods |
| DIM_DATE_005 | Verify date component extractions | YEAR, MONTH, DAY components correctly extracted |
| DIM_DATE_006 | Test week of year calculation | WEEK_OF_YEAR values within valid range (1-53) |
| DIM_DATE_007 | Validate day name and month name | DAY_NAME and MONTH_NAME correctly populated |
| DIM_DATE_008 | Test leap year handling | February 29th correctly handled in leap years |

#### 1.3 GO_DIM_FEATURE Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| DIM_FEATURE_001 | Verify FEATURE_ID uniqueness | All FEATURE_ID values are unique |
| DIM_FEATURE_002 | Test FEATURE_CATEGORY classification | Features correctly categorized (Collaboration, Recording, etc.) |
| DIM_FEATURE_003 | Validate IS_PREMIUM_FEATURE logic | Premium features correctly identified |
| DIM_FEATURE_004 | Test FEATURE_COMPLEXITY assignment | Complexity levels correctly assigned based on feature type |
| DIM_FEATURE_005 | Verify feature name standardization | FEATURE_NAME values properly formatted |

#### 1.4 GO_DIM_LICENSE Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| DIM_LICENSE_001 | Verify LICENSE_ID uniqueness | All LICENSE_ID values are unique |
| DIM_LICENSE_002 | Test pricing calculation logic | MONTHLY_PRICE and ANNUAL_PRICE correctly assigned |
| DIM_LICENSE_003 | Validate feature entitlements | Boolean flags correctly set based on license type |
| DIM_LICENSE_004 | Test license tier mapping | LICENSE_TIER correctly assigned (Tier 1, 2, 3) |
| DIM_LICENSE_005 | Verify capacity limits | MAX_PARTICIPANTS, STORAGE_LIMIT_GB correctly set |

#### 1.5 GO_DIM_MEETING_TYPE Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| DIM_MEETING_001 | Verify MEETING_TYPE_ID uniqueness | All MEETING_TYPE_ID values are unique |
| DIM_MEETING_002 | Test duration categorization | DURATION_CATEGORY correctly assigned based on minutes |
| DIM_MEETING_003 | Validate time of day classification | TIME_OF_DAY_CATEGORY correctly assigned |
| DIM_MEETING_004 | Test weekend meeting identification | IS_WEEKEND_MEETING correctly identified |

#### 1.6 GO_DIM_SUPPORT_CATEGORY Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| DIM_SUPPORT_001 | Verify SUPPORT_CATEGORY_ID uniqueness | All SUPPORT_CATEGORY_ID values are unique |
| DIM_SUPPORT_002 | Test priority level assignment | PRIORITY_LEVEL correctly assigned based on ticket type |
| DIM_SUPPORT_003 | Validate SLA target calculation | SLA_TARGET_HOURS correctly set based on priority |
| DIM_SUPPORT_004 | Test escalation requirement logic | REQUIRES_ESCALATION correctly determined |

### 2. Fact Table Tests

#### 2.1 GO_FACT_MEETING_ACTIVITY Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| FACT_MEETING_001 | Verify MEETING_ACTIVITY_ID uniqueness | All MEETING_ACTIVITY_ID values are unique |
| FACT_MEETING_002 | Test foreign key relationships | Valid DATE_ID, USER_DIM_ID, MEETING_TYPE_ID references |
| FACT_MEETING_003 | Validate duration calculations | ACTUAL_DURATION_MINUTES correctly calculated |
| FACT_MEETING_004 | Test participant metrics aggregation | Participant counts and minutes correctly aggregated |
| FACT_MEETING_005 | Verify meeting quality score calculation | MEETING_QUALITY_SCORE within valid range (1.0-5.0) |
| FACT_MEETING_006 | Test feature usage metrics | Feature counts and durations correctly calculated |
| FACT_MEETING_007 | Validate null handling for optional metrics | NULL values handled appropriately with defaults |
| FACT_MEETING_008 | Test data quality filtering | Only validated meetings included |

#### 2.2 GO_FACT_FEATURE_USAGE Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| FACT_FEATURE_001 | Verify FEATURE_USAGE_ID uniqueness | All FEATURE_USAGE_ID values are unique |
| FACT_FEATURE_002 | Test foreign key relationships | Valid DATE_ID, FEATURE_ID, USER_DIM_ID references |
| FACT_FEATURE_003 | Validate usage metrics calculation | USAGE_COUNT and USAGE_DURATION_MINUTES correctly calculated |
| FACT_FEATURE_004 | Test adoption score logic | FEATURE_ADOPTION_SCORE within valid range |
| FACT_FEATURE_005 | Verify success rate calculation | SUCCESS_RATE correctly calculated from error counts |

#### 2.3 GO_FACT_REVENUE_EVENTS Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| FACT_REVENUE_001 | Verify REVENUE_EVENT_ID uniqueness | All REVENUE_EVENT_ID values are unique |
| FACT_REVENUE_002 | Test foreign key relationships | Valid DATE_ID, LICENSE_ID, USER_DIM_ID references |
| FACT_REVENUE_003 | Validate amount calculations | NET_AMOUNT = GROSS_AMOUNT - TAX_AMOUNT - DISCOUNT_AMOUNT |
| FACT_REVENUE_004 | Test currency conversion | USD_AMOUNT correctly calculated using EXCHANGE_RATE |
| FACT_REVENUE_005 | Verify MRR/ARR impact calculation | MRR_IMPACT and ARR_IMPACT correctly calculated |
| FACT_REVENUE_006 | Test payment status validation | PAYMENT_STATUS contains only valid values |

#### 2.4 GO_FACT_SUPPORT_METRICS Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| FACT_SUPPORT_001 | Verify SUPPORT_METRICS_ID uniqueness | All SUPPORT_METRICS_ID values are unique |
| FACT_SUPPORT_002 | Test foreign key relationships | Valid DATE_ID, SUPPORT_CATEGORY_ID, USER_DIM_ID references |
| FACT_SUPPORT_003 | Validate response time calculations | FIRST_RESPONSE_TIME_HOURS correctly calculated |
| FACT_SUPPORT_004 | Test resolution time metrics | RESOLUTION_TIME_HOURS correctly calculated |
| FACT_SUPPORT_005 | Verify SLA compliance logic | SLA_MET correctly determined based on target times |
| FACT_SUPPORT_006 | Test customer satisfaction scoring | CUSTOMER_SATISFACTION_SCORE within valid range (1.0-5.0) |

### 3. Edge Case Tests

#### 3.1 Null Value Handling

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| EDGE_NULL_001 | Test null USER_NAME handling | NULL USER_NAME replaced with 'Unknown User' |
| EDGE_NULL_002 | Test null EMAIL handling | NULL EMAIL replaced with 'unknown@domain.com' |
| EDGE_NULL_003 | Test null COMPANY handling | NULL COMPANY replaced with 'Unknown Company' |
| EDGE_NULL_004 | Test null PLAN_TYPE handling | NULL PLAN_TYPE mapped to 'Unknown' |
| EDGE_NULL_005 | Test null date handling | NULL dates handled without causing failures |

#### 3.2 Boundary Conditions

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| EDGE_BOUND_001 | Test minimum date values | Dates at lower boundary (2020-01-01) handled correctly |
| EDGE_BOUND_002 | Test maximum date values | Dates at upper boundary (2030-12-31) handled correctly |
| EDGE_BOUND_003 | Test zero duration meetings | Zero-duration meetings handled appropriately |
| EDGE_BOUND_004 | Test maximum participant counts | Large participant counts handled without overflow |
| EDGE_BOUND_005 | Test negative amounts | Negative revenue amounts (refunds) handled correctly |

#### 3.3 Invalid Data Scenarios

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| EDGE_INVALID_001 | Test invalid email formats | Invalid emails handled gracefully |
| EDGE_INVALID_002 | Test invalid date formats | Invalid dates filtered out or corrected |
| EDGE_INVALID_003 | Test invalid plan types | Unknown plan types mapped to 'Unknown' category |
| EDGE_INVALID_004 | Test invalid numeric values | Invalid numbers handled with appropriate defaults |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# models/gold/schema.yml
version: 2

models:
  - name: go_dim_user
    description: "User dimension table with enhanced attributes"
    columns:
      - name: user_dim_id
        description: "Unique user dimension identifier"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Business key for user"
        tests:
          - not_null
      - name: user_name
        description: "Standardized user name"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: "^[A-Z][a-z]*( [A-Z][a-z]*)*$"
      - name: plan_type
        description: "Standardized plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Unknown']
      - name: user_status
        description: "User status"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive']
      - name: is_current_record
        description: "SCD Type 2 current record flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_date
    description: "Standard date dimension"
    columns:
      - name: date_id
        description: "Unique date identifier"
        tests:
          - unique
          - not_null
      - name: date_value
        description: "Date value"
        tests:
          - unique
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: "'2020-01-01'"
              max_value: "'2030-12-31'"
      - name: fiscal_year
        description: "Fiscal year"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 2019
              max_value: 2030
      - name: is_weekend
        description: "Weekend flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_feature
    description: "Feature dimension table"
    columns:
      - name: feature_id
        description: "Unique feature identifier"
        tests:
          - unique
          - not_null
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

  - name: go_dim_license
    description: "License dimension table"
    columns:
      - name: license_id
        description: "Unique license identifier"
        tests:
          - unique
          - not_null
      - name: monthly_price
        description: "Monthly price"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000
      - name: max_participants
        description: "Maximum participants allowed"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1
              max_value: 10000

  - name: go_fact_meeting_activity
    description: "Meeting activity fact table"
    columns:
      - name: meeting_activity_id
        description: "Unique meeting activity identifier"
        tests:
          - unique
          - not_null
      - name: date_id
        description: "Foreign key to date dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_date')
              field: date_id
      - name: host_user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - relationships:
              to: ref('go_dim_user')
              field: user_dim_id
      - name: actual_duration_minutes
        description: "Actual meeting duration"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours
      - name: meeting_quality_score
        description: "Meeting quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0
      - name: participant_count
        description: "Number of participants"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000

  - name: go_fact_feature_usage
    description: "Feature usage fact table"
    columns:
      - name: feature_usage_id
        description: "Unique feature usage identifier"
        tests:
          - unique
          - not_null
      - name: date_id
        description: "Foreign key to date dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_date')
              field: date_id
      - name: feature_id
        description: "Foreign key to feature dimension"
        tests:
          - relationships:
              to: ref('go_dim_feature')
              field: feature_id
      - name: usage_count
        description: "Usage count"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000000
      - name: success_rate
        description: "Success rate percentage"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 100.0

  - name: go_fact_revenue_events
    description: "Revenue events fact table"
    columns:
      - name: revenue_event_id
        description: "Unique revenue event identifier"
        tests:
          - unique
          - not_null
      - name: date_id
        description: "Foreign key to date dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_date')
              field: date_id
      - name: net_amount
        description: "Net revenue amount"
        tests:
          - not_null
      - name: currency_code
        description: "Currency code"
        tests:
          - not_null
          - accepted_values:
              values: ['USD', 'EUR', 'GBP', 'CAD', 'AUD']
      - name: payment_status
        description: "Payment status"
        tests:
          - accepted_values:
              values: ['Paid', 'Pending', 'Failed', 'Refunded', 'Cancelled']

  - name: go_fact_support_metrics
    description: "Support metrics fact table"
    columns:
      - name: support_metrics_id
        description: "Unique support metrics identifier"
        tests:
          - unique
          - not_null
      - name: date_id
        description: "Foreign key to date dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_date')
              field: date_id
      - name: first_response_time_hours
        description: "First response time in hours"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 168  # 1 week
      - name: resolution_time_hours
        description: "Resolution time in hours"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 720  # 30 days
      - name: customer_satisfaction_score
        description: "Customer satisfaction score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0
      - name: sla_met
        description: "SLA met flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
```

### Custom SQL-based dbt Tests

```sql
-- tests/assert_user_name_standardization.sql
-- Test that user names follow proper case format
SELECT *
FROM {{ ref('go_dim_user') }}
WHERE user_name IS NOT NULL
  AND user_name != INITCAP(TRIM(user_name))
```

```sql
-- tests/assert_email_domain_extraction.sql
-- Test that email domains are correctly extracted
SELECT *
FROM {{ ref('go_dim_user') }}
WHERE email_domain IS NOT NULL
  AND email_domain NOT LIKE '%.%'
```

```sql
-- tests/assert_fiscal_year_calculation.sql
-- Test fiscal year calculation logic
SELECT *
FROM {{ ref('go_dim_date') }}
WHERE (
    (MONTH(date_value) >= 4 AND fiscal_year != YEAR(date_value))
    OR
    (MONTH(date_value) < 4 AND fiscal_year != YEAR(date_value) - 1)
)
```

```sql
-- tests/assert_meeting_duration_consistency.sql
-- Test that meeting durations are consistent
SELECT *
FROM {{ ref('go_fact_meeting_activity') }}
WHERE actual_duration_minutes < 0
   OR actual_duration_minutes > 1440  -- More than 24 hours
   OR (meeting_end_time IS NOT NULL 
       AND meeting_start_time IS NOT NULL 
       AND actual_duration_minutes != DATEDIFF('minute', meeting_start_time, meeting_end_time))
```

```sql
-- tests/assert_revenue_calculation_accuracy.sql
-- Test revenue calculation accuracy
SELECT *
FROM {{ ref('go_fact_revenue_events') }}
WHERE ABS(net_amount - (gross_amount - COALESCE(tax_amount, 0) - COALESCE(discount_amount, 0))) > 0.01
```

```sql
-- tests/assert_sla_compliance_logic.sql
-- Test SLA compliance calculation
SELECT 
    sm.*,
    sc.sla_target_hours
FROM {{ ref('go_fact_support_metrics') }} sm
JOIN {{ ref('go_dim_support_category') }} sc ON sm.support_category_id = sc.support_category_id
WHERE (
    (sm.resolution_time_hours <= sc.sla_target_hours AND sm.sla_met = FALSE)
    OR
    (sm.resolution_time_hours > sc.sla_target_hours AND sm.sla_met = TRUE)
)
```

```sql
-- tests/assert_feature_categorization.sql
-- Test feature categorization logic
SELECT *
FROM {{ ref('go_dim_feature') }}
WHERE (
    (UPPER(feature_name) LIKE '%SCREEN%SHARE%' AND feature_category != 'Collaboration')
    OR
    (UPPER(feature_name) LIKE '%RECORD%' AND feature_category != 'Recording')
    OR
    (UPPER(feature_name) LIKE '%CHAT%' AND feature_category != 'Communication')
)
```

```sql
-- tests/assert_plan_type_mapping.sql
-- Test plan type standardization
SELECT *
FROM {{ ref('go_dim_user') }}
WHERE plan_type NOT IN ('Basic', 'Pro', 'Enterprise', 'Unknown')
```

```sql
-- tests/assert_date_range_completeness.sql
-- Test that date dimension covers expected range
WITH expected_dates AS (
    SELECT 
        DATEADD(day, ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) AS expected_date
    FROM TABLE(GENERATOR(ROWCOUNT => 4018))  -- 2020-2030
),
actual_dates AS (
    SELECT date_value
    FROM {{ ref('go_dim_date') }}
)
SELECT expected_date
FROM expected_dates
WHERE expected_date NOT IN (SELECT date_value FROM actual_dates)
```

```sql
-- tests/assert_surrogate_key_uniqueness.sql
-- Test surrogate key uniqueness across all dimension tables
WITH key_counts AS (
    SELECT 'go_dim_user' as table_name, COUNT(*) as total_count, COUNT(DISTINCT user_dim_id) as unique_count
    FROM {{ ref('go_dim_user') }}
    UNION ALL
    SELECT 'go_dim_date', COUNT(*), COUNT(DISTINCT date_id)
    FROM {{ ref('go_dim_date') }}
    UNION ALL
    SELECT 'go_dim_feature', COUNT(*), COUNT(DISTINCT feature_id)
    FROM {{ ref('go_dim_feature') }}
    UNION ALL
    SELECT 'go_dim_license', COUNT(*), COUNT(DISTINCT license_id)
    FROM {{ ref('go_dim_license') }}
)
SELECT *
FROM key_counts
WHERE total_count != unique_count
```

### Parameterized Tests

```sql
-- macros/test_column_completeness.sql
{% macro test_column_completeness(model, column_name, threshold=0.95) %}
    SELECT 
        '{{ model }}' as model_name,
        '{{ column_name }}' as column_name,
        COUNT(*) as total_records,
        COUNT({{ column_name }}) as non_null_records,
        COUNT({{ column_name }}) * 1.0 / COUNT(*) as completeness_rate,
        {{ threshold }} as threshold
    FROM {{ model }}
    HAVING completeness_rate < {{ threshold }}
{% endmacro %}
```

```sql
-- tests/test_critical_column_completeness.sql
{{ test_column_completeness(ref('go_dim_user'), 'user_name', 0.98) }}
UNION ALL
{{ test_column_completeness(ref('go_dim_user'), 'plan_type', 0.95) }}
UNION ALL
{{ test_column_completeness(ref('go_fact_meeting_activity'), 'actual_duration_minutes', 0.99) }}
UNION ALL
{{ test_column_completeness(ref('go_fact_revenue_events'), 'net_amount', 1.0) }}
```

### Data Quality Monitoring Tests

```sql
-- tests/monitor_data_freshness.sql
-- Monitor data freshness across all models
WITH freshness_check AS (
    SELECT 
        'go_dim_user' as model_name,
        MAX(update_date) as last_update,
        DATEDIFF('hour', MAX(update_date), CURRENT_TIMESTAMP()) as hours_since_update
    FROM {{ ref('go_dim_user') }}
    UNION ALL
    SELECT 
        'go_fact_meeting_activity',
        MAX(update_date),
        DATEDIFF('hour', MAX(update_date), CURRENT_TIMESTAMP())
    FROM {{ ref('go_fact_meeting_activity') }}
    UNION ALL
    SELECT 
        'go_fact_feature_usage',
        MAX(update_date),
        DATEDIFF('hour', MAX(update_date), CURRENT_TIMESTAMP())
    FROM {{ ref('go_fact_feature_usage') }}
)
SELECT *
FROM freshness_check
WHERE hours_since_update > 25  -- Alert if data is more than 25 hours old
```

```sql
-- tests/monitor_record_counts.sql
-- Monitor unexpected changes in record counts
WITH current_counts AS (
    SELECT 
        'go_dim_user' as model_name,
        COUNT(*) as current_count
    FROM {{ ref('go_dim_user') }}
    UNION ALL
    SELECT 
        'go_fact_meeting_activity',
        COUNT(*)
    FROM {{ ref('go_fact_meeting_activity') }}
),
expected_ranges AS (
    SELECT 
        'go_dim_user' as model_name,
        1000 as min_expected,
        1000000 as max_expected
    UNION ALL
    SELECT 
        'go_fact_meeting_activity',
        5000,
        10000000
)
SELECT 
    c.model_name,
    c.current_count,
    e.min_expected,
    e.max_expected
FROM current_counts c
JOIN expected_ranges e ON c.model_name = e.model_name
WHERE c.current_count < e.min_expected 
   OR c.current_count > e.max_expected
```

## Test Execution Strategy

### 1. Test Execution Order
1. **Schema Tests**: Run basic uniqueness and not-null tests first
2. **Business Logic Tests**: Validate transformation rules and calculations
3. **Referential Integrity Tests**: Check foreign key relationships
4. **Data Quality Tests**: Comprehensive data quality validation
5. **Performance Tests**: Monitor query execution times

### 2. Test Automation
```bash
# Run all tests
dbt test

# Run tests for specific models
dbt test --models go_dim_user
dbt test --models go_fact_meeting_activity

# Run specific test types
dbt test --select test_type:schema
dbt test --select test_type:data

# Run tests with specific tags
dbt test --select tag:dimension
dbt test --select tag:fact
```

### 3. Test Results Tracking
- Store test results in `dbt_test_results` table
- Generate daily test summary reports
- Set up alerts for test failures
- Track test execution performance over time

## Performance Considerations

### 1. Test Optimization
- Use `LIMIT` clauses for large table tests during development
- Implement sampling strategies for performance tests
- Optimize test queries with proper indexing
- Use incremental testing for large datasets

### 2. Resource Management
- Configure appropriate warehouse sizes for test execution
- Use separate compute resources for testing
- Implement test parallelization where possible
- Monitor resource consumption during test runs

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Gold Layer dbt models in Snowflake. The tests cover all critical aspects of data transformation, business logic validation, and data quality assurance, providing confidence in the data pipeline's integrity and supporting robust analytics and reporting capabilities.

Regular execution of these tests, combined with proper monitoring and alerting, will help maintain high data quality standards and quickly identify any issues in the data transformation process.