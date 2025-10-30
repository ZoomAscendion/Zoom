_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases and dbt test scripts for Zoom Platform Analytics Silver Layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Case for Silver Layer Models
## Zoom Platform Analytics System

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Silver Layer dbt models in the Zoom Platform Analytics System. The tests are designed to validate data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and high-quality data processing in Snowflake.

## Test Coverage Overview

The unit tests cover the following Silver Layer dbt models:
1. **si_users** - User account data with standardization and validation
2. **si_meetings** - Meeting session data with calculated metrics
3. **si_participants** - Participant attendance data with duration calculations
4. **si_feature_usage** - Feature usage data with categorization
5. **si_support_tickets** - Support ticket data with resolution metrics
6. **si_billing_events** - Billing transaction data with validation
7. **si_licenses** - License management data with status derivation
8. **si_webinars** - Webinar data with engagement metrics
9. **si_data_quality_errors** - Error tracking and management
10. **si_pipeline_audit** - Pipeline execution audit trail

## Test Case Categories

### 1. Data Transformation Tests
- Field mapping and data type conversions
- Business rule implementations
- Calculated field validations
- Data standardization and cleansing

### 2. Data Quality Tests
- Null value handling
- Duplicate detection and prevention
- Referential integrity validation
- Data format and pattern validation

### 3. Edge Case Tests
- Empty datasets
- Boundary value testing
- Invalid data handling
- Schema evolution scenarios

### 4. Error Handling Tests
- Failed transformation scenarios
- Data quality violations
- Constraint validation failures
- Recovery and rollback procedures

---

## Test Case List

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| **SI_USERS_001** | Validate USER_ID uniqueness and non-null constraint | All USER_ID values are unique and non-null |
| **SI_USERS_002** | Validate email format standardization (lowercase) | All email addresses are in lowercase format |
| **SI_USERS_003** | Validate PLAN_TYPE enumeration values | All PLAN_TYPE values are in (Free, Basic, Pro, Enterprise) |
| **SI_USERS_004** | Validate USER_NAME standardization (INITCAP) | All user names are properly capitalized |
| **SI_USERS_005** | Validate ACCOUNT_STATUS derivation logic | Account status correctly derived from user activity |
| **SI_USERS_006** | Validate DATA_QUALITY_SCORE calculation | Quality scores are between 0.00 and 1.00 |
| **SI_USERS_007** | Test null handling for optional fields | Null values handled gracefully with defaults |
| **SI_USERS_008** | Test duplicate USER_ID handling | Duplicates are identified and latest record is kept |
| **SI_MEETINGS_001** | Validate MEETING_ID uniqueness and non-null constraint | All MEETING_ID values are unique and non-null |
| **SI_MEETINGS_002** | Validate duration calculation logic | DURATION_MINUTES matches DATEDIFF(minute, START_TIME, END_TIME) |
| **SI_MEETINGS_003** | Validate END_TIME >= START_TIME constraint | All meetings have valid time relationships |
| **SI_MEETINGS_004** | Validate HOST_ID referential integrity | All HOST_ID values exist in si_users table |
| **SI_MEETINGS_005** | Validate MEETING_TYPE derivation | Meeting types correctly categorized |
| **SI_MEETINGS_006** | Validate PARTICIPANT_COUNT calculation | Count matches actual participants from si_participants |
| **SI_MEETINGS_007** | Test zero-duration meeting handling | Meetings with 0 duration are handled appropriately |
| **SI_MEETINGS_008** | Test future meeting date handling | Future meetings are processed correctly |
| **SI_PARTICIPANTS_001** | Validate PARTICIPANT_ID uniqueness | All PARTICIPANT_ID values are unique |
| **SI_PARTICIPANTS_002** | Validate MEETING_ID referential integrity | All MEETING_ID values exist in si_meetings table |
| **SI_PARTICIPANTS_003** | Validate USER_ID referential integrity | All USER_ID values exist in si_users table |
| **SI_PARTICIPANTS_004** | Validate LEAVE_TIME >= JOIN_TIME constraint | All participants have valid attendance times |
| **SI_PARTICIPANTS_005** | Validate ATTENDANCE_DURATION calculation | Duration matches DATEDIFF(minute, JOIN_TIME, LEAVE_TIME) |
| **SI_PARTICIPANTS_006** | Validate PARTICIPANT_ROLE derivation | Roles correctly assigned based on meeting context |
| **SI_PARTICIPANTS_007** | Test null LEAVE_TIME handling | Ongoing participants handled correctly |
| **SI_PARTICIPANTS_008** | Test same user multiple joins | Multiple participant records for same user handled |
| **SI_FEATURE_USAGE_001** | Validate USAGE_ID uniqueness | All USAGE_ID values are unique |
| **SI_FEATURE_USAGE_002** | Validate MEETING_ID referential integrity | All MEETING_ID values exist in si_meetings table |
| **SI_FEATURE_USAGE_003** | Validate USAGE_COUNT non-negative constraint | All usage counts are >= 0 |
| **SI_FEATURE_USAGE_004** | Validate FEATURE_CATEGORY mapping | Features correctly categorized (Audio, Video, Collaboration, Security) |
| **SI_FEATURE_USAGE_005** | Validate USAGE_DURATION calculation | Duration values are reasonable and non-negative |
| **SI_FEATURE_USAGE_006** | Test unknown feature name handling | Unknown features are categorized appropriately |
| **SI_SUPPORT_TICKETS_001** | Validate TICKET_ID uniqueness | All TICKET_ID values are unique |
| **SI_SUPPORT_TICKETS_002** | Validate USER_ID referential integrity | All USER_ID values exist in si_users table |
| **SI_SUPPORT_TICKETS_003** | Validate TICKET_TYPE enumeration | All ticket types are valid (Technical, Billing, Feature Request, Bug Report) |
| **SI_SUPPORT_TICKETS_004** | Validate PRIORITY_LEVEL derivation | Priority levels correctly assigned |
| **SI_SUPPORT_TICKETS_005** | Validate CLOSE_DATE >= OPEN_DATE constraint | All resolved tickets have valid date relationships |
| **SI_SUPPORT_TICKETS_006** | Validate RESOLUTION_TIME_HOURS calculation | Resolution time calculated correctly in business hours |
| **SI_SUPPORT_TICKETS_007** | Test open ticket handling | Open tickets have null close dates |
| **SI_BILLING_EVENTS_001** | Validate EVENT_ID uniqueness | All EVENT_ID values are unique |
| **SI_BILLING_EVENTS_002** | Validate USER_ID referential integrity | All USER_ID values exist in si_users table |
| **SI_BILLING_EVENTS_003** | Validate TRANSACTION_AMOUNT logic | Amounts are positive except for refunds |
| **SI_BILLING_EVENTS_004** | Validate EVENT_TYPE enumeration | All event types are valid |
| **SI_BILLING_EVENTS_005** | Validate CURRENCY_CODE format | All currency codes are valid 3-character ISO codes |
| **SI_BILLING_EVENTS_006** | Validate INVOICE_NUMBER uniqueness | Invoice numbers are unique when present |
| **SI_BILLING_EVENTS_007** | Test refund amount validation | Refund amounts are negative |
| **SI_LICENSES_001** | Validate LICENSE_ID uniqueness | All LICENSE_ID values are unique |
| **SI_LICENSES_002** | Validate ASSIGNED_TO_USER_ID referential integrity | All assigned user IDs exist in si_users table |
| **SI_LICENSES_003** | Validate LICENSE_TYPE enumeration | All license types are valid |
| **SI_LICENSES_004** | Validate END_DATE >= START_DATE constraint | All licenses have valid date relationships |
| **SI_LICENSES_005** | Validate LICENSE_STATUS derivation | Status correctly derived from dates |
| **SI_LICENSES_006** | Validate LICENSE_COST calculation | Costs are non-negative and reasonable |
| **SI_LICENSES_007** | Validate UTILIZATION_PERCENTAGE range | Utilization is between 0 and 100 |
| **SI_WEBINARS_001** | Validate WEBINAR_ID uniqueness | All WEBINAR_ID values are unique |
| **SI_WEBINARS_002** | Validate HOST_ID referential integrity | All HOST_ID values exist in si_users table |
| **SI_WEBINARS_003** | Validate END_TIME >= START_TIME constraint | All webinars have valid time relationships |
| **SI_WEBINARS_004** | Validate DURATION_MINUTES calculation | Duration matches time difference |
| **SI_WEBINARS_005** | Validate ATTENDEES <= REGISTRANTS constraint | Attendees don't exceed registrants |
| **SI_WEBINARS_006** | Validate ATTENDANCE_RATE calculation | Rate correctly calculated as (ATTENDEES/REGISTRANTS)*100 |
| **SI_WEBINARS_007** | Test zero registrants handling | Webinars with no registrants handled correctly |
| **SI_DQ_ERRORS_001** | Validate error record creation | Data quality errors are properly logged |
| **SI_DQ_ERRORS_002** | Validate error categorization | Errors are correctly categorized by type and severity |
| **SI_DQ_ERRORS_003** | Validate error resolution tracking | Error resolution status is properly maintained |
| **SI_AUDIT_001** | Validate pipeline execution logging | All pipeline runs are properly audited |
| **SI_AUDIT_002** | Validate execution metrics calculation | Processing metrics are accurately calculated |
| **SI_AUDIT_003** | Validate data lineage tracking | Data lineage information is properly captured |

---

## dbt Test Scripts

### YAML-based Schema Tests

#### tests/schema.yml

```yaml
version: 2

models:
  - name: si_users
    description: "Silver layer user data with standardization and validation"
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
          - accepted_values:
              values: ['Free', 'Basic', 'Pro', 'Enterprise']
      - name: account_status
        description: "Current account status"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive', 'Suspended']
      - name: data_quality_score
        description: "Data quality score"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0.00
              max_value: 1.00
      - name: registration_date
        description: "User registration date"
        tests:
          - dbt_expectations.expect_column_values_to_be_of_type:
              column_type: date
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: '2011-01-01'
              max_value: "{{ var('current_date') }}"

  - name: si_meetings
    description: "Silver layer meeting data with calculated metrics"
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
      - name: meeting_type
        description: "Type of meeting"
        tests:
          - accepted_values:
              values: ['Scheduled', 'Instant', 'Webinar', 'Personal']
      - name: meeting_status
        description: "Meeting status"
        tests:
          - accepted_values:
              values: ['Scheduled', 'In Progress', 'Completed', 'Cancelled']
      - name: participant_count
        description: "Number of participants"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000

  - name: si_participants
    description: "Silver layer participant data with attendance metrics"
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
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: participant_role
        description: "Role in meeting"
        tests:
          - accepted_values:
              values: ['Host', 'Co-host', 'Participant', 'Observer']
      - name: attendance_duration
        description: "Time spent in meeting"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440

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
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1000000
      - name: feature_category
        description: "Feature category"
        tests:
          - accepted_values:
              values: ['Audio', 'Video', 'Collaboration', 'Security']

  - name: si_support_tickets
    description: "Silver layer support ticket data"
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
          - accepted_values:
              values: ['Technical', 'Billing', 'Feature Request', 'Bug Report']
      - name: priority_level
        description: "Priority level of ticket"
        tests:
          - accepted_values:
              values: ['Low', 'Medium', 'High', 'Critical']
      - name: resolution_status
        description: "Current resolution status"
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
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: event_type
        description: "Type of billing event"
        tests:
          - accepted_values:
              values: ['Subscription', 'Upgrade', 'Downgrade', 'Refund']
      - name: transaction_amount
        description: "Transaction amount"
        tests:
          - not_null
      - name: currency_code
        description: "ISO currency code"
        tests:
          - dbt_expectations.expect_column_value_lengths_to_equal:
              value: 3
      - name: invoice_number
        description: "Invoice number"
        tests:
          - unique:
              config:
                where: "invoice_number is not null"

  - name: si_licenses
    description: "Silver layer license data"
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
              config:
                where: "assigned_to_user_id is not null"
      - name: license_type
        description: "Type of license"
        tests:
          - accepted_values:
              values: ['Basic', 'Pro', 'Enterprise', 'Add-on']
      - name: license_status
        description: "Current license status"
        tests:
          - accepted_values:
              values: ['Active', 'Expired', 'Suspended']
      - name: license_cost
        description: "License cost"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
      - name: utilization_percentage
        description: "License utilization percentage"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100

  - name: si_webinars
    description: "Silver layer webinar data"
    columns:
      - name: webinar_id
        description: "Unique identifier for webinar"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "Webinar host user ID"
        tests:
          - not_null
          - relationships:
              to: ref('si_users')
              field: user_id
      - name: duration_minutes
        description: "Webinar duration in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440
      - name: registrants
        description: "Number of registrants"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100000
      - name: attendees
        description: "Number of attendees"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100000
      - name: attendance_rate
        description: "Attendance rate percentage"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100
```

### Custom SQL-based dbt Tests

#### tests/test_meeting_duration_consistency.sql

```sql
-- Test that calculated duration matches the difference between start and end times
SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF('minute', start_time, end_time) as calculated_duration,
    ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) as duration_diff
FROM {{ ref('si_meetings') }}
WHERE ABS(duration_minutes - DATEDIFF('minute', start_time, end_time)) > 1
```

#### tests/test_participant_count_accuracy.sql

```sql
-- Test that meeting participant count matches actual participant records
WITH meeting_participant_counts AS (
    SELECT 
        m.meeting_id,
        m.participant_count as reported_count,
        COUNT(p.participant_id) as actual_count
    FROM {{ ref('si_meetings') }} m
    LEFT JOIN {{ ref('si_participants') }} p ON m.meeting_id = p.meeting_id
    GROUP BY m.meeting_id, m.participant_count
)
SELECT *
FROM meeting_participant_counts
WHERE reported_count != actual_count
```

#### tests/test_attendance_duration_logic.sql

```sql
-- Test that attendance duration is calculated correctly
SELECT 
    participant_id,
    join_time,
    leave_time,
    attendance_duration,
    DATEDIFF('minute', join_time, leave_time) as calculated_duration
FROM {{ ref('si_participants') }}
WHERE leave_time IS NOT NULL
  AND ABS(attendance_duration - DATEDIFF('minute', join_time, leave_time)) > 1
```

#### tests/test_webinar_attendance_logic.sql

```sql
-- Test that webinar attendees don't exceed registrants
SELECT 
    webinar_id,
    registrants,
    attendees,
    attendance_rate
FROM {{ ref('si_webinars') }}
WHERE attendees > registrants
   OR (registrants > 0 AND ABS(attendance_rate - (attendees::FLOAT / registrants * 100)) > 0.01)
```

#### tests/test_billing_amount_logic.sql

```sql
-- Test that billing amounts follow business rules (positive except refunds)
SELECT 
    event_id,
    event_type,
    transaction_amount
FROM {{ ref('si_billing_events') }}
WHERE (event_type != 'Refund' AND transaction_amount <= 0)
   OR (event_type = 'Refund' AND transaction_amount >= 0)
```

#### tests/test_license_date_logic.sql

```sql
-- Test that license end dates are after start dates
SELECT 
    license_id,
    start_date,
    end_date,
    license_status
FROM {{ ref('si_licenses') }}
WHERE end_date IS NOT NULL 
  AND start_date >= end_date
```

#### tests/test_support_ticket_resolution_logic.sql

```sql
-- Test that resolved tickets have close dates after open dates
SELECT 
    ticket_id,
    open_date,
    close_date,
    resolution_status
FROM {{ ref('si_support_tickets') }}
WHERE resolution_status IN ('Resolved', 'Closed')
  AND (close_date IS NULL OR close_date < open_date)
```

#### tests/test_data_quality_score_range.sql

```sql
-- Test that data quality scores are within valid range across all tables
WITH quality_scores AS (
    SELECT 'si_users' as table_name, user_id as record_id, data_quality_score
    FROM {{ ref('si_users') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_meetings', meeting_id, data_quality_score
    FROM {{ ref('si_meetings') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_participants', participant_id, data_quality_score
    FROM {{ ref('si_participants') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_feature_usage', usage_id, data_quality_score
    FROM {{ ref('si_feature_usage') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_support_tickets', ticket_id, data_quality_score
    FROM {{ ref('si_support_tickets') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_billing_events', event_id, data_quality_score
    FROM {{ ref('si_billing_events') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_licenses', license_id, data_quality_score
    FROM {{ ref('si_licenses') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
    
    UNION ALL
    
    SELECT 'si_webinars', webinar_id, data_quality_score
    FROM {{ ref('si_webinars') }}
    WHERE data_quality_score < 0 OR data_quality_score > 1
)
SELECT * FROM quality_scores
```

#### tests/test_email_format_standardization.sql

```sql
-- Test that email addresses are properly standardized (lowercase)
SELECT 
    user_id,
    email
FROM {{ ref('si_users') }}
WHERE email IS NOT NULL
  AND email != LOWER(email)
```

#### tests/test_user_name_standardization.sql

```sql
-- Test that user names are properly standardized (proper case)
SELECT 
    user_id,
    user_name
FROM {{ ref('si_users') }}
WHERE user_name IS NOT NULL
  AND user_name != INITCAP(user_name)
```

### Parameterized Tests

#### macros/test_referential_integrity.sql

```sql
{% macro test_referential_integrity(model, column_name, parent_model, parent_column) %}
  SELECT 
    {{ column_name }} as orphaned_key,
    COUNT(*) as orphan_count
  FROM {{ model }}
  WHERE {{ column_name }} IS NOT NULL
    AND {{ column_name }} NOT IN (
      SELECT {{ parent_column }}
      FROM {{ parent_model }}
      WHERE {{ parent_column }} IS NOT NULL
    )
  GROUP BY {{ column_name }}
{% endmacro %}
```

#### macros/test_enumeration_values.sql

```sql
{% macro test_enumeration_values(model, column_name, valid_values) %}
  SELECT 
    {{ column_name }} as invalid_value,
    COUNT(*) as invalid_count
  FROM {{ model }}
  WHERE {{ column_name }} IS NOT NULL
    AND {{ column_name }} NOT IN ({{ valid_values | join("','") | replace("','", "','")}}
  GROUP BY {{ column_name }}
{% endmacro %}
```

#### macros/test_date_range_validation.sql

```sql
{% macro test_date_range_validation(model, date_column, min_date=none, max_date=none) %}
  SELECT 
    {{ date_column }},
    COUNT(*) as invalid_date_count
  FROM {{ model }}
  WHERE {{ date_column }} IS NOT NULL
    {% if min_date %}
    AND {{ date_column }} < '{{ min_date }}'
    {% endif %}
    {% if max_date %}
    AND {{ date_column }} > '{{ max_date }}'
    {% endif %}
  GROUP BY {{ date_column }}
{% endmacro %}
```

### Test Execution Commands

#### Run All Tests
```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select si_users

# Run tests with specific tag
dbt test --select tag:data_quality

# Run tests excluding certain models
dbt test --exclude si_audit_log
```

#### Run Specific Test Categories
```bash
# Run only schema tests
dbt test --select test_type:schema

# Run only custom SQL tests
dbt test --select test_type:data

# Run tests for specific source
dbt test --select source:bronze_layer
```

### Test Results Tracking

#### Test Results Analysis Query
```sql
-- Query to analyze test results from dbt run_results.json
SELECT 
    test_name,
    model_name,
    status,
    execution_time,
    failures,
    message,
    run_started_at
FROM dbt_test_results
WHERE run_started_at >= CURRENT_DATE() - 7
ORDER BY run_started_at DESC, status, test_name;
```

#### Data Quality Dashboard Query
```sql
-- Summary of data quality test results
WITH test_summary AS (
    SELECT 
        DATE(run_started_at) as test_date,
        model_name,
        COUNT(*) as total_tests,
        SUM(CASE WHEN status = 'pass' THEN 1 ELSE 0 END) as passed_tests,
        SUM(CASE WHEN status = 'fail' THEN 1 ELSE 0 END) as failed_tests,
        SUM(CASE WHEN status = 'error' THEN 1 ELSE 0 END) as error_tests
    FROM dbt_test_results
    WHERE run_started_at >= CURRENT_DATE() - 30
    GROUP BY DATE(run_started_at), model_name
)
SELECT 
    test_date,
    model_name,
    total_tests,
    passed_tests,
    failed_tests,
    error_tests,
    ROUND((passed_tests::FLOAT / total_tests * 100), 2) as pass_rate
FROM test_summary
ORDER BY test_date DESC, model_name;
```

## Test Maintenance and Best Practices

### 1. Test Organization
- Group related tests in the same file
- Use descriptive test names that explain the validation
- Tag tests by category (data_quality, business_rules, referential_integrity)
- Document test purpose and expected behavior

### 2. Performance Optimization
- Use appropriate WHERE clauses to limit test scope
- Consider sampling for large datasets in development
- Optimize test queries for execution speed
- Use incremental testing where appropriate

### 3. Error Handling
- Implement graceful failure handling
- Provide meaningful error messages
- Log test failures for analysis
- Set up alerting for critical test failures

### 4. Continuous Integration
- Run tests automatically on code changes
- Include test results in deployment pipeline
- Block deployments on critical test failures
- Generate test reports for stakeholders

### 5. Test Data Management
- Maintain representative test datasets
- Update test data regularly
- Document test data requirements
- Ensure test data privacy compliance

---

## Conclusion

This comprehensive unit test suite ensures the reliability and quality of the Silver Layer dbt models in the Zoom Platform Analytics System. The tests cover data transformations, business rules, edge cases, and error handling scenarios, providing confidence in the data pipeline's accuracy and consistency.

Regular execution of these tests, combined with proper monitoring and alerting, will help maintain high data quality standards and catch issues early in the development cycle. The test results should be tracked in Snowflake audit schemas and integrated into data quality dashboards for ongoing monitoring and improvement.

**Key Benefits:**
- **Data Quality Assurance**: Comprehensive validation of all data transformations
- **Early Issue Detection**: Catch problems before they reach production
- **Regression Prevention**: Ensure changes don't break existing functionality
- **Documentation**: Tests serve as living documentation of business rules
- **Confidence**: Stakeholders can trust the data quality and accuracy

**Next Steps:**
1. Implement the test suite in the dbt project
2. Set up automated test execution in CI/CD pipeline
3. Configure monitoring and alerting for test failures
4. Create data quality dashboards using test results
5. Establish regular test maintenance and updates schedule