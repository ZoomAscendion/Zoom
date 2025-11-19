_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Platform Analytics Gold Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Platform Analytics

## Overview

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Gold Layer dimensional models running in Snowflake. The test suite covers all 14 dbt models including 6 dimension tables, 4 fact tables, and 4 supporting models with extensive validation for data transformations, business rules, edge cases, and error handling.

## Test Strategy

### Testing Approach
- **Happy Path Testing**: Validate successful transformations and business logic
- **Edge Case Testing**: Handle null values, empty datasets, boundary conditions
- **Error Handling**: Test data quality failures and constraint violations
- **Performance Testing**: Validate clustering and optimization strategies
- **Integration Testing**: Verify relationships between dimensions and facts

### Test Categories
1. **Schema Tests**: Built-in dbt tests (unique, not_null, relationships, accepted_values)
2. **Data Tests**: Custom SQL-based tests for business rules
3. **Transformation Tests**: Validate data transformations and calculations
4. **Quality Tests**: Data quality and completeness validation
5. **Performance Tests**: Query performance and optimization validation

## Test Case List

### Dimension Table Tests

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| DIM_USER_001 | Validate user dimension unique keys | dim_user | All USER_DIM_ID values are unique |
| DIM_USER_002 | Validate user dimension not null constraints | dim_user | Critical fields are not null |
| DIM_USER_003 | Validate plan type standardization | dim_user | Plan types follow standard values |
| DIM_USER_004 | Validate SCD Type 2 implementation | dim_user | Historical records maintained correctly |
| DIM_USER_005 | Validate email domain extraction | dim_user | Email domains extracted correctly |
| DIM_USER_006 | Validate geographic region derivation | dim_user | Regions derived from email domains |
| DIM_USER_007 | Validate industry sector classification | dim_user | Industries classified from company names |
| DIM_DATE_001 | Validate date dimension completeness | dim_date | All dates from 2020-2030 present |
| DIM_DATE_002 | Validate fiscal year calculations | dim_date | Fiscal years calculated correctly |
| DIM_DATE_003 | Validate weekend flag accuracy | dim_date | Weekend flags set correctly |
| DIM_DATE_004 | Validate quarter calculations | dim_date | Quarters calculated correctly |
| DIM_FEATURE_001 | Validate feature categorization | dim_feature | Features categorized correctly |
| DIM_FEATURE_002 | Validate premium feature flags | dim_feature | Premium features identified correctly |
| DIM_FEATURE_003 | Validate feature complexity scoring | dim_feature | Complexity scores assigned correctly |
| DIM_LICENSE_001 | Validate license pricing logic | dim_license | Pricing assigned based on license type |
| DIM_LICENSE_002 | Validate license entitlements | dim_license | Entitlements match license tiers |
| DIM_LICENSE_003 | Validate SCD Type 2 for licenses | dim_license | License changes tracked historically |
| DIM_MEETING_001 | Validate meeting type categorization | dim_meeting_type | Meeting types categorized correctly |
| DIM_MEETING_002 | Validate time of day categories | dim_meeting_type | Time categories assigned correctly |
| DIM_SUPPORT_001 | Validate support category SLA targets | dim_support_category | SLA targets match priority levels |
| DIM_SUPPORT_002 | Validate escalation requirements | dim_support_category | Escalation flags set correctly |

### Fact Table Tests

| Test Case ID | Test Case Description | Model | Expected Outcome |
|--------------|----------------------|-------|------------------|
| FACT_MEETING_001 | Validate meeting activity metrics | fact_meeting_activity | All metrics calculated correctly |
| FACT_MEETING_002 | Validate foreign key relationships | fact_meeting_activity | All dimension keys exist |
| FACT_MEETING_003 | Validate duration calculations | fact_meeting_activity | Duration metrics are consistent |
| FACT_MEETING_004 | Validate participant metrics | fact_meeting_activity | Participant counts are logical |
| FACT_MEETING_005 | Validate quality scores | fact_meeting_activity | Quality scores within valid ranges |
| FACT_FEATURE_001 | Validate feature usage aggregations | fact_feature_usage | Usage metrics aggregated correctly |
| FACT_FEATURE_002 | Validate adoption score calculations | fact_feature_usage | Adoption scores calculated correctly |
| FACT_FEATURE_003 | Validate performance metrics | fact_feature_usage | Performance scores within ranges |
| FACT_REVENUE_001 | Validate revenue calculations | fact_revenue_events | Revenue amounts calculated correctly |
| FACT_REVENUE_002 | Validate MRR/ARR calculations | fact_revenue_events | Recurring revenue calculated correctly |
| FACT_REVENUE_003 | Validate currency conversions | fact_revenue_events | USD amounts converted correctly |
| FACT_REVENUE_004 | Validate customer lifetime value | fact_revenue_events | CLV calculated correctly |
| FACT_SUPPORT_001 | Validate support metrics | fact_support_metrics | Support KPIs calculated correctly |
| FACT_SUPPORT_002 | Validate SLA compliance | fact_support_metrics | SLA metrics calculated correctly |
| FACT_SUPPORT_003 | Validate resolution time calculations | fact_support_metrics | Resolution times calculated correctly |

### Integration Tests

| Test Case ID | Test Case Description | Models | Expected Outcome |
|--------------|----------------------|--------|------------------|
| INT_001 | Validate dimension-fact relationships | All models | All foreign keys have matching dimension records |
| INT_002 | Validate data consistency across models | All models | Consistent data across related tables |
| INT_003 | Validate referential integrity | All models | No orphaned records in fact tables |

## dbt Test Scripts

### Schema Tests (schema.yml)

```yaml
version: 2

models:
  # Dimension Tables
  - name: dim_user
    description: "User dimension with SCD Type 2 support"
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
      - name: email_domain
        description: "Email domain extracted from user email"
        tests:
          - not_null
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
      - name: user_status
        description: "User account status"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive']
      - name: geographic_region
        description: "Geographic region derived from email"
        tests:
          - accepted_values:
              values: ['North America', 'Europe', 'Unknown']
      - name: industry_sector
        description: "Industry sector classification"
        tests:
          - accepted_values:
              values: ['Technology', 'Financial Services', 'Unknown']
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

  - name: dim_date
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
          - accepted_values:
              values: [2020, 2021, 2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030]
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
          - accepted_values:
              values: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
      - name: day_of_week
        description: "Day of week (1-7)"
        tests:
          - not_null
          - accepted_values:
              values: [1, 2, 3, 4, 5, 6, 7]
      - name: is_weekend
        description: "Weekend flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
      - name: fiscal_year
        description: "Fiscal year starting April 1st"
        tests:
          - not_null
      - name: fiscal_quarter
        description: "Fiscal quarter"
        tests:
          - not_null
          - accepted_values:
              values: [1, 2, 3, 4]

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
        description: "Feature category classification"
        tests:
          - not_null
          - accepted_values:
              values: ['Collaboration', 'Recording', 'Communication', 'Advanced Meeting', 'Engagement', 'General']
      - name: feature_type
        description: "Feature type classification"
        tests:
          - accepted_values:
              values: ['Core', 'Advanced', 'Standard']
      - name: feature_complexity
        description: "Feature complexity level"
        tests:
          - accepted_values:
              values: ['High', 'Medium', 'Low']
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
        description: "Surrogate key for license dimension"
        tests:
          - unique
          - not_null
      - name: license_type
        description: "License type"
        tests:
          - not_null
      - name: license_category
        description: "License category"
        tests:
          - accepted_values:
              values: ['Standard', 'Professional', 'Enterprise', 'Other']
      - name: license_tier
        description: "License tier"
        tests:
          - accepted_values:
              values: ['Tier 0', 'Tier 1', 'Tier 2', 'Tier 3']
      - name: max_participants
        description: "Maximum participants allowed"
        tests:
          - not_null
      - name: monthly_price
        description: "Monthly price"
        tests:
          - not_null
      - name: annual_price
        description: "Annual price"
        tests:
          - not_null
      - name: effective_start_date
        description: "License effective start date"
        tests:
          - not_null
      - name: effective_end_date
        description: "License effective end date"
        tests:
          - not_null
      - name: is_current_record
        description: "Current record flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: dim_meeting_type
    description: "Meeting type dimension with characteristics"
    columns:
      - name: meeting_type_id
        description: "Surrogate key for meeting type dimension"
        tests:
          - unique
          - not_null
      - name: meeting_type
        description: "Meeting type"
        tests:
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

  - name: dim_support_category
    description: "Support category dimension with SLA targets"
    columns:
      - name: support_category_id
        description: "Surrogate key for support category dimension"
        tests:
          - unique
          - not_null
      - name: support_category
        description: "Support category"
        tests:
          - not_null
      - name: priority_level
        description: "Priority level"
        tests:
          - accepted_values:
              values: ['Critical', 'High', 'Medium', 'Low']
      - name: expected_resolution_time_hours
        description: "Expected resolution time in hours"
        tests:
          - not_null
      - name: requires_escalation
        description: "Escalation requirement flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
      - name: sla_target_hours
        description: "SLA target in hours"
        tests:
          - not_null

  # Fact Tables
  - name: fact_meeting_activity
    description: "Meeting activity fact table with comprehensive metrics"
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
              to: ref('dim_date')
              field: date_id
      - name: meeting_type_id
        description: "Foreign key to meeting type dimension"
        tests:
          - relationships:
              to: ref('dim_meeting_type')
              field: meeting_type_id
      - name: host_user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - relationships:
              to: ref('dim_user')
              field: user_dim_id
      - name: meeting_id
        description: "Business key for meeting"
        tests:
          - not_null
      - name: meeting_date
        description: "Meeting date"
        tests:
          - not_null
      - name: scheduled_duration_minutes
        description: "Scheduled duration in minutes"
        tests:
          - not_null
      - name: actual_duration_minutes
        description: "Actual duration in minutes"
        tests:
          - not_null
      - name: participant_count
        description: "Number of participants"
        tests:
          - not_null
      - name: meeting_quality_score
        description: "Meeting quality score"
        tests:
          - not_null

  - name: fact_feature_usage
    description: "Feature usage fact table with adoption metrics"
    columns:
      - name: feature_usage_id
        description: "Surrogate key for feature usage fact"
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
          - relationships:
              to: ref('dim_user')
              field: user_dim_id
      - name: usage_count
        description: "Usage count"
        tests:
          - not_null
      - name: usage_duration_minutes
        description: "Usage duration in minutes"
        tests:
          - not_null
      - name: feature_adoption_score
        description: "Feature adoption score"
        tests:
          - not_null

  - name: fact_revenue_events
    description: "Revenue events fact table with financial metrics"
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
              to: ref('dim_date')
              field: date_id
      - name: license_id
        description: "Foreign key to license dimension"
        tests:
          - relationships:
              to: ref('dim_license')
              field: license_id
      - name: user_dim_id
        description: "Foreign key to user dimension"
        tests:
          - relationships:
              to: ref('dim_user')
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
      - name: usd_amount
        description: "USD converted amount"
        tests:
          - not_null

  - name: fact_support_metrics
    description: "Support metrics fact table with SLA tracking"
    columns:
      - name: support_metrics_id
        description: "Surrogate key for support metrics fact"
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
          - relationships:
              to: ref('dim_user')
              field: user_dim_id
      - name: ticket_id
        description: "Business key for support ticket"
        tests:
          - not_null
      - name: resolution_time_hours
        description: "Resolution time in hours"
        tests:
          - not_null
      - name: sla_met
        description: "SLA compliance flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
```

### Custom SQL-Based Tests

#### Test: Validate Date Dimension Completeness
```sql
-- tests/test_dim_date_completeness.sql
SELECT 
    expected_days,
    actual_days,
    CASE 
        WHEN expected_days = actual_days THEN 'PASS'
        ELSE 'FAIL'
    END AS test_result
FROM (
    SELECT 
        DATEDIFF('day', '2020-01-01'::DATE, '2030-12-31'::DATE) + 1 AS expected_days,
        COUNT(*) AS actual_days
    FROM {{ ref('dim_date') }}
)
WHERE expected_days != actual_days
```

#### Test: Validate SCD Type 2 Implementation
```sql
-- tests/test_scd_type2_user.sql
SELECT 
    user_id,
    COUNT(*) as record_count,
    SUM(CASE WHEN is_current_record THEN 1 ELSE 0 END) as current_records
FROM {{ ref('dim_user') }}
GROUP BY user_id
HAVING current_records != 1 OR current_records > record_count
```

#### Test: Validate Plan Type Standardization
```sql
-- tests/test_plan_type_standardization.sql
SELECT 
    plan_type,
    COUNT(*) as record_count
FROM {{ ref('dim_user') }}
WHERE plan_type NOT IN ('Basic', 'Pro', 'Enterprise', 'Unknown')
GROUP BY plan_type
```

#### Test: Validate Email Domain Extraction
```sql
-- tests/test_email_domain_extraction.sql
SELECT 
    user_id,
    email_domain
FROM {{ ref('dim_user') }}
WHERE email_domain IS NULL 
   OR email_domain = ''
   OR email_domain NOT LIKE '%.%'
```

#### Test: Validate Fiscal Year Calculations
```sql
-- tests/test_fiscal_year_calculation.sql
SELECT 
    date_value,
    year,
    month,
    fiscal_year,
    CASE 
        WHEN month >= 4 THEN year
        ELSE year - 1
    END AS expected_fiscal_year
FROM {{ ref('dim_date') }}
WHERE fiscal_year != expected_fiscal_year
```

#### Test: Validate Weekend Flag Accuracy
```sql
-- tests/test_weekend_flag_accuracy.sql
SELECT 
    date_value,
    day_of_week,
    is_weekend,
    CASE 
        WHEN day_of_week IN (1, 7) THEN TRUE
        ELSE FALSE
    END AS expected_weekend_flag
FROM {{ ref('dim_date') }}
WHERE is_weekend != expected_weekend_flag
```

#### Test: Validate Feature Categorization Logic
```sql
-- tests/test_feature_categorization.sql
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
    END AS expected_category
FROM {{ ref('dim_feature') }}
WHERE feature_category != expected_category
```

#### Test: Validate Premium Feature Logic
```sql
-- tests/test_premium_feature_logic.sql
SELECT 
    feature_name,
    is_premium_feature,
    CASE 
        WHEN UPPER(feature_name) LIKE '%RECORD%' OR UPPER(feature_name) LIKE '%BREAKOUT%' THEN TRUE
        ELSE FALSE
    END AS expected_premium_flag
FROM {{ ref('dim_feature') }}
WHERE is_premium_feature != expected_premium_flag
```

#### Test: Validate License Pricing Logic
```sql
-- tests/test_license_pricing_logic.sql
SELECT 
    license_type,
    monthly_price,
    annual_price,
    CASE 
        WHEN UPPER(license_type) LIKE '%BASIC%' THEN 14.99
        WHEN UPPER(license_type) LIKE '%PRO%' THEN 19.99
        WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 39.99
        ELSE 0.00
    END AS expected_monthly_price
FROM {{ ref('dim_license') }}
WHERE monthly_price != expected_monthly_price
```

#### Test: Validate Meeting Duration Consistency
```sql
-- tests/test_meeting_duration_consistency.sql
SELECT 
    meeting_id,
    scheduled_duration_minutes,
    actual_duration_minutes
FROM {{ ref('fact_meeting_activity') }}
WHERE actual_duration_minutes < 0 
   OR scheduled_duration_minutes < 0
   OR actual_duration_minutes > (scheduled_duration_minutes * 3) -- Allow up to 3x scheduled duration
```

#### Test: Validate Participant Count Logic
```sql
-- tests/test_participant_count_logic.sql
SELECT 
    meeting_id,
    participant_count,
    unique_participants,
    peak_concurrent_participants
FROM {{ ref('fact_meeting_activity') }}
WHERE participant_count < unique_participants
   OR peak_concurrent_participants > participant_count
   OR participant_count <= 0
```

#### Test: Validate Quality Score Ranges
```sql
-- tests/test_quality_score_ranges.sql
SELECT 
    meeting_id,
    meeting_quality_score,
    audio_quality_score,
    video_quality_score
FROM {{ ref('fact_meeting_activity') }}
WHERE meeting_quality_score < 0 OR meeting_quality_score > 10
   OR audio_quality_score < 0 OR audio_quality_score > 10
   OR video_quality_score < 0 OR video_quality_score > 10
```

#### Test: Validate Revenue Amount Consistency
```sql
-- tests/test_revenue_amount_consistency.sql
SELECT 
    revenue_event_id,
    gross_amount,
    tax_amount,
    discount_amount,
    net_amount,
    (gross_amount - tax_amount - discount_amount) AS calculated_net_amount
FROM {{ ref('fact_revenue_events') }}
WHERE ABS(net_amount - calculated_net_amount) > 0.01 -- Allow for rounding differences
   OR gross_amount < 0
   OR net_amount < 0
```

#### Test: Validate Currency Conversion Logic
```sql
-- tests/test_currency_conversion_logic.sql
SELECT 
    revenue_event_id,
    gross_amount,
    currency_code,
    exchange_rate,
    usd_amount,
    (gross_amount * exchange_rate) AS calculated_usd_amount
FROM {{ ref('fact_revenue_events') }}
WHERE ABS(usd_amount - calculated_usd_amount) > 0.01
   OR exchange_rate <= 0
   OR usd_amount < 0
```

#### Test: Validate SLA Compliance Logic
```sql
-- tests/test_sla_compliance_logic.sql
SELECT 
    s.ticket_id,
    s.resolution_time_hours,
    s.sla_met,
    sc.sla_target_hours,
    CASE 
        WHEN s.resolution_time_hours <= sc.sla_target_hours THEN TRUE
        ELSE FALSE
    END AS expected_sla_met
FROM {{ ref('fact_support_metrics') }} s
JOIN {{ ref('dim_support_category') }} sc ON s.support_category_id = sc.support_category_id
WHERE s.sla_met != expected_sla_met
```

#### Test: Validate Foreign Key Relationships
```sql
-- tests/test_foreign_key_relationships.sql
-- Test for orphaned records in fact tables
SELECT 'fact_meeting_activity' AS table_name, COUNT(*) AS orphaned_records
FROM {{ ref('fact_meeting_activity') }} f
LEFT JOIN {{ ref('dim_date') }} d ON f.date_id = d.date_id
WHERE d.date_id IS NULL

UNION ALL

SELECT 'fact_feature_usage' AS table_name, COUNT(*) AS orphaned_records
FROM {{ ref('fact_feature_usage') }} f
LEFT JOIN {{ ref('dim_feature') }} d ON f.feature_id = d.feature_id
WHERE d.feature_id IS NULL

UNION ALL

SELECT 'fact_revenue_events' AS table_name, COUNT(*) AS orphaned_records
FROM {{ ref('fact_revenue_events') }} f
LEFT JOIN {{ ref('dim_license') }} d ON f.license_id = d.license_id
WHERE d.license_id IS NULL

UNION ALL

SELECT 'fact_support_metrics' AS table_name, COUNT(*) AS orphaned_records
FROM {{ ref('fact_support_metrics') }} f
LEFT JOIN {{ ref('dim_support_category') }} d ON f.support_category_id = d.support_category_id
WHERE d.support_category_id IS NULL
```

### Edge Case Tests

#### Test: Handle Null Values in Source Data
```sql
-- tests/test_null_value_handling.sql
SELECT 
    'dim_user' AS table_name,
    'user_name' AS column_name,
    COUNT(*) AS null_count
FROM {{ ref('dim_user') }}
WHERE user_name IS NULL OR user_name = ''

UNION ALL

SELECT 
    'dim_user' AS table_name,
    'email_domain' AS column_name,
    COUNT(*) AS null_count
FROM {{ ref('dim_user') }}
WHERE email_domain IS NULL OR email_domain = ''
```

#### Test: Validate Data Type Consistency
```sql
-- tests/test_data_type_consistency.sql
SELECT 
    'dim_date' AS table_name,
    COUNT(*) AS invalid_dates
FROM {{ ref('dim_date') }}
WHERE date_value IS NULL 
   OR date_value < '1900-01-01'::DATE 
   OR date_value > '2100-12-31'::DATE
```

#### Test: Validate Business Rule Violations
```sql
-- tests/test_business_rule_violations.sql
SELECT 
    'effective_date_range' AS rule_name,
    COUNT(*) AS violation_count
FROM {{ ref('dim_user') }}
WHERE effective_start_date > effective_end_date

UNION ALL

SELECT 
    'license_pricing_consistency' AS rule_name,
    COUNT(*) AS violation_count
FROM {{ ref('dim_license') }}
WHERE monthly_price * 10 > annual_price -- Annual should be less than 12 months
```

### Performance Tests

#### Test: Validate Clustering Key Effectiveness
```sql
-- tests/test_clustering_effectiveness.sql
-- This test checks if clustering keys are being used effectively
SELECT 
    table_name,
    clustering_key,
    average_depth,
    average_overlaps
FROM INFORMATION_SCHEMA.AUTOMATIC_CLUSTERING_HISTORY
WHERE table_name IN (
    'DIM_USER', 'DIM_DATE', 'DIM_FEATURE', 'DIM_LICENSE', 
    'DIM_MEETING_TYPE', 'DIM_SUPPORT_CATEGORY',
    'FACT_MEETING_ACTIVITY', 'FACT_FEATURE_USAGE', 
    'FACT_REVENUE_EVENTS', 'FACT_SUPPORT_METRICS'
)
AND average_depth > 5 -- Flag tables with poor clustering
```

#### Test: Validate Query Performance
```sql
-- tests/test_query_performance.sql
-- Sample performance test for common BI queries
SELECT 
    COUNT(*) as total_meetings,
    AVG(actual_duration_minutes) as avg_duration,
    SUM(participant_count) as total_participants
FROM {{ ref('fact_meeting_activity') }} f
JOIN {{ ref('dim_date') }} d ON f.date_id = d.date_id
WHERE d.date_value >= '2024-01-01'
  AND d.date_value < '2024-02-01'
```

## Test Execution Strategy

### 1. Continuous Integration Tests
- Run schema tests on every dbt run
- Execute custom SQL tests during CI/CD pipeline
- Validate data quality thresholds before deployment

### 2. Scheduled Data Quality Tests
- Daily validation of dimension data completeness
- Weekly validation of fact table metrics
- Monthly validation of historical data integrity

### 3. Performance Monitoring Tests
- Monitor clustering key effectiveness
- Track query performance trends
- Alert on performance degradation

### 4. Business Rule Validation
- Validate transformation logic accuracy
- Check business rule compliance
- Monitor data quality scores

## Test Results Tracking

### dbt Test Results
- Results stored in `dbt_test_results` table
- Integration with Snowflake audit schema
- Automated alerting on test failures

### Custom Test Results
- Results logged to `GO_DATA_VALIDATION_ERRORS` table
- Detailed error tracking and resolution
- Business impact assessment

### Performance Metrics
- Query execution times tracked
- Clustering effectiveness monitored
- Resource utilization measured

## Conclusion

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics Gold Layer dbt models in Snowflake. The combination of schema tests, custom SQL tests, edge case handling, and performance validation provides robust coverage for all aspects of the dimensional data model.

The test cases cover:
- **Data Quality**: Ensuring data accuracy and completeness
- **Business Rules**: Validating transformation logic and business requirements
- **Performance**: Monitoring query performance and optimization effectiveness
- **Integration**: Verifying relationships between dimensions and facts
- **Edge Cases**: Handling null values, boundary conditions, and error scenarios

Regular execution of these tests will maintain high data quality standards and ensure reliable analytics for business users.