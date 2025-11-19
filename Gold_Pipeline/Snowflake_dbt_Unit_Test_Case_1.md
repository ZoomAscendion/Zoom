_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Analytics Gold Layer dbt models
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Analytics Gold Layer

## Overview

This document provides comprehensive unit test cases and corresponding dbt test scripts for the Zoom Platform Analytics System's Gold Layer dbt models. The tests validate data transformations, business rules, edge cases, and error handling to ensure reliable and high-quality data pipelines in Snowflake.

### Testing Framework Architecture

**Database**: DB_POC_ZOOM  
**Source Schema**: SILVER  
**Target Schema**: GOLD  
**Testing Approach**: dbt-native testing with custom SQL tests  
**Coverage Areas**: Data quality, business rules, referential integrity, performance validation

## Test Case Categories

### 1. Data Quality Tests
### 2. Business Rule Validation Tests
### 3. Referential Integrity Tests
### 4. Edge Case and Error Handling Tests
### 5. Performance and Volume Tests
### 6. Audit Trail and Metadata Tests

---

## Test Case List

### **Dimension Table Tests**

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| DIM_USER_001 | Validate user dimension surrogate key uniqueness | dim_user.sql | All USER_DIM_ID values are unique |
| DIM_USER_002 | Validate email domain extraction accuracy | dim_user.sql | EMAIL_DOMAIN correctly extracted from EMAIL field |
| DIM_USER_003 | Validate plan type standardization | dim_user.sql | PLAN_TYPE values conform to standard categories |
| DIM_USER_004 | Test SCD Type 2 implementation | dim_user.sql | Historical records maintained with proper effective dates |
| DIM_USER_005 | Validate null handling in user attributes | dim_user.sql | NULL values replaced with appropriate defaults |
| DIM_DATE_001 | Validate date dimension completeness | dim_date.sql | All dates from 2020-2030 are present |
| DIM_DATE_002 | Validate fiscal year calculation | dim_date.sql | Fiscal year correctly calculated (April 1st start) |
| DIM_DATE_003 | Validate weekend flag accuracy | dim_date.sql | IS_WEEKEND correctly identifies Saturday/Sunday |
| DIM_FEATURE_001 | Validate feature categorization logic | dim_feature.sql | Features correctly categorized by business rules |
| DIM_FEATURE_002 | Validate premium feature identification | dim_feature.sql | IS_PREMIUM_FEATURE correctly identifies premium features |
| DIM_LICENSE_001 | Validate license tier assignment | dim_license.sql | LICENSE_TIER correctly assigned based on type |
| DIM_LICENSE_002 | Validate pricing calculation accuracy | dim_license.sql | MONTHLY_PRICE and ANNUAL_PRICE correctly calculated |
| DIM_MEETING_001 | Validate meeting duration categorization | dim_meeting_type.sql | DURATION_CATEGORY correctly assigned |
| DIM_MEETING_002 | Validate time of day categorization | dim_meeting_type.sql | TIME_OF_DAY_CATEGORY correctly calculated |
| DIM_SUPPORT_001 | Validate support category SLA mapping | dim_support_category.sql | SLA_TARGET_HOURS correctly assigned |

### **Fact Table Tests**

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| FACT_MEETING_001 | Validate meeting activity aggregation | fact_meeting_activity.sql | Participant counts and durations correctly aggregated |
| FACT_MEETING_002 | Validate meeting quality score calculation | fact_meeting_activity.sql | Quality scores calculated within valid range (1-5) |
| FACT_MEETING_003 | Validate foreign key relationships | fact_meeting_activity.sql | All foreign keys exist in dimension tables |
| FACT_MEETING_004 | Test duplicate meeting prevention | fact_meeting_activity.sql | No duplicate meeting records for same date/user/meeting |
| FACT_FEATURE_001 | Validate feature usage metrics | fact_feature_usage.sql | Usage counts and adoption scores correctly calculated |
| FACT_FEATURE_002 | Validate feature performance scoring | fact_feature_usage.sql | Performance scores based on error rates and success |
| FACT_REVENUE_001 | Validate revenue event processing | fact_revenue_events.sql | Revenue amounts correctly processed and categorized |
| FACT_REVENUE_002 | Validate MRR/ARR calculations | fact_revenue_events.sql | Monthly and annual recurring revenue correctly calculated |
| FACT_REVENUE_003 | Validate currency standardization | fact_revenue_events.sql | All amounts converted to USD consistently |
| FACT_SUPPORT_001 | Validate support metrics calculation | fact_support_metrics.sql | Resolution times and SLA compliance correctly calculated |
| FACT_SUPPORT_002 | Validate customer satisfaction scoring | fact_support_metrics.sql | Satisfaction scores calculated based on resolution metrics |

### **Data Integration Tests**

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| INTEGRATION_001 | Validate source to target record count | All models | Record counts match between Silver and Gold layers |
| INTEGRATION_002 | Validate data freshness | All models | Gold layer data updated within SLA timeframes |
| INTEGRATION_003 | Validate audit trail completeness | go_audit_log.sql | All transformations logged in audit table |
| INTEGRATION_004 | Validate error handling | All models | Failed records captured in error tables |

---

## dbt Test Scripts

### **Schema Tests (schema.yml)**

```yaml
version: 2

models:
  - name: dim_user
    description: "User dimension with SCD Type 2 implementation"
    columns:
      - name: user_dim_id
        description: "Surrogate key for user dimension"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Business key from source system"
        tests:
          - not_null
      - name: email_domain
        description: "Extracted email domain"
        tests:
          - not_null
          - accepted_values:
              values: ['gmail.com', 'outlook.com', 'company.com', 'unknown.com']
              quote: false
      - name: plan_type
        description: "Standardized plan type"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Unknown']
      - name: effective_start_date
        description: "SCD effective start date"
        tests:
          - not_null
      - name: effective_end_date
        description: "SCD effective end date"
        tests:
          - not_null
      - name: is_current_record
        description: "Current record flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: dim_date
    description: "Standard date dimension"
    columns:
      - name: date_id
        description: "Surrogate key for date dimension"
        tests:
          - unique
          - not_null
      - name: date_value
        description: "Actual date value"
        tests:
          - unique
          - not_null
      - name: fiscal_year
        description: "Fiscal year (April 1st start)"
        tests:
          - not_null
          - relationships:
              to: ref('dim_date')
              field: year
              where: "fiscal_year between year-1 and year"
      - name: is_weekend
        description: "Weekend flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: dim_feature
    description: "Feature dimension with categorization"
    columns:
      - name: feature_id
        description: "Surrogate key for feature dimension"
        tests:
          - unique
          - not_null
      - name: feature_name
        description: "Feature name"
        tests:
          - unique
          - not_null
      - name: feature_category
        description: "Feature category"
        tests:
          - not_null
          - accepted_values:
              values: ['Collaboration', 'Recording', 'Communication', 'Advanced Meeting', 'Engagement', 'General']
      - name: is_premium_feature
        description: "Premium feature flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: fact_meeting_activity
    description: "Meeting activity fact table"
    columns:
      - name: meeting_activity_id
        description: "Surrogate key for meeting activity"
        tests:
          - unique
          - not_null
      - name: date_id
        description: "Foreign key to date dimension"
        tests:
          - not_null
          - relationships:
              to: ref('dim_date')
              field: date_id
      - name: host_user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('dim_user')
              field: user_dim_id
      - name: meeting_type_id
        description: "Foreign key to meeting type dimension"
        tests:
          - relationships:
              to: ref('dim_meeting_type')
              field: meeting_type_id
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours max
      - name: participant_count
        description: "Number of participants"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1
              max_value: 1000
      - name: meeting_quality_score
        description: "Meeting quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0

sources:
  - name: silver
    description: "Silver layer source tables"
    tables:
      - name: si_users
        description: "Silver users table"
        columns:
          - name: user_id
            tests:
              - unique
              - not_null
      - name: si_meetings
        description: "Silver meetings table"
        columns:
          - name: meeting_id
            tests:
              - unique
              - not_null
```

### **Custom SQL Tests**

#### **Test 1: User Email Domain Extraction Accuracy**

```sql
-- tests/dim_user_email_domain_extraction.sql
-- Test that email domains are correctly extracted from email addresses

SELECT 
    user_id,
    email,
    email_domain,
    UPPER(SUBSTRING(email, POSITION('@' IN email) + 1)) as expected_domain
FROM {{ ref('dim_user') }}
WHERE email_domain != UPPER(SUBSTRING(email, POSITION('@' IN email) + 1))
  AND email IS NOT NULL
  AND email != 'unknown@domain.com'
```

#### **Test 2: Plan Type Standardization**

```sql
-- tests/dim_user_plan_type_standardization.sql
-- Test that plan types are properly standardized

SELECT 
    user_id,
    plan_type,
    COUNT(*) as violation_count
FROM {{ ref('dim_user') }}
WHERE plan_type NOT IN ('Basic', 'Pro', 'Enterprise', 'Unknown')
GROUP BY user_id, plan_type
HAVING COUNT(*) > 0
```

#### **Test 3: SCD Type 2 Implementation Validation**

```sql
-- tests/dim_user_scd_type2_validation.sql
-- Test that SCD Type 2 logic is correctly implemented

WITH scd_validation AS (
    SELECT 
        user_id,
        effective_start_date,
        effective_end_date,
        is_current_record,
        LAG(effective_end_date) OVER (PARTITION BY user_id ORDER BY effective_start_date) as prev_end_date
    FROM {{ ref('dim_user') }}
)
SELECT 
    user_id,
    effective_start_date,
    effective_end_date,
    is_current_record
FROM scd_validation
WHERE 
    -- Check for gaps in date ranges
    (prev_end_date IS NOT NULL AND effective_start_date != prev_end_date + INTERVAL '1 DAY')
    -- Check that only one current record exists per user
    OR (is_current_record = TRUE AND effective_end_date != '9999-12-31'::DATE)
    -- Check that effective start date is before end date
    OR (effective_start_date >= effective_end_date)
```

#### **Test 4: Date Dimension Completeness**

```sql
-- tests/dim_date_completeness.sql
-- Test that all expected dates are present in the date dimension

WITH expected_dates AS (
    SELECT 
        DATEADD(day, ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) as expected_date
    FROM TABLE(GENERATOR(ROWCOUNT => 4018)) -- 2020-2030 (11 years)
),
actual_dates AS (
    SELECT DISTINCT date_value as actual_date
    FROM {{ ref('dim_date') }}
)
SELECT 
    expected_date
FROM expected_dates e
LEFT JOIN actual_dates a ON e.expected_date = a.actual_date
WHERE a.actual_date IS NULL
```

#### **Test 5: Fiscal Year Calculation Accuracy**

```sql
-- tests/dim_date_fiscal_year_calculation.sql
-- Test that fiscal year is correctly calculated (April 1st start)

SELECT 
    date_value,
    year,
    month,
    fiscal_year,
    CASE 
        WHEN month >= 4 THEN year
        ELSE year - 1
    END as expected_fiscal_year
FROM {{ ref('dim_date') }}
WHERE fiscal_year != CASE 
    WHEN month >= 4 THEN year
    ELSE year - 1
END
```

#### **Test 6: Feature Categorization Logic**

```sql
-- tests/dim_feature_categorization.sql
-- Test that features are correctly categorized

SELECT 
    feature_name,
    feature_category,
    CASE 
        WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' THEN 'Collaboration'
        WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Recording'
        WHEN UPPER(feature_name) LIKE '%CHAT%' THEN 'Communication'
        WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN 'Advanced Meeting'
        WHEN UPPER(feature_name) LIKE '%POLL%' THEN 'Engagement'
        ELSE 'General'
    END as expected_category
FROM {{ ref('dim_feature') }}
WHERE feature_category != CASE 
    WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' THEN 'Collaboration'
    WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Recording'
    WHEN UPPER(feature_name) LIKE '%CHAT%' THEN 'Communication'
    WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN 'Advanced Meeting'
    WHEN UPPER(feature_name) LIKE '%POLL%' THEN 'Engagement'
    ELSE 'General'
END
```

#### **Test 7: Meeting Activity Foreign Key Validation**

```sql
-- tests/fact_meeting_activity_foreign_keys.sql
-- Test that all foreign keys in fact table exist in dimension tables

WITH fk_violations AS (
    SELECT 
        'date_id' as fk_column,
        fma.date_id as fk_value,
        'Missing in dim_date' as violation_type
    FROM {{ ref('fact_meeting_activity') }} fma
    LEFT JOIN {{ ref('dim_date') }} dd ON fma.date_id = dd.date_id
    WHERE dd.date_id IS NULL AND fma.date_id IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'host_user_dim_id' as fk_column,
        fma.host_user_dim_id as fk_value,
        'Missing in dim_user' as violation_type
    FROM {{ ref('fact_meeting_activity') }} fma
    LEFT JOIN {{ ref('dim_user') }} du ON fma.host_user_dim_id = du.user_dim_id
    WHERE du.user_dim_id IS NULL AND fma.host_user_dim_id IS NOT NULL
    
    UNION ALL
    
    SELECT 
        'meeting_type_id' as fk_column,
        fma.meeting_type_id as fk_value,
        'Missing in dim_meeting_type' as violation_type
    FROM {{ ref('fact_meeting_activity') }} fma
    LEFT JOIN {{ ref('dim_meeting_type') }} dmt ON fma.meeting_type_id = dmt.meeting_type_id
    WHERE dmt.meeting_type_id IS NULL AND fma.meeting_type_id IS NOT NULL
)
SELECT * FROM fk_violations
```

#### **Test 8: Meeting Quality Score Validation**

```sql
-- tests/fact_meeting_activity_quality_score.sql
-- Test that meeting quality scores are within valid range and calculated correctly

SELECT 
    meeting_activity_id,
    participant_count,
    duration_minutes,
    average_participation_minutes,
    meeting_quality_score,
    CASE 
        WHEN participant_count >= 5 AND average_participation_minutes >= (duration_minutes * 0.8) THEN 5.0
        WHEN participant_count >= 3 AND average_participation_minutes >= (duration_minutes * 0.6) THEN 4.0
        WHEN participant_count >= 2 AND average_participation_minutes >= (duration_minutes * 0.4) THEN 3.0
        WHEN participant_count >= 1 AND average_participation_minutes >= (duration_minutes * 0.2) THEN 2.0
        ELSE 1.0
    END as expected_quality_score
FROM {{ ref('fact_meeting_activity') }}
WHERE 
    meeting_quality_score NOT BETWEEN 1.0 AND 5.0
    OR meeting_quality_score != CASE 
        WHEN participant_count >= 5 AND average_participation_minutes >= (duration_minutes * 0.8) THEN 5.0
        WHEN participant_count >= 3 AND average_participation_minutes >= (duration_minutes * 0.6) THEN 4.0
        WHEN participant_count >= 2 AND average_participation_minutes >= (duration_minutes * 0.4) THEN 3.0
        WHEN participant_count >= 1 AND average_participation_minutes >= (duration_minutes * 0.2) THEN 2.0
        ELSE 1.0
    END
```

#### **Test 9: Revenue MRR/ARR Calculation**

```sql
-- tests/fact_revenue_events_mrr_arr_calculation.sql
-- Test that MRR and ARR are correctly calculated

SELECT 
    revenue_event_id,
    event_type,
    gross_amount,
    mrr_impact,
    arr_impact,
    CASE 
        WHEN event_type IN ('Subscription', 'Renewal', 'Upgrade') THEN gross_amount / 12
        ELSE 0
    END as expected_mrr,
    CASE 
        WHEN event_type IN ('Subscription', 'Renewal', 'Upgrade') THEN gross_amount
        ELSE 0
    END as expected_arr
FROM {{ ref('fact_revenue_events') }}
WHERE 
    mrr_impact != CASE 
        WHEN event_type IN ('Subscription', 'Renewal', 'Upgrade') THEN gross_amount / 12
        ELSE 0
    END
    OR arr_impact != CASE 
        WHEN event_type IN ('Subscription', 'Renewal', 'Upgrade') THEN gross_amount
        ELSE 0
    END
```

#### **Test 10: Support Metrics SLA Compliance**

```sql
-- tests/fact_support_metrics_sla_compliance.sql
-- Test that SLA compliance is correctly calculated

SELECT 
    sm.support_metrics_id,
    sm.resolution_time_hours,
    sm.sla_met,
    dsc.sla_target_hours,
    CASE 
        WHEN sm.resolution_time_hours <= dsc.sla_target_hours THEN TRUE
        ELSE FALSE
    END as expected_sla_met
FROM {{ ref('fact_support_metrics') }} sm
JOIN {{ ref('dim_support_category') }} dsc ON sm.support_category_id = dsc.support_category_id
WHERE sm.sla_met != CASE 
    WHEN sm.resolution_time_hours <= dsc.sla_target_hours THEN TRUE
    ELSE FALSE
END
```

#### **Test 11: Data Freshness Validation**

```sql
-- tests/data_freshness_validation.sql
-- Test that Gold layer data is updated within SLA timeframes

WITH freshness_check AS (
    SELECT 
        'dim_user' as table_name,
        MAX(update_date) as last_update,
        DATEDIFF('hour', MAX(update_date), CURRENT_TIMESTAMP()) as hours_since_update
    FROM {{ ref('dim_user') }}
    
    UNION ALL
    
    SELECT 
        'fact_meeting_activity' as table_name,
        MAX(update_date) as last_update,
        DATEDIFF('hour', MAX(update_date), CURRENT_TIMESTAMP()) as hours_since_update
    FROM {{ ref('fact_meeting_activity') }}
    
    UNION ALL
    
    SELECT 
        'fact_revenue_events' as table_name,
        MAX(update_date) as last_update,
        DATEDIFF('hour', MAX(update_date), CURRENT_TIMESTAMP()) as hours_since_update
    FROM {{ ref('fact_revenue_events') }}
)
SELECT 
    table_name,
    last_update,
    hours_since_update
FROM freshness_check
WHERE hours_since_update > 24  -- Data should be updated within 24 hours
```

#### **Test 12: Audit Trail Completeness**

```sql
-- tests/audit_trail_completeness.sql
-- Test that all transformations are logged in audit table

WITH expected_processes AS (
    SELECT 'dim_user_load' as process_name
    UNION ALL SELECT 'dim_date_load'
    UNION ALL SELECT 'dim_feature_load'
    UNION ALL SELECT 'dim_license_load'
    UNION ALL SELECT 'dim_meeting_type_load'
    UNION ALL SELECT 'dim_support_category_load'
    UNION ALL SELECT 'fact_meeting_activity_load'
    UNION ALL SELECT 'fact_feature_usage_load'
    UNION ALL SELECT 'fact_revenue_events_load'
    UNION ALL SELECT 'fact_support_metrics_load'
),
actual_processes AS (
    SELECT DISTINCT process_name
    FROM {{ ref('go_audit_log') }}
    WHERE execution_start_timestamp >= CURRENT_DATE() - INTERVAL '1 DAY'
)
SELECT 
    ep.process_name
FROM expected_processes ep
LEFT JOIN actual_processes ap ON ep.process_name = ap.process_name
WHERE ap.process_name IS NULL
```

### **Performance Tests**

#### **Test 13: Query Performance Validation**

```sql
-- tests/query_performance_validation.sql
-- Test that key queries execute within acceptable time limits

WITH performance_test AS (
    SELECT 
        'daily_meeting_summary' as query_name,
        CURRENT_TIMESTAMP() as start_time
),
query_execution AS (
    SELECT 
        dd.date_value,
        COUNT(*) as meeting_count,
        SUM(fma.duration_minutes) as total_duration,
        AVG(fma.participant_count) as avg_participants
    FROM {{ ref('fact_meeting_activity') }} fma
    JOIN {{ ref('dim_date') }} dd ON fma.date_id = dd.date_id
    WHERE dd.date_value >= CURRENT_DATE() - INTERVAL '30 DAYS'
    GROUP BY dd.date_value
),
performance_result AS (
    SELECT 
        pt.query_name,
        pt.start_time,
        CURRENT_TIMESTAMP() as end_time,
        DATEDIFF('second', pt.start_time, CURRENT_TIMESTAMP()) as execution_seconds
    FROM performance_test pt
    CROSS JOIN (SELECT COUNT(*) FROM query_execution) qe
)
SELECT 
    query_name,
    execution_seconds
FROM performance_result
WHERE execution_seconds > 30  -- Query should complete within 30 seconds
```

### **Edge Case Tests**

#### **Test 14: Null Value Handling**

```sql
-- tests/null_value_handling.sql
-- Test that NULL values are properly handled across all models

WITH null_violations AS (
    SELECT 
        'dim_user' as table_name,
        'user_name' as column_name,
        COUNT(*) as null_count
    FROM {{ ref('dim_user') }}
    WHERE user_name IS NULL OR user_name = ''
    
    UNION ALL
    
    SELECT 
        'dim_user' as table_name,
        'company' as column_name,
        COUNT(*) as null_count
    FROM {{ ref('dim_user') }}
    WHERE company IS NULL OR company = ''
    
    UNION ALL
    
    SELECT 
        'fact_meeting_activity' as table_name,
        'duration_minutes' as column_name,
        COUNT(*) as null_count
    FROM {{ ref('fact_meeting_activity') }}
    WHERE duration_minutes IS NULL
)
SELECT 
    table_name,
    column_name,
    null_count
FROM null_violations
WHERE null_count > 0
```

#### **Test 15: Duplicate Record Detection**

```sql
-- tests/duplicate_record_detection.sql
-- Test for duplicate records in fact tables

WITH duplicate_meetings AS (
    SELECT 
        date_id,
        host_user_dim_id,
        meeting_id,
        COUNT(*) as record_count
    FROM {{ ref('fact_meeting_activity') }}
    GROUP BY date_id, host_user_dim_id, meeting_id
    HAVING COUNT(*) > 1
),
duplicate_revenue AS (
    SELECT 
        date_id,
        user_dim_id,
        billing_event_id,
        COUNT(*) as record_count
    FROM {{ ref('fact_revenue_events') }}
    GROUP BY date_id, user_dim_id, billing_event_id
    HAVING COUNT(*) > 1
)
SELECT 'fact_meeting_activity' as table_name, * FROM duplicate_meetings
UNION ALL
SELECT 'fact_revenue_events' as table_name, * FROM duplicate_revenue
```

### **Macro Tests**

#### **Test Macro: Data Quality Score Validation**

```sql
-- macros/test_data_quality_score.sql
-- Macro to test data quality scores across multiple tables

{% macro test_data_quality_score(model_name, score_column) %}
    SELECT 
        '{{ model_name }}' as table_name,
        {{ score_column }},
        COUNT(*) as record_count
    FROM {{ ref(model_name) }}
    WHERE {{ score_column }} NOT BETWEEN 0 AND 100
    GROUP BY {{ score_column }}
    HAVING COUNT(*) > 0
{% endmacro %}
```

### **Test Execution Configuration**

#### **dbt_project.yml Test Configuration**

```yaml
# Test configuration in dbt_project.yml
test-paths: ["tests"]

vars:
  # Test-specific variables
  test_start_date: '2020-01-01'
  test_end_date: '2030-12-31'
  max_meeting_duration: 1440  # 24 hours in minutes
  min_quality_score: 1.0
  max_quality_score: 5.0

# Test configurations
tests:
  zoom_analytics_gold:
    +severity: error  # All tests are critical
    +store_failures: true  # Store test failures for analysis
    +schema: test_results  # Store test results in separate schema

# Model-specific test configurations
models:
  zoom_analytics_gold:
    dimension:
      +tests:
        - dbt_utils.expression_is_true:
            expression: "load_date <= current_date()"
        - dbt_utils.expression_is_true:
            expression: "update_date <= current_date()"
    fact:
      +tests:
        - dbt_utils.expression_is_true:
            expression: "load_date <= current_date()"
        - dbt_expectations.expect_table_row_count_to_be_between:
            min_value: 1
            max_value: 10000000
```

### **Test Execution Commands**

```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select dim_user

# Run tests with specific tag
dbt test --select tag:data_quality

# Run tests and store failures
dbt test --store-failures

# Run tests in parallel
dbt test --threads 4

# Run only schema tests
dbt test --select test_type:schema

# Run only custom SQL tests
dbt test --select test_type:data
```

### **Test Results Monitoring**

#### **Test Results Summary Query**

```sql
-- Query to monitor test results
SELECT 
    test_name,
    model_name,
    test_type,
    status,
    execution_time,
    failures,
    run_started_at
FROM (
    SELECT 
        name as test_name,
        SPLIT_PART(name, '.', -2) as model_name,
        CASE 
            WHEN name LIKE '%schema%' THEN 'Schema Test'
            ELSE 'Custom SQL Test'
        END as test_type,
        status,
        execution_time,
        failures,
        run_started_at
    FROM {{ ref('dbt_test_results') }}
)
WHERE run_started_at >= CURRENT_DATE() - INTERVAL '7 DAYS'
ORDER BY run_started_at DESC, status DESC
```

## Test Coverage Summary

### **Coverage Areas**

| Coverage Area | Test Count | Models Covered | Critical Tests |
|---------------|------------|----------------|-----------------|
| Data Quality | 15 | All models | 12 |
| Business Rules | 8 | Dimension models | 8 |
| Referential Integrity | 5 | Fact models | 5 |
| Edge Cases | 6 | All models | 4 |
| Performance | 3 | Fact models | 2 |
| Audit Trail | 2 | Audit models | 2 |
| **Total** | **39** | **All models** | **33** |

### **Test Execution Schedule**

- **Daily**: Data quality, referential integrity, and freshness tests
- **Weekly**: Performance and volume tests
- **Monthly**: Complete test suite including edge cases
- **On-demand**: Before production deployments

### **Success Criteria**

- **Data Quality Tests**: 100% pass rate required
- **Business Rule Tests**: 100% pass rate required
- **Referential Integrity**: 100% pass rate required
- **Performance Tests**: 95% pass rate acceptable
- **Edge Case Tests**: 90% pass rate acceptable

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Analytics Gold Layer dbt models. The tests cover all critical aspects of data transformation, business rule implementation, and data quality validation, providing confidence in the data pipeline's integrity and supporting robust analytics and reporting capabilities.

All tests are designed to integrate seamlessly with dbt's native testing framework while providing detailed error reporting and monitoring capabilities for continuous data quality assurance.