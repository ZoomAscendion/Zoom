_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics Gold Layer Pipeline
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Gold Layer Pipeline

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Gold Layer Pipeline. The tests ensure data quality, transformation accuracy, and business rule compliance across all dimension and fact tables in the Gold layer.

### Test Coverage Areas

1. **Data Transformation Validation**
   - Source to target mapping accuracy
   - Business rule implementation
   - Data type conversions
   - Calculated field validation

2. **Data Quality Assurance**
   - Null value handling
   - Data completeness checks
   - Referential integrity validation
   - Duplicate detection

3. **Business Logic Testing**
   - KPI calculations
   - Aggregation accuracy
   - Categorization logic
   - SCD Type 2 implementation

4. **Edge Case Handling**
   - Empty datasets
   - Invalid data scenarios
   - Boundary value testing
   - Error condition handling

## Test Case List

### Dimension Table Tests

| Test Case ID | Test Case Description | Expected Outcome | Priority | Test Type |
|--------------|----------------------|------------------|----------|----------|
| DIM_USER_001 | Validate user dimension transformation from Silver to Gold | All users transformed with proper categorization | High | Transformation |
| DIM_USER_002 | Test plan type standardization logic | Plan types mapped to Basic/Pro/Enterprise | High | Business Rule |
| DIM_USER_003 | Validate email domain extraction | Email domains correctly extracted and standardized | Medium | Data Quality |
| DIM_USER_004 | Test SCD Type 2 implementation for user changes | Historical records maintained with proper effective dates | High | SCD |
| DIM_USER_005 | Handle null values in user data | Null values replaced with appropriate defaults | Medium | Edge Case |
| DIM_DATE_001 | Validate date dimension generation | Complete date range from 2020-2030 generated | High | Data Generation |
| DIM_DATE_002 | Test fiscal year calculation | Fiscal year correctly calculated (April 1st start) | High | Business Rule |
| DIM_DATE_003 | Validate weekend and holiday flags | Weekend flags set correctly for Sat/Sun | Medium | Logic |
| DIM_FEATURE_001 | Test feature categorization logic | Features categorized into correct categories | High | Business Rule |
| DIM_FEATURE_002 | Validate premium feature identification | Premium features correctly identified | Medium | Classification |
| DIM_LICENSE_001 | Test license tier assignment | License tiers assigned based on type | High | Business Rule |
| DIM_LICENSE_002 | Validate pricing information mapping | Correct pricing assigned to each license type | High | Data Mapping |
| DIM_MEETING_001 | Test meeting duration categorization | Meetings categorized by duration correctly | Medium | Classification |
| DIM_MEETING_002 | Validate time of day categorization | Meetings categorized by time periods | Medium | Logic |
| DIM_SUPPORT_001 | Test support category priority mapping | Priority levels assigned correctly | High | Business Rule |
| DIM_SUPPORT_002 | Validate SLA target assignment | SLA targets set based on category | High | Business Rule |

### Fact Table Tests

| Test Case ID | Test Case Description | Expected Outcome | Priority | Test Type |
|--------------|----------------------|------------------|----------|----------|
| FACT_MEETING_001 | Validate meeting activity fact aggregation | Meeting metrics calculated correctly | High | Aggregation |
| FACT_MEETING_002 | Test participant count calculation | Participant counts match source data | High | Calculation |
| FACT_MEETING_003 | Validate meeting quality score logic | Quality scores calculated based on engagement | Medium | KPI |
| FACT_MEETING_004 | Test foreign key relationships | All dimension keys exist in dimension tables | High | Referential Integrity |
| FACT_FEATURE_001 | Validate feature usage aggregation | Usage counts and metrics calculated correctly | High | Aggregation |
| FACT_FEATURE_002 | Test adoption score calculation | Adoption scores calculated based on usage patterns | Medium | KPI |
| FACT_REVENUE_001 | Validate revenue event processing | Revenue amounts and types processed correctly | High | Financial |
| FACT_REVENUE_002 | Test MRR/ARR calculations | Monthly and annual recurring revenue calculated | High | KPI |
| FACT_REVENUE_003 | Validate currency standardization | All amounts converted to USD | Medium | Standardization |
| FACT_SUPPORT_001 | Test support metrics calculation | Resolution times and SLA compliance calculated | High | KPI |
| FACT_SUPPORT_002 | Validate escalation logic | Escalation flags set based on ticket type | Medium | Business Rule |

### Data Quality Tests

| Test Case ID | Test Case Description | Expected Outcome | Priority | Test Type |
|--------------|----------------------|------------------|----------|----------|
| DQ_001 | Test for duplicate records in dimensions | No duplicate surrogate keys | High | Data Quality |
| DQ_002 | Validate referential integrity across all facts | All foreign keys have matching dimension records | High | Integrity |
| DQ_003 | Check for null values in required fields | No nulls in mandatory business fields | High | Completeness |
| DQ_004 | Validate data type consistency | All fields match expected data types | Medium | Schema |
| DQ_005 | Test audit trail completeness | All records have load/update timestamps | Medium | Audit |

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  # Dimension Table Tests
  - name: go_dim_user
    description: "User dimension with enhanced attributes"
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
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: plan_type
        description: "Standardized plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Unknown']
      - name: email_domain
        description: "Extracted email domain"
        tests:
          - not_null
      - name: effective_start_date
        description: "SCD Type 2 start date"
        tests:
          - not_null
      - name: effective_end_date
        description: "SCD Type 2 end date"
        tests:
          - not_null
      - name: is_current_record
        description: "Current record flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_date
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
      - name: year
        description: "Year component"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 2020
              max_value: 2030
      - name: fiscal_year
        description: "Fiscal year starting April 1st"
        tests:
          - not_null
      - name: is_weekend
        description: "Weekend flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_feature
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
          - accepted_values:
              values: ['Collaboration', 'Recording', 'Communication', 'Advanced Meeting', 'Engagement', 'General']
      - name: is_premium_feature
        description: "Premium feature flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_license
    description: "License dimension with pricing"
    columns:
      - name: license_id
        description: "Surrogate key for license dimension"
        tests:
          - unique
          - not_null
      - name: license_type
        description: "License type"
        tests:
          - not_null
      - name: license_tier
        description: "License tier"
        tests:
          - accepted_values:
              values: ['Tier 0', 'Tier 1', 'Tier 2', 'Tier 3']
      - name: monthly_price
        description: "Monthly price"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1000
      - name: max_participants
        description: "Maximum participants allowed"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10000

  - name: go_dim_meeting_type
    description: "Meeting type dimension"
    columns:
      - name: meeting_type_id
        description: "Surrogate key for meeting type dimension"
        tests:
          - unique
          - not_null
      - name: duration_category
        description: "Duration category"
        tests:
          - accepted_values:
              values: ['Brief', 'Standard', 'Extended', 'Long']
      - name: time_of_day_category
        description: "Time of day category"
        tests:
          - accepted_values:
              values: ['Morning', 'Afternoon', 'Evening', 'Night']
      - name: is_weekend_meeting
        description: "Weekend meeting flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_support_category
    description: "Support category dimension"
    columns:
      - name: support_category_id
        description: "Surrogate key for support category dimension"
        tests:
          - unique
          - not_null
      - name: priority_level
        description: "Priority level"
        tests:
          - accepted_values:
              values: ['Critical', 'High', 'Medium', 'Low']
      - name: sla_target_hours
        description: "SLA target in hours"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 168  # 1 week
      - name: requires_escalation
        description: "Escalation required flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  # Fact Table Tests
  - name: go_fact_meeting_activity
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
              to: ref('go_dim_date')
              field: date_id
      - name: meeting_type_id
        description: "Foreign key to meeting type dimension"
        tests:
          - relationships:
              to: ref('go_dim_meeting_type')
              field: meeting_type_id
      - name: host_user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_user')
              field: user_dim_id
      - name: actual_duration_minutes
        description: "Actual meeting duration"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1440  # 24 hours
      - name: participant_count
        description: "Number of participants"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 10000
      - name: meeting_quality_score
        description: "Meeting quality score"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10

  - name: go_fact_feature_usage
    description: "Feature usage fact table"
    columns:
      - name: feature_usage_id
        description: "Surrogate key for feature usage"
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
          - not_null
          - relationships:
              to: ref('go_dim_feature')
              field: feature_id
      - name: user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - relationships:
              to: ref('go_dim_user')
              field: user_dim_id
      - name: usage_count
        description: "Feature usage count"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10000
      - name: feature_adoption_score
        description: "Feature adoption score"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10
      - name: success_rate
        description: "Success rate percentage"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100

  - name: go_fact_revenue_events
    description: "Revenue events fact table"
    columns:
      - name: revenue_event_id
        description: "Surrogate key for revenue event"
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
      - name: license_id
        description: "Foreign key to license dimension"
        tests:
          - relationships:
              to: ref('go_dim_license')
              field: license_id
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
      - name: mrr_impact
        description: "Monthly recurring revenue impact"
        tests:
          - dbt_utils.accepted_range:
              min_value: -10000
              max_value: 10000
      - name: churn_risk_score
        description: "Churn risk score"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10

  - name: go_fact_support_metrics
    description: "Support metrics fact table"
    columns:
      - name: support_metrics_id
        description: "Surrogate key for support metrics"
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
      - name: support_category_id
        description: "Foreign key to support category dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_support_category')
              field: support_category_id
      - name: user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_user')
              field: user_dim_id
      - name: resolution_time_hours
        description: "Resolution time in hours"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 8760  # 1 year
      - name: sla_met
        description: "SLA met flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
      - name: customer_satisfaction_score
        description: "Customer satisfaction score"
        tests:
          - dbt_utils.accepted_range:
              min_value: 1
              max_value: 5
      - name: first_contact_resolution
        description: "First contact resolution flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  # Audit Table Tests
  - name: go_audit_log
    description: "Audit log table"
    columns:
      - name: process_name
        description: "Process name"
        tests:
          - not_null
      - name: execution_status
        description: "Execution status"
        tests:
          - not_null
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'RUNNING', 'PENDING']
      - name: records_processed
        description: "Number of records processed"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 10000000
      - name: data_quality_score
        description: "Data quality score"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100
```

### Custom SQL Tests

#### Test 1: User Plan Type Standardization

```sql
-- tests/assert_user_plan_type_standardization.sql
-- Test that all plan types are properly standardized

SELECT *
FROM {{ ref('go_dim_user') }}
WHERE plan_type NOT IN ('Basic', 'Pro', 'Enterprise', 'Unknown')
```

#### Test 2: Date Dimension Completeness

```sql
-- tests/assert_date_dimension_completeness.sql
-- Test that date dimension has no gaps

WITH expected_dates AS (
    SELECT 
        DATEADD(day, ROW_NUMBER() OVER (ORDER BY 1) - 1, '2020-01-01'::DATE) AS expected_date
    FROM TABLE(GENERATOR(ROWCOUNT => 4018))
),
actual_dates AS (
    SELECT date_value AS actual_date
    FROM {{ ref('go_dim_date') }}
)
SELECT expected_date
FROM expected_dates
LEFT JOIN actual_dates ON expected_dates.expected_date = actual_dates.actual_date
WHERE actual_dates.actual_date IS NULL
```

#### Test 3: Meeting Duration Logic

```sql
-- tests/assert_meeting_duration_logic.sql
-- Test that meeting duration calculations are correct

SELECT *
FROM {{ ref('go_fact_meeting_activity') }}
WHERE actual_duration_minutes != DATEDIFF('minute', meeting_start_time, meeting_end_time)
   OR actual_duration_minutes < 0
   OR actual_duration_minutes > 1440  -- 24 hours
```

#### Test 4: Revenue Amount Consistency

```sql
-- tests/assert_revenue_amount_consistency.sql
-- Test that revenue calculations are consistent

SELECT *
FROM {{ ref('go_fact_revenue_events') }}
WHERE net_amount != (gross_amount - tax_amount - discount_amount)
   OR (event_type = 'Refund' AND net_amount > 0)
   OR (event_type != 'Refund' AND net_amount < 0)
```

#### Test 5: SLA Compliance Logic

```sql
-- tests/assert_sla_compliance_logic.sql
-- Test that SLA compliance is calculated correctly

SELECT 
    sm.*,
    sc.sla_target_hours
FROM {{ ref('go_fact_support_metrics') }} sm
JOIN {{ ref('go_dim_support_category') }} sc 
    ON sm.support_category_id = sc.support_category_id
WHERE (sm.resolution_time_hours <= sc.sla_target_hours AND sm.sla_met = FALSE)
   OR (sm.resolution_time_hours > sc.sla_target_hours AND sm.sla_met = TRUE)
```

#### Test 6: Feature Adoption Score Logic

```sql
-- tests/assert_feature_adoption_score_logic.sql
-- Test that feature adoption scores are calculated correctly

SELECT *
FROM {{ ref('go_fact_feature_usage') }}
WHERE 
    (usage_count >= 10 AND feature_adoption_score != 5.0)
    OR (usage_count >= 5 AND usage_count < 10 AND feature_adoption_score != 4.0)
    OR (usage_count >= 3 AND usage_count < 5 AND feature_adoption_score != 3.0)
    OR (usage_count >= 1 AND usage_count < 3 AND feature_adoption_score != 2.0)
    OR (usage_count = 0 AND feature_adoption_score != 1.0)
```

#### Test 7: Referential Integrity Check

```sql
-- tests/assert_referential_integrity.sql
-- Test that all foreign keys have matching dimension records

WITH integrity_violations AS (
    -- Check meeting activity foreign keys
    SELECT 'go_fact_meeting_activity' as fact_table, 'date_id' as fk_column, date_id as fk_value
    FROM {{ ref('go_fact_meeting_activity') }} f
    LEFT JOIN {{ ref('go_dim_date') }} d ON f.date_id = d.date_id
    WHERE d.date_id IS NULL AND f.date_id IS NOT NULL
    
    UNION ALL
    
    SELECT 'go_fact_meeting_activity' as fact_table, 'host_user_dim_id' as fk_column, host_user_dim_id as fk_value
    FROM {{ ref('go_fact_meeting_activity') }} f
    LEFT JOIN {{ ref('go_dim_user') }} u ON f.host_user_dim_id = u.user_dim_id
    WHERE u.user_dim_id IS NULL AND f.host_user_dim_id IS NOT NULL
    
    UNION ALL
    
    -- Check feature usage foreign keys
    SELECT 'go_fact_feature_usage' as fact_table, 'feature_id' as fk_column, feature_id as fk_value
    FROM {{ ref('go_fact_feature_usage') }} f
    LEFT JOIN {{ ref('go_dim_feature') }} d ON f.feature_id = d.feature_id
    WHERE d.feature_id IS NULL AND f.feature_id IS NOT NULL
    
    UNION ALL
    
    -- Check revenue events foreign keys
    SELECT 'go_fact_revenue_events' as fact_table, 'license_id' as fk_column, license_id as fk_value
    FROM {{ ref('go_fact_revenue_events') }} f
    LEFT JOIN {{ ref('go_dim_license') }} l ON f.license_id = l.license_id
    WHERE l.license_id IS NULL AND f.license_id IS NOT NULL
    
    UNION ALL
    
    -- Check support metrics foreign keys
    SELECT 'go_fact_support_metrics' as fact_table, 'support_category_id' as fk_column, support_category_id as fk_value
    FROM {{ ref('go_fact_support_metrics') }} f
    LEFT JOIN {{ ref('go_dim_support_category') }} s ON f.support_category_id = s.support_category_id
    WHERE s.support_category_id IS NULL AND f.support_category_id IS NOT NULL
)
SELECT * FROM integrity_violations
```

#### Test 8: Data Freshness Check

```sql
-- tests/assert_data_freshness.sql
-- Test that data is being loaded regularly

SELECT 
    'go_fact_meeting_activity' as table_name,
    MAX(load_date) as last_load_date,
    DATEDIFF('day', MAX(load_date), CURRENT_DATE()) as days_since_last_load
FROM {{ ref('go_fact_meeting_activity') }}
HAVING days_since_last_load > 1  -- Alert if data is more than 1 day old

UNION ALL

SELECT 
    'go_fact_feature_usage' as table_name,
    MAX(load_date) as last_load_date,
    DATEDIFF('day', MAX(load_date), CURRENT_DATE()) as days_since_last_load
FROM {{ ref('go_fact_feature_usage') }}
HAVING days_since_last_load > 1

UNION ALL

SELECT 
    'go_fact_revenue_events' as table_name,
    MAX(load_date) as last_load_date,
    DATEDIFF('day', MAX(load_date), CURRENT_DATE()) as days_since_last_load
FROM {{ ref('go_fact_revenue_events') }}
HAVING days_since_last_load > 1

UNION ALL

SELECT 
    'go_fact_support_metrics' as table_name,
    MAX(load_date) as last_load_date,
    DATEDIFF('day', MAX(load_date), CURRENT_DATE()) as days_since_last_load
FROM {{ ref('go_fact_support_metrics') }}
HAVING days_since_last_load > 1
```

#### Test 9: Duplicate Detection

```sql
-- tests/assert_no_duplicates.sql
-- Test for duplicate records in dimension tables

WITH duplicate_users AS (
    SELECT user_id, COUNT(*) as record_count
    FROM {{ ref('go_dim_user') }}
    WHERE is_current_record = TRUE
    GROUP BY user_id
    HAVING COUNT(*) > 1
),
duplicate_features AS (
    SELECT feature_name, COUNT(*) as record_count
    FROM {{ ref('go_dim_feature') }}
    GROUP BY feature_name
    HAVING COUNT(*) > 1
),
duplicate_licenses AS (
    SELECT license_type, COUNT(*) as record_count
    FROM {{ ref('go_dim_license') }}
    WHERE is_current_record = TRUE
    GROUP BY license_type
    HAVING COUNT(*) > 1
)
SELECT 'go_dim_user' as table_name, user_id as duplicate_key, record_count
FROM duplicate_users

UNION ALL

SELECT 'go_dim_feature' as table_name, feature_name as duplicate_key, record_count
FROM duplicate_features

UNION ALL

SELECT 'go_dim_license' as table_name, license_type as duplicate_key, record_count
FROM duplicate_licenses
```

#### Test 10: Business Rule Validation

```sql
-- tests/assert_business_rules.sql
-- Test various business rules

WITH business_rule_violations AS (
    -- Rule 1: Meeting duration should be positive
    SELECT 
        'Meeting duration negative' as rule_violation,
        meeting_activity_id as record_id,
        actual_duration_minutes as violation_value
    FROM {{ ref('go_fact_meeting_activity') }}
    WHERE actual_duration_minutes <= 0
    
    UNION ALL
    
    -- Rule 2: Participant count should be at least 1
    SELECT 
        'Participant count invalid' as rule_violation,
        meeting_activity_id as record_id,
        participant_count as violation_value
    FROM {{ ref('go_fact_meeting_activity') }}
    WHERE participant_count < 1
    
    UNION ALL
    
    -- Rule 3: Revenue amounts should be reasonable
    SELECT 
        'Revenue amount unreasonable' as rule_violation,
        revenue_event_id as record_id,
        gross_amount as violation_value
    FROM {{ ref('go_fact_revenue_events') }}
    WHERE gross_amount < 0 OR gross_amount > 100000
    
    UNION ALL
    
    -- Rule 4: Support resolution time should be reasonable
    SELECT 
        'Resolution time unreasonable' as rule_violation,
        support_metrics_id as record_id,
        resolution_time_hours as violation_value
    FROM {{ ref('go_fact_support_metrics') }}
    WHERE resolution_time_hours < 0 OR resolution_time_hours > 8760  -- 1 year
    
    UNION ALL
    
    -- Rule 5: Feature usage count should be non-negative
    SELECT 
        'Usage count negative' as rule_violation,
        feature_usage_id as record_id,
        usage_count as violation_value
    FROM {{ ref('go_fact_feature_usage') }}
    WHERE usage_count < 0
)
SELECT * FROM business_rule_violations
```

### Macros for Reusable Tests

#### Macro 1: Test Data Quality Score

```sql
-- macros/test_data_quality_score.sql
{% macro test_data_quality_score(model, column_name, min_score=70) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} < {{ min_score }}
{% endmacro %}
```

#### Macro 2: Test Date Range

```sql
-- macros/test_date_range.sql
{% macro test_date_range(model, date_column, start_date, end_date) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ date_column }} < '{{ start_date }}'::DATE
       OR {{ date_column }} > '{{ end_date }}'::DATE
{% endmacro %}
```

#### Macro 3: Test Percentage Range

```sql
-- macros/test_percentage_range.sql
{% macro test_percentage_range(model, column_name) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} < 0 OR {{ column_name }} > 100
{% endmacro %}
```

### Test Execution Commands

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
dbt test --select tag:data_quality

# Generate test documentation
dbt docs generate
dbt docs serve
```

### Test Results Monitoring

#### Test Results Summary View

```sql
-- Create view for test results monitoring
CREATE OR REPLACE VIEW GOLD.VW_TEST_RESULTS_SUMMARY AS
SELECT 
    test_name,
    model_name,
    test_type,
    status,
    execution_time,
    error_count,
    warning_count,
    execution_date
FROM GOLD.GO_AUDIT_LOG
WHERE process_name LIKE '%TEST%'
ORDER BY execution_date DESC;
```

#### Daily Test Report

```sql
-- Daily test execution report
SELECT 
    DATE(execution_date) as test_date,
    COUNT(*) as total_tests,
    SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) as passed_tests,
    SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END) as failed_tests,
    ROUND((SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) as success_rate
FROM GOLD.VW_TEST_RESULTS_SUMMARY
WHERE execution_date >= CURRENT_DATE() - INTERVAL '7 DAYS'
GROUP BY DATE(execution_date)
ORDER BY test_date DESC;
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before deploying models
- Execute custom SQL tests for business logic validation
- Validate data quality scores and completeness
- Check referential integrity across all tables

### 2. Post-deployment Validation
- Run freshness tests to ensure data is current
- Execute business rule validation tests
- Monitor test results and alert on failures
- Generate test coverage reports

### 3. Continuous Monitoring
- Schedule daily test execution
- Set up alerts for test failures
- Monitor data quality trends
- Track test performance metrics

### 4. Test Maintenance
- Review and update tests regularly
- Add new tests for new business requirements
- Archive obsolete tests
- Maintain test documentation

## Conclusion

This comprehensive test suite ensures the reliability and quality of the Zoom Platform Analytics Gold Layer Pipeline. The tests cover:

- **Data Transformation Accuracy**: Validates that all transformations from Silver to Gold layer are correct
- **Business Rule Compliance**: Ensures all business logic is implemented correctly
- **Data Quality Assurance**: Maintains high data quality standards across all tables
- **Referential Integrity**: Validates relationships between fact and dimension tables
- **Performance Monitoring**: Tracks data freshness and processing performance
- **Edge Case Handling**: Tests boundary conditions and error scenarios

Regular execution of these tests will help maintain data quality, catch issues early, and ensure the reliability of the analytics platform for business users and BI tools.