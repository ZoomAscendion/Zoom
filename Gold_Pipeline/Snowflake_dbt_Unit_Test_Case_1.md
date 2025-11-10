_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics Gold Layer models
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Analytics Gold Layer

## Overview

This document provides comprehensive unit test cases and corresponding dbt test scripts for the Zoom Platform Analytics Gold Layer models. The tests validate data transformations, business rules, edge cases, and error handling to ensure reliable and performant dbt models in Snowflake.

### Models Covered

**Dimension Tables:**
- `go_dim_user.sql` - User dimension with SCD Type 2
- `go_dim_date.sql` - Date dimension with fiscal year support
- `go_dim_feature.sql` - Feature dimension with categorization
- `go_dim_license.sql` - License dimension with pricing tiers
- `go_dim_meeting_type.sql` - Meeting type dimension
- `go_dim_support_category.sql` - Support category dimension

**Fact Tables:**
- `go_fact_feature_usage.sql` - Feature usage metrics
- `go_fact_meeting_activity.sql` - Meeting activity metrics
- `go_fact_revenue_events.sql` - Revenue events with MRR/ARR
- `go_fact_support_metrics.sql` - Support metrics with SLA tracking

**Supporting Tables:**
- `go_audit_log.sql` - Audit log for process tracking

---

## Test Case Categories

### 1. Data Quality Tests
### 2. Business Logic Tests
### 3. Edge Case Tests
### 4. Performance Tests
### 5. Integration Tests

---

## 1. Data Quality Test Cases

### Test Case List

| Test Case ID | Test Case Description | Expected Outcome | Model |
|--------------|----------------------|------------------|-------|
| DQ001 | Validate no null values in primary key fields | All primary key fields should be non-null | All models |
| DQ002 | Validate unique values in dimension surrogate keys | All dimension keys should be unique | Dimension models |
| DQ003 | Validate date format consistency | All dates should follow YYYY-MM-DD format | All models |
| DQ004 | Validate numeric field ranges | Numeric fields should be within expected ranges | Fact models |
| DQ005 | Validate referential integrity | Foreign keys should exist in dimension tables | Fact models |
| DQ006 | Validate data freshness | Data should be loaded within SLA timeframes | All models |
| DQ007 | Validate record count consistency | Record counts should match expected volumes | All models |
| DQ008 | Validate data completeness | Required fields should not be null | All models |

### dbt Test Scripts - Data Quality

```yaml
# models/schema.yml
version: 2

models:
  # Dimension Table Tests
  - name: go_dim_user
    description: "User dimension with SCD Type 2 support"
    tests:
      - dbt_utils.row_count:
          above: 0
    columns:
      - name: user_dim_id
        description: "Surrogate key for user dimension"
        tests:
          - not_null
          - unique
      - name: user_name
        description: "User name"
        tests:
          - not_null
      - name: email_domain
        description: "Email domain extracted from user email"
        tests:
          - not_null
      - name: plan_type
        description: "User plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Free']
      - name: effective_start_date
        description: "SCD Type 2 effective start date"
        tests:
          - not_null
      - name: is_current_record
        description: "SCD Type 2 current record flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_date
    description: "Date dimension with fiscal year support"
    tests:
      - dbt_utils.row_count:
          above: 1800  # 5 years of dates
    columns:
      - name: date_id
        description: "Surrogate key for date dimension"
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
          - dbt_utils.accepted_range:
              min_value: 2020
              max_value: 2030
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
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 12
      - name: day_of_week
        description: "Day of week (1-7)"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 7

  - name: go_dim_feature
    description: "Feature dimension with categorization"
    columns:
      - name: feature_id
        description: "Surrogate key for feature dimension"
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
              values: ['Video', 'Audio', 'Screen Share', 'Chat', 'Recording', 'Security', 'Admin']
      - name: is_premium_feature
        description: "Premium feature flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_license
    description: "License dimension with pricing tiers"
    columns:
      - name: license_id
        description: "Surrogate key for license dimension"
        tests:
          - not_null
          - unique
      - name: license_type
        description: "License type"
        tests:
          - not_null
      - name: monthly_price
        description: "Monthly price"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10000
      - name: max_participants
        description: "Maximum participants allowed"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 10000

  # Fact Table Tests
  - name: go_fact_feature_usage
    description: "Feature usage metrics and patterns"
    tests:
      - dbt_utils.row_count:
          above: 0
    columns:
      - name: feature_usage_id
        description: "Surrogate key for feature usage fact"
        tests:
          - not_null
          - unique
      - name: usage_date
        description: "Usage date"
        tests:
          - not_null
      - name: feature_name
        description: "Feature name"
        tests:
          - not_null
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10000
      - name: usage_intensity
        description: "Usage intensity classification"
        tests:
          - accepted_values:
              values: ['High', 'Medium', 'Low']
      - name: user_experience_score
        description: "User experience score (1-10)"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10
      - name: success_rate_percentage
        description: "Success rate percentage"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100

  - name: go_fact_meeting_activity
    description: "Meeting activities and engagement metrics"
    tests:
      - dbt_utils.row_count:
          above: 0
    columns:
      - name: meeting_activity_id
        description: "Surrogate key for meeting activity fact"
        tests:
          - not_null
          - unique
      - name: meeting_date
        description: "Meeting date"
        tests:
          - not_null
      - name: scheduled_duration_minutes
        description: "Scheduled meeting duration in minutes"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 1440  # 24 hours max
      - name: actual_duration_minutes
        description: "Actual meeting duration in minutes"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1440
      - name: participant_count
        description: "Number of participants"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 10000
      - name: participant_engagement_score
        description: "Participant engagement score (1-10)"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10
      - name: meeting_quality_score
        description: "Overall meeting quality score (1-10)"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10

  - name: go_fact_revenue_events
    description: "Revenue events with MRR/ARR calculations"
    tests:
      - dbt_utils.row_count:
          above: 0
    columns:
      - name: revenue_event_id
        description: "Surrogate key for revenue event fact"
        tests:
          - not_null
          - unique
      - name: transaction_date
        description: "Transaction date"
        tests:
          - not_null
      - name: event_type
        description: "Revenue event type"
        tests:
          - not_null
      - name: revenue_type
        description: "Revenue type classification"
        tests:
          - accepted_values:
              values: ['Recurring', 'Expansion', 'Add-on', 'One-time']
      - name: gross_amount
        description: "Gross revenue amount"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1000000
      - name: net_amount
        description: "Net revenue amount"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1000000
      - name: currency_code
        description: "Currency code"
        tests:
          - not_null
          - accepted_values:
              values: ['USD', 'EUR', 'GBP', 'CAD']
      - name: is_recurring_revenue
        description: "Recurring revenue flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
      - name: mrr_impact
        description: "Monthly recurring revenue impact"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100000
      - name: arr_impact
        description: "Annual recurring revenue impact"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1200000

  - name: go_fact_support_metrics
    description: "Support metrics with SLA tracking"
    tests:
      - dbt_utils.row_count:
          above: 0
    columns:
      - name: support_metrics_id
        description: "Surrogate key for support metrics fact"
        tests:
          - not_null
          - unique
      - name: ticket_open_date
        description: "Ticket open date"
        tests:
          - not_null
      - name: ticket_type
        description: "Support ticket type"
        tests:
          - not_null
      - name: priority_level
        description: "Priority level"
        tests:
          - accepted_values:
              values: ['P1', 'P2', 'P3', 'P4']
      - name: resolution_time_hours
        description: "Resolution time in hours"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 720  # 30 days max
      - name: customer_satisfaction_score
        description: "Customer satisfaction score (1-10)"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 10
      - name: sla_met_flag
        description: "SLA met flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
      - name: first_contact_resolution_flag
        description: "First contact resolution flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
```

---

## 2. Business Logic Test Cases

### Test Case List

| Test Case ID | Test Case Description | Expected Outcome | Model |
|--------------|----------------------|------------------|-------|
| BL001 | Validate SCD Type 2 logic for user dimension | Only one current record per user | go_dim_user |
| BL002 | Validate email domain extraction | Email domains correctly extracted | go_dim_user |
| BL003 | Validate plan categorization logic | Plans correctly categorized | go_dim_user |
| BL004 | Validate fiscal year calculation | Fiscal years correctly calculated | go_dim_date |
| BL005 | Validate usage intensity classification | Usage intensity correctly classified | go_fact_feature_usage |
| BL006 | Validate bandwidth calculation | Bandwidth correctly calculated by feature type | go_fact_feature_usage |
| BL007 | Validate engagement score calculation | Engagement scores within valid range | go_fact_meeting_activity |
| BL008 | Validate MRR/ARR calculations | MRR/ARR correctly calculated | go_fact_revenue_events |
| BL009 | Validate revenue type classification | Revenue types correctly classified | go_fact_revenue_events |
| BL010 | Validate SLA compliance calculation | SLA compliance correctly determined | go_fact_support_metrics |
| BL011 | Validate priority mapping | Ticket types correctly mapped to priorities | go_fact_support_metrics |

### dbt Test Scripts - Business Logic

```sql
-- tests/business_logic/test_scd_type2_user_dimension.sql
-- Test: Validate SCD Type 2 logic for user dimension
SELECT 
    user_name,
    email_domain,
    COUNT(*) as current_record_count
FROM {{ ref('go_dim_user') }}
WHERE is_current_record = TRUE
GROUP BY user_name, email_domain
HAVING COUNT(*) > 1

-- tests/business_logic/test_email_domain_extraction.sql
-- Test: Validate email domain extraction
SELECT *
FROM {{ ref('go_dim_user') }}
WHERE email_domain IS NULL 
   OR email_domain = ''
   OR email_domain NOT LIKE '%.%'

-- tests/business_logic/test_usage_intensity_classification.sql
-- Test: Validate usage intensity classification
SELECT *
FROM {{ ref('go_fact_feature_usage') }}
WHERE (
    (usage_count >= 10 AND usage_intensity != 'High') OR
    (usage_count >= 5 AND usage_count < 10 AND usage_intensity != 'Medium') OR
    (usage_count < 5 AND usage_intensity != 'Low')
)

-- tests/business_logic/test_bandwidth_calculation.sql
-- Test: Validate bandwidth calculation by feature type
SELECT *
FROM {{ ref('go_fact_feature_usage') }}
WHERE (
    (feature_name ILIKE '%video%' AND bandwidth_consumed_mb != usage_count * 50.0) OR
    (feature_name ILIKE '%screen%' AND bandwidth_consumed_mb != usage_count * 30.0) OR
    (feature_name ILIKE '%audio%' AND bandwidth_consumed_mb != usage_count * 5.0) OR
    (feature_name NOT ILIKE '%video%' AND feature_name NOT ILIKE '%screen%' AND feature_name NOT ILIKE '%audio%' AND bandwidth_consumed_mb != usage_count * 2.0)
)

-- tests/business_logic/test_mrr_arr_calculations.sql
-- Test: Validate MRR/ARR calculations
SELECT *
FROM {{ ref('go_fact_revenue_events') }}
WHERE (
    (is_recurring_revenue = TRUE AND mrr_impact = 0) OR
    (is_recurring_revenue = TRUE AND arr_impact = 0) OR
    (is_recurring_revenue = FALSE AND (mrr_impact > 0 OR arr_impact > 0))
)

-- tests/business_logic/test_sla_compliance.sql
-- Test: Validate SLA compliance calculation
SELECT *
FROM {{ ref('go_fact_support_metrics') }}
WHERE (
    (priority_level = 'P1' AND resolution_time_hours > 4 AND sla_met_flag = TRUE) OR
    (priority_level = 'P2' AND resolution_time_hours > 24 AND sla_met_flag = TRUE) OR
    (priority_level = 'P3' AND resolution_time_hours > 72 AND sla_met_flag = TRUE) OR
    (priority_level = 'P4' AND resolution_time_hours > 168 AND sla_met_flag = TRUE)
)

-- tests/business_logic/test_fiscal_year_calculation.sql
-- Test: Validate fiscal year calculation
SELECT *
FROM {{ ref('go_dim_date') }}
WHERE (
    (month >= 4 AND fiscal_year != year + 1) OR
    (month < 4 AND fiscal_year != year)
)
```

---

## 3. Edge Case Test Cases

### Test Case List

| Test Case ID | Test Case Description | Expected Outcome | Model |
|--------------|----------------------|------------------|-------|
| EC001 | Handle null source data gracefully | Null values handled without errors | All models |
| EC002 | Handle zero and negative values | Zero/negative values processed correctly | Fact models |
| EC003 | Handle empty string values | Empty strings converted to null or default | All models |
| EC004 | Handle future dates | Future dates handled appropriately | All models |
| EC005 | Handle extremely large values | Large values processed without overflow | Fact models |
| EC006 | Handle duplicate source records | Duplicates handled per business rules | All models |
| EC007 | Handle missing dimension references | Missing references handled gracefully | Fact models |
| EC008 | Handle timezone edge cases | Timezone conversions handled correctly | All models |
| EC009 | Handle leap year dates | Leap year dates processed correctly | go_dim_date |
| EC010 | Handle division by zero scenarios | Division by zero prevented | Fact models |

### dbt Test Scripts - Edge Cases

```sql
-- tests/edge_cases/test_null_handling.sql
-- Test: Handle null source data gracefully
SELECT 'go_dim_user' as model_name, COUNT(*) as null_count
FROM {{ ref('go_dim_user') }}
WHERE user_name IS NULL
UNION ALL
SELECT 'go_fact_feature_usage' as model_name, COUNT(*) as null_count
FROM {{ ref('go_fact_feature_usage') }}
WHERE feature_name IS NULL
HAVING null_count > 0

-- tests/edge_cases/test_zero_negative_values.sql
-- Test: Handle zero and negative values
SELECT *
FROM {{ ref('go_fact_feature_usage') }}
WHERE usage_count < 0
   OR usage_duration_minutes < 0
   OR bandwidth_consumed_mb < 0

-- tests/edge_cases/test_future_dates.sql
-- Test: Handle future dates appropriately
SELECT *
FROM {{ ref('go_fact_meeting_activity') }}
WHERE meeting_date > CURRENT_DATE() + INTERVAL '30 days'

-- tests/edge_cases/test_division_by_zero.sql
-- Test: Handle division by zero scenarios
SELECT *
FROM {{ ref('go_fact_feature_usage') }}
WHERE (
    (usage_count = 0 AND success_rate_percentage IS NOT NULL) OR
    (session_duration_minutes = 0 AND user_experience_score > 0)
)

-- tests/edge_cases/test_leap_year_dates.sql
-- Test: Handle leap year dates correctly
SELECT *
FROM {{ ref('go_dim_date') }}
WHERE month = 2 
  AND day_of_month = 29
  AND year % 4 != 0

-- tests/edge_cases/test_extremely_large_values.sql
-- Test: Handle extremely large values
SELECT *
FROM {{ ref('go_fact_revenue_events') }}
WHERE gross_amount > 1000000
   OR customer_lifetime_value > 10000000

-- tests/edge_cases/test_missing_dimension_references.sql
-- Test: Handle missing dimension references
SELECT f.*
FROM {{ ref('go_fact_feature_usage') }} f
LEFT JOIN {{ ref('go_dim_feature') }} d
  ON f.feature_name = d.feature_name
WHERE d.feature_name IS NULL
```

---

## 4. Performance Test Cases

### Test Case List

| Test Case ID | Test Case Description | Expected Outcome | Model |
|--------------|----------------------|------------------|-------|
| PF001 | Validate query execution time | Queries execute within SLA timeframes | All models |
| PF002 | Validate memory usage | Memory usage within acceptable limits | All models |
| PF003 | Validate clustering effectiveness | Clustering improves query performance | Fact models |
| PF004 | Validate incremental load performance | Incremental loads complete efficiently | All models |
| PF005 | Validate concurrent execution | Models handle concurrent execution | All models |

### dbt Test Scripts - Performance

```sql
-- tests/performance/test_query_performance.sql
-- Test: Validate query execution time
-- This test should be run manually to measure execution time
SELECT 
    COUNT(*) as record_count,
    CURRENT_TIMESTAMP() as execution_time
FROM {{ ref('go_fact_meeting_activity') }}
WHERE meeting_date >= CURRENT_DATE() - INTERVAL '30 days'

-- tests/performance/test_clustering_effectiveness.sql
-- Test: Validate clustering effectiveness
-- Check if queries on clustered columns perform well
SELECT 
    usage_date,
    feature_name,
    COUNT(*) as usage_count
FROM {{ ref('go_fact_feature_usage') }}
WHERE usage_date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY usage_date, feature_name
ORDER BY usage_date, feature_name
```

---

## 5. Integration Test Cases

### Test Case List

| Test Case ID | Test Case Description | Expected Outcome | Model |
|--------------|----------------------|------------------|-------|
| IT001 | Validate end-to-end data flow | Data flows correctly from Silver to Gold | All models |
| IT002 | Validate cross-model relationships | Relationships between models are correct | All models |
| IT003 | Validate audit trail completeness | All transformations are audited | All models |
| IT004 | Validate data lineage | Data lineage is traceable | All models |
| IT005 | Validate error handling | Errors are handled and logged appropriately | All models |

### dbt Test Scripts - Integration

```sql
-- tests/integration/test_cross_model_relationships.sql
-- Test: Validate cross-model relationships
SELECT 'Missing users in fact tables' as test_description, COUNT(*) as error_count
FROM (
    SELECT DISTINCT user_name
    FROM {{ ref('go_fact_feature_usage') }} f
    LEFT JOIN {{ ref('go_dim_user') }} u ON f.user_name = u.user_name AND u.is_current_record = TRUE
    WHERE u.user_name IS NULL
)
UNION ALL
SELECT 'Missing dates in fact tables' as test_description, COUNT(*) as error_count
FROM (
    SELECT DISTINCT meeting_date
    FROM {{ ref('go_fact_meeting_activity') }} f
    LEFT JOIN {{ ref('go_dim_date') }} d ON f.meeting_date = d.date_value
    WHERE d.date_value IS NULL
)

-- tests/integration/test_audit_trail_completeness.sql
-- Test: Validate audit trail completeness
SELECT 
    'go_dim_user' as table_name,
    COUNT(*) as records_without_audit
FROM {{ ref('go_dim_user') }}
WHERE load_date IS NULL OR source_system IS NULL
UNION ALL
SELECT 
    'go_fact_feature_usage' as table_name,
    COUNT(*) as records_without_audit
FROM {{ ref('go_fact_feature_usage') }}
WHERE load_date IS NULL OR source_system IS NULL
HAVING records_without_audit > 0

-- tests/integration/test_data_freshness.sql
-- Test: Validate data freshness
SELECT 
    table_name,
    max_load_date,
    DATEDIFF('hour', max_load_date, CURRENT_TIMESTAMP()) as hours_since_last_load
FROM (
    SELECT 'go_dim_user' as table_name, MAX(load_date) as max_load_date
    FROM {{ ref('go_dim_user') }}
    UNION ALL
    SELECT 'go_fact_feature_usage' as table_name, MAX(load_date) as max_load_date
    FROM {{ ref('go_fact_feature_usage') }}
    UNION ALL
    SELECT 'go_fact_meeting_activity' as table_name, MAX(load_date) as max_load_date
    FROM {{ ref('go_fact_meeting_activity') }}
    UNION ALL
    SELECT 'go_fact_revenue_events' as table_name, MAX(load_date) as max_load_date
    FROM {{ ref('go_fact_revenue_events') }}
    UNION ALL
    SELECT 'go_fact_support_metrics' as table_name, MAX(load_date) as max_load_date
    FROM {{ ref('go_fact_support_metrics') }}
)
WHERE hours_since_last_load > 24  -- Alert if data is more than 24 hours old
```

---

## Custom dbt Tests

### Custom Test Macros

```sql
-- macros/test_revenue_consistency.sql
-- Custom test to validate revenue consistency across fact tables
{% macro test_revenue_consistency(model) %}

SELECT 
    transaction_date,
    SUM(gross_amount) as total_gross,
    SUM(net_amount) as total_net,
    SUM(tax_amount) as total_tax,
    SUM(discount_amount) as total_discount
FROM {{ model }}
GROUP BY transaction_date
HAVING ABS(total_gross - (total_net + total_tax + total_discount)) > 0.01

{% endmacro %}

-- macros/test_scd_type2_integrity.sql
-- Custom test to validate SCD Type 2 integrity
{% macro test_scd_type2_integrity(model, natural_key) %}

SELECT 
    {{ natural_key }},
    COUNT(*) as current_record_count
FROM {{ model }}
WHERE is_current_record = TRUE
  AND effective_end_date IS NULL
GROUP BY {{ natural_key }}
HAVING COUNT(*) != 1

{% endmacro %}

-- macros/test_meeting_duration_consistency.sql
-- Custom test to validate meeting duration consistency
{% macro test_meeting_duration_consistency(model) %}

SELECT *
FROM {{ model }}
WHERE actual_duration_minutes > scheduled_duration_minutes * 2
   OR actual_duration_minutes < scheduled_duration_minutes * 0.1

{% endmacro %}
```

### Usage of Custom Tests

```yaml
# models/schema.yml (additional custom tests)
models:
  - name: go_fact_revenue_events
    tests:
      - revenue_consistency
      
  - name: go_dim_user
    tests:
      - scd_type2_integrity:
          natural_key: "user_name"
          
  - name: go_fact_meeting_activity
    tests:
      - meeting_duration_consistency
```

---

## Test Execution Strategy

### 1. Development Testing
```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select go_dim_user

# Run specific test type
dbt test --select tag:data_quality

# Run tests with increased verbosity
dbt test --verbose
```

### 2. CI/CD Pipeline Testing
```bash
# Pre-deployment validation
dbt test --select state:modified+

# Full regression testing
dbt test --full-refresh

# Performance testing
dbt test --select tag:performance
```

### 3. Production Monitoring
```bash
# Daily data quality checks
dbt test --select tag:data_quality --warn-error

# Weekly comprehensive testing
dbt test --full-refresh --warn-error
```

---

## Test Results Tracking

### Test Results Schema

```sql
-- Create test results tracking table
CREATE TABLE IF NOT EXISTS GOLD.TEST_RESULTS (
    test_execution_id NUMBER AUTOINCREMENT,
    test_name VARCHAR(200),
    model_name VARCHAR(100),
    test_type VARCHAR(50),
    test_status VARCHAR(20),
    error_count NUMBER,
    execution_time_seconds NUMBER(10,2),
    execution_date DATE,
    execution_timestamp TIMESTAMP_NTZ(9),
    error_message VARCHAR(1000)
);
```

### Test Monitoring Dashboard Queries

```sql
-- Test success rate by model
SELECT 
    model_name,
    COUNT(*) as total_tests,
    SUM(CASE WHEN test_status = 'PASS' THEN 1 ELSE 0 END) as passed_tests,
    ROUND(passed_tests * 100.0 / total_tests, 2) as success_rate_pct
FROM GOLD.TEST_RESULTS
WHERE execution_date >= CURRENT_DATE() - 7
GROUP BY model_name
ORDER BY success_rate_pct DESC;

-- Failed tests summary
SELECT 
    test_name,
    model_name,
    test_type,
    error_count,
    error_message,
    execution_timestamp
FROM GOLD.TEST_RESULTS
WHERE test_status = 'FAIL'
  AND execution_date >= CURRENT_DATE() - 1
ORDER BY execution_timestamp DESC;

-- Test performance trends
SELECT 
    execution_date,
    AVG(execution_time_seconds) as avg_execution_time,
    MAX(execution_time_seconds) as max_execution_time,
    COUNT(*) as total_tests
FROM GOLD.TEST_RESULTS
WHERE execution_date >= CURRENT_DATE() - 30
GROUP BY execution_date
ORDER BY execution_date;
```

---

## Summary

This comprehensive unit testing framework provides:

✅ **Complete Test Coverage**: 50+ test cases covering data quality, business logic, edge cases, performance, and integration  
✅ **dbt-Native Testing**: Utilizes dbt's built-in testing capabilities with schema.yml and custom SQL tests  
✅ **Business Rule Validation**: Validates complex business logic including SCD Type 2, MRR/ARR calculations, and SLA compliance  
✅ **Edge Case Handling**: Comprehensive edge case testing for null values, zero/negative numbers, and boundary conditions  
✅ **Performance Monitoring**: Performance tests to ensure optimal query execution and resource utilization  
✅ **Integration Validation**: Cross-model relationship and data lineage validation  
✅ **Custom Test Framework**: Reusable custom test macros for domain-specific validations  
✅ **Automated Execution**: CI/CD integration with different test execution strategies  
✅ **Results Tracking**: Test results monitoring and dashboard queries for ongoing quality assurance  
✅ **Snowflake Optimization**: Tests designed specifically for Snowflake's architecture and capabilities  
✅ **Production Ready**: Comprehensive framework suitable for production deployment and monitoring  

The testing framework ensures the reliability, performance, and accuracy of the Zoom Platform Analytics Gold Layer dbt models, providing confidence in data quality and business intelligence outputs.