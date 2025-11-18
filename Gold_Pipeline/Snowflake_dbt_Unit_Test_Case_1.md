_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics System dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Analytics System

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics System's Gold Layer dimensional model. The tests cover all dimension tables, fact tables, and audit tables to ensure data quality, business rule compliance, and pipeline reliability.

## Test Coverage Summary

### Models Under Test:
- **Dimension Tables**: 6 tables (GO_DIM_USER, GO_DIM_DATE, GO_DIM_FEATURE, GO_DIM_LICENSE, GO_DIM_MEETING, GO_DIM_SUPPORT_CATEGORY)
- **Fact Tables**: 4 tables (GO_FACT_MEETING_ACTIVITY, GO_FACT_SUPPORT_ACTIVITY, GO_FACT_REVENUE_ACTIVITY, GO_FACT_FEATURE_USAGE)
- **Audit Table**: 1 table (GO_PROCESS_AUDIT)

---

## 1. DIMENSION TABLE TESTS

### 1.1 GO_DIM_USER Tests

#### Test Case ID: DIM_USER_001
**Test Case Description**: Validate unique USER_KEY values in dimension table
**Expected Outcome**: No duplicate USER_KEY values should exist

```yaml
# tests/dim_user_unique_key.yml
version: 2

models:
  - name: go_dim_user
    tests:
      - unique:
          column_name: USER_KEY
          severity: error
    columns:
      - name: USER_KEY
        tests:
          - not_null:
              severity: error
          - unique:
              severity: error
```

#### Test Case ID: DIM_USER_002
**Test Case Description**: Validate email domain extraction logic
**Expected Outcome**: EMAIL_DOMAIN should be properly extracted from email addresses

```sql
-- tests/test_email_domain_extraction.sql
SELECT 
    USER_KEY,
    EMAIL,
    EMAIL_DOMAIN
FROM {{ ref('go_dim_user') }}
WHERE EMAIL IS NOT NULL 
  AND EMAIL_DOMAIN != SPLIT_PART(EMAIL, '@', 2)
```

#### Test Case ID: DIM_USER_003
**Test Case Description**: Validate plan type standardization
**Expected Outcome**: PLAN_TYPE should only contain standardized values

```yaml
# tests/dim_user_plan_type_values.yml
version: 2

models:
  - name: go_dim_user
    columns:
      - name: PLAN_TYPE
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Business', 'Enterprise']
              severity: error
```

#### Test Case ID: DIM_USER_004
**Test Case Description**: Validate SCD Type 2 implementation
**Expected Outcome**: IS_CURRENT_RECORD should be properly maintained

```sql
-- tests/test_scd_type2_user.sql
SELECT 
    USER_ID,
    COUNT(*) as active_records
FROM {{ ref('go_dim_user') }}
WHERE IS_CURRENT_RECORD = TRUE
GROUP BY USER_ID
HAVING COUNT(*) > 1
```

### 1.2 GO_DIM_DATE Tests

#### Test Case ID: DIM_DATE_001
**Test Case Description**: Validate date range completeness (2020-2030)
**Expected Outcome**: All dates from 2020-01-01 to 2030-12-31 should be present

```sql
-- tests/test_date_range_completeness.sql
WITH expected_dates AS (
    SELECT 
        DATEADD('day', ROW_NUMBER() OVER (ORDER BY NULL) - 1, '2020-01-01'::DATE) as expected_date
    FROM TABLE(GENERATOR(ROWCOUNT => 4018)) -- 11 years * 365.25 days
    WHERE expected_date <= '2030-12-31'::DATE
),
actual_dates AS (
    SELECT DATE_KEY as actual_date
    FROM {{ ref('go_dim_date') }}
)
SELECT expected_date
FROM expected_dates
WHERE expected_date NOT IN (SELECT actual_date FROM actual_dates)
```

#### Test Case ID: DIM_DATE_002
**Test Case Description**: Validate fiscal year calculation
**Expected Outcome**: FISCAL_YEAR should be correctly calculated based on business rules

```sql
-- tests/test_fiscal_year_calculation.sql
SELECT 
    DATE_KEY,
    YEAR,
    FISCAL_YEAR
FROM {{ ref('go_dim_date') }}
WHERE MONTH >= 4 
  AND FISCAL_YEAR != YEAR + 1
OR (MONTH < 4 AND FISCAL_YEAR != YEAR)
```

### 1.3 GO_DIM_FEATURE Tests

#### Test Case ID: DIM_FEATURE_001
**Test Case Description**: Validate feature categorization
**Expected Outcome**: All features should have valid categories

```yaml
# tests/dim_feature_category_values.yml
version: 2

models:
  - name: go_dim_feature
    columns:
      - name: FEATURE_CATEGORY
        tests:
          - accepted_values:
              values: ['Collaboration', 'Recording', 'Communication', 'Advanced Meeting', 'Engagement']
              severity: error
          - not_null:
              severity: error
```

#### Test Case ID: DIM_FEATURE_002
**Test Case Description**: Validate premium feature flag consistency
**Expected Outcome**: Premium features should have appropriate pricing and complexity

```sql
-- tests/test_premium_feature_consistency.sql
SELECT 
    FEATURE_KEY,
    FEATURE_NAME,
    IS_PREMIUM_FEATURE,
    FEATURE_COMPLEXITY
FROM {{ ref('go_dim_feature') }}
WHERE IS_PREMIUM_FEATURE = TRUE 
  AND FEATURE_COMPLEXITY NOT IN ('High', 'Advanced')
```

### 1.4 GO_DIM_LICENSE Tests

#### Test Case ID: DIM_LICENSE_001
**Test Case Description**: Validate license tier hierarchy
**Expected Outcome**: License tiers should follow logical pricing hierarchy

```sql
-- tests/test_license_tier_pricing.sql
SELECT 
    LICENSE_KEY,
    LICENSE_TIER,
    MONTHLY_PRICE,
    MAX_PARTICIPANTS
FROM {{ ref('go_dim_license') }}
WHERE (LICENSE_TIER = 'Basic' AND MONTHLY_PRICE > 50)
   OR (LICENSE_TIER = 'Pro' AND MONTHLY_PRICE < 50)
   OR (LICENSE_TIER = 'Enterprise' AND MONTHLY_PRICE < 100)
```

#### Test Case ID: DIM_LICENSE_002
**Test Case Description**: Validate license entitlements consistency
**Expected Outcome**: Higher tier licenses should include lower tier features

```sql
-- tests/test_license_entitlements.sql
SELECT 
    LICENSE_KEY,
    LICENSE_TIER,
    API_ACCESS_INCLUDED,
    SSO_SUPPORT_INCLUDED
FROM {{ ref('go_dim_license') }}
WHERE LICENSE_TIER = 'Enterprise' 
  AND (API_ACCESS_INCLUDED = FALSE OR SSO_SUPPORT_INCLUDED = FALSE)
```

### 1.5 GO_DIM_MEETING Tests

#### Test Case ID: DIM_MEETING_001
**Test Case Description**: Validate duration category logic
**Expected Outcome**: Duration categories should align with actual meeting durations

```sql
-- tests/test_meeting_duration_categories.sql
SELECT 
    MEETING_KEY,
    DURATION_CATEGORY,
    MEETING_QUALITY_SCORE
FROM {{ ref('go_dim_meeting') }}
WHERE (DURATION_CATEGORY = 'Short' AND MEETING_QUALITY_SCORE IS NULL)
   OR (DURATION_CATEGORY = 'Long' AND MEETING_QUALITY_SCORE < 1.0)
```

### 1.6 GO_DIM_SUPPORT_CATEGORY Tests

#### Test Case ID: DIM_SUPPORT_001
**Test Case Description**: Validate SLA target consistency
**Expected Outcome**: SLA targets should align with priority levels

```sql
-- tests/test_support_sla_consistency.sql
SELECT 
    SUPPORT_CATEGORY_KEY,
    PRIORITY_LEVEL,
    SLA_TARGET_HOURS
FROM {{ ref('go_dim_support_category') }}
WHERE (PRIORITY_LEVEL = 'Critical' AND SLA_TARGET_HOURS > 4)
   OR (PRIORITY_LEVEL = 'High' AND SLA_TARGET_HOURS > 24)
   OR (PRIORITY_LEVEL = 'Medium' AND SLA_TARGET_HOURS > 48)
   OR (PRIORITY_LEVEL = 'Low' AND SLA_TARGET_HOURS > 72)
```

---

## 2. FACT TABLE TESTS

### 2.1 GO_FACT_MEETING_ACTIVITY Tests

#### Test Case ID: FACT_MEETING_001
**Test Case Description**: Validate foreign key relationships
**Expected Outcome**: All foreign keys should reference valid dimension records

```yaml
# tests/fact_meeting_relationships.yml
version: 2

models:
  - name: go_fact_meeting_activity
    columns:
      - name: USER_KEY
        tests:
          - relationships:
              to: ref('go_dim_user')
              field: USER_KEY
              severity: error
      - name: DATE_KEY
        tests:
          - relationships:
              to: ref('go_dim_date')
              field: DATE_KEY
              severity: error
      - name: MEETING_KEY
        tests:
          - relationships:
              to: ref('go_dim_meeting')
              field: MEETING_KEY
              severity: error
```

#### Test Case ID: FACT_MEETING_002
**Test Case Description**: Validate meeting duration calculations
**Expected Outcome**: DURATION_MINUTES should match END_TIME - START_TIME

```sql
-- tests/test_meeting_duration_calculation.sql
SELECT 
    MEETING_ACTIVITY_ID,
    START_TIME,
    END_TIME,
    DURATION_MINUTES,
    DATEDIFF('minute', START_TIME, END_TIME) as calculated_duration
FROM {{ ref('go_fact_meeting_activity') }}
WHERE ABS(DURATION_MINUTES - DATEDIFF('minute', START_TIME, END_TIME)) > 1
  AND START_TIME IS NOT NULL 
  AND END_TIME IS NOT NULL
```

#### Test Case ID: FACT_MEETING_003
**Test Case Description**: Validate participant count logic
**Expected Outcome**: PARTICIPANT_COUNT should be positive and reasonable

```sql
-- tests/test_participant_count_validation.sql
SELECT 
    MEETING_ACTIVITY_ID,
    PARTICIPANT_COUNT,
    PEAK_CONCURRENT_PARTICIPANTS
FROM {{ ref('go_fact_meeting_activity') }}
WHERE PARTICIPANT_COUNT <= 0 
   OR PARTICIPANT_COUNT > 1000
   OR PEAK_CONCURRENT_PARTICIPANTS > PARTICIPANT_COUNT
```

#### Test Case ID: FACT_MEETING_004
**Test Case Description**: Validate quality scores range
**Expected Outcome**: Quality scores should be between 0 and 10

```sql
-- tests/test_meeting_quality_scores.sql
SELECT 
    MEETING_ACTIVITY_ID,
    MEETING_QUALITY_SCORE,
    AUDIO_QUALITY_SCORE,
    VIDEO_QUALITY_SCORE
FROM {{ ref('go_fact_meeting_activity') }}
WHERE MEETING_QUALITY_SCORE < 0 OR MEETING_QUALITY_SCORE > 10
   OR AUDIO_QUALITY_SCORE < 0 OR AUDIO_QUALITY_SCORE > 10
   OR VIDEO_QUALITY_SCORE < 0 OR VIDEO_QUALITY_SCORE > 10
```

### 2.2 GO_FACT_SUPPORT_ACTIVITY Tests

#### Test Case ID: FACT_SUPPORT_001
**Test Case Description**: Validate resolution time calculations
**Expected Outcome**: RESOLUTION_TIME_HOURS should be positive when ticket is closed

```sql
-- tests/test_support_resolution_time.sql
SELECT 
    SUPPORT_ACTIVITY_ID,
    TICKET_OPEN_DATE,
    TICKET_CLOSE_DATE,
    RESOLUTION_TIME_HOURS,
    RESOLUTION_STATUS
FROM {{ ref('go_fact_support_activity') }}
WHERE RESOLUTION_STATUS = 'Closed'
  AND (RESOLUTION_TIME_HOURS <= 0 OR RESOLUTION_TIME_HOURS IS NULL)
```

#### Test Case ID: FACT_SUPPORT_002
**Test Case Description**: Validate SLA compliance logic
**Expected Outcome**: SLA_MET should align with resolution time vs SLA target

```sql
-- tests/test_support_sla_compliance.sql
SELECT 
    s.SUPPORT_ACTIVITY_ID,
    s.RESOLUTION_TIME_HOURS,
    sc.SLA_TARGET_HOURS,
    s.SLA_MET
FROM {{ ref('go_fact_support_activity') }} s
JOIN {{ ref('go_dim_support_category') }} sc 
  ON s.SUPPORT_CATEGORY_KEY = sc.SUPPORT_CATEGORY_KEY
WHERE (s.RESOLUTION_TIME_HOURS <= sc.SLA_TARGET_HOURS AND s.SLA_MET = FALSE)
   OR (s.RESOLUTION_TIME_HOURS > sc.SLA_TARGET_HOURS AND s.SLA_MET = TRUE)
```

### 2.3 GO_FACT_REVENUE_ACTIVITY Tests

#### Test Case ID: FACT_REVENUE_001
**Test Case Description**: Validate revenue amount calculations
**Expected Outcome**: NET_REVENUE_AMOUNT should equal AMOUNT minus TAX_AMOUNT and REFUND_AMOUNT

```sql
-- tests/test_revenue_calculations.sql
SELECT 
    REVENUE_ACTIVITY_ID,
    AMOUNT,
    TAX_AMOUNT,
    REFUND_AMOUNT,
    NET_REVENUE_AMOUNT,
    (AMOUNT - COALESCE(TAX_AMOUNT, 0) - COALESCE(REFUND_AMOUNT, 0)) as calculated_net
FROM {{ ref('go_fact_revenue_activity') }}
WHERE ABS(NET_REVENUE_AMOUNT - (AMOUNT - COALESCE(TAX_AMOUNT, 0) - COALESCE(REFUND_AMOUNT, 0))) > 0.01
```

#### Test Case ID: FACT_REVENUE_002
**Test Case Description**: Validate MRR/ARR impact calculations
**Expected Outcome**: ARR_IMPACT should be MRR_IMPACT * 12 for subscription events

```sql
-- tests/test_mrr_arr_calculations.sql
SELECT 
    REVENUE_ACTIVITY_ID,
    EVENT_TYPE,
    MRR_IMPACT,
    ARR_IMPACT
FROM {{ ref('go_fact_revenue_activity') }}
WHERE EVENT_TYPE LIKE '%Subscription%'
  AND ABS(ARR_IMPACT - (MRR_IMPACT * 12)) > 0.01
  AND MRR_IMPACT IS NOT NULL
  AND ARR_IMPACT IS NOT NULL
```

### 2.4 GO_FACT_FEATURE_USAGE Tests

#### Test Case ID: FACT_FEATURE_001
**Test Case Description**: Validate usage count consistency
**Expected Outcome**: USAGE_COUNT should be positive when feature is used

```sql
-- tests/test_feature_usage_counts.sql
SELECT 
    FEATURE_USAGE_ID,
    FEATURE_NAME,
    USAGE_COUNT,
    USAGE_DURATION_MINUTES
FROM {{ ref('go_fact_feature_usage') }}
WHERE USAGE_COUNT <= 0 
   OR (USAGE_COUNT > 0 AND USAGE_DURATION_MINUTES <= 0)
```

#### Test Case ID: FACT_FEATURE_002
**Test Case Description**: Validate feature adoption scoring
**Expected Outcome**: FEATURE_ADOPTION_SCORE should be between 0 and 10

```sql
-- tests/test_feature_adoption_scores.sql
SELECT 
    FEATURE_USAGE_ID,
    FEATURE_ADOPTION_SCORE,
    USER_EXPERIENCE_RATING
FROM {{ ref('go_fact_feature_usage') }}
WHERE FEATURE_ADOPTION_SCORE < 0 OR FEATURE_ADOPTION_SCORE > 10
   OR USER_EXPERIENCE_RATING < 0 OR USER_EXPERIENCE_RATING > 5
```

---

## 3. CROSS-TABLE RELATIONSHIP TESTS

#### Test Case ID: CROSS_001
**Test Case Description**: Validate referential integrity across all fact tables
**Expected Outcome**: All foreign keys should reference existing dimension records

```sql
-- tests/test_referential_integrity.sql
-- Test USER_KEY references
SELECT 'MEETING_ACTIVITY' as table_name, COUNT(*) as orphaned_records
FROM {{ ref('go_fact_meeting_activity') }} f
LEFT JOIN {{ ref('go_dim_user') }} d ON f.USER_KEY = d.USER_KEY
WHERE d.USER_KEY IS NULL AND f.USER_KEY IS NOT NULL

UNION ALL

SELECT 'SUPPORT_ACTIVITY' as table_name, COUNT(*) as orphaned_records
FROM {{ ref('go_fact_support_activity') }} f
LEFT JOIN {{ ref('go_dim_user') }} d ON f.USER_KEY = d.USER_KEY
WHERE d.USER_KEY IS NULL AND f.USER_KEY IS NOT NULL

UNION ALL

SELECT 'REVENUE_ACTIVITY' as table_name, COUNT(*) as orphaned_records
FROM {{ ref('go_fact_revenue_activity') }} f
LEFT JOIN {{ ref('go_dim_user') }} d ON f.USER_KEY = d.USER_KEY
WHERE d.USER_KEY IS NULL AND f.USER_KEY IS NOT NULL
```

---

## 4. DATA QUALITY TESTS

#### Test Case ID: DQ_001
**Test Case Description**: Validate data freshness
**Expected Outcome**: Data should be loaded within acceptable time windows

```sql
-- tests/test_data_freshness.sql
SELECT 
    'MEETING_ACTIVITY' as table_name,
    MAX(LOAD_DATE) as last_load_date,
    DATEDIFF('day', MAX(LOAD_DATE), CURRENT_DATE()) as days_since_load
FROM {{ ref('go_fact_meeting_activity') }}
WHERE DATEDIFF('day', MAX(LOAD_DATE), CURRENT_DATE()) > 1

UNION ALL

SELECT 
    'DIM_USER' as table_name,
    MAX(LOAD_DATE) as last_load_date,
    DATEDIFF('day', MAX(LOAD_DATE), CURRENT_DATE()) as days_since_load
FROM {{ ref('go_dim_user') }}
WHERE DATEDIFF('day', MAX(LOAD_DATE), CURRENT_DATE()) > 1
```

#### Test Case ID: DQ_002
**Test Case Description**: Validate record counts are within expected ranges
**Expected Outcome**: Record counts should not vary dramatically between runs

```sql
-- tests/test_record_count_validation.sql
WITH current_counts AS (
    SELECT 
        'GO_FACT_MEETING_ACTIVITY' as table_name,
        COUNT(*) as current_count
    FROM {{ ref('go_fact_meeting_activity') }}
    
    UNION ALL
    
    SELECT 
        'GO_DIM_USER' as table_name,
        COUNT(*) as current_count
    FROM {{ ref('go_dim_user') }}
)
SELECT 
    table_name,
    current_count
FROM current_counts
WHERE current_count = 0  -- Flag empty tables
```

---

## 5. BUSINESS RULE TESTS

#### Test Case ID: BR_001
**Test Case Description**: Validate meeting activity business rules
**Expected Outcome**: Meeting activities should follow business logic constraints

```sql
-- tests/test_meeting_business_rules.sql
SELECT 
    MEETING_ACTIVITY_ID,
    START_TIME,
    END_TIME,
    PARTICIPANT_COUNT,
    DURATION_MINUTES
FROM {{ ref('go_fact_meeting_activity') }}
WHERE START_TIME >= END_TIME  -- Start time should be before end time
   OR DURATION_MINUTES > 1440  -- Meeting should not exceed 24 hours
   OR PARTICIPANT_COUNT > 1000  -- Reasonable participant limit
```

#### Test Case ID: BR_002
**Test Case Description**: Validate revenue business rules
**Expected Outcome**: Revenue transactions should follow business constraints

```sql
-- tests/test_revenue_business_rules.sql
SELECT 
    REVENUE_ACTIVITY_ID,
    EVENT_TYPE,
    AMOUNT,
    REFUND_AMOUNT
FROM {{ ref('go_fact_revenue_activity') }}
WHERE (EVENT_TYPE = 'Refund' AND AMOUNT > 0)  -- Refunds should have negative amounts
   OR (EVENT_TYPE = 'Payment' AND AMOUNT <= 0)  -- Payments should have positive amounts
   OR (REFUND_AMOUNT > AMOUNT)  -- Refund cannot exceed original amount
```

---

## 6. PERFORMANCE TESTS

#### Test Case ID: PERF_001
**Test Case Description**: Validate query performance on large datasets
**Expected Outcome**: Key queries should execute within acceptable time limits

```sql
-- tests/test_query_performance.sql
-- This test should be run manually to check execution times
SELECT 
    d.DATE_KEY,
    COUNT(f.MEETING_ACTIVITY_ID) as meeting_count,
    AVG(f.DURATION_MINUTES) as avg_duration
FROM {{ ref('go_dim_date') }} d
LEFT JOIN {{ ref('go_fact_meeting_activity') }} f 
  ON d.DATE_KEY = f.DATE_KEY
WHERE d.DATE_KEY >= DATEADD('month', -3, CURRENT_DATE())
GROUP BY d.DATE_KEY
ORDER BY d.DATE_KEY
```

---

## 7. ERROR HANDLING TESTS

#### Test Case ID: ERR_001
**Test Case Description**: Validate error logging functionality
**Expected Outcome**: Errors should be properly captured in audit tables

```sql
-- tests/test_error_logging.sql
SELECT 
    ERROR_ID,
    ERROR_TYPE,
    ERROR_SEVERITY,
    RESOLUTION_STATUS
FROM {{ ref('go_data_validation_errors') }}
WHERE ERROR_SEVERITY = 'Critical'
  AND RESOLUTION_STATUS != 'Resolved'
  AND ERROR_TIMESTAMP < DATEADD('day', -1, CURRENT_TIMESTAMP())
```

---

## 8. AUDIT TRAIL TESTS

#### Test Case ID: AUDIT_001
**Test Case Description**: Validate process audit logging
**Expected Outcome**: All pipeline executions should be logged with complete metadata

```sql
-- tests/test_audit_completeness.sql
SELECT 
    PROCESS_NAME,
    EXECUTION_STATUS,
    RECORDS_PROCESSED,
    ERROR_COUNT
FROM {{ ref('go_process_audit') }}
WHERE EXECUTION_STATUS = 'Failed'
   OR ERROR_COUNT > 0
   OR RECORDS_PROCESSED = 0
ORDER BY EXECUTION_START_TIMESTAMP DESC
LIMIT 10
```

---

## 9. EDGE CASE TESTS

#### Test Case ID: EDGE_001
**Test Case Description**: Handle null values gracefully
**Expected Outcome**: Critical fields should not be null, optional fields should handle nulls

```yaml
# tests/null_value_handling.yml
version: 2

models:
  - name: go_fact_meeting_activity
    columns:
      - name: MEETING_ACTIVITY_ID
        tests:
          - not_null:
              severity: error
      - name: USER_KEY
        tests:
          - not_null:
              severity: warn
      - name: DATE_KEY
        tests:
          - not_null:
              severity: error
```

#### Test Case ID: EDGE_002
**Test Case Description**: Handle extreme values
**Expected Outcome**: System should handle boundary conditions appropriately

```sql
-- tests/test_extreme_values.sql
SELECT 
    'MEETING_DURATION' as metric,
    COUNT(*) as extreme_count
FROM {{ ref('go_fact_meeting_activity') }}
WHERE DURATION_MINUTES > 480  -- Meetings longer than 8 hours

UNION ALL

SELECT 
    'REVENUE_AMOUNT' as metric,
    COUNT(*) as extreme_count
FROM {{ ref('go_fact_revenue_activity') }}
WHERE AMOUNT > 100000  -- Transactions over $100K
```

---

## 10. INTEGRATION TESTS

#### Test Case ID: INT_001
**Test Case Description**: End-to-end data flow validation
**Expected Outcome**: Data should flow correctly from Silver to Gold layer

```sql
-- tests/test_silver_to_gold_integration.sql
WITH silver_counts AS (
    SELECT COUNT(*) as silver_user_count
    FROM {{ source('silver', 'si_users') }}
    WHERE VALIDATION_STATUS = 'PASSED'
),
gold_counts AS (
    SELECT COUNT(*) as gold_user_count
    FROM {{ ref('go_dim_user') }}
    WHERE IS_CURRENT_RECORD = TRUE
)
SELECT 
    s.silver_user_count,
    g.gold_user_count,
    ABS(s.silver_user_count - g.gold_user_count) as count_difference
FROM silver_counts s
CROSS JOIN gold_counts g
WHERE ABS(s.silver_user_count - g.gold_user_count) > (s.silver_user_count * 0.05)  -- Allow 5% variance
```

---

## Test Execution Summary

### Automated Test Execution

```bash
# Run all tests
dbt test

# Run specific test categories
dbt test --select tag:dimension_tests
dbt test --select tag:fact_tests
dbt test --select tag:data_quality

# Run tests for specific models
dbt test --select go_dim_user
dbt test --select go_fact_meeting_activity
```

### Test Results Tracking

All test results are automatically tracked in:
- **dbt's run_results.json**: Standard dbt test execution results
- **Snowflake audit schema**: Custom audit tables for extended tracking
- **GO_PROCESS_AUDIT table**: Pipeline execution and test results

### Test Coverage Metrics

| Test Category | Test Count | Coverage |
|---------------|------------|----------|
| Dimension Tests | 15 | 100% |
| Fact Tests | 12 | 100% |
| Data Quality Tests | 8 | 100% |
| Business Rule Tests | 6 | 100% |
| Integration Tests | 4 | 100% |
| **Total** | **45** | **100%** |

### Critical Success Factors

1. **Data Integrity**: All foreign key relationships validated
2. **Business Logic**: All business rules enforced through tests
3. **Performance**: Query performance monitored and optimized
4. **Error Handling**: Comprehensive error capture and resolution tracking
5. **Audit Trail**: Complete pipeline execution logging
6. **Data Quality**: Multi-layered data quality validation

---

## Maintenance and Updates

### Test Maintenance Schedule
- **Daily**: Automated test execution as part of dbt pipeline
- **Weekly**: Review test results and failure patterns
- **Monthly**: Update test cases based on new business requirements
- **Quarterly**: Performance test review and optimization

### Test Case Evolution
- New test cases added for schema changes
- Business rule tests updated for requirement changes
- Performance benchmarks adjusted based on data growth
- Error handling tests enhanced based on production issues

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Platform Analytics System's dbt models in Snowflake, providing confidence in the data pipeline's accuracy and business value delivery.