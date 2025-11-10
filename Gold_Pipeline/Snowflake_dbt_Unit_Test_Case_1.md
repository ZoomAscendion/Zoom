_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Gold Layer dbt models
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Analytics Gold Layer

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Gold Layer models. The tests cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and reliability in the Snowflake environment.

## Models Under Test

### Dimension Models
1. `go_audit_log` - Audit logging for pipeline execution
2. `go_dim_date` - Date dimension table
3. `go_dim_user` - User dimension with SCD Type 2
4. `go_dim_feature` - Feature dimension
5. `go_dim_license` - License dimension
6. `go_dim_meeting_type` - Meeting type dimension
7. `go_dim_support_category` - Support category dimension

### Fact Models
1. `go_fact_feature_usage` - Feature usage metrics
2. `go_fact_meeting_activity` - Meeting activity metrics
3. `go_fact_revenue_events` - Revenue and billing events
4. `go_fact_support_metrics` - Support ticket metrics

## Test Case Categories

### 1. Data Quality Tests
### 2. Business Rule Validation Tests
### 3. Edge Case Tests
### 4. Performance Tests
### 5. Integration Tests

---

## Test Case List

| Test Case ID | Test Case Description | Model | Expected Outcome | Test Type |
|--------------|----------------------|-------|------------------|----------|
| TC_001 | Validate audit log execution ID uniqueness | go_audit_log | All execution IDs are unique | Data Quality |
| TC_002 | Verify date dimension completeness | go_dim_date | All dates from 2020-2030 present | Data Quality |
| TC_003 | Test user dimension SCD Type 2 logic | go_dim_user | Proper versioning of user records | Business Rule |
| TC_004 | Validate feature categorization logic | go_dim_feature | Correct feature category assignment | Business Rule |
| TC_005 | Test license pricing calculations | go_dim_license | Accurate pricing for all license types | Business Rule |
| TC_006 | Verify meeting type classification | go_dim_meeting_type | Proper meeting type assignment | Business Rule |
| TC_007 | Test support category priority mapping | go_dim_support_category | Correct priority level assignment | Business Rule |
| TC_008 | Validate feature usage metrics calculation | go_fact_feature_usage | Accurate usage metrics and scores | Business Rule |
| TC_009 | Test meeting activity aggregations | go_fact_meeting_activity | Correct participant and engagement metrics | Business Rule |
| TC_010 | Verify revenue calculations | go_fact_revenue_events | Accurate MRR, ARR, and tax calculations | Business Rule |
| TC_011 | Test support metrics SLA calculations | go_fact_support_metrics | Correct resolution time and SLA metrics | Business Rule |
| TC_012 | Handle null values in source data | All Models | Graceful handling of null values | Edge Case |
| TC_013 | Test with empty source tables | All Models | Models execute without errors | Edge Case |
| TC_014 | Validate data quality threshold filtering | All Models | Only records above threshold processed | Edge Case |
| TC_015 | Test duplicate record handling | All Models | Proper deduplication logic | Edge Case |
| TC_016 | Verify foreign key relationships | Fact Models | Valid references to dimension tables | Integration |
| TC_017 | Test incremental load behavior | All Models | Proper handling of new and updated records | Integration |
| TC_018 | Validate audit trail completeness | All Models | All transformations logged in audit table | Integration |
| TC_019 | Test performance with large datasets | All Models | Models complete within acceptable time | Performance |
| TC_020 | Verify data lineage tracking | All Models | Source system information preserved | Data Quality |

---

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  # Audit Log Tests
  - name: go_audit_log
    description: "Gold layer process audit log"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - execution_id
            - pipeline_name
    columns:
      - name: execution_id
        description: "Unique execution identifier"
        tests:
          - not_null
          - unique
      - name: pipeline_name
        description: "Pipeline name"
        tests:
          - not_null
      - name: execution_status
        description: "Execution status"
        tests:
          - not_null
          - accepted_values:
              values: ['STARTED', 'SUCCESS', 'FAILED', 'RUNNING']
      - name: records_processed
        description: "Number of records processed"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"

  # Date Dimension Tests
  - name: go_dim_date
    description: "Date dimension table"
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) = 4018"  # 11 years * 365.25 days
          config:
            severity: error
    columns:
      - name: date_id
        description: "Unique date identifier"
        tests:
          - not_null
          - unique
      - name: date_value
        description: "Date value"
        tests:
          - not_null
          - unique
      - name: year
        description: "Year component"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "between 2020 and 2030"
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
              expression: "between 1 and 12"
      - name: is_weekend
        description: "Weekend flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  # User Dimension Tests
  - name: go_dim_user
    description: "User dimension with SCD Type 2"
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
    columns:
      - name: user_dim_id
        description: "User dimension ID"
        tests:
          - not_null
          - unique
      - name: user_name
        description: "User name"
        tests:
          - not_null
      - name: plan_type
        description: "Plan type"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise']
      - name: plan_category
        description: "Plan category"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Professional', 'Premium']
      - name: geographic_region
        description: "Geographic region"
        tests:
          - not_null
          - accepted_values:
              values: ['North America', 'Europe', 'Asia Pacific', 'Other']
      - name: is_current_record
        description: "Current record flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  # Feature Dimension Tests
  - name: go_dim_feature
    description: "Feature dimension"
    columns:
      - name: feature_id
        description: "Feature ID"
        tests:
          - not_null
          - unique
      - name: feature_name
        description: "Feature name"
        tests:
          - not_null
          - unique
      - name: feature_category
        description: "Feature category"
        tests:
          - not_null
          - accepted_values:
              values: ['Video', 'Audio', 'Screen Sharing', 'Communication', 'Recording', 'Collaboration', 'File Sharing', 'Other']
      - name: is_premium_feature
        description: "Premium feature flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  # License Dimension Tests
  - name: go_dim_license
    description: "License dimension"
    columns:
      - name: license_id
        description: "License ID"
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
          - dbt_utils.expression_is_true:
              expression: "> 0"
      - name: max_participants
        description: "Maximum participants"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "> 0"

  # Feature Usage Fact Tests
  - name: go_fact_feature_usage
    description: "Feature usage fact table"
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) > 0"
    columns:
      - name: feature_usage_id
        description: "Feature usage ID"
        tests:
          - not_null
          - unique
      - name: usage_date
        description: "Usage date"
        tests:
          - not_null
      - name: usage_count
        description: "Usage count"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      - name: user_experience_score
        description: "User experience score"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "between 0 and 10"
      - name: success_rate_percentage
        description: "Success rate percentage"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "between 0 and 100"

  # Meeting Activity Fact Tests
  - name: go_fact_meeting_activity
    description: "Meeting activity fact table"
    columns:
      - name: meeting_activity_id
        description: "Meeting activity ID"
        tests:
          - not_null
          - unique
      - name: meeting_date
        description: "Meeting date"
        tests:
          - not_null
      - name: participant_count
        description: "Participant count"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      - name: meeting_quality_score
        description: "Meeting quality score"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "between 0 and 10"

  # Revenue Events Fact Tests
  - name: go_fact_revenue_events
    description: "Revenue events fact table"
    columns:
      - name: revenue_event_id
        description: "Revenue event ID"
        tests:
          - not_null
          - unique
      - name: transaction_date
        description: "Transaction date"
        tests:
          - not_null
      - name: gross_amount
        description: "Gross amount"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "> 0"
      - name: net_amount
        description: "Net amount"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "> 0"
      - name: currency_code
        description: "Currency code"
        tests:
          - not_null
          - accepted_values:
              values: ['USD']
      - name: mrr_impact
        description: "MRR impact"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"

  # Support Metrics Fact Tests
  - name: go_fact_support_metrics
    description: "Support metrics fact table"
    columns:
      - name: support_metrics_id
        description: "Support metrics ID"
        tests:
          - not_null
          - unique
      - name: ticket_open_date
        description: "Ticket open date"
        tests:
          - not_null
      - name: priority_level
        description: "Priority level"
        tests:
          - not_null
          - accepted_values:
              values: ['P1', 'P2', 'P3', 'P4']
      - name: customer_satisfaction_score
        description: "Customer satisfaction score"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "between 0 and 10"
      - name: sla_met_flag
        description: "SLA met flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
```

### Custom SQL Tests

#### Test 1: Date Dimension Completeness
```sql
-- tests/test_date_dimension_completeness.sql
SELECT 
    'Date dimension missing dates' as test_name,
    COUNT(*) as failure_count
FROM (
    SELECT date_value
    FROM {{ ref('go_dim_date') }}
    WHERE date_value BETWEEN '2020-01-01' AND '2030-12-31'
) actual
RIGHT JOIN (
    SELECT DATEADD('day', seq4(), '2020-01-01') as expected_date
    FROM TABLE(GENERATOR(ROWCOUNT => 4018))
) expected ON actual.date_value = expected.expected_date
WHERE actual.date_value IS NULL
HAVING COUNT(*) > 0
```

#### Test 2: User Dimension SCD Type 2 Validation
```sql
-- tests/test_user_scd_type2.sql
SELECT 
    'Invalid SCD Type 2 records' as test_name,
    COUNT(*) as failure_count
FROM {{ ref('go_dim_user') }}
WHERE (
    -- Check for overlapping effective dates for same user
    (effective_start_date >= effective_end_date)
    OR 
    -- Check for multiple current records per user
    (is_current_record = TRUE AND user_name IN (
        SELECT user_name 
        FROM {{ ref('go_dim_user') }} 
        WHERE is_current_record = TRUE 
        GROUP BY user_name 
        HAVING COUNT(*) > 1
    ))
)
HAVING COUNT(*) > 0
```

#### Test 3: Feature Usage Metrics Validation
```sql
-- tests/test_feature_usage_metrics.sql
SELECT 
    'Invalid feature usage metrics' as test_name,
    COUNT(*) as failure_count
FROM {{ ref('go_fact_feature_usage') }}
WHERE (
    -- Usage count should be positive
    usage_count < 0
    OR 
    -- Success rate should be between 0 and 100
    success_rate_percentage < 0 OR success_rate_percentage > 100
    OR 
    -- User experience score should be between 0 and 10
    user_experience_score < 0 OR user_experience_score > 10
    OR 
    -- Bandwidth consumed should be positive when usage count > 0
    (usage_count > 0 AND bandwidth_consumed_mb <= 0)
)
HAVING COUNT(*) > 0
```

#### Test 4: Revenue Calculations Validation
```sql
-- tests/test_revenue_calculations.sql
SELECT 
    'Invalid revenue calculations' as test_name,
    COUNT(*) as failure_count
FROM {{ ref('go_fact_revenue_events') }}
WHERE (
    -- Net amount should be less than or equal to gross amount
    net_amount > gross_amount
    OR 
    -- Tax amount should be reasonable (0-20% of gross)
    tax_amount < 0 OR tax_amount > (gross_amount * 0.20)
    OR 
    -- MRR impact should be positive for recurring revenue
    (is_recurring_revenue = TRUE AND mrr_impact <= 0)
    OR 
    -- ARR impact should be positive for subscription events
    (event_type ILIKE '%subscription%' AND arr_impact <= 0)
)
HAVING COUNT(*) > 0
```

#### Test 5: Meeting Activity Aggregations
```sql
-- tests/test_meeting_activity_aggregations.sql
SELECT 
    'Invalid meeting activity aggregations' as test_name,
    COUNT(*) as failure_count
FROM {{ ref('go_fact_meeting_activity') }}
WHERE (
    -- Participant count should be non-negative
    participant_count < 0
    OR 
    -- Duration should be positive
    actual_duration_minutes <= 0
    OR 
    -- Engagement score should be between 0 and 10
    participant_engagement_score < 0 OR participant_engagement_score > 10
    OR 
    -- Quality scores should be between 0 and 10
    meeting_quality_score < 0 OR meeting_quality_score > 10
    OR audio_quality_score < 0 OR audio_quality_score > 10
    OR video_quality_score < 0 OR video_quality_score > 10
)
HAVING COUNT(*) > 0
```

#### Test 6: Support Metrics SLA Validation
```sql
-- tests/test_support_sla_metrics.sql
SELECT 
    'Invalid support SLA metrics' as test_name,
    COUNT(*) as failure_count
FROM {{ ref('go_fact_support_metrics') }}
WHERE (
    -- Resolution time should be positive when ticket is resolved
    (ticket_close_date IS NOT NULL AND resolution_time_hours <= 0)
    OR 
    -- First response time should be positive
    first_response_time_hours <= 0
    OR 
    -- Customer satisfaction should be between 0 and 10
    customer_satisfaction_score < 0 OR customer_satisfaction_score > 10
    OR 
    -- SLA breach hours should be non-negative
    sla_breach_hours < 0
)
HAVING COUNT(*) > 0
```

#### Test 7: Data Quality Threshold Compliance
```sql
-- tests/test_data_quality_threshold.sql
SELECT 
    'Records below data quality threshold' as test_name,
    SUM(failure_count) as total_failures
FROM (
    SELECT COUNT(*) as failure_count FROM {{ source('silver', 'si_users') }} 
    WHERE data_quality_score < {{ var('data_quality_threshold') }}
    
    UNION ALL
    
    SELECT COUNT(*) as failure_count FROM {{ source('silver', 'si_meetings') }} 
    WHERE data_quality_score < {{ var('data_quality_threshold') }}
    
    UNION ALL
    
    SELECT COUNT(*) as failure_count FROM {{ source('silver', 'si_feature_usage') }} 
    WHERE data_quality_score < {{ var('data_quality_threshold') }}
    
    UNION ALL
    
    SELECT COUNT(*) as failure_count FROM {{ source('silver', 'si_support_tickets') }} 
    WHERE data_quality_score < {{ var('data_quality_threshold') }}
    
    UNION ALL
    
    SELECT COUNT(*) as failure_count FROM {{ source('silver', 'si_billing_events') }} 
    WHERE data_quality_score < {{ var('data_quality_threshold') }}
    
    UNION ALL
    
    SELECT COUNT(*) as failure_count FROM {{ source('silver', 'si_licenses') }} 
    WHERE data_quality_score < {{ var('data_quality_threshold') }}
)
HAVING SUM(failure_count) > 0
```

#### Test 8: Referential Integrity Check
```sql
-- tests/test_referential_integrity.sql
SELECT 
    'Referential integrity violations' as test_name,
    SUM(violation_count) as total_violations
FROM (
    -- Check feature usage references valid features
    SELECT COUNT(*) as violation_count
    FROM {{ ref('go_fact_feature_usage') }} f
    LEFT JOIN {{ ref('go_dim_feature') }} d ON f.feature_name = d.feature_name
    WHERE d.feature_name IS NULL
    
    UNION ALL
    
    -- Check meeting activity references valid dates
    SELECT COUNT(*) as violation_count
    FROM {{ ref('go_fact_meeting_activity') }} f
    LEFT JOIN {{ ref('go_dim_date') }} d ON f.meeting_date = d.date_value
    WHERE d.date_value IS NULL
    
    UNION ALL
    
    -- Check revenue events reference valid dates
    SELECT COUNT(*) as violation_count
    FROM {{ ref('go_fact_revenue_events') }} f
    LEFT JOIN {{ ref('go_dim_date') }} d ON f.transaction_date = d.date_value
    WHERE d.date_value IS NULL
)
HAVING SUM(violation_count) > 0
```

### Parameterized Tests

#### Test 9: Generic Null Check for Critical Columns
```sql
-- tests/generic/test_critical_columns_not_null.sql
{% test critical_columns_not_null(model, column_name) %}

SELECT COUNT(*) as null_count
FROM {{ model }}
WHERE {{ column_name }} IS NULL
HAVING COUNT(*) > 0

{% endtest %}
```

#### Test 10: Generic Range Validation
```sql
-- tests/generic/test_value_range.sql
{% test value_in_range(model, column_name, min_value, max_value) %}

SELECT COUNT(*) as out_of_range_count
FROM {{ model }}
WHERE {{ column_name }} < {{ min_value }} 
   OR {{ column_name }} > {{ max_value }}
HAVING COUNT(*) > 0

{% endtest %}
```

## Test Execution Strategy

### 1. Pre-deployment Tests
- Run all schema tests before model deployment
- Execute custom SQL tests for business rule validation
- Verify data quality thresholds are met

### 2. Post-deployment Tests
- Validate row counts and data completeness
- Check referential integrity across models
- Verify audit trail completeness

### 3. Performance Tests
- Monitor model execution times
- Check for query optimization opportunities
- Validate resource utilization

### 4. Continuous Monitoring
- Set up automated test runs on schedule
- Configure alerts for test failures
- Track test results over time

## Test Configuration

### dbt_project.yml Test Configuration
```yaml
tests:
  zoom_analytics_gold:
    +severity: error
    +store_failures: true
    +schema: test_results
    
    # Custom test configurations
    custom:
      +severity: warn
      +limit: 100
      
    # Performance test configurations  
    performance:
      +severity: warn
      +store_failures: false
```

### Test Profiles
```yaml
# profiles.yml
zoom_analytics_gold:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('SNOWFLAKE_USER') }}"
      private_key_path: "{{ env_var('SNOWFLAKE_PRIVATE_KEY_PATH') }}"
      role: "{{ env_var('SNOWFLAKE_ROLE') }}"
      database: DB_POC_ZOOM
      warehouse: WH_POC_ZOOM_DEV_XSMALL
      schema: GOLD_TEST
      threads: 4
      keepalives_idle: 240
      search_path: 'GOLD_TEST,SILVER,BRONZE'
```

## Expected Test Results

### Success Criteria
- All schema tests pass with 0 failures
- Custom SQL tests return 0 violation counts
- Data quality scores meet minimum thresholds (80%+)
- Model execution completes within performance SLAs
- Audit logs capture all transformation activities

### Failure Handling
- Test failures trigger immediate alerts
- Failed records are logged for investigation
- Rollback procedures activated for critical failures
- Root cause analysis performed for recurring issues

## Maintenance and Updates

### Regular Activities
- Review and update test cases quarterly
- Add new tests for model enhancements
- Optimize test performance and coverage
- Update expected values based on business changes

### Documentation Updates
- Maintain test case documentation
- Update expected outcomes for new requirements
- Document test failure resolution procedures
- Keep test execution guides current

---

*This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Analytics Gold Layer dbt models in Snowflake, providing confidence in data quality and business rule compliance.*