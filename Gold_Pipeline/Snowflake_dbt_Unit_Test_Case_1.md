_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics Gold layer models
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Gold Layer Models

## Overview

This document provides comprehensive unit test cases and corresponding dbt test scripts for the Zoom Platform Analytics Gold layer models. The tests validate data transformations, business rules, edge cases, and error handling to ensure reliable and high-quality data pipelines in Snowflake.

## Test Coverage Strategy

The testing framework covers:
- **Data Integrity Tests**: Validate primary keys, foreign keys, and referential integrity
- **Business Rule Tests**: Ensure transformations follow business logic requirements
- **Data Quality Tests**: Check for null values, data types, and value ranges
- **Edge Case Tests**: Handle boundary conditions and exceptional scenarios
- **Performance Tests**: Validate clustering and optimization strategies
- **Audit Trail Tests**: Ensure proper logging and error tracking

## Test Case Categories

### 1. Dimension Table Tests

#### 1.1 GO_DIM_USER Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_USER_001 | Validate USER_KEY uniqueness | All USER_KEY values are unique | Data Integrity |
| DIM_USER_002 | Check USER_NAME standardization | All names follow INITCAP format | Business Rule |
| DIM_USER_003 | Validate EMAIL_DOMAIN extraction | Domain correctly extracted from email | Transformation |
| DIM_USER_004 | Test PLAN_TYPE categorization | Plan types mapped to standard values | Business Rule |
| DIM_USER_005 | Verify SCD Type 2 implementation | Historical records maintained correctly | Data Integrity |
| DIM_USER_006 | Check null value handling | No critical nulls in required fields | Data Quality |
| DIM_USER_007 | Validate GEOGRAPHIC_REGION derivation | Region correctly derived from email domain | Business Rule |
| DIM_USER_008 | Test EFFECTIVE_DATE logic | Start/end dates follow SCD rules | Data Integrity |
| DIM_USER_009 | Verify IS_CURRENT_RECORD flag | Only one current record per user | Data Integrity |
| DIM_USER_010 | Test edge case: Invalid email format | Handles malformed emails gracefully | Edge Case |

#### 1.2 GO_DIM_DATE Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_DATE_001 | Validate date range completeness | All dates from 2020-2030 present | Data Integrity |
| DIM_DATE_002 | Check fiscal year calculation | Fiscal year starts April 1st | Business Rule |
| DIM_DATE_003 | Verify weekend flag accuracy | Saturdays and Sundays marked as weekend | Business Rule |
| DIM_DATE_004 | Test leap year handling | February 29th included in leap years | Edge Case |
| DIM_DATE_005 | Validate quarter calculations | Quarters correctly assigned | Business Rule |
| DIM_DATE_006 | Check week of year calculation | Week numbers follow ISO standard | Business Rule |
| DIM_DATE_007 | Verify day name consistency | Day names match date values | Data Integrity |
| DIM_DATE_008 | Test fiscal quarter logic | Fiscal quarters align with fiscal year | Business Rule |
| DIM_DATE_009 | Validate DATE_KEY uniqueness | All DATE_KEY values are unique | Data Integrity |
| DIM_DATE_010 | Check holiday flag implementation | Holiday logic properly implemented | Business Rule |

#### 1.3 GO_DIM_FEATURE Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_FEAT_001 | Validate FEATURE_KEY uniqueness | All FEATURE_KEY values are unique | Data Integrity |
| DIM_FEAT_002 | Check feature categorization | Features correctly categorized | Business Rule |
| DIM_FEAT_003 | Verify premium feature flagging | Premium features correctly identified | Business Rule |
| DIM_FEAT_004 | Test feature complexity assignment | Complexity levels properly assigned | Business Rule |
| DIM_FEAT_005 | Validate feature name standardization | Names follow INITCAP format | Transformation |
| DIM_FEAT_006 | Check feature status consistency | All features have valid status | Data Quality |
| DIM_FEAT_007 | Test target user segment assignment | Segments properly assigned | Business Rule |
| DIM_FEAT_008 | Verify feature description generation | Descriptions generated correctly | Transformation |
| DIM_FEAT_009 | Test edge case: Unknown feature type | Handles unknown features gracefully | Edge Case |
| DIM_FEAT_010 | Validate source system tracking | Source systems properly recorded | Data Integrity |

#### 1.4 GO_DIM_LICENSE Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_LIC_001 | Validate LICENSE_KEY uniqueness | All LICENSE_KEY values are unique | Data Integrity |
| DIM_LIC_002 | Check license tier assignment | Tiers correctly assigned by type | Business Rule |
| DIM_LIC_003 | Verify pricing calculations | Monthly/annual prices are accurate | Business Rule |
| DIM_LIC_004 | Test participant limits | Max participants set correctly | Business Rule |
| DIM_LIC_005 | Validate storage limits | Storage limits assigned properly | Business Rule |
| DIM_LIC_006 | Check feature entitlements | Admin/API/SSO flags set correctly | Business Rule |
| DIM_LIC_007 | Verify effective date ranges | Date ranges are logical | Data Integrity |
| DIM_LIC_008 | Test SCD Type 2 for licenses | Historical license changes tracked | Data Integrity |
| DIM_LIC_009 | Validate license benefits text | Benefits descriptions generated | Transformation |
| DIM_LIC_010 | Test edge case: Invalid license type | Handles unknown license types | Edge Case |

#### 1.5 GO_DIM_MEETING_TYPE Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_MEET_001 | Validate MEETING_TYPE_KEY uniqueness | All keys are unique | Data Integrity |
| DIM_MEET_002 | Check duration categorization | Duration categories assigned correctly | Business Rule |
| DIM_MEET_003 | Verify time of day classification | Time categories properly assigned | Business Rule |
| DIM_MEET_004 | Test weekend meeting flagging | Weekend meetings identified correctly | Business Rule |
| DIM_MEET_005 | Validate quality score thresholds | Quality thresholds set appropriately | Business Rule |
| DIM_MEET_006 | Check business purpose assignment | Business purposes assigned correctly | Business Rule |
| DIM_MEET_007 | Verify participant size categories | Size categories properly assigned | Business Rule |
| DIM_MEET_008 | Test recurring meeting logic | Recurring flags set correctly | Business Rule |
| DIM_MEET_009 | Validate typical features used | Feature lists generated properly | Transformation |
| DIM_MEET_010 | Test edge case: Zero duration meeting | Handles invalid durations gracefully | Edge Case |

#### 1.6 GO_DIM_SUPPORT_CATEGORY Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| DIM_SUPP_001 | Validate SUPPORT_CATEGORY_KEY uniqueness | All keys are unique | Data Integrity |
| DIM_SUPP_002 | Check priority level assignment | Priority levels assigned correctly | Business Rule |
| DIM_SUPP_003 | Verify SLA target calculations | SLA targets set appropriately | Business Rule |
| DIM_SUPP_004 | Test escalation requirements | Escalation flags set correctly | Business Rule |
| DIM_SUPP_005 | Validate self-service availability | Self-service flags assigned properly | Business Rule |
| DIM_SUPP_006 | Check knowledge base article counts | Article counts assigned correctly | Business Rule |
| DIM_SUPP_007 | Verify customer impact levels | Impact levels assigned properly | Business Rule |
| DIM_SUPP_008 | Test department responsibility | Departments assigned correctly | Business Rule |
| DIM_SUPP_009 | Validate resolution steps generation | Resolution steps generated properly | Transformation |
| DIM_SUPP_010 | Test edge case: Unknown ticket type | Handles unknown types gracefully | Edge Case |

### 2. Fact Table Tests

#### 2.1 GO_FACT_MEETING_ACTIVITY Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| FACT_MEET_001 | Validate foreign key relationships | All FKs reference valid dimension records | Data Integrity |
| FACT_MEET_002 | Check meeting duration calculations | Duration calculated correctly | Business Rule |
| FACT_MEET_003 | Verify participant count accuracy | Participant counts match source data | Data Quality |
| FACT_MEET_004 | Test meeting quality score calculation | Quality scores calculated correctly | Business Rule |
| FACT_MEET_005 | Validate feature usage aggregation | Feature counts aggregated properly | Business Rule |
| FACT_MEET_006 | Check audio/video quality metrics | Quality metrics calculated correctly | Business Rule |
| FACT_MEET_007 | Verify engagement metrics | Engagement scores calculated properly | Business Rule |
| FACT_MEET_008 | Test late joiner/early leaver logic | Counts calculated correctly | Business Rule |
| FACT_MEET_009 | Validate peak concurrent participants | Peak counts calculated accurately | Business Rule |
| FACT_MEET_010 | Test edge case: Meeting with no participants | Handles zero participants gracefully | Edge Case |
| FACT_MEET_011 | Check clustering key performance | Queries use clustering effectively | Performance |
| FACT_MEET_012 | Verify incremental loading | Only new/changed records processed | Performance |
| FACT_MEET_013 | Test data quality scoring | Quality scores within valid ranges | Data Quality |
| FACT_MEET_014 | Validate audit trail creation | Audit records created for all loads | Audit Trail |
| FACT_MEET_015 | Test error handling for invalid data | Invalid records logged to error table | Error Handling |

#### 2.2 GO_FACT_FEATURE_USAGE Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| FACT_FEAT_001 | Validate foreign key relationships | All FKs reference valid dimensions | Data Integrity |
| FACT_FEAT_002 | Check usage count accuracy | Usage counts match source data | Data Quality |
| FACT_FEAT_003 | Verify adoption score calculation | Adoption scores calculated correctly | Business Rule |
| FACT_FEAT_004 | Test performance score logic | Performance scores calculated properly | Business Rule |
| FACT_FEAT_005 | Validate user experience ratings | UX ratings calculated correctly | Business Rule |
| FACT_FEAT_006 | Check usage context categorization | Context categories assigned properly | Business Rule |
| FACT_FEAT_007 | Verify success rate calculations | Success rates calculated accurately | Business Rule |
| FACT_FEAT_008 | Test concurrent feature usage | Concurrent usage tracked correctly | Business Rule |
| FACT_FEAT_009 | Validate session duration tracking | Session durations calculated properly | Business Rule |
| FACT_FEAT_010 | Test edge case: Feature with zero usage | Handles zero usage gracefully | Edge Case |
| FACT_FEAT_011 | Check error count tracking | Error counts tracked accurately | Data Quality |
| FACT_FEAT_012 | Verify device type categorization | Device types categorized correctly | Business Rule |
| FACT_FEAT_013 | Test platform version tracking | Platform versions tracked properly | Data Quality |
| FACT_FEAT_014 | Validate clustering performance | Clustering keys optimize queries | Performance |
| FACT_FEAT_015 | Test incremental processing | Only changed records processed | Performance |

#### 2.3 GO_FACT_REVENUE_EVENTS Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| FACT_REV_001 | Validate foreign key relationships | All FKs reference valid dimensions | Data Integrity |
| FACT_REV_002 | Check revenue amount calculations | Revenue amounts calculated correctly | Business Rule |
| FACT_REV_003 | Verify MRR/ARR impact calculations | MRR/ARR calculated accurately | Business Rule |
| FACT_REV_004 | Test currency conversion logic | Currency conversions applied correctly | Business Rule |
| FACT_REV_005 | Validate customer lifetime value | CLV calculated properly | Business Rule |
| FACT_REV_006 | Check churn risk scoring | Churn scores calculated correctly | Business Rule |
| FACT_REV_007 | Verify payment status assignment | Payment statuses assigned properly | Business Rule |
| FACT_REV_008 | Test refund handling | Refunds processed correctly | Business Rule |
| FACT_REV_009 | Validate commission calculations | Commissions calculated accurately | Business Rule |
| FACT_REV_010 | Test edge case: Negative revenue | Handles refunds and chargebacks | Edge Case |
| FACT_REV_011 | Check proration logic | Prorations calculated correctly | Business Rule |
| FACT_REV_012 | Verify subscription period tracking | Periods tracked accurately | Data Quality |
| FACT_REV_013 | Test sales channel attribution | Channels attributed correctly | Business Rule |
| FACT_REV_014 | Validate promotion code tracking | Promotion codes tracked properly | Data Quality |
| FACT_REV_015 | Test clustering optimization | Revenue queries optimized | Performance |

#### 2.4 GO_FACT_SUPPORT_METRICS Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| FACT_SUPP_001 | Validate foreign key relationships | All FKs reference valid dimensions | Data Integrity |
| FACT_SUPP_002 | Check resolution time calculations | Resolution times calculated correctly | Business Rule |
| FACT_SUPP_003 | Verify SLA compliance tracking | SLA compliance tracked accurately | Business Rule |
| FACT_SUPP_004 | Test first contact resolution logic | FCR flags set correctly | Business Rule |
| FACT_SUPP_005 | Validate escalation count tracking | Escalation counts tracked properly | Business Rule |
| FACT_SUPP_006 | Check customer satisfaction scoring | Satisfaction scores calculated correctly | Business Rule |
| FACT_SUPP_007 | Verify agent interaction tracking | Interaction counts tracked accurately | Data Quality |
| FACT_SUPP_008 | Test knowledge base usage | KB usage tracked properly | Business Rule |
| FACT_SUPP_009 | Validate cost to resolve calculations | Resolution costs calculated correctly | Business Rule |
| FACT_SUPP_010 | Test edge case: Ticket never closed | Handles open tickets gracefully | Edge Case |
| FACT_SUPP_011 | Check SLA breach calculations | Breach hours calculated accurately | Business Rule |
| FACT_SUPP_012 | Verify preventable issue flagging | Preventable flags set correctly | Business Rule |
| FACT_SUPP_013 | Test follow-up requirement logic | Follow-up flags assigned properly | Business Rule |
| FACT_SUPP_014 | Validate root cause categorization | Root causes categorized correctly | Business Rule |
| FACT_SUPP_015 | Test clustering performance | Support queries optimized | Performance |

### 3. Audit and Error Handling Tests

#### 3.1 GO_PROCESS_AUDIT Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| AUDIT_001 | Validate audit log creation | Audit records created for all processes | Audit Trail |
| AUDIT_002 | Check execution time tracking | Start/end times recorded accurately | Audit Trail |
| AUDIT_003 | Verify record count tracking | Record counts tracked correctly | Audit Trail |
| AUDIT_004 | Test error count logging | Error counts logged accurately | Audit Trail |
| AUDIT_005 | Validate process status tracking | Process statuses updated correctly | Audit Trail |
| AUDIT_006 | Check data quality score logging | Quality scores logged properly | Audit Trail |
| AUDIT_007 | Verify configuration parameter storage | Parameters stored correctly | Audit Trail |
| AUDIT_008 | Test performance metrics tracking | Performance metrics captured | Audit Trail |
| AUDIT_009 | Validate process trigger logging | Triggers logged accurately | Audit Trail |
| AUDIT_010 | Test audit log retention | Old audit logs archived properly | Data Management |

#### 3.2 GO_DATA_VALIDATION_ERRORS Tests

| Test Case ID | Test Case Description | Expected Outcome | Test Type |
|--------------|----------------------|------------------|----------|
| ERROR_001 | Validate error record creation | Error records created for failures | Error Handling |
| ERROR_002 | Check error categorization | Errors categorized correctly | Error Handling |
| ERROR_003 | Verify error severity assignment | Severity levels assigned properly | Error Handling |
| ERROR_004 | Test error message generation | Error messages are descriptive | Error Handling |
| ERROR_005 | Validate resolution tracking | Resolution status tracked correctly | Error Handling |
| ERROR_006 | Check retry count tracking | Retry counts tracked accurately | Error Handling |
| ERROR_007 | Verify false positive flagging | False positives flagged correctly | Error Handling |
| ERROR_008 | Test business impact assessment | Business impact assessed properly | Error Handling |
| ERROR_009 | Validate resolution action logging | Resolution actions logged correctly | Error Handling |
| ERROR_010 | Test error notification triggers | Notifications triggered appropriately | Error Handling |

## dbt Test Scripts

### 1. Schema Tests (schema.yml)

```yaml
version: 2

models:
  - name: go_dim_user
    description: "User dimension with SCD Type 2 implementation"
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - user_key
            - effective_start_date
    columns:
      - name: user_dim_id
        description: "Surrogate key for user dimension"
        tests:
          - unique
          - not_null
      - name: user_key
        description: "Business key for user"
        tests:
          - not_null
      - name: user_name
        description: "Standardized user name"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: "^[A-Z][a-z]+(\\s[A-Z][a-z]+)*$"
      - name: email_domain
        description: "Email domain extracted from user email"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: "^[A-Z0-9.-]+\\.[A-Z]{2,}$"
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
        description: "Current user status"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive']
      - name: effective_start_date
        description: "SCD effective start date"
        tests:
          - not_null
      - name: effective_end_date
        description: "SCD effective end date"
        tests:
          - not_null
      - name: is_current_record
        description: "SCD current record flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]

  - name: go_dim_date
    description: "Standard date dimension"
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) = 4018"  # 11 years of dates
    columns:
      - name: date_id
        description: "Surrogate key for date dimension"
        tests:
          - unique
          - not_null
      - name: date_key
        description: "Date value as business key"
        tests:
          - unique
          - not_null
      - name: year
        description: "Calendar year"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 2020
              max_value: 2030
      - name: quarter
        description: "Calendar quarter"
        tests:
          - not_null
          - accepted_values:
              values: [1, 2, 3, 4]
      - name: month
        description: "Calendar month"
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
      - name: fiscal_year
        description: "Fiscal year starting April 1st"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 2019
              max_value: 2030

  - name: go_dim_feature
    description: "Feature dimension with categorization"
    columns:
      - name: feature_id
        description: "Surrogate key for feature dimension"
        tests:
          - unique
          - not_null
      - name: feature_key
        description: "Business key for feature"
        tests:
          - unique
          - not_null
      - name: feature_name
        description: "Standardized feature name"
        tests:
          - not_null
      - name: feature_category
        description: "Feature category"
        tests:
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

  - name: go_dim_license
    description: "License dimension with pricing and entitlements"
    columns:
      - name: license_id
        description: "Surrogate key for license dimension"
        tests:
          - unique
          - not_null
      - name: license_key
        description: "Business key for license"
        tests:
          - unique
          - not_null
      - name: license_type
        description: "Standardized license type"
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
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: monthly_price
        description: "Monthly subscription price"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000
      - name: annual_price
        description: "Annual subscription price"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000

  - name: go_fact_meeting_activity
    description: "Meeting activity fact table"
    tests:
      - dbt_utils.expression_is_true:
          expression: "duration_minutes >= 0"
      - dbt_utils.expression_is_true:
          expression: "participant_count >= 0"
    columns:
      - name: meeting_activity_id
        description: "Surrogate key for meeting activity"
        tests:
          - unique
          - not_null
      - name: date_key
        description: "Foreign key to date dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_date')
              field: date_key
      - name: user_key
        description: "Foreign key to user dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_user')
              field: user_key
      - name: meeting_type_key
        description: "Foreign key to meeting type dimension"
        tests:
          - relationships:
              to: ref('go_dim_meeting_type')
              field: meeting_type_key
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours
      - name: participant_count
        description: "Number of meeting participants"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: meeting_quality_score
        description: "Meeting quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0
      - name: audio_quality_score
        description: "Audio quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0

  - name: go_fact_feature_usage
    description: "Feature usage fact table"
    columns:
      - name: feature_usage_id
        description: "Surrogate key for feature usage"
        tests:
          - unique
          - not_null
      - name: date_key
        description: "Foreign key to date dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_date')
              field: date_key
      - name: feature_key
        description: "Foreign key to feature dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_feature')
              field: feature_key
      - name: user_key
        description: "Foreign key to user dimension"
        tests:
          - relationships:
              to: ref('go_dim_user')
              field: user_key
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: feature_adoption_score
        description: "Feature adoption score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0
      - name: success_rate
        description: "Feature usage success rate"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.0
              max_value: 100.0

  - name: go_fact_revenue_events
    description: "Revenue events fact table"
    columns:
      - name: revenue_event_id
        description: "Surrogate key for revenue event"
        tests:
          - unique
          - not_null
      - name: date_key
        description: "Foreign key to date dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_date')
              field: date_key
      - name: license_key
        description: "Foreign key to license dimension"
        tests:
          - relationships:
              to: ref('go_dim_license')
              field: license_key
      - name: user_key
        description: "Foreign key to user dimension"
        tests:
          - relationships:
              to: ref('go_dim_user')
              field: user_key
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
              values: ['USD', 'EUR', 'GBP', 'CAD', 'AUD']
      - name: mrr_impact
        description: "Monthly recurring revenue impact"
        tests:
          - not_null
      - name: arr_impact
        description: "Annual recurring revenue impact"
        tests:
          - not_null
      - name: churn_risk_score
        description: "Customer churn risk score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0

  - name: go_fact_support_metrics
    description: "Support metrics fact table"
    columns:
      - name: support_metrics_id
        description: "Surrogate key for support metrics"
        tests:
          - unique
          - not_null
      - name: date_key
        description: "Foreign key to date dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_date')
              field: date_key
      - name: support_category_key
        description: "Foreign key to support category dimension"
        tests:
          - not_null
          - relationships:
              to: ref('go_dim_support_category')
              field: support_category_key
      - name: user_key
        description: "Foreign key to user dimension"
        tests:
          - relationships:
              to: ref('go_dim_user')
              field: user_key
      - name: resolution_time_hours
        description: "Time to resolve ticket in hours"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 8760  # 1 year in hours
      - name: first_contact_resolution
        description: "First contact resolution flag"
        tests:
          - accepted_values:
              values: [true, false]
      - name: sla_met
        description: "SLA compliance flag"
        tests:
          - not_null
          - accepted_values:
              values: [true, false]
      - name: customer_satisfaction_score
        description: "Customer satisfaction score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 1.0
              max_value: 5.0
```

### 2. Custom SQL Tests

#### 2.1 Data Quality Tests

```sql
-- tests/assert_user_scd_integrity.sql
-- Test that each user has only one current record
select user_key
from {{ ref('go_dim_user') }}
where is_current_record = true
group by user_key
having count(*) > 1
```

```sql
-- tests/assert_date_continuity.sql
-- Test that date dimension has no gaps
with date_gaps as (
  select 
    date_key,
    lag(date_key) over (order by date_key) as prev_date,
    datediff('day', lag(date_key) over (order by date_key), date_key) as gap_days
  from {{ ref('go_dim_date') }}
)
select *
from date_gaps
where gap_days > 1
```

```sql
-- tests/assert_meeting_duration_logic.sql
-- Test that meeting duration is consistent with start/end times
select *
from {{ ref('go_fact_meeting_activity') }}
where abs(duration_minutes - datediff('minute', start_time, end_time)) > 1
```

```sql
-- tests/assert_revenue_consistency.sql
-- Test that net amount equals gross minus tax and discount
select *
from {{ ref('go_fact_revenue_events') }}
where abs(net_amount - (gross_amount - tax_amount - discount_amount)) > 0.01
```

```sql
-- tests/assert_feature_adoption_logic.sql
-- Test that feature adoption scores align with usage counts
select *
from {{ ref('go_fact_feature_usage') }}
where (
  (usage_count >= 10 and feature_adoption_score != 5.0) or
  (usage_count >= 5 and usage_count < 10 and feature_adoption_score != 4.0) or
  (usage_count >= 3 and usage_count < 5 and feature_adoption_score != 3.0) or
  (usage_count >= 1 and usage_count < 3 and feature_adoption_score != 2.0) or
  (usage_count = 0 and feature_adoption_score != 1.0)
)
```

#### 2.2 Business Rule Tests

```sql
-- tests/assert_plan_type_consistency.sql
-- Test that plan category aligns with plan type
select *
from {{ ref('go_dim_user') }}
where (
  (plan_type = 'Basic' and plan_category != 'Free') or
  (plan_type in ('Pro', 'Enterprise') and plan_category != 'Paid')
)
```

```sql
-- tests/assert_license_pricing_logic.sql
-- Test that annual price is approximately 10x monthly price
select *
from {{ ref('go_dim_license') }}
where monthly_price > 0 
  and abs(annual_price - (monthly_price * 10)) > (monthly_price * 0.5)
```

```sql
-- tests/assert_sla_compliance_logic.sql
-- Test that SLA compliance aligns with resolution times
select sm.*, sc.sla_target_hours
from {{ ref('go_fact_support_metrics') }} sm
join {{ ref('go_dim_support_category') }} sc 
  on sm.support_category_key = sc.support_category_key
where (
  (sm.resolution_time_hours <= sc.sla_target_hours and sm.sla_met = false) or
  (sm.resolution_time_hours > sc.sla_target_hours and sm.sla_met = true)
)
```

```sql
-- tests/assert_fiscal_year_logic.sql
-- Test that fiscal year calculation is correct
select *
from {{ ref('go_dim_date') }}
where (
  (month >= 4 and fiscal_year != year) or
  (month < 4 and fiscal_year != year - 1)
)
```

#### 2.3 Performance Tests

```sql
-- tests/assert_clustering_effectiveness.sql
-- Test that clustering keys are being used effectively
select 
  'go_fact_meeting_activity' as table_name,
  count(*) as total_rows,
  count(distinct date_key) as distinct_date_keys,
  count(distinct user_key) as distinct_user_keys
from {{ ref('go_fact_meeting_activity') }}
having count(*) / count(distinct date_key) < 10  -- Flag if clustering may not be effective
```

```sql
-- tests/assert_incremental_loading.sql
-- Test that incremental loading is working correctly
select 
  load_date,
  count(*) as records_loaded
from {{ ref('go_fact_meeting_activity') }}
where load_date >= current_date - 7
group by load_date
having count(*) = 0  -- Flag if no records loaded recently
```

### 3. Parameterized Tests

#### 3.1 Generic Test Macros

```sql
-- macros/test_foreign_key_coverage.sql
{% macro test_foreign_key_coverage(model, column_name, parent_model, parent_column) %}
  select count(*) as missing_fk_count
  from {{ model }} child
  left join {{ parent_model }} parent
    on child.{{ column_name }} = parent.{{ parent_column }}
  where child.{{ column_name }} is not null
    and parent.{{ parent_column }} is null
  having count(*) > 0
{% endmacro %}
```

```sql
-- macros/test_data_freshness.sql
{% macro test_data_freshness(model, date_column, max_days_old=7) %}
  select 
    max({{ date_column }}) as latest_date,
    current_date as today,
    datediff('day', max({{ date_column }}), current_date) as days_old
  from {{ model }}
  having datediff('day', max({{ date_column }}), current_date) > {{ max_days_old }}
{% endmacro %}
```

```sql
-- macros/test_dimension_completeness.sql
{% macro test_dimension_completeness(fact_model, dim_model, fk_column, dim_key_column) %}
  select 
    '{{ fact_model }}' as fact_table,
    '{{ dim_model }}' as dimension_table,
    count(distinct f.{{ fk_column }}) as fact_keys,
    count(distinct d.{{ dim_key_column }}) as dim_keys,
    count(distinct f.{{ fk_column }}) - count(distinct d.{{ dim_key_column }}) as missing_keys
  from {{ fact_model }} f
  full outer join {{ dim_model }} d
    on f.{{ fk_column }} = d.{{ dim_key_column }}
  having count(distinct f.{{ fk_column }}) != count(distinct d.{{ dim_key_column }})
{% endmacro %}
```

### 4. Test Execution Strategy

#### 4.1 Test Categories and Execution Order

1. **Pre-hook Tests**: Run before model execution
   - Source data availability
   - Source data quality checks
   - Dependency validation

2. **Model Tests**: Run after model execution
   - Schema tests (uniqueness, not_null, relationships)
   - Custom SQL tests (business rules, data quality)
   - Performance tests

3. **Post-hook Tests**: Run after all models complete
   - Cross-model consistency
   - Audit trail validation
   - End-to-end data flow tests

#### 4.2 Test Configuration

```yaml
# dbt_project.yml
name: 'zoom_gold_layer'
version: '1.0.0'
config-version: 2

model-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
seed-paths: ["data"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

models:
  zoom_gold_layer:
    +materialized: table
    +pre-hook: "{{ log_process_start() }}"
    +post-hook: "{{ log_process_end() }}"
    gold:
      dimension:
        +materialized: table
        +cluster_by: ["load_date"]
      fact:
        +materialized: table
        +cluster_by: ["date_key"]

tests:
  +store_failures: true
  +severity: error

vars:
  # Test configuration variables
  test_data_freshness_days: 7
  test_performance_threshold: 1000
  test_quality_score_min: 80
```

#### 4.3 Continuous Integration Tests

```yaml
# .github/workflows/dbt_tests.yml
name: dbt Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
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

## Test Execution and Monitoring

### 1. Test Execution Commands

```bash
# Run all tests
dbt test

# Run tests for specific models
dbt test --models go_dim_user
dbt test --models go_fact_meeting_activity

# Run specific test types
dbt test --select test_type:generic
dbt test --select test_type:singular

# Run tests with specific tags
dbt test --select tag:data_quality
dbt test --select tag:business_rules

# Run tests in fail-fast mode
dbt test --fail-fast

# Store test failures for analysis
dbt test --store-failures
```

### 2. Test Results Monitoring

```sql
-- Query to monitor test results
select 
  test_name,
  model_name,
  test_type,
  status,
  execution_time,
  failures,
  run_started_at
from (
  select 
    invocation_id,
    unique_id,
    name as test_name,
    split_part(unique_id, '.', 3) as model_name,
    case 
      when unique_id like '%test_type:generic%' then 'Generic'
      when unique_id like '%test_type:singular%' then 'Singular'
      else 'Custom'
    end as test_type,
    status,
    execution_time,
    failures,
    run_started_at
  from {{ ref('dbt_test_results') }}
)
where run_started_at >= current_date - 7
order by run_started_at desc, test_name
```

### 3. Test Performance Optimization

```sql
-- Identify slow-running tests
select 
  test_name,
  model_name,
  avg(execution_time) as avg_execution_time,
  max(execution_time) as max_execution_time,
  count(*) as execution_count
from test_results_history
where run_started_at >= current_date - 30
group by test_name, model_name
having avg(execution_time) > 60  -- Tests taking more than 60 seconds
order by avg_execution_time desc
```

## Conclusion

This comprehensive unit testing framework ensures:

1. **Data Quality**: Validates data integrity, completeness, and accuracy
2. **Business Rules**: Ensures transformations follow business logic
3. **Performance**: Monitors query performance and optimization
4. **Reliability**: Provides early detection of data issues
5. **Maintainability**: Supports continuous integration and deployment
6. **Compliance**: Ensures audit trails and error tracking

The test cases cover all critical aspects of the Gold layer models including:
- Dimension table integrity and SCD implementation
- Fact table relationships and calculations
- Business rule enforcement
- Edge case handling
- Performance optimization validation
- Audit and error tracking

All tests are designed to run efficiently in Snowflake and integrate seamlessly with dbt's testing framework, providing comprehensive coverage for the Zoom Platform Analytics Gold layer data pipeline.