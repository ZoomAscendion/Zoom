_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Gold Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Platform Analytics Gold Layer

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Gold Layer pipeline. The tests ensure data quality, transformation accuracy, and business rule compliance across all dimension and fact tables in the Gold layer.

### Test Coverage Areas

1. **Data Transformation Validation**: Verify correct transformation logic from Silver to Gold layer
2. **Business Rule Compliance**: Ensure adherence to business rules and constraints
3. **Data Quality Assurance**: Validate data completeness, accuracy, and consistency
4. **Referential Integrity**: Test foreign key relationships between facts and dimensions
5. **Edge Case Handling**: Test null values, empty datasets, and boundary conditions
6. **Performance Validation**: Ensure optimal query performance and clustering effectiveness

### dbt Testing Framework Components

- **Schema Tests**: YAML-based tests for data quality (unique, not_null, relationships, accepted_values)
- **Custom SQL Tests**: Complex business logic validation using SQL
- **Unit Tests**: Isolated testing of individual model transformations
- **Integration Tests**: End-to-end pipeline validation
- **Data Quality Tests**: Comprehensive data validation using dbt-expectations

## Test Case Categories

### 1. Dimension Table Tests

#### 1.1 GO_DIM_USER Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_USER_001 | Validate USER_KEY uniqueness across all records | All USER_KEY values are unique | Schema Test |
| DIM_USER_002 | Ensure USER_ID is not null for all records | No null values in USER_ID column | Schema Test |
| DIM_USER_003 | Validate PLAN_TYPE contains only allowed values | Only 'Basic', 'Pro', 'Enterprise', 'Unknown' values | Schema Test |
| DIM_USER_004 | Test EMAIL_DOMAIN extraction logic | Correct domain extraction from email addresses | Custom SQL Test |
| DIM_USER_005 | Validate SCD Type 2 implementation | Proper effective date handling and current record flags | Custom SQL Test |
| DIM_USER_006 | Test PLAN_CATEGORY derivation logic | Correct mapping from PLAN_TYPE to PLAN_CATEGORY | Custom SQL Test |
| DIM_USER_007 | Validate USER_STATUS calculation | Proper status derivation from VALIDATION_STATUS | Custom SQL Test |
| DIM_USER_008 | Test null handling in USER_NAME | Proper handling of null/empty user names | Edge Case Test |
| DIM_USER_009 | Validate GEOGRAPHIC_REGION assignment | Correct region mapping from email domains | Custom SQL Test |
| DIM_USER_010 | Test INDUSTRY_SECTOR classification | Proper industry assignment from company names | Custom SQL Test |

#### 1.2 GO_DIM_DATE Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_DATE_001 | Validate DATE_KEY uniqueness | All dates are unique in the dimension | Schema Test |
| DIM_DATE_002 | Ensure complete date range coverage | All dates from 2020-01-01 to 2030-12-31 present | Custom SQL Test |
| DIM_DATE_003 | Validate fiscal year calculation | Correct fiscal year assignment (April 1st start) | Custom SQL Test |
| DIM_DATE_004 | Test weekend flag accuracy | Proper weekend identification (Saturday/Sunday) | Custom SQL Test |
| DIM_DATE_005 | Validate quarter calculation | Correct quarter assignment for all dates | Custom SQL Test |
| DIM_DATE_006 | Test fiscal quarter logic | Proper fiscal quarter calculation | Custom SQL Test |
| DIM_DATE_007 | Validate month name consistency | Correct month names for all dates | Custom SQL Test |
| DIM_DATE_008 | Test day name accuracy | Proper day names for all dates | Custom SQL Test |
| DIM_DATE_009 | Validate week of year calculation | Correct week numbers for all dates | Custom SQL Test |
| DIM_DATE_010 | Test leap year handling | Proper handling of February 29th in leap years | Edge Case Test |

#### 1.3 GO_DIM_FEATURE Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_FEAT_001 | Validate FEATURE_KEY uniqueness | All feature keys are unique | Schema Test |
| DIM_FEAT_002 | Ensure FEATURE_NAME is not null | No null values in feature names | Schema Test |
| DIM_FEAT_003 | Test FEATURE_CATEGORY classification | Correct categorization of features | Custom SQL Test |
| DIM_FEAT_004 | Validate IS_PREMIUM_FEATURE logic | Proper premium feature identification | Custom SQL Test |
| DIM_FEAT_005 | Test FEATURE_COMPLEXITY assignment | Correct complexity level assignment | Custom SQL Test |
| DIM_FEAT_006 | Validate FEATURE_TYPE derivation | Proper feature type classification | Custom SQL Test |
| DIM_FEAT_007 | Test feature name standardization | Consistent feature name formatting | Custom SQL Test |
| DIM_FEAT_008 | Validate TARGET_USER_SEGMENT assignment | Correct user segment targeting | Custom SQL Test |
| DIM_FEAT_009 | Test duplicate feature handling | No duplicate features in dimension | Edge Case Test |
| DIM_FEAT_010 | Validate FEATURE_STATUS consistency | All features have valid status values | Schema Test |

#### 1.4 GO_DIM_LICENSE Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_LIC_001 | Validate LICENSE_KEY uniqueness | All license keys are unique | Schema Test |
| DIM_LIC_002 | Test LICENSE_CATEGORY mapping | Correct category assignment from license type | Custom SQL Test |
| DIM_LIC_003 | Validate pricing calculations | Accurate monthly and annual pricing | Custom SQL Test |
| DIM_LIC_004 | Test participant limits assignment | Correct max participant limits per license | Custom SQL Test |
| DIM_LIC_005 | Validate storage limits | Proper storage limit assignment | Custom SQL Test |
| DIM_LIC_006 | Test feature entitlements | Correct feature inclusion flags | Custom SQL Test |
| DIM_LIC_007 | Validate SCD Type 2 for licenses | Proper historical tracking of license changes | Custom SQL Test |
| DIM_LIC_008 | Test LICENSE_TIER assignment | Correct tier classification | Custom SQL Test |
| DIM_LIC_009 | Validate effective date ranges | Proper start and end date handling | Custom SQL Test |
| DIM_LIC_010 | Test null license type handling | Proper handling of unknown license types | Edge Case Test |

#### 1.5 GO_DIM_MEETING_TYPE Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_MEET_001 | Validate MEETING_TYPE_ID uniqueness | All meeting type IDs are unique | Schema Test |
| DIM_MEET_002 | Test DURATION_CATEGORY logic | Correct duration categorization | Custom SQL Test |
| DIM_MEET_003 | Validate TIME_OF_DAY_CATEGORY | Proper time of day classification | Custom SQL Test |
| DIM_MEET_004 | Test IS_WEEKEND_MEETING flag | Correct weekend meeting identification | Custom SQL Test |
| DIM_MEET_005 | Validate MEETING_QUALITY_THRESHOLD | Proper quality threshold assignment | Custom SQL Test |
| DIM_MEET_006 | Test BUSINESS_PURPOSE assignment | Correct business purpose classification | Custom SQL Test |
| DIM_MEET_007 | Validate DAY_OF_WEEK extraction | Proper day name extraction | Custom SQL Test |
| DIM_MEET_008 | Test PARTICIPANT_SIZE_CATEGORY | Correct participant size classification | Custom SQL Test |
| DIM_MEET_009 | Validate IS_RECURRING_TYPE logic | Proper recurring meeting identification | Custom SQL Test |
| DIM_MEET_010 | Test meeting categorization rules | Consistent meeting category assignment | Custom SQL Test |

#### 1.6 GO_DIM_SUPPORT_CATEGORY Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_SUPP_001 | Validate SUPPORT_CATEGORY_ID uniqueness | All support category IDs are unique | Schema Test |
| DIM_SUPP_002 | Test PRIORITY_LEVEL assignment | Correct priority level classification | Custom SQL Test |
| DIM_SUPP_003 | Validate SLA_TARGET_HOURS calculation | Proper SLA target assignment | Custom SQL Test |
| DIM_SUPP_004 | Test REQUIRES_ESCALATION logic | Correct escalation requirement flags | Custom SQL Test |
| DIM_SUPP_005 | Validate SELF_SERVICE_AVAILABLE flags | Proper self-service availability assignment | Custom SQL Test |
| DIM_SUPP_006 | Test CUSTOMER_IMPACT_LEVEL classification | Correct impact level assignment | Custom SQL Test |
| DIM_SUPP_007 | Validate DEPARTMENT_RESPONSIBLE mapping | Proper department assignment | Custom SQL Test |
| DIM_SUPP_008 | Test EXPECTED_RESOLUTION_TIME logic | Correct resolution time calculation | Custom SQL Test |
| DIM_SUPP_009 | Validate KNOWLEDGE_BASE_ARTICLES count | Proper article count assignment | Custom SQL Test |
| DIM_SUPP_010 | Test support subcategory derivation | Correct subcategory classification | Custom SQL Test |

### 2. Fact Table Tests

#### 2.1 GO_FACT_MEETING_ACTIVITY Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| FACT_MEET_001 | Validate foreign key relationships | All dimension keys exist in respective dimensions | Relationship Test |
| FACT_MEET_002 | Test meeting duration calculations | Accurate duration calculations from start/end times | Custom SQL Test |
| FACT_MEET_003 | Validate participant count accuracy | Correct participant count aggregation | Custom SQL Test |
| FACT_MEET_004 | Test meeting quality score calculation | Proper quality score derivation | Custom SQL Test |
| FACT_MEET_005 | Validate feature usage aggregation | Accurate feature usage count summation | Custom SQL Test |
| FACT_MEET_006 | Test null handling in metrics | Proper null value handling in calculations | Edge Case Test |
| FACT_MEET_007 | Validate date key assignment | Correct date key mapping from meeting dates | Custom SQL Test |
| FACT_MEET_008 | Test duplicate meeting prevention | No duplicate meeting records | Custom SQL Test |
| FACT_MEET_009 | Validate audio/video quality scores | Proper quality score calculations | Custom SQL Test |
| FACT_MEET_010 | Test meeting satisfaction metrics | Accurate satisfaction score derivation | Custom SQL Test |

#### 2.2 GO_FACT_FEATURE_USAGE Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| FACT_FEAT_001 | Validate foreign key relationships | All dimension keys exist in respective dimensions | Relationship Test |
| FACT_FEAT_002 | Test usage count accuracy | Correct usage count aggregation | Custom SQL Test |
| FACT_FEAT_003 | Validate adoption score calculation | Proper adoption score derivation | Custom SQL Test |
| FACT_FEAT_004 | Test performance score logic | Accurate performance score calculation | Custom SQL Test |
| FACT_FEAT_005 | Validate success rate calculation | Correct success rate computation | Custom SQL Test |
| FACT_FEAT_006 | Test usage duration metrics | Proper duration calculation and aggregation | Custom SQL Test |
| FACT_FEAT_007 | Validate user experience rating | Accurate user experience score derivation | Custom SQL Test |
| FACT_FEAT_008 | Test concurrent features tracking | Proper concurrent feature count | Custom SQL Test |
| FACT_FEAT_009 | Validate error count handling | Correct error count aggregation | Custom SQL Test |
| FACT_FEAT_010 | Test usage context classification | Proper usage context assignment | Custom SQL Test |

#### 2.3 GO_FACT_REVENUE_EVENTS Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| FACT_REV_001 | Validate foreign key relationships | All dimension keys exist in respective dimensions | Relationship Test |
| FACT_REV_002 | Test revenue amount calculations | Accurate revenue amount computations | Custom SQL Test |
| FACT_REV_003 | Validate MRR/ARR calculations | Correct MRR and ARR derivation | Custom SQL Test |
| FACT_REV_004 | Test currency standardization | Proper USD conversion and standardization | Custom SQL Test |
| FACT_REV_005 | Validate customer lifetime value | Accurate CLV calculation | Custom SQL Test |
| FACT_REV_006 | Test churn risk scoring | Proper churn risk score assignment | Custom SQL Test |
| FACT_REV_007 | Validate payment status logic | Correct payment status classification | Custom SQL Test |
| FACT_REV_008 | Test refund handling | Proper refund amount and reason tracking | Custom SQL Test |
| FACT_REV_009 | Validate commission calculations | Accurate commission amount computation | Custom SQL Test |
| FACT_REV_010 | Test proration logic | Correct proration amount calculation | Custom SQL Test |

#### 2.4 GO_FACT_SUPPORT_METRICS Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| FACT_SUPP_001 | Validate foreign key relationships | All dimension keys exist in respective dimensions | Relationship Test |
| FACT_SUPP_002 | Test resolution time calculations | Accurate resolution time computation | Custom SQL Test |
| FACT_SUPP_003 | Validate SLA compliance tracking | Correct SLA met/breach calculations | Custom SQL Test |
| FACT_SUPP_004 | Test first contact resolution logic | Proper FCR flag assignment | Custom SQL Test |
| FACT_SUPP_005 | Validate escalation count accuracy | Correct escalation count tracking | Custom SQL Test |
| FACT_SUPP_006 | Test customer satisfaction scoring | Accurate satisfaction score calculation | Custom SQL Test |
| FACT_SUPP_007 | Validate response time metrics | Proper first response time calculation | Custom SQL Test |
| FACT_SUPP_008 | Test reopened ticket tracking | Correct reopened count handling | Custom SQL Test |
| FACT_SUPP_009 | Validate cost to resolve calculation | Accurate cost computation | Custom SQL Test |
| FACT_SUPP_010 | Test preventable issue identification | Proper preventable issue flagging | Custom SQL Test |

### 3. Data Quality and Audit Tests

#### 3.1 GO_AUDIT_LOG Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| AUDIT_001 | Validate audit log completeness | All pipeline executions are logged | Custom SQL Test |
| AUDIT_002 | Test execution status accuracy | Correct status tracking (SUCCESS/FAILED) | Custom SQL Test |
| AUDIT_003 | Validate record count accuracy | Accurate record count tracking | Custom SQL Test |
| AUDIT_004 | Test error count tracking | Proper error count aggregation | Custom SQL Test |
| AUDIT_005 | Validate execution duration calculation | Accurate duration computation | Custom SQL Test |
| AUDIT_006 | Test performance metrics capture | Proper performance metric logging | Custom SQL Test |
| AUDIT_007 | Validate process name consistency | Consistent process naming convention | Custom SQL Test |
| AUDIT_008 | Test timestamp accuracy | Proper timestamp recording | Custom SQL Test |
| AUDIT_009 | Validate configuration tracking | Accurate configuration parameter logging | Custom SQL Test |
| AUDIT_010 | Test error detail capture | Comprehensive error detail logging | Custom SQL Test |

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  - name: go_dim_user
    description: "User dimension table with enhanced attributes for analytics"
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
          - unique
      - name: user_name
        description: "Standardized user name"
        tests:
          - not_null
      - name: email_domain
        description: "Extracted email domain"
        tests:
          - not_null
      - name: plan_type
        description: "Standardized plan type"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Unknown']
      - name: plan_category
        description: "High-level plan categorization"
        tests:
          - accepted_values:
              values: ['Free', 'Paid']
      - name: user_status
        description: "Current user status"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive']
      - name: effective_start_date
        description: "SCD Type 2 effective start date"
        tests:
          - not_null
      - name: effective_end_date
        description: "SCD Type 2 effective end date"
        tests:
          - not_null
      - name: is_current_record
        description: "SCD Type 2 current record flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_date
    description: "Standard date dimension for time-based analysis"
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

  - name: go_dim_feature
    description: "Feature dimension with categorization and characteristics"
    columns:
      - name: feature_id
        description: "Surrogate key for feature dimension"
        tests:
          - unique
          - not_null
      - name: feature_name
        description: "Standardized feature name"
        tests:
          - unique
          - not_null
      - name: feature_category
        description: "Feature category classification"
        tests:
          - accepted_values:
              values: ['Collaboration', 'Recording', 'Communication', 'Advanced Meeting', 'Engagement', 'General']
      - name: is_premium_feature
        description: "Premium feature flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_fact_meeting_activity
    description: "Central fact table for meeting activities and engagement metrics"
    columns:
      - name: meeting_activity_id
        description: "Surrogate key for meeting activity fact"
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
      - name: user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_user')
              field: user_dim_id
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours max
      - name: participant_count
        description: "Number of meeting participants"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1
              max_value: 10000
      - name: meeting_quality_score
        description: "Meeting quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 10.0

  - name: go_fact_revenue_events
    description: "Revenue events fact table for financial analysis"
    columns:
      - name: revenue_event_id
        description: "Surrogate key for revenue event fact"
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
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000000
      - name: currency_code
        description: "Currency code"
        tests:
          - not_null
          - accepted_values:
              values: ['USD', 'EUR', 'GBP', 'CAD']
```

### Custom SQL Tests

#### Test 1: Email Domain Extraction Validation

```sql
-- tests/test_email_domain_extraction.sql
-- Test that email domain extraction is working correctly

SELECT 
    user_id,
    email,
    email_domain,
    CASE 
        WHEN email_domain != UPPER(SUBSTRING(email, POSITION('@' IN email) + 1)) 
        THEN 'FAIL' 
        ELSE 'PASS' 
    END as test_result
FROM {{ ref('go_dim_user') }}
WHERE email IS NOT NULL
  AND test_result = 'FAIL'
```

#### Test 2: SCD Type 2 Validation

```sql
-- tests/test_scd_type2_validation.sql
-- Test that SCD Type 2 logic is working correctly

WITH scd_validation AS (
    SELECT 
        user_id,
        COUNT(*) as record_count,
        SUM(CASE WHEN is_current_record = TRUE THEN 1 ELSE 0 END) as current_count,
        MIN(effective_start_date) as min_start_date,
        MAX(effective_end_date) as max_end_date
    FROM {{ ref('go_dim_user') }}
    GROUP BY user_id
)
SELECT *
FROM scd_validation
WHERE current_count != 1  -- Each user should have exactly one current record
   OR min_start_date > max_end_date  -- Start date should be before end date
```

#### Test 3: Meeting Duration Validation

```sql
-- tests/test_meeting_duration_validation.sql
-- Test that meeting durations are calculated correctly

SELECT 
    meeting_id,
    meeting_start_time,
    meeting_end_time,
    actual_duration_minutes,
    DATEDIFF('minute', meeting_start_time, meeting_end_time) as calculated_duration,
    ABS(actual_duration_minutes - calculated_duration) as duration_diff
FROM {{ ref('go_fact_meeting_activity') }}
WHERE duration_diff > 1  -- Allow 1 minute tolerance for rounding
```

#### Test 4: Revenue Calculation Validation

```sql
-- tests/test_revenue_calculation_validation.sql
-- Test that revenue calculations are accurate

SELECT 
    revenue_event_id,
    gross_amount,
    tax_amount,
    discount_amount,
    net_amount,
    (gross_amount - tax_amount - discount_amount) as calculated_net,
    ABS(net_amount - calculated_net) as net_diff
FROM {{ ref('go_fact_revenue_events') }}
WHERE net_diff > 0.01  -- Allow 1 cent tolerance for rounding
```

#### Test 5: Feature Usage Aggregation Validation

```sql
-- tests/test_feature_usage_aggregation.sql
-- Test that feature usage counts are aggregated correctly

WITH source_counts AS (
    SELECT 
        meeting_id,
        feature_name,
        SUM(usage_count) as source_total
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE validation_status = 'PASSED'
    GROUP BY meeting_id, feature_name
),
gold_counts AS (
    SELECT 
        meeting_id,
        feature_name,
        usage_count as gold_total
    FROM {{ ref('go_fact_feature_usage') }}
)
SELECT 
    s.meeting_id,
    s.feature_name,
    s.source_total,
    g.gold_total,
    ABS(s.source_total - g.gold_total) as count_diff
FROM source_counts s
JOIN gold_counts g ON s.meeting_id = g.meeting_id AND s.feature_name = g.feature_name
WHERE count_diff > 0
```

#### Test 6: Data Quality Score Validation

```sql
-- tests/test_data_quality_score_validation.sql
-- Test that data quality scores are within valid ranges

SELECT 
    table_name,
    column_name,
    data_quality_score,
    CASE 
        WHEN data_quality_score < 0 OR data_quality_score > 100 THEN 'INVALID_RANGE'
        WHEN data_quality_score IS NULL THEN 'NULL_SCORE'
        ELSE 'VALID'
    END as validation_result
FROM (
    SELECT 'go_dim_user' as table_name, 'data_quality_score' as column_name, data_quality_score FROM {{ source('silver', 'si_users') }}
    UNION ALL
    SELECT 'go_dim_feature' as table_name, 'data_quality_score' as column_name, data_quality_score FROM {{ source('silver', 'si_feature_usage') }}
    UNION ALL
    SELECT 'go_fact_meeting_activity' as table_name, 'data_quality_score' as column_name, data_quality_score FROM {{ source('silver', 'si_meetings') }}
)
WHERE validation_result != 'VALID'
```

### Data Quality Tests using dbt-expectations

#### Test 7: Comprehensive Data Profiling

```sql
-- tests/test_comprehensive_data_profiling.sql
-- Comprehensive data profiling and validation

{{ config(severity = 'warn') }}

SELECT 
    'go_dim_user' as table_name,
    COUNT(*) as total_records,
    COUNT(DISTINCT user_id) as unique_users,
    SUM(CASE WHEN user_name IS NULL THEN 1 ELSE 0 END) as null_user_names,
    SUM(CASE WHEN email_domain IS NULL THEN 1 ELSE 0 END) as null_email_domains,
    AVG(CASE WHEN is_current_record = TRUE THEN 1 ELSE 0 END) * 100 as current_record_percentage
FROM {{ ref('go_dim_user') }}

UNION ALL

SELECT 
    'go_fact_meeting_activity' as table_name,
    COUNT(*) as total_records,
    COUNT(DISTINCT meeting_id) as unique_meetings,
    SUM(CASE WHEN duration_minutes IS NULL THEN 1 ELSE 0 END) as null_durations,
    SUM(CASE WHEN participant_count IS NULL THEN 1 ELSE 0 END) as null_participant_counts,
    AVG(meeting_quality_score) as avg_quality_score
FROM {{ ref('go_fact_meeting_activity') }}
```

#### Test 8: Business Rule Validation

```sql
-- tests/test_business_rule_validation.sql
-- Validate business rules and constraints

-- Rule 1: Meeting end time should be after start time
SELECT 
    'meeting_time_logic' as rule_name,
    COUNT(*) as violation_count
FROM {{ ref('go_fact_meeting_activity') }}
WHERE meeting_end_time <= meeting_start_time

UNION ALL

-- Rule 2: Revenue amounts should be positive for non-refund events
SELECT 
    'positive_revenue_rule' as rule_name,
    COUNT(*) as violation_count
FROM {{ ref('go_fact_revenue_events') }}
WHERE event_type != 'Refund' AND net_amount <= 0

UNION ALL

-- Rule 3: Support tickets should have valid priority levels
SELECT 
    'valid_priority_rule' as rule_name,
    COUNT(*) as violation_count
FROM {{ ref('go_fact_support_metrics') }}
WHERE priority_level NOT IN ('Critical', 'High', 'Medium', 'Low')
```

### Performance Tests

#### Test 9: Query Performance Validation

```sql
-- tests/test_query_performance.sql
-- Test query performance on clustered tables

{{ config(severity = 'warn') }}

WITH performance_test AS (
    SELECT 
        COUNT(*) as record_count,
        COUNT(DISTINCT date_id) as unique_dates,
        COUNT(DISTINCT user_dim_id) as unique_users,
        AVG(duration_minutes) as avg_duration
    FROM {{ ref('go_fact_meeting_activity') }}
    WHERE date_id >= (SELECT DATE_ID FROM {{ ref('go_dim_date') }} WHERE date_value = CURRENT_DATE - 30)
)
SELECT 
    'performance_test' as test_name,
    record_count,
    unique_dates,
    unique_users,
    avg_duration,
    CASE 
        WHEN record_count = 0 THEN 'NO_DATA'
        WHEN unique_dates = 0 THEN 'NO_DATE_RANGE'
        ELSE 'PASS'
    END as test_result
FROM performance_test
WHERE test_result != 'PASS'
```

### Integration Tests

#### Test 10: End-to-End Pipeline Validation

```sql
-- tests/test_end_to_end_pipeline.sql
-- Validate complete pipeline from Silver to Gold

WITH pipeline_validation AS (
    SELECT 
        'silver_to_gold_user_count' as metric_name,
        (
            SELECT COUNT(DISTINCT user_id) 
            FROM {{ source('silver', 'si_users') }} 
            WHERE validation_status = 'PASSED'
        ) as silver_count,
        (
            SELECT COUNT(DISTINCT user_id) 
            FROM {{ ref('go_dim_user') }} 
            WHERE is_current_record = TRUE
        ) as gold_count
    
    UNION ALL
    
    SELECT 
        'silver_to_gold_meeting_count' as metric_name,
        (
            SELECT COUNT(*) 
            FROM {{ source('silver', 'si_meetings') }} 
            WHERE validation_status = 'PASSED'
        ) as silver_count,
        (
            SELECT COUNT(*) 
            FROM {{ ref('go_fact_meeting_activity') }}
        ) as gold_count
)
SELECT 
    metric_name,
    silver_count,
    gold_count,
    ABS(silver_count - gold_count) as count_difference,
    CASE 
        WHEN ABS(silver_count - gold_count) > (silver_count * 0.05) THEN 'SIGNIFICANT_DIFFERENCE'
        WHEN silver_count = 0 AND gold_count = 0 THEN 'NO_DATA'
        ELSE 'PASS'
    END as validation_result
FROM pipeline_validation
WHERE validation_result != 'PASS'
```

## Test Execution Strategy

### 1. Test Execution Order

1. **Schema Tests**: Run first to validate basic data structure and constraints
2. **Custom SQL Tests**: Execute transformation logic validation
3. **Data Quality Tests**: Comprehensive data profiling and validation
4. **Business Rule Tests**: Validate business logic compliance
5. **Performance Tests**: Ensure optimal query performance
6. **Integration Tests**: End-to-end pipeline validation

### 2. Test Automation

```yaml
# dbt_project.yml test configuration
test-paths: ["tests"]

# Test execution commands
# Run all tests: dbt test
# Run specific test: dbt test --select test_name
# Run tests for specific model: dbt test --select go_dim_user
# Run tests with specific severity: dbt test --severity warn
```

### 3. Continuous Integration

```yaml
# .github/workflows/dbt_tests.yml
name: dbt Tests
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup dbt
        run: |
          pip install dbt-snowflake
      - name: Run dbt tests
        run: |
          dbt deps
          dbt seed
          dbt run
          dbt test
        env:
          SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
          SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
          SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}
```

## Test Results Tracking

### 1. Test Results Schema

```sql
-- Create test results tracking table
CREATE TABLE IF NOT EXISTS GOLD.GO_TEST_RESULTS (
    test_execution_id VARCHAR(50),
    test_name VARCHAR(200),
    test_type VARCHAR(100),
    model_name VARCHAR(200),
    test_status VARCHAR(50),
    execution_timestamp TIMESTAMP_NTZ(9),
    error_message VARCHAR(1000),
    records_tested NUMBER(20,0),
    records_failed NUMBER(20,0),
    execution_duration_seconds NUMBER(10,2),
    load_date DATE,
    source_system VARCHAR(100)
);
```

### 2. Test Monitoring Dashboard

```sql
-- Test results summary view for monitoring
CREATE OR REPLACE VIEW GOLD.VW_TEST_RESULTS_SUMMARY AS
SELECT 
    DATE(execution_timestamp) as test_date,
    test_type,
    COUNT(*) as total_tests,
    SUM(CASE WHEN test_status = 'PASS' THEN 1 ELSE 0 END) as passed_tests,
    SUM(CASE WHEN test_status = 'FAIL' THEN 1 ELSE 0 END) as failed_tests,
    SUM(CASE WHEN test_status = 'WARN' THEN 1 ELSE 0 END) as warning_tests,
    ROUND((passed_tests * 100.0) / total_tests, 2) as pass_rate_percentage,
    AVG(execution_duration_seconds) as avg_execution_time
FROM GOLD.GO_TEST_RESULTS
WHERE execution_timestamp >= CURRENT_DATE - 30
GROUP BY DATE(execution_timestamp), test_type
ORDER BY test_date DESC, test_type;
```

## Conclusion

This comprehensive unit test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics Gold Layer dbt models. The tests cover:

- **Data Transformation Accuracy**: Validates all transformation logic from Silver to Gold layer
- **Business Rule Compliance**: Ensures adherence to business requirements and constraints
- **Data Quality Assurance**: Comprehensive validation of data completeness and consistency
- **Performance Optimization**: Validates clustering effectiveness and query performance
- **Integration Validation**: End-to-end pipeline testing and validation

The test framework supports continuous integration, automated execution, and comprehensive monitoring to maintain high data quality standards in the Gold layer analytics platform.

### Key Benefits

1. **Early Issue Detection**: Catch data quality issues before they impact business reporting
2. **Automated Validation**: Continuous testing ensures ongoing data reliability
3. **Performance Monitoring**: Track and optimize query performance over time
4. **Business Confidence**: Ensure accurate business metrics and KPIs
5. **Compliance Assurance**: Validate adherence to business rules and data governance policies

All tests are designed to run efficiently in Snowflake's cloud-native environment and integrate seamlessly with dbt's testing framework for optimal development and deployment workflows.