_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive Snowflake dbt Unit Test Cases for Zoom Platform Analytics Silver Layer Pipeline
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Silver Layer Pipeline
## Zoom Platform Analytics System

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Platform Analytics Silver Layer dbt models running in Snowflake. The test cases cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality, consistency, and reliability across all Silver layer models.

## Test Coverage Overview

The test suite covers the following Silver layer models:
1. **si_users** - User data cleansing and standardization
2. **si_meetings** - Meeting data enrichment and validation
3. **si_participants** - Participant attendance data processing
4. **si_feature_usage** - Feature usage categorization and metrics
5. **si_support_tickets** - Support ticket standardization and SLA tracking
6. **si_billing_events** - Financial transaction validation
7. **si_licenses** - License management and utilization tracking
8. **si_webinars** - Webinar data processing (referenced in context)
9. **audit_log** - Pipeline execution audit trail

---

## Test Case List

### **Test Case 1: SI_USERS Model - Data Quality and Transformation Tests**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SU_001 | Validate USER_ID uniqueness and not null constraint | All USER_ID values are unique and not null |
| TC_SU_002 | Validate email format standardization (lowercase, valid format) | All emails are lowercase and match valid email regex pattern |
| TC_SU_003 | Validate PLAN_TYPE enumeration (Free, Basic, Pro, Enterprise) | All PLAN_TYPE values are from predefined list |
| TC_SU_004 | Validate USER_NAME proper case formatting | All USER_NAME values are properly capitalized |
| TC_SU_005 | Validate ACCOUNT_STATUS derivation logic | ACCOUNT_STATUS correctly derived based on last activity |
| TC_SU_006 | Validate DATA_QUALITY_SCORE calculation (0.00-1.00 range) | All quality scores are between 0.00 and 1.00 |
| TC_SU_007 | Test deduplication logic (latest record per USER_ID) | Only one record per USER_ID with latest UPDATE_TIMESTAMP |
| TC_SU_008 | Validate minimum quality threshold filtering (>= 0.50) | Only records with quality score >= 0.50 are included |
| TC_SU_009 | Test handling of null/empty USER_NAME values | NULL USER_NAME replaced with 'Unknown User' |
| TC_SU_010 | Test handling of invalid email formats | Invalid emails set to NULL after validation |

### **Test Case 2: SI_MEETINGS Model - Business Logic and Enrichment Tests**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SM_001 | Validate MEETING_ID uniqueness and not null constraint | All MEETING_ID values are unique and not null |
| TC_SM_002 | Validate HOST_ID foreign key relationship with SI_USERS | All HOST_ID values exist in SI_USERS.USER_ID |
| TC_SM_003 | Validate duration recalculation logic | DURATION_MINUTES matches DATEDIFF between START_TIME and END_TIME |
| TC_SM_004 | Validate MEETING_TYPE derivation logic | MEETING_TYPE correctly derived from meeting characteristics |
| TC_SM_005 | Validate MEETING_STATUS derivation based on timestamps | Status correctly reflects current meeting state |
| TC_SM_006 | Validate PARTICIPANT_COUNT calculation from participants table | Count matches actual participants in BZ_PARTICIPANTS |
| TC_SM_007 | Test handling of invalid END_TIME (before START_TIME) | END_TIME defaults to START_TIME when invalid |
| TC_SM_008 | Validate HOST_NAME enrichment from users table | HOST_NAME correctly joined from BZ_USERS |
| TC_SM_009 | Test minimum quality threshold filtering (>= 0.60) | Only records with quality score >= 0.60 are included |
| TC_SM_010 | Validate RECORDING_STATUS derivation logic | Recording status derived based on meeting duration |

### **Test Case 3: SI_PARTICIPANTS Model - Attendance Calculation Tests**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SP_001 | Validate PARTICIPANT_ID uniqueness and not null constraint | All PARTICIPANT_ID values are unique and not null |
| TC_SP_002 | Validate MEETING_ID foreign key relationship | All MEETING_ID values exist in SI_MEETINGS |
| TC_SP_003 | Validate USER_ID foreign key relationship | All USER_ID values exist in SI_USERS |
| TC_SP_004 | Validate ATTENDANCE_DURATION calculation | Duration correctly calculated from JOIN_TIME to LEAVE_TIME |
| TC_SP_005 | Validate PARTICIPANT_ROLE derivation logic | Role correctly assigned based on host status and duration |
| TC_SP_006 | Validate CONNECTION_QUALITY derivation | Quality rating based on attendance duration |
| TC_SP_007 | Test handling of null LEAVE_TIME | Default 2-hour session applied when LEAVE_TIME is null |
| TC_SP_008 | Test handling of invalid LEAVE_TIME (before JOIN_TIME) | LEAVE_TIME defaults to JOIN_TIME when invalid |
| TC_SP_009 | Validate minimum quality threshold filtering (>= 0.75) | Only records with quality score >= 0.75 are included |
| TC_SP_010 | Test deduplication logic for participants | Latest record per PARTICIPANT_ID retained |

### **Test Case 4: SI_FEATURE_USAGE Model - Categorization and Metrics Tests**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SF_001 | Validate USAGE_ID uniqueness and not null constraint | All USAGE_ID values are unique and not null |
| TC_SF_002 | Validate MEETING_ID foreign key relationship | All MEETING_ID values exist in SI_MEETINGS |
| TC_SF_003 | Validate FEATURE_CATEGORY mapping logic | Features correctly categorized (Audio, Video, Collaboration, Security) |
| TC_SF_004 | Validate USAGE_DURATION calculation by feature type | Duration calculated based on feature type and usage count |
| TC_SF_005 | Validate FEATURE_NAME standardization (uppercase) | All feature names converted to uppercase |
| TC_SF_006 | Validate USAGE_COUNT non-negative constraint | All usage counts are >= 0 |
| TC_SF_007 | Test default feature category assignment | Unknown features default to 'Collaboration' category |
| TC_SF_008 | Validate minimum quality threshold filtering (>= 0.75) | Only records with quality score >= 0.75 are included |
| TC_SF_009 | Test deduplication logic for feature usage | Latest record per USAGE_ID retained |
| TC_SF_010 | Validate usage duration business rules by feature type | Screen share: 5min, Chat: 1min, Recording: 30min per usage |

### **Test Case 5: SI_SUPPORT_TICKETS Model - SLA and Resolution Tests**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_ST_001 | Validate TICKET_ID uniqueness and not null constraint | All TICKET_ID values are unique and not null |
| TC_ST_002 | Validate USER_ID foreign key relationship | All USER_ID values exist in SI_USERS |
| TC_ST_003 | Validate TICKET_TYPE standardization | Types standardized to Technical, Billing, Feature Request, Bug Report |
| TC_ST_004 | Validate PRIORITY_LEVEL derivation logic | Priority correctly derived from ticket type and keywords |
| TC_ST_005 | Validate RESOLUTION_STATUS standardization | Status standardized to Open, In Progress, Resolved, Closed |
| TC_ST_006 | Validate CLOSE_DATE calculation based on priority | Close date calculated based on priority SLA targets |
| TC_ST_007 | Validate RESOLUTION_TIME_HOURS calculation | Resolution time correctly calculated in business hours |
| TC_ST_008 | Test SLA compliance validation | Critical: 1 day, High: 3 days, Medium: 7 days, Low: 14 days |
| TC_ST_009 | Validate minimum quality threshold filtering (>= 0.75) | Only records with quality score >= 0.75 are included |
| TC_ST_010 | Test default ticket type assignment | Unknown types default to 'Technical' |

### **Test Case 6: SI_BILLING_EVENTS Model - Financial Validation Tests**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SB_001 | Validate EVENT_ID uniqueness and not null constraint | All EVENT_ID values are unique and not null |
| TC_SB_002 | Validate USER_ID foreign key relationship | All USER_ID values exist in SI_USERS |
| TC_SB_003 | Validate TRANSACTION_AMOUNT positive value constraint | All amounts are > 0 and properly rounded to 2 decimals |
| TC_SB_004 | Validate EVENT_TYPE standardization | Types standardized to Subscription, Upgrade, Downgrade, Refund |
| TC_SB_005 | Validate CURRENCY_CODE default assignment | All records have 'USD' as currency code |
| TC_SB_006 | Validate INVOICE_NUMBER generation logic | Invoice numbers follow format 'INV-YYYY-NNNNNN' |
| TC_SB_007 | Validate PAYMENT_METHOD derivation | Method derived based on transaction amount ranges |
| TC_SB_008 | Validate TRANSACTION_STATUS logic | Status correctly derived from event type and amount |
| TC_SB_009 | Validate minimum quality threshold filtering (>= 0.80) | Only records with quality score >= 0.80 are included |
| TC_SB_010 | Test deduplication logic for billing events | Latest record per EVENT_ID retained |

### **Test Case 7: SI_LICENSES Model - License Management Tests**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_SL_001 | Validate LICENSE_ID uniqueness and not null constraint | All LICENSE_ID values are unique and not null |
| TC_SL_002 | Validate ASSIGNED_TO_USER_ID foreign key relationship | All user IDs exist in SI_USERS |
| TC_SL_003 | Validate LICENSE_TYPE standardization | Types standardized to Basic, Pro, Enterprise, Add-on |
| TC_SL_004 | Validate LICENSE_STATUS derivation based on dates | Status correctly derived from current date vs END_DATE |
| TC_SL_005 | Validate LICENSE_COST assignment by type | Costs: Basic $14.99, Pro $19.99, Enterprise $39.99, Add-on $9.99 |
| TC_SL_006 | Validate ASSIGNED_USER_NAME enrichment | User name correctly joined from BZ_USERS |
| TC_SL_007 | Validate RENEWAL_STATUS logic | Renewal status based on END_DATE proximity |
| TC_SL_008 | Validate UTILIZATION_PERCENTAGE by license type | Enterprise: 85.5%, Pro: 72.3%, Basic: 45.2%, Other: 30% |
| TC_SL_009 | Validate date logic (END_DATE >= START_DATE) | All license date ranges are logically valid |
| TC_SL_010 | Validate minimum quality threshold filtering (>= 0.80) | Only records with quality score >= 0.80 are included |

### **Test Case 8: AUDIT_LOG Model - Pipeline Tracking Tests**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_AL_001 | Validate EXECUTION_ID generation and uniqueness | All execution IDs are unique and properly generated |
| TC_AL_002 | Validate pipeline execution logging | All pipeline runs are properly logged with metadata |
| TC_AL_003 | Validate execution status tracking | Status correctly reflects pipeline execution outcome |
| TC_AL_004 | Validate execution duration calculation | Duration correctly calculated in seconds |
| TC_AL_005 | Validate record count tracking | Processed, inserted, updated, rejected counts are accurate |
| TC_AL_006 | Test error message logging for failed executions | Error messages properly captured and stored |
| TC_AL_007 | Validate data lineage information tracking | Source and target tables properly documented |
| TC_AL_008 | Test execution environment tracking | Environment (Dev, Test, Prod) correctly identified |
| TC_AL_009 | Validate executed_by field population | User or system executing pipeline properly identified |
| TC_AL_010 | Test audit log initialization logic | Initial setup record properly created |

### **Test Case 9: Cross-Model Integration Tests**

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_CM_001 | Validate referential integrity across all models | All foreign key relationships are maintained |
| TC_CM_002 | Test cascade effects of user deactivation | Dependent records properly handled when users are deactivated |
| TC_CM_003 | Validate meeting-participant count consistency | Participant counts in meetings match actual participant records |
| TC_CM_004 | Test data quality score consistency | Quality scores are consistently calculated across models |
| TC_CM_005 | Validate audit trail completeness | All model executions are properly logged in audit_log |
| TC_CM_006 | Test incremental processing logic | Only changed records are processed in subsequent runs |
| TC_CM_007 | Validate metadata consistency | Load dates, update dates, and source systems are consistent |
| TC_CM_008 | Test error handling across models | Errors in one model don't prevent others from processing |
| TC_CM_009 | Validate performance with large datasets | Models perform within acceptable time limits |
| TC_CM_010 | Test end-to-end pipeline execution | Complete pipeline runs successfully from Bronze to Silver |

---

## dbt Test Scripts

### **YAML-based Schema Tests**

```yaml
# models/silver/schema.yml
version: 2

models:
  - name: si_users
    description: "Silver layer users table with cleansed and standardized user data"
    columns:
      - name: user_id
        description: "Unique identifier for each user"
        tests:
          - unique
          - not_null
      - name: email
        description: "Validated email address"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: plan_type
        description: "Subscription plan type"
        tests:
          - not_null
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
      - name: account_status
        description: "Current account status"
        tests:
          - not_null
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
      - name: data_quality_score
        description: "Data quality score"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.00
              max_value: 1.00

  - name: si_meetings
    description: "Silver layer meetings table with enriched meeting data"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "Meeting host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: meeting_type
        description: "Type of meeting"
        tests:
          - not_null
          - accepted_values:
              values: ['Scheduled', 'Instant', 'Webinar', 'Personal']
      - name: meeting_status
        description: "Current meeting status"
        tests:
          - not_null
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Cancelled']

  - name: si_participants
    description: "Silver layer participants table with attendance metrics"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant record"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: attendance_duration
        description: "Time spent in meeting"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
      - name: participant_role
        description: "Role in meeting"
        tests:
          - not_null
          - accepted_values:
              values: ['Host', 'Participant', 'Observer']

  - name: si_feature_usage
    description: "Silver layer feature usage with categorization"
    columns:
      - name: usage_id
        description: "Unique identifier for usage record"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: feature_category
        description: "Feature category"
        tests:
          - not_null
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security']
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: si_support_tickets
    description: "Silver layer support tickets with SLA tracking"
    columns:
      - name: ticket_id
        description: "Unique identifier for ticket"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user who created ticket"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: ticket_type
        description: "Type of support ticket"
        tests:
          - not_null
          - accepted_values:
              values: ['Technical', 'Billing', 'Feature Request', 'Bug Report']
      - name: priority_level
        description: "Priority level of ticket"
        tests:
          - not_null
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']
      - name: resolution_status
        description: "Current resolution status"
        tests:
          - not_null
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: si_billing_events
    description: "Silver layer billing events with financial validation"
    columns:
      - name: event_id
        description: "Unique identifier for billing event"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: transaction_amount
        description: "Transaction amount"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.01
      - name: event_type
        description: "Type of billing event"
        tests:
          - not_null
          - accepted_values:
              values: ['Subscription', 'Upgrade', 'Downgrade', 'Refund']
      - name: currency_code
        description: "Currency code"
        tests:
          - not_null
          - dbt_expectations.expect_column_value_lengths_to_equal:
              value: 3

  - name: si_licenses
    description: "Silver layer licenses with utilization metrics"
    columns:
      - name: license_id
        description: "Unique identifier for license"
        tests:
          - unique
          - not_null
      - name: assigned_to_user_id
        description: "User assigned to license"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: license_type
        description: "Type of license"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Add-on']
      - name: license_status
        description: "Current license status"
        tests:
          - not_null
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended']
      - name: utilization_percentage
        description: "License utilization percentage"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100

  - name: audit_log
    description: "Pipeline execution audit trail"
    columns:
      - name: execution_id
        description: "Unique execution identifier"
        tests:
          - unique
          - not_null
      - name: pipeline_name
        description: "Name of executed pipeline"
        tests:
          - not_null
      - name: status
        description: "Execution status"
        tests:
          - accepted_values:
              values: ['SUCCESS', 'FAILED', 'STARTED', 'CANCELLED']
```

### **Custom SQL-based dbt Tests**

```sql
-- tests/assert_user_email_format.sql
-- Test to ensure all user emails follow proper format
SELECT *
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL
  AND NOT REGEXP_LIKE(email, '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$')
```

```sql
-- tests/assert_meeting_duration_consistency.sql
-- Test to ensure meeting duration matches calculated time difference
SELECT *
FROM {{ ref('si_meetings') }}
WHERE duration_minutes != DATEDIFF('minute', start_time, end_time)
   OR duration_minutes IS NULL
   OR start_time IS NULL
   OR end_time IS NULL
```

```sql
-- tests/assert_participant_attendance_logic.sql
-- Test to ensure participant attendance duration is logical
SELECT p.*
FROM {{ ref('si_participants') }} p
JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE p.attendance_duration > m.duration_minutes
   OR p.attendance_duration < 0
   OR p.leave_time < p.join_time
```

```sql
-- tests/assert_data_quality_scores.sql
-- Test to ensure all data quality scores are within valid range
SELECT 'si_users' as table_name, COUNT(*) as invalid_scores
FROM {{ ref('si_users') }}
WHERE data_quality_score < 0.00 OR data_quality_score > 1.00
UNION ALL
SELECT 'si_meetings', COUNT(*)
FROM {{ ref('si_meetings') }}
WHERE data_quality_score < 0.00 OR data_quality_score > 1.00
UNION ALL
SELECT 'si_participants', COUNT(*)
FROM {{ ref('si_participants') }}
WHERE data_quality_score < 0.00 OR data_quality_score > 1.00
HAVING invalid_scores > 0
```

```sql
-- tests/assert_referential_integrity.sql
-- Test to ensure all foreign key relationships are maintained
SELECT 'meetings_host_id' as relationship, COUNT(*) as orphaned_records
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_users') }} u ON m.host_id = u.user_id
WHERE u.user_id IS NULL
UNION ALL
SELECT 'participants_meeting_id', COUNT(*)
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE m.meeting_id IS NULL
UNION ALL
SELECT 'participants_user_id', COUNT(*)
FROM {{ ref('si_participants') }} p
LEFT JOIN {{ ref('si_users') }} u ON p.user_id = u.user_id
WHERE u.user_id IS NULL
HAVING orphaned_records > 0
```

```sql
-- tests/assert_billing_amount_validation.sql
-- Test to ensure all billing amounts are positive and properly formatted
SELECT *
FROM {{ ref('si_billing_events') }}
WHERE transaction_amount <= 0
   OR transaction_amount IS NULL
   OR transaction_amount != ROUND(transaction_amount, 2)
```

```sql
-- tests/assert_license_date_logic.sql
-- Test to ensure license start and end dates are logical
SELECT *
FROM {{ ref('si_licenses') }}
WHERE end_date < start_date
   OR start_date IS NULL
   OR end_date IS NULL
   OR start_date > CURRENT_DATE()
```

```sql
-- tests/assert_support_ticket_sla.sql
-- Test to validate SLA compliance for resolved tickets
SELECT *
FROM {{ ref('si_support_tickets') }}
WHERE resolution_status = 'Resolved'
  AND (
    (priority_level = 'Critical' AND resolution_time_hours > 24)
    OR (priority_level = 'High' AND resolution_time_hours > 72)
    OR (priority_level = 'Medium' AND resolution_time_hours > 168)
    OR (priority_level = 'Low' AND resolution_time_hours > 336)
  )
```

```sql
-- tests/assert_feature_usage_categories.sql
-- Test to ensure all features are properly categorized
SELECT *
FROM {{ ref('si_feature_usage') }}
WHERE feature_category NOT IN ('Audio', 'Video', 'Collaboration', 'Security')
   OR feature_category IS NULL
   OR feature_name IS NULL
   OR TRIM(feature_name) = ''
```

```sql
-- tests/assert_audit_log_completeness.sql
-- Test to ensure audit log captures all pipeline executions
SELECT pipeline_name, COUNT(*) as execution_count
FROM {{ ref('audit_log') }}
WHERE load_date = CURRENT_DATE()
GROUP BY pipeline_name
HAVING execution_count = 0
```

```sql
-- tests/assert_cross_model_consistency.sql
-- Test to ensure participant counts match between meetings and participants
SELECT m.meeting_id,
       m.participant_count as meeting_participant_count,
       COUNT(p.participant_id) as actual_participant_count
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_participants') }} p ON m.meeting_id = p.meeting_id
GROUP BY m.meeting_id, m.participant_count
HAVING meeting_participant_count != actual_participant_count
```

### **Parameterized Tests for Reusability**

```sql
-- macros/test_data_quality_threshold.sql
{% macro test_data_quality_threshold(model, threshold=0.75) %}
  SELECT *
  FROM {{ model }}
  WHERE data_quality_score < {{ threshold }}
{% endmacro %}
```

```sql
-- macros/test_foreign_key_relationship.sql
{% macro test_foreign_key_relationship(child_model, parent_model, child_column, parent_column) %}
  SELECT c.*
  FROM {{ child_model }} c
  LEFT JOIN {{ parent_model }} p ON c.{{ child_column }} = p.{{ parent_column }}
  WHERE p.{{ parent_column }} IS NULL
    AND c.{{ child_column }} IS NOT NULL
{% endmacro %}
```

```sql
-- macros/test_enumeration_values.sql
{% macro test_enumeration_values(model, column, valid_values) %}
  SELECT *
  FROM {{ model }}
  WHERE {{ column }} NOT IN ({{ valid_values | join(', ') }})
     OR {{ column }} IS NULL
{% endmacro %}
```

## Test Execution Strategy

### **1. Pre-deployment Testing**
- Run all schema tests before deploying models
- Execute custom SQL tests to validate business logic
- Perform data quality threshold checks
- Validate referential integrity across models

### **2. Post-deployment Validation**
- Monitor data quality scores in production
- Track audit log entries for pipeline execution
- Validate SLA compliance for support tickets
- Check cross-model consistency metrics

### **3. Continuous Monitoring**
- Set up automated test execution on schedule
- Configure alerts for test failures
- Monitor performance metrics and execution times
- Track data freshness and completeness

### **4. Error Handling and Recovery**
- Log all test failures with detailed error messages
- Implement retry logic for transient failures
- Establish escalation procedures for critical issues
- Maintain test result history for trend analysis

## Performance Considerations

1. **Test Optimization**
   - Use sampling for large datasets where appropriate
   - Implement incremental testing for changed data only
   - Optimize test queries with proper indexing
   - Parallelize independent test execution

2. **Resource Management**
   - Use appropriate warehouse sizes for test execution
   - Schedule resource-intensive tests during off-peak hours
   - Monitor and optimize test execution times
   - Implement timeout controls for long-running tests

3. **Scalability**
   - Design tests to scale with data volume growth
   - Use statistical sampling for very large datasets
   - Implement data partitioning strategies
   - Consider test execution frequency based on data criticality

This comprehensive test suite ensures the reliability, accuracy, and performance of the Zoom Platform Analytics Silver Layer dbt models in Snowflake, providing confidence in data quality and business rule compliance across all transformations and processes.