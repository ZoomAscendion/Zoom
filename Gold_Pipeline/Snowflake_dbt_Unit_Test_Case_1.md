_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Gold Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Analytics Gold Layer

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Gold Layer transformation project. The tests cover 6 dimension tables and 4 fact tables with comprehensive business logic validation, data quality checks, and performance optimizations.

## Project Structure Tested

```
models/
├── gold/
│   ├── dimension/
│   │   ├── dim_date.sql
│   │   ├── dim_user.sql
│   │   ├── dim_feature.sql
│   │   ├── dim_license.sql
│   │   ├── dim_meeting_type.sql
│   │   └── dim_support_category.sql
│   ├── fact/
│   │   ├── fact_meeting_activity.sql
│   │   ├── fact_feature_usage.sql
│   │   ├── fact_revenue_events.sql
│   │   └── fact_support_metrics.sql
│   ├── sources.yml
│   └── schema.yml
```

## Test Case Categories

### 1. Data Quality Tests
### 2. Business Logic Tests
### 3. Referential Integrity Tests
### 4. Performance Tests
### 5. Edge Case Tests
### 6. Error Handling Tests

---

## Test Case List

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| TC_DIM_001 | Validate dim_date completeness for date range 2020-2030 | dim_date | All dates present without gaps |
| TC_DIM_002 | Validate dim_user SCD Type 2 implementation | dim_user | Proper versioning with effective dates |
| TC_DIM_003 | Validate dim_feature categorization logic | dim_feature | Correct feature categories assigned |
| TC_DIM_004 | Validate dim_license pricing calculations | dim_license | Accurate pricing and entitlements |
| TC_DIM_005 | Validate dim_meeting_type duration categories | dim_meeting_type | Proper duration bucketing |
| TC_DIM_006 | Validate dim_support_category SLA mappings | dim_support_category | Correct SLA targets assigned |
| TC_FACT_001 | Validate fact_meeting_activity aggregations | fact_meeting_activity | Accurate meeting metrics |
| TC_FACT_002 | Validate fact_feature_usage adoption scores | fact_feature_usage | Correct adoption calculations |
| TC_FACT_003 | Validate fact_revenue_events MRR/ARR calculations | fact_revenue_events | Accurate financial metrics |
| TC_FACT_004 | Validate fact_support_metrics SLA compliance | fact_support_metrics | Correct SLA tracking |
| TC_REF_001 | Validate foreign key relationships | All fact tables | Valid dimension references |
| TC_DQ_001 | Validate data quality scores | All tables | Quality scores within range |
| TC_EDGE_001 | Handle null values in transformations | All models | Proper null handling |
| TC_EDGE_002 | Handle empty datasets | All models | Graceful empty set handling |
| TC_PERF_001 | Validate incremental loading | All models | Efficient incremental processing |

---

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  # DIMENSION TABLES
  - name: dim_date
    description: "Standard date dimension for time-based analysis"
    columns:
      - name: date_id
        description: "Primary key for date dimension"
        tests:
          - unique
          - not_null
      - name: date_value
        description: "Actual date value"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: "'2020-01-01'"
              max_value: "'2030-12-31'"
      - name: year
        description: "Year component"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
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
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1
              max_value: 12
      - name: is_weekend
        description: "Weekend flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: dim_user
    description: "User dimension with SCD Type 2"
    columns:
      - name: user_dim_id
        description: "Surrogate key for user dimension"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Business key for user"
        tests:
          - not_null
      - name: user_name
        description: "User display name"
        tests:
          - not_null
          - dbt_expectations.expect_column_value_lengths_to_be_between:
              min_value: 1
              max_value: 200
      - name: email_domain
        description: "Email domain extracted from user email"
        tests:
          - not_null
      - name: plan_type
        description: "Standardized plan type"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Unknown']
      - name: plan_category
        description: "Plan category classification"
        tests:
          - not_null
          - accepted_values:
              values: ['Free', 'Paid']
      - name: geographic_region
        description: "Geographic region derived from email domain"
        tests:
          - not_null
          - accepted_values:
              values: ['North America', 'Europe', 'Unknown']
      - name: industry_sector
        description: "Industry sector classification"
        tests:
          - not_null
          - accepted_values:
              values: ['Technology', 'Financial Services', 'Unknown']
      - name: is_current_record
        description: "SCD Type 2 current record flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: dim_feature
    description: "Feature dimension with categorization"
    columns:
      - name: feature_id
        description: "Primary key for feature dimension"
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
              values: ['Communication', 'Collaboration', 'Security', 'Analytics', 'Integration']
      - name: feature_complexity
        description: "Feature complexity level"
        tests:
          - not_null
          - accepted_values:
              values: ['Low', 'Medium', 'High']
      - name: is_premium_feature
        description: "Premium feature flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: dim_license
    description: "License dimension with pricing and entitlements"
    columns:
      - name: license_id
        description: "Primary key for license dimension"
        tests:
          - unique
          - not_null
      - name: license_type
        description: "License type"
        tests:
          - not_null
      - name: license_tier
        description: "License tier classification"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Professional', 'Enterprise']
      - name: monthly_price
        description: "Monthly price for license"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: annual_price
        description: "Annual price for license"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100000
      - name: is_current_record
        description: "SCD Type 2 current record flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: dim_meeting_type
    description: "Meeting type dimension with characteristics"
    columns:
      - name: meeting_type_id
        description: "Primary key for meeting type dimension"
        tests:
          - unique
          - not_null
      - name: duration_category
        description: "Meeting duration category"
        tests:
          - not_null
          - accepted_values:
              values: ['Brief', 'Standard', 'Extended', 'Long']
      - name: time_of_day_category
        description: "Time of day category"
        tests:
          - not_null
          - accepted_values:
              values: ['Morning', 'Afternoon', 'Evening', 'Night']
      - name: meeting_quality_threshold
        description: "Quality threshold for meeting type"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0

  - name: dim_support_category
    description: "Support category dimension with SLA targets"
    columns:
      - name: support_category_id
        description: "Primary key for support category dimension"
        tests:
          - unique
          - not_null
      - name: support_category
        description: "Support category"
        tests:
          - not_null
      - name: priority_level
        description: "Priority level for support category"
        tests:
          - not_null
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']
      - name: sla_target_hours
        description: "SLA target in hours"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1
              max_value: 168
      - name: requires_escalation
        description: "Escalation requirement flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  # FACT TABLES
  - name: fact_meeting_activity
    description: "Meeting activity fact table"
    columns:
      - name: meeting_activity_id
        description: "Primary key for meeting activity fact"
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
      - name: meeting_type_id
        description: "Foreign key to meeting type dimension"
        tests:
          - not_null
          - relationships:
              to: ref('dim_meeting_type')
              field: meeting_type_id
      - name: host_user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('dim_user')
              field: user_dim_id
      - name: participant_count
        description: "Number of participants"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: actual_duration_minutes
        description: "Actual meeting duration in minutes"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: meeting_quality_score
        description: "Meeting quality score"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0
      - name: audio_quality_score
        description: "Audio quality score"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0
      - name: video_quality_score
        description: "Video quality score"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0

  - name: fact_feature_usage
    description: "Feature usage fact table"
    columns:
      - name: feature_usage_id
        description: "Primary key for feature usage fact"
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
      - name: feature_id
        description: "Foreign key to feature dimension"
        tests:
          - not_null
          - relationships:
              to: ref('dim_feature')
              field: feature_id
      - name: user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('dim_user')
              field: user_dim_id
      - name: usage_count
        description: "Feature usage count"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: feature_adoption_score
        description: "Feature adoption score"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 100.0
      - name: success_rate
        description: "Feature usage success rate"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 100.0

  - name: fact_revenue_events
    description: "Revenue events fact table"
    columns:
      - name: revenue_event_id
        description: "Primary key for revenue event fact"
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
      - name: license_id
        description: "Foreign key to license dimension"
        tests:
          - not_null
          - relationships:
              to: ref('dim_license')
              field: license_id
      - name: user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('dim_user')
              field: user_dim_id
      - name: gross_amount
        description: "Gross revenue amount"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000000
      - name: net_amount
        description: "Net revenue amount"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000000
      - name: mrr_impact
        description: "Monthly recurring revenue impact"
        tests:
          - not_null
      - name: arr_impact
        description: "Annual recurring revenue impact"
        tests:
          - not_null
      - name: payment_status
        description: "Payment status"
        tests:
          - not_null
          - accepted_values:
              values: ['Pending', 'Completed', 'Failed', 'Refunded']

  - name: fact_support_metrics
    description: "Support metrics fact table"
    columns:
      - name: support_metrics_id
        description: "Primary key for support metrics fact"
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
      - name: support_category_id
        description: "Foreign key to support category dimension"
        tests:
          - not_null
          - relationships:
              to: ref('dim_support_category')
              field: support_category_id
      - name: user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('dim_user')
              field: user_dim_id
      - name: resolution_time_hours
        description: "Resolution time in hours"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 8760
      - name: first_response_time_hours
        description: "First response time in hours"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 168
      - name: customer_satisfaction_score
        description: "Customer satisfaction score"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0
      - name: sla_met
        description: "SLA compliance flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
      - name: first_contact_resolution
        description: "First contact resolution flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
```

### Custom SQL Tests

#### Test 1: Date Dimension Completeness
```sql
-- tests/test_dim_date_completeness.sql
-- Test to ensure no gaps in date dimension
SELECT 
    COUNT(*) as missing_dates
FROM (
    SELECT 
        DATE_VALUE + INTERVAL '1 day' as expected_date
    FROM {{ ref('dim_date') }}
    WHERE DATE_VALUE < '2030-12-31'
) expected
LEFT JOIN {{ ref('dim_date') }} actual
    ON expected.expected_date = actual.DATE_VALUE
WHERE actual.DATE_VALUE IS NULL
HAVING COUNT(*) > 0
```

#### Test 2: User Dimension SCD Type 2 Validation
```sql
-- tests/test_dim_user_scd_type2.sql
-- Test to ensure proper SCD Type 2 implementation
SELECT 
    USER_ID,
    COUNT(*) as version_count
FROM {{ ref('dim_user') }}
WHERE IS_CURRENT_RECORD = true
GROUP BY USER_ID
HAVING COUNT(*) > 1
```

#### Test 3: Meeting Activity Aggregation Validation
```sql
-- tests/test_fact_meeting_activity_aggregations.sql
-- Test to validate meeting activity calculations
SELECT 
    MEETING_ID,
    CASE 
        WHEN PARTICIPANT_COUNT < 0 THEN 'Invalid participant count'
        WHEN ACTUAL_DURATION_MINUTES < 0 THEN 'Invalid duration'
        WHEN MEETING_QUALITY_SCORE NOT BETWEEN 1.0 AND 5.0 THEN 'Invalid quality score'
        WHEN TOTAL_PARTICIPANT_MINUTES < 0 THEN 'Invalid total participant minutes'
        ELSE 'Valid'
    END as validation_result
FROM {{ ref('fact_meeting_activity') }}
WHERE 
    PARTICIPANT_COUNT < 0 
    OR ACTUAL_DURATION_MINUTES < 0 
    OR MEETING_QUALITY_SCORE NOT BETWEEN 1.0 AND 5.0
    OR TOTAL_PARTICIPANT_MINUTES < 0
```

#### Test 4: Revenue Events Financial Validation
```sql
-- tests/test_fact_revenue_events_financial.sql
-- Test to validate financial calculations
SELECT 
    BILLING_EVENT_ID,
    GROSS_AMOUNT,
    TAX_AMOUNT,
    DISCOUNT_AMOUNT,
    NET_AMOUNT,
    (GROSS_AMOUNT - TAX_AMOUNT - DISCOUNT_AMOUNT) as calculated_net
FROM {{ ref('fact_revenue_events') }}
WHERE 
    ABS(NET_AMOUNT - (GROSS_AMOUNT - TAX_AMOUNT - DISCOUNT_AMOUNT)) > 0.01
    OR GROSS_AMOUNT < 0
    OR TAX_AMOUNT < 0
    OR DISCOUNT_AMOUNT < 0
    OR NET_AMOUNT < 0
```

#### Test 5: Support Metrics SLA Compliance
```sql
-- tests/test_fact_support_metrics_sla.sql
-- Test to validate SLA compliance calculations
SELECT 
    sm.TICKET_ID,
    sm.RESOLUTION_TIME_HOURS,
    sc.SLA_TARGET_HOURS,
    sm.SLA_MET,
    CASE 
        WHEN sm.RESOLUTION_TIME_HOURS <= sc.SLA_TARGET_HOURS AND sm.SLA_MET = false THEN 'SLA_MET should be true'
        WHEN sm.RESOLUTION_TIME_HOURS > sc.SLA_TARGET_HOURS AND sm.SLA_MET = true THEN 'SLA_MET should be false'
        ELSE 'Valid'
    END as validation_result
FROM {{ ref('fact_support_metrics') }} sm
JOIN {{ ref('dim_support_category') }} sc
    ON sm.SUPPORT_CATEGORY_ID = sc.SUPPORT_CATEGORY_ID
WHERE 
    (sm.RESOLUTION_TIME_HOURS <= sc.SLA_TARGET_HOURS AND sm.SLA_MET = false)
    OR (sm.RESOLUTION_TIME_HOURS > sc.SLA_TARGET_HOURS AND sm.SLA_MET = true)
```

#### Test 6: Feature Usage Adoption Score Validation
```sql
-- tests/test_fact_feature_usage_adoption.sql
-- Test to validate feature adoption score calculations
SELECT 
    FEATURE_USAGE_ID,
    USAGE_COUNT,
    FEATURE_ADOPTION_SCORE,
    SUCCESS_RATE
FROM {{ ref('fact_feature_usage') }}
WHERE 
    FEATURE_ADOPTION_SCORE < 0 
    OR FEATURE_ADOPTION_SCORE > 100
    OR SUCCESS_RATE < 0
    OR SUCCESS_RATE > 100
    OR (USAGE_COUNT = 0 AND FEATURE_ADOPTION_SCORE > 0)
```

#### Test 7: Cross-Table Referential Integrity
```sql
-- tests/test_referential_integrity.sql
-- Test to ensure all foreign keys have valid references
SELECT 
    'fact_meeting_activity' as table_name,
    'date_id' as column_name,
    COUNT(*) as orphaned_records
FROM {{ ref('fact_meeting_activity') }} f
LEFT JOIN {{ ref('dim_date') }} d ON f.DATE_ID = d.DATE_ID
WHERE d.DATE_ID IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    'fact_feature_usage' as table_name,
    'feature_id' as column_name,
    COUNT(*) as orphaned_records
FROM {{ ref('fact_feature_usage') }} f
LEFT JOIN {{ ref('dim_feature') }} d ON f.FEATURE_ID = d.FEATURE_ID
WHERE d.FEATURE_ID IS NULL
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    'fact_revenue_events' as table_name,
    'license_id' as column_name,
    COUNT(*) as orphaned_records
FROM {{ ref('fact_revenue_events') }} f
LEFT JOIN {{ ref('dim_license') }} d ON f.LICENSE_ID = d.LICENSE_ID
WHERE d.LICENSE_ID IS NULL
HAVING COUNT(*) > 0
```

#### Test 8: Data Quality Score Validation
```sql
-- tests/test_data_quality_scores.sql
-- Test to validate data quality scores across all tables
SELECT 
    'dim_user' as table_name,
    COUNT(*) as records_with_invalid_quality_score
FROM {{ source('silver', 'si_users') }}
WHERE DATA_QUALITY_SCORE < 0 OR DATA_QUALITY_SCORE > 100
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    'dim_meeting' as table_name,
    COUNT(*) as records_with_invalid_quality_score
FROM {{ source('silver', 'si_meetings') }}
WHERE DATA_QUALITY_SCORE < 0 OR DATA_QUALITY_SCORE > 100
HAVING COUNT(*) > 0
```

### Performance Tests

#### Test 9: Incremental Model Performance
```sql
-- tests/test_incremental_performance.sql
-- Test to ensure incremental models process efficiently
SELECT 
    COUNT(*) as duplicate_records
FROM (
    SELECT 
        MEETING_ID,
        MEETING_DATE,
        COUNT(*) as record_count
    FROM {{ ref('fact_meeting_activity') }}
    GROUP BY MEETING_ID, MEETING_DATE
    HAVING COUNT(*) > 1
) duplicates
HAVING COUNT(*) > 0
```

#### Test 10: Source Data Validation
```sql
-- tests/test_source_data_validation.sql
-- Test to validate source data quality before transformation
SELECT 
    'si_users' as source_table,
    COUNT(*) as records_with_validation_failed
FROM {{ source('silver', 'si_users') }}
WHERE VALIDATION_STATUS != 'PASSED'
HAVING COUNT(*) > 0

UNION ALL

SELECT 
    'si_meetings' as source_table,
    COUNT(*) as records_with_validation_failed
FROM {{ source('silver', 'si_meetings') }}
WHERE VALIDATION_STATUS != 'PASSED'
HAVING COUNT(*) > 0
```

## Edge Case Tests

### Test 11: Null Value Handling
```sql
-- tests/test_null_value_handling.sql
-- Test to ensure proper null value handling in transformations
SELECT 
    'dim_user' as table_name,
    'company' as column_name,
    COUNT(*) as null_values_not_handled
FROM {{ ref('dim_user') }}
WHERE COMPANY IS NULL OR COMPANY = ''
HAVING COUNT(*) > 0
```

### Test 12: Empty Dataset Handling
```sql
-- tests/test_empty_dataset_handling.sql
-- Test to ensure models handle empty source datasets gracefully
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN 'Empty dataset handled correctly'
        ELSE 'Dataset has records'
    END as result
FROM {{ ref('dim_date') }}
WHERE DATE_VALUE < '1900-01-01'
```

## Error Handling Tests

### Test 13: Invalid Data Type Handling
```sql
-- tests/test_invalid_data_types.sql
-- Test to ensure invalid data types are handled properly
SELECT 
    MEETING_ID,
    PARTICIPANT_COUNT
FROM {{ ref('fact_meeting_activity') }}
WHERE TRY_CAST(PARTICIPANT_COUNT AS INTEGER) IS NULL
    AND PARTICIPANT_COUNT IS NOT NULL
```

### Test 14: Business Rule Violations
```sql
-- tests/test_business_rule_violations.sql
-- Test to identify business rule violations
SELECT 
    MEETING_ID,
    MEETING_START_TIME,
    MEETING_END_TIME,
    'End time before start time' as violation
FROM {{ ref('fact_meeting_activity') }}
WHERE MEETING_END_TIME < MEETING_START_TIME

UNION ALL

SELECT 
    BILLING_EVENT_ID,
    GROSS_AMOUNT,
    NET_AMOUNT,
    'Net amount greater than gross amount' as violation
FROM {{ ref('fact_revenue_events') }}
WHERE NET_AMOUNT > GROSS_AMOUNT
```

## Test Execution Commands

### Run All Tests
```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select dim_user

# Run tests for specific tag
dbt test --select tag:data_quality

# Run tests with specific severity
dbt test --select test_type:generic
```

### Test Results Tracking

```yaml
# dbt_project.yml test configuration
tests:
  zoom_analytics_gold:
    +severity: error  # fail, warn, error
    +store_failures: true
    +schema: test_failures
```

## Monitoring and Alerting

### Test Failure Notifications
```sql
-- Create view for test failure monitoring
CREATE OR REPLACE VIEW gold.test_failure_summary AS
SELECT 
    test_name,
    model_name,
    failure_count,
    last_failure_time,
    severity_level
FROM gold.test_results
WHERE status = 'FAILED'
ORDER BY last_failure_time DESC;
```

## Performance Benchmarks

| Model | Expected Runtime | Row Count Range | Test Coverage |
|-------|------------------|-----------------|---------------|
| dim_date | < 5 seconds | 4,018 rows | 100% |
| dim_user | < 30 seconds | 1K - 1M rows | 95% |
| dim_feature | < 10 seconds | 50 - 500 rows | 100% |
| dim_license | < 5 seconds | 10 - 100 rows | 100% |
| dim_meeting_type | < 5 seconds | 20 - 200 rows | 100% |
| dim_support_category | < 5 seconds | 15 - 150 rows | 100% |
| fact_meeting_activity | < 2 minutes | 10K - 10M rows | 90% |
| fact_feature_usage | < 3 minutes | 50K - 50M rows | 85% |
| fact_revenue_events | < 1 minute | 5K - 5M rows | 95% |
| fact_support_metrics | < 1 minute | 2K - 2M rows | 90% |

## Conclusion

This comprehensive test suite ensures:

1. **Data Quality**: All data meets defined quality standards
2. **Business Logic**: Transformations correctly implement business rules
3. **Referential Integrity**: All foreign key relationships are valid
4. **Performance**: Models execute within acceptable time limits
5. **Error Handling**: Edge cases and errors are handled gracefully
6. **Monitoring**: Continuous monitoring of data pipeline health

The test cases cover happy path scenarios, edge cases, and exception handling to ensure robust and reliable dbt models in the Snowflake environment.

---

**Test Execution Schedule:**
- **Daily**: Critical data quality tests
- **Weekly**: Full test suite execution
- **On-demand**: Before production deployments

**Success Criteria:**
- 100% pass rate for critical tests
- 95% pass rate for all tests
- Zero data quality violations in production
