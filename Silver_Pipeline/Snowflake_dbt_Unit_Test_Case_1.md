_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics System Silver layer models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Silver Layer Models
## Zoom Platform Analytics System

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Silver layer models in the Zoom Platform Analytics System. The tests cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and reliability in the Snowflake environment.

## Test Coverage Overview

The test suite covers 8 Silver layer models:
- SI_USERS
- SI_MEETINGS 
- SI_PARTICIPANTS
- SI_FEATURE_USAGE
- SI_SUPPORT_TICKETS
- SI_BILLING_EVENTS
- SI_LICENSES
- SI_Audit_Log

## Test Case List

### 1. SI_USERS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SU_001 | Validate USER_ID uniqueness | No duplicate USER_IDs |
| SU_002 | Check for null USER_IDs | Zero null values in USER_ID |
| SU_003 | Email format validation | All emails follow valid format pattern |
| SU_004 | Plan type standardization | Only valid plan types (Free, Basic, Pro, Enterprise) |
| SU_005 | Data quality score range | All scores between 0-100 |
| SU_006 | Validation status check | Only PASSED, FAILED, WARNING values |
| SU_007 | Load timestamp validation | All records have valid load timestamps |
| SU_008 | Email domain analysis | Identify corporate vs personal email domains |
| SU_009 | User name length validation | User names within acceptable length limits |
| SU_010 | Company field standardization | Company names properly cleaned and formatted |

### 2. SI_MEETINGS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SM_001 | Meeting duration consistency | Calculated duration matches start/end time difference |
| SM_002 | Meeting time logic validation | End time is after start time |
| SM_003 | Host ID referential integrity | All hosts exist in SI_USERS table |
| SM_004 | Duration range validation | Meeting durations within 0-1440 minutes |
| SM_005 | EST timezone conversion | EST timestamps properly converted to UTC |
| SM_006 | Duration text cleaning (P1) | "108 mins" format properly cleaned to numeric |
| SM_007 | Meeting topic validation | Meeting topics are not null and within length limits |
| SM_008 | Meeting classification | Meetings properly classified by duration |
| SM_009 | Concurrent meeting validation | Host cannot have overlapping meetings |
| SM_010 | Weekend meeting analysis | Identify meetings scheduled on weekends |

### 3. SI_PARTICIPANTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SP_001 | Participant session time validation | Leave time is after join time |
| SP_002 | Meeting boundary validation | Join/leave times within meeting duration |
| SP_003 | Meeting referential integrity | All participants reference valid meetings |
| SP_004 | User referential integrity | All participants reference valid users |
| SP_005 | Unique participant per meeting | No duplicate participant-meeting combinations |
| SP_006 | MM/DD/YYYY timestamp conversion | MM/DD/YYYY HH:MM format properly converted |
| SP_007 | Participant duration calculation | Calculate actual participation duration |
| SP_008 | Late joiners identification | Identify participants who joined after meeting start |
| SP_009 | Early leavers identification | Identify participants who left before meeting end |
| SP_010 | Host participation validation | Meeting host is also a participant |

### 4. SI_FEATURE_USAGE Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SF_001 | Feature name standardization | Feature names follow naming conventions |
| SF_002 | Usage count validation | Usage counts are non-negative integers |
| SF_003 | Meeting referential integrity | All feature usage references valid meetings |
| SF_004 | Usage date consistency | Usage dates align with meeting dates |
| SF_005 | Feature adoption rate calculation | Calculate feature adoption metrics |
| SF_006 | Popular features analysis | Identify most and least used features |
| SF_007 | Feature usage trends | Track feature usage over time |
| SF_008 | Zero usage validation | Handle meetings with no feature usage |
| SF_009 | Feature category grouping | Group features by category for analysis |
| SF_010 | Usage spike detection | Identify unusual spikes in feature usage |

### 5. SI_SUPPORT_TICKETS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| ST_001 | Ticket status validation | Only valid status values (Open, In Progress, Resolved, Closed) |
| ST_002 | User referential integrity | All tickets reference valid users |
| ST_003 | Ticket ID uniqueness | No duplicate ticket IDs |
| ST_004 | Open date validation | Open dates are valid and not in future |
| ST_005 | Ticket volume analysis | Calculate tickets per 1000 users |
| ST_006 | Resolution time calculation | Calculate average resolution times |
| ST_007 | Ticket type distribution | Analyze distribution of ticket types |
| ST_008 | Escalation tracking | Track tickets requiring escalation |
| ST_009 | Customer satisfaction correlation | Correlate ticket volume with user activity |
| ST_010 | Seasonal ticket patterns | Identify seasonal patterns in ticket volume |

### 6. SI_BILLING_EVENTS Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SB_001 | Amount validation | Billing amounts are positive numbers |
| SB_002 | Event date validation | Event dates are valid and not in future |
| SB_003 | User referential integrity | All billing events reference valid users |
| SB_004 | Event type standardization | Event types follow standardized categories |
| SB_005 | MRR calculation | Calculate Monthly Recurring Revenue |
| SB_006 | Revenue trend analysis | Track revenue trends over time |
| SB_007 | Refund processing validation | Properly handle refund transactions |
| SB_008 | Currency consistency | Ensure all amounts in consistent currency |
| SB_009 | Payment method analysis | Analyze distribution of payment methods |
| SB_010 | Churn correlation | Correlate billing events with user churn |

### 7. SI_LICENSES Model Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| SL_001 | License date logic validation | Start date is before end date |
| SL_002 | User referential integrity | All licenses assigned to valid users |
| SL_003 | Active license validation | Active licenses have future end dates |
| SL_004 | License type standardization | License types follow predefined categories |
| SL_005 | License utilization calculation | Calculate license utilization rates |
| SL_006 | DD/MM/YYYY date conversion (P1) | "27/08/2024" format properly converted |
| SL_007 | License overlap detection | Detect overlapping license periods |
| SL_008 | Expiration notification | Identify licenses expiring soon |
| SL_009 | License upgrade tracking | Track license upgrades and downgrades |
| SL_010 | Compliance validation | Ensure license compliance with usage |

### 8. Cross-Table Integration Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| CT_001 | User activity consistency | Users with meetings have participant records |
| CT_002 | Feature usage alignment | Feature usage aligns with meeting participants |
| CT_003 | Billing-license consistency | Users with billing events have license records |
| CT_004 | Data freshness validation | All tables loaded within acceptable timeframes |
| CT_005 | Record count validation | Monitor record counts for unexpected changes |
| CT_006 | Audit trail completeness | All operations logged in audit table |
| CT_007 | Data lineage validation | Trace data from Bronze to Silver layer |
| CT_008 | Business rule consistency | Business rules applied consistently across tables |
| CT_009 | Performance validation | Query performance within acceptable limits |
| CT_010 | Data quality score distribution | Monitor overall data quality trends |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# models/silver/schema.yml
version: 2

models:
  - name: si_users
    description: "Silver layer user data with cleansed and standardized information"
    columns:
      - name: user_id
        description: "Unique identifier for each user"
        tests:
          - unique
          - not_null
      - name: email
        description: "User email address"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
      - name: plan_type
        description: "User subscription plan"
        tests:
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
      - name: data_quality_score
        description: "Data quality score (0-100)"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
      - name: validation_status
        description: "Data validation status"
        tests:
          - accepted_values:
              values: ['PASSED', 'FAILED', 'WARNING']

  - name: si_meetings
    description: "Silver layer meeting data with duration and timezone fixes"
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
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: end_time
        description: "Meeting end timestamp"
        tests:
          - not_null

  - name: si_participants
    description: "Silver layer participant data with timestamp format fixes"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant"
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
          - relationships:
              to: ref('si_users')
              field: user_id

  - name: si_feature_usage
    description: "Silver layer feature usage data"
    columns:
      - name: usage_id
        description: "Unique identifier for usage record"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - relationships:
              to: ref('si_meetings')
              field: meeting_id
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: number
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: si_support_tickets
    description: "Silver layer support ticket data"
    columns:
      - name: ticket_id
        description: "Unique identifier for each ticket"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user who created ticket"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: resolution_status
        description: "Current ticket status"
        tests:
          - accepted_values:
              values: ['Open', 'In Progress', 'Resolved', 'Closed']

  - name: si_billing_events
    description: "Silver layer billing event data"
    columns:
      - name: event_id
        description: "Unique identifier for billing event"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: amount
        description: "Billing amount"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0

  - name: si_licenses
    description: "Silver layer license data with date format fixes"
    columns:
      - name: license_id
        description: "Unique identifier for license"
        tests:
          - unique
          - not_null
      - name: assigned_to_user_id
        description: "User assigned to license"
        tests:
          - relationships:
              to: ref('si_users')
              field: user_id
```

### Custom SQL-based dbt Tests

#### 1. Meeting Duration Consistency Test
```sql
-- tests/assert_meeting_duration_consistency.sql
SELECT 
    meeting_id,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) as duration_diff
FROM {{ ref('si_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### 2. Duration Text Cleaning Validation (Critical P1)
```sql
-- tests/assert_duration_text_cleaning.sql
SELECT 
    meeting_id,
    duration_minutes,
    CASE 
        WHEN duration_minutes::STRING REGEXP '[a-zA-Z]' THEN 'CONTAINS_TEXT'
        ELSE 'NUMERIC_ONLY'
    END as format_status
FROM {{ ref('si_meetings') }}
WHERE duration_minutes::STRING REGEXP '[a-zA-Z]'
```

#### 3. DD/MM/YYYY Date Format Validation (Critical P1)
```sql
-- tests/assert_ddmmyyyy_date_conversion.sql
SELECT 
    license_id,
    start_date,
    end_date,
    CASE 
        WHEN start_date::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4}$' 
             AND TRY_TO_DATE(start_date::STRING, 'DD/MM/YYYY') IS NULL THEN 'START_DATE_CONVERSION_FAILED'
        WHEN end_date::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4}$' 
             AND TRY_TO_DATE(end_date::STRING, 'DD/MM/YYYY') IS NULL THEN 'END_DATE_CONVERSION_FAILED'
        ELSE 'CONVERSION_SUCCESS'
    END as conversion_status
FROM {{ ref('si_licenses') }}
WHERE (start_date::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4}$'
       OR end_date::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4}$')
AND conversion_status != 'CONVERSION_SUCCESS'
```

#### 4. Participant Session Time Validation
```sql
-- tests/assert_participant_session_times.sql
SELECT 
    participant_id,
    join_time,
    leave_time
FROM {{ ref('si_participants') }}
WHERE leave_time <= join_time
```

#### 5. Meeting Boundary Validation
```sql
-- tests/assert_meeting_boundaries.sql
SELECT 
    p.participant_id,
    p.meeting_id,
    p.join_time,
    p.leave_time,
    m.start_time,
    m.end_time
FROM {{ ref('si_participants') }} p
JOIN {{ ref('si_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE p.join_time < m.start_time 
   OR p.leave_time > m.end_time
```

#### 6. EST Timezone Conversion Validation
```sql
-- tests/assert_est_timezone_conversion.sql
SELECT 
    meeting_id,
    start_time,
    end_time
FROM {{ ref('si_meetings') }}
WHERE (start_time::STRING LIKE '%EST%' 
       AND TRY_TO_TIMESTAMP(REPLACE(start_time::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS') IS NULL)
   OR (end_time::STRING LIKE '%EST%' 
       AND TRY_TO_TIMESTAMP(REPLACE(end_time::STRING, ' EST', ''), 'YYYY-MM-DD HH24:MI:SS') IS NULL)
```

#### 7. MM/DD/YYYY Timestamp Format Validation
```sql
-- tests/assert_mmddyyyy_timestamp_conversion.sql
SELECT 
    participant_id,
    join_time,
    leave_time
FROM {{ ref('si_participants') }}
WHERE (join_time::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{2}$'
       AND TRY_TO_TIMESTAMP(join_time::STRING, 'MM/DD/YYYY HH24:MI') IS NULL)
   OR (leave_time::STRING REGEXP '^\d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{2}$'
       AND TRY_TO_TIMESTAMP(leave_time::STRING, 'MM/DD/YYYY HH24:MI') IS NULL)
```

#### 8. Cross-Table Referential Integrity
```sql
-- tests/assert_cross_table_integrity.sql
SELECT 
    'meetings_without_host_participation' as test_type,
    COUNT(*) as violation_count
FROM {{ ref('si_meetings') }} m
LEFT JOIN {{ ref('si_participants') }} p ON m.meeting_id = p.meeting_id AND m.host_id = p.user_id
WHERE p.user_id IS NULL

UNION ALL

SELECT 
    'feature_usage_without_participants',
    COUNT(*)
FROM {{ ref('si_feature_usage') }} f
LEFT JOIN {{ ref('si_participants') }} p ON f.meeting_id = p.meeting_id
WHERE p.meeting_id IS NULL

UNION ALL

SELECT 
    'billing_without_licenses',
    COUNT(*)
FROM {{ ref('si_billing_events') }} b
LEFT JOIN {{ ref('si_licenses') }} l ON b.user_id = l.assigned_to_user_id
WHERE l.assigned_to_user_id IS NULL
```

#### 9. Data Quality Score Distribution
```sql
-- tests/assert_data_quality_distribution.sql
SELECT 
    'si_users' as table_name,
    AVG(data_quality_score) as avg_score,
    MIN(data_quality_score) as min_score,
    MAX(data_quality_score) as max_score,
    COUNT(CASE WHEN data_quality_score < 70 THEN 1 END) as low_quality_count
FROM {{ ref('si_users') }}
WHERE data_quality_score IS NOT NULL
HAVING avg_score < 80 OR low_quality_count > 0

UNION ALL

SELECT 
    'si_meetings',
    AVG(data_quality_score),
    MIN(data_quality_score),
    MAX(data_quality_score),
    COUNT(CASE WHEN data_quality_score < 70 THEN 1 END)
FROM {{ ref('si_meetings') }}
WHERE data_quality_score IS NOT NULL
HAVING avg_score < 80 OR low_quality_count > 0
```

#### 10. Business Rule Validation - Daily Active Users
```sql
-- tests/assert_dau_calculation.sql
WITH daily_active_users AS (
    SELECT 
        DATE(start_time) as activity_date,
        COUNT(DISTINCT host_id) as dau_count
    FROM {{ ref('si_meetings') }}
    WHERE start_time >= CURRENT_DATE() - INTERVAL '7 days'
    GROUP BY DATE(start_time)
)
SELECT 
    activity_date,
    dau_count
FROM daily_active_users
WHERE dau_count = 0  -- Flag days with zero active users
```

### Parameterized Tests for Reusability

#### Generic Test Macro for Timestamp Format Validation
```sql
-- macros/test_timestamp_format.sql
{% macro test_timestamp_format(model, column_name, format_pattern, format_string) %}
    SELECT 
        {{ column_name }},
        CASE 
            WHEN {{ column_name }}::STRING REGEXP '{{ format_pattern }}'
                 AND TRY_TO_TIMESTAMP({{ column_name }}::STRING, '{{ format_string }}') IS NULL 
            THEN 'CONVERSION_FAILED'
            ELSE 'CONVERSION_SUCCESS'
        END as conversion_status
    FROM {{ model }}
    WHERE {{ column_name }}::STRING REGEXP '{{ format_pattern }}'
    AND conversion_status = 'CONVERSION_FAILED'
{% endmacro %}
```

#### Generic Test Macro for Date Range Validation
```sql
-- macros/test_date_range.sql
{% macro test_date_range(model, start_date_column, end_date_column) %}
    SELECT 
        {{ start_date_column }},
        {{ end_date_column }}
    FROM {{ model }}
    WHERE {{ start_date_column }} >= {{ end_date_column }}
{% endmacro %}
```

## Test Execution Strategy

### 1. Test Prioritization
- **Critical (P1)**: Data integrity, referential integrity, format conversion tests
- **High (P2)**: Business rule validation, data quality checks
- **Medium (P3)**: Performance tests, trend analysis
- **Low (P4)**: Reporting and analytics validation

### 2. Test Automation
- Execute P1 tests on every dbt run
- Schedule P2 tests daily
- Run P3 and P4 tests weekly
- Implement CI/CD pipeline integration

### 3. Error Handling
- Route test failures to SI_DATA_QUALITY_ERRORS table
- Generate alerts for critical test failures
- Maintain test execution logs in SI_PIPELINE_EXECUTION_LOG
- Implement retry mechanisms for transient failures

### 4. Monitoring and Alerting
- Set up Snowflake alerts for test failures
- Create dashboards for test result monitoring
- Establish SLAs for test execution times
- Implement escalation procedures for persistent failures

## Expected Test Results

### Success Criteria
- All P1 tests pass with 100% success rate
- P2 tests pass with >95% success rate
- Data quality scores maintain >80 average
- Test execution completes within 10 minutes
- Zero critical format conversion failures

### Performance Benchmarks
- Individual test execution: <30 seconds
- Full test suite execution: <10 minutes
- Data quality validation: <5 minutes
- Cross-table integrity checks: <2 minutes

## Maintenance and Updates

### Regular Review Schedule
- Weekly review of test results and trends
- Monthly update of test cases based on new requirements
- Quarterly performance optimization review
- Annual comprehensive test strategy review

### Version Control
- All test scripts maintained in Git repository
- Test case documentation updated with each release
- Change log maintained for test modifications
- Rollback procedures documented for test failures

---

**Note**: This comprehensive test suite ensures the reliability and performance of dbt models in Snowflake by validating key data transformations, business rules, edge cases, and error handling. The tests are designed to catch potential issues early in the development cycle and prevent production failures while maintaining high data quality standards in the Silver layer of the Medallion architecture.