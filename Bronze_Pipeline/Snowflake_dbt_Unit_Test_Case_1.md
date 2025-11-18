_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze Pipeline dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Pipeline

## Description

This document provides comprehensive unit test cases and dbt test scripts for the Zoom Bronze Pipeline dbt models running in Snowflake. The test suite covers data transformations, business rules, edge cases, and error handling scenarios to ensure reliable and performant dbt models in the Bronze layer of the Medallion architecture.

## Test Coverage Overview

The test suite covers 7 Bronze layer models:
- **BZ_USERS**: User profile and subscription information
- **BZ_MEETINGS**: Meeting information and session details
- **BZ_PARTICIPANTS**: Meeting participants and attendance tracking
- **BZ_FEATURE_USAGE**: Platform feature utilization metrics
- **BZ_SUPPORT_TICKETS**: Customer support requests and resolution
- **BZ_BILLING_EVENTS**: Financial transactions and billing activities
- **BZ_LICENSES**: License assignments and entitlements

## Test Case List

### 1. BZ_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_USERS_001 | Validate USER_ID uniqueness and not null | All USER_ID values are unique and not null |
| BZ_USERS_002 | Validate EMAIL uniqueness and format | All EMAIL values are unique and contain '@' symbol |
| BZ_USERS_003 | Validate PLAN_TYPE accepted values | PLAN_TYPE contains only: Basic, Pro, Business, Enterprise, Education |
| BZ_USERS_004 | Validate LOAD_TIMESTAMP not null | All records have LOAD_TIMESTAMP populated |
| BZ_USERS_005 | Validate SOURCE_SYSTEM accepted values | SOURCE_SYSTEM contains only: ZOOM_API, USER_MANAGEMENT_SYSTEM, MANUAL_ENTRY |
| BZ_USERS_006 | Test null handling for optional fields | COMPANY and UPDATE_TIMESTAMP can be null |
| BZ_USERS_007 | Test data type consistency | All fields match expected Snowflake data types |
| BZ_USERS_008 | Test duplicate record handling | Duplicate USER_ID records are properly handled |
| BZ_USERS_009 | Test PII data presence | USER_NAME and EMAIL contain valid PII data |
| BZ_USERS_010 | Test record count validation | Bronze record count matches RAW source count |

### 2. BZ_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_MEETINGS_001 | Validate MEETING_ID uniqueness and not null | All MEETING_ID values are unique and not null |
| BZ_MEETINGS_002 | Validate HOST_ID not null | All HOST_ID values are populated |
| BZ_MEETINGS_003 | Validate START_TIME not null | All START_TIME values are populated |
| BZ_MEETINGS_004 | Validate END_TIME logic | END_TIME is null or greater than START_TIME |
| BZ_MEETINGS_005 | Validate DURATION_MINUTES logic | DURATION_MINUTES is null or >= 0 |
| BZ_MEETINGS_006 | Validate SOURCE_SYSTEM accepted values | SOURCE_SYSTEM contains only: ZOOM_API, MEETING_SYSTEM |
| BZ_MEETINGS_007 | Test meeting duration calculation | DURATION_MINUTES aligns with START_TIME and END_TIME |
| BZ_MEETINGS_008 | Test null handling for optional fields | MEETING_TOPIC, END_TIME, DURATION_MINUTES can be null |
| BZ_MEETINGS_009 | Test timestamp format consistency | All timestamp fields use TIMESTAMP_NTZ format |
| BZ_MEETINGS_010 | Test foreign key relationship | HOST_ID exists in BZ_USERS table |

### 3. BZ_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_PARTICIPANTS_001 | Validate PARTICIPANT_ID uniqueness and not null | All PARTICIPANT_ID values are unique and not null |
| BZ_PARTICIPANTS_002 | Validate MEETING_ID not null | All MEETING_ID values are populated |
| BZ_PARTICIPANTS_003 | Validate USER_ID not null | All USER_ID values are populated |
| BZ_PARTICIPANTS_004 | Validate JOIN_TIME and LEAVE_TIME logic | LEAVE_TIME is null or greater than JOIN_TIME |
| BZ_PARTICIPANTS_005 | Validate SOURCE_SYSTEM accepted values | SOURCE_SYSTEM contains only: ZOOM_API, PARTICIPANT_TRACKING_SYSTEM |
| BZ_PARTICIPANTS_006 | Test foreign key relationships | MEETING_ID exists in BZ_MEETINGS and USER_ID exists in BZ_USERS |
| BZ_PARTICIPANTS_007 | Test participant session duration | Session duration calculated correctly from JOIN_TIME and LEAVE_TIME |
| BZ_PARTICIPANTS_008 | Test null handling for optional fields | JOIN_TIME and LEAVE_TIME can be null |
| BZ_PARTICIPANTS_009 | Test duplicate participant prevention | Same USER_ID cannot have multiple active sessions in same MEETING_ID |
| BZ_PARTICIPANTS_010 | Test data consistency with meetings | Participant timestamps align with meeting START_TIME and END_TIME |

### 4. BZ_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_FEATURE_USAGE_001 | Validate USAGE_ID uniqueness and not null | All USAGE_ID values are unique and not null |
| BZ_FEATURE_USAGE_002 | Validate MEETING_ID not null | All MEETING_ID values are populated |
| BZ_FEATURE_USAGE_003 | Validate FEATURE_NAME accepted values | FEATURE_NAME contains only: screen_share, recording, chat, breakout_rooms, whiteboard |
| BZ_FEATURE_USAGE_004 | Validate USAGE_COUNT not null and >= 0 | All USAGE_COUNT values are non-negative integers |
| BZ_FEATURE_USAGE_005 | Validate USAGE_DATE not null | All USAGE_DATE values are populated |
| BZ_FEATURE_USAGE_006 | Validate SOURCE_SYSTEM accepted values | SOURCE_SYSTEM contains only: ZOOM_API, ANALYTICS_SYSTEM |
| BZ_FEATURE_USAGE_007 | Test foreign key relationship | MEETING_ID exists in BZ_MEETINGS table |
| BZ_FEATURE_USAGE_008 | Test usage date consistency | USAGE_DATE aligns with meeting date from BZ_MEETINGS |
| BZ_FEATURE_USAGE_009 | Test feature usage aggregation | Multiple usage records per meeting are properly aggregated |
| BZ_FEATURE_USAGE_010 | Test zero usage count handling | USAGE_COUNT of 0 is valid and properly recorded |

### 5. BZ_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_SUPPORT_TICKETS_001 | Validate TICKET_ID uniqueness and not null | All TICKET_ID values are unique and not null |
| BZ_SUPPORT_TICKETS_002 | Validate USER_ID not null | All USER_ID values are populated |
| BZ_SUPPORT_TICKETS_003 | Validate TICKET_TYPE accepted values | TICKET_TYPE contains only: technical, billing, account, feature_request, bug_report |
| BZ_SUPPORT_TICKETS_004 | Validate RESOLUTION_STATUS accepted values | RESOLUTION_STATUS contains only: open, in_progress, resolved, closed, escalated |
| BZ_SUPPORT_TICKETS_005 | Validate OPEN_DATE not null | All OPEN_DATE values are populated |
| BZ_SUPPORT_TICKETS_006 | Validate SOURCE_SYSTEM accepted values | SOURCE_SYSTEM contains only: SUPPORT_SYSTEM, ZENDESK, MANUAL_ENTRY |
| BZ_SUPPORT_TICKETS_007 | Test foreign key relationship | USER_ID exists in BZ_USERS table |
| BZ_SUPPORT_TICKETS_008 | Test ticket status workflow | Status transitions follow logical workflow |
| BZ_SUPPORT_TICKETS_009 | Test date consistency | OPEN_DATE is not in the future |
| BZ_SUPPORT_TICKETS_010 | Test ticket aging calculation | Ticket age calculated correctly from OPEN_DATE |

### 6. BZ_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_BILLING_EVENTS_001 | Validate EVENT_ID uniqueness and not null | All EVENT_ID values are unique and not null |
| BZ_BILLING_EVENTS_002 | Validate USER_ID not null | All USER_ID values are populated |
| BZ_BILLING_EVENTS_003 | Validate EVENT_TYPE accepted values | EVENT_TYPE contains only: subscription, usage, refund, upgrade, downgrade |
| BZ_BILLING_EVENTS_004 | Validate AMOUNT not null and format | All AMOUNT values are populated and numeric |
| BZ_BILLING_EVENTS_005 | Validate EVENT_DATE not null | All EVENT_DATE values are populated |
| BZ_BILLING_EVENTS_006 | Validate SOURCE_SYSTEM accepted values | SOURCE_SYSTEM contains only: ZOOM_API, BILLING_SYSTEM, MANUAL_ENTRY |
| BZ_BILLING_EVENTS_007 | Test foreign key relationship | USER_ID exists in BZ_USERS table |
| BZ_BILLING_EVENTS_008 | Test amount validation | AMOUNT values are reasonable for billing events |
| BZ_BILLING_EVENTS_009 | Test refund amount logic | Refund amounts are negative or zero |
| BZ_BILLING_EVENTS_010 | Test billing event chronology | EVENT_DATE follows logical sequence for user billing history |

### 7. BZ_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| BZ_LICENSES_001 | Validate LICENSE_ID uniqueness and not null | All LICENSE_ID values are unique and not null |
| BZ_LICENSES_002 | Validate LICENSE_TYPE accepted values | LICENSE_TYPE contains only: Basic, Pro, Business, Enterprise, Education |
| BZ_LICENSES_003 | Validate START_DATE not null | All START_DATE values are populated |
| BZ_LICENSES_004 | Validate date logic | END_DATE is null or greater than START_DATE |
| BZ_LICENSES_005 | Validate SOURCE_SYSTEM accepted values | SOURCE_SYSTEM contains only: ZOOM_API, LICENSE_MANAGEMENT_SYSTEM |
| BZ_LICENSES_006 | Test foreign key relationship | ASSIGNED_TO_USER_ID exists in BZ_USERS table when not null |
| BZ_LICENSES_007 | Test license assignment logic | Only one active license per user at any time |
| BZ_LICENSES_008 | Test null handling for optional fields | ASSIGNED_TO_USER_ID and END_DATE can be null |
| BZ_LICENSES_009 | Test license validity period | License is valid between START_DATE and END_DATE |
| BZ_LICENSES_010 | Test unassigned license handling | Licenses can exist without user assignment |

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# models/bronze/schema.yml
version: 2

models:
  - name: bz_users
    description: "Bronze layer user profile and subscription information"
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - unique
          - not_null
      - name: email
        description: "Email address of the user (PII)"
        tests:
          - unique
          - not_null
          - dbt_utils.expression_is_true:
              expression: "email LIKE '%@%'"
      - name: plan_type
        description: "Type of Zoom plan the user is subscribed to"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Education']
      - name: load_timestamp
        description: "Timestamp when record was loaded into Bronze layer"
        tests:
          - not_null
      - name: source_system
        description: "Source system from which data originated"
        tests:
          - not_null
          - accepted_values:
              values: ['ZOOM_API', 'USER_MANAGEMENT_SYSTEM', 'MANUAL_ENTRY']

  - name: bz_meetings
    description: "Bronze layer meeting information and session details"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - unique
          - not_null
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_time
        description: "Meeting start timestamp"
        tests:
          - not_null
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - dbt_utils.expression_is_true:
              expression: "duration_minutes IS NULL OR duration_minutes >= 0"
      - name: source_system
        description: "Source system from which data originated"
        tests:
          - not_null
          - accepted_values:
              values: ['ZOOM_API', 'MEETING_SYSTEM']

  - name: bz_participants
    description: "Bronze layer meeting participants and attendance tracking"
    columns:
      - name: participant_id
        description: "Unique identifier for each meeting participant"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: user_id
        description: "Reference to user who participated"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: source_system
        description: "Source system from which data originated"
        tests:
          - not_null
          - accepted_values:
              values: ['ZOOM_API', 'PARTICIPANT_TRACKING_SYSTEM']

  - name: bz_feature_usage
    description: "Bronze layer platform feature utilization metrics"
    columns:
      - name: usage_id
        description: "Unique identifier for each feature usage record"
        tests:
          - unique
          - not_null
      - name: meeting_id
        description: "Reference to meeting where feature was used"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: feature_name
        description: "Name of the feature being tracked"
        tests:
          - not_null
          - accepted_values:
              values: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard']
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: "usage_count >= 0"
      - name: usage_date
        description: "Date when feature usage occurred"
        tests:
          - not_null
      - name: source_system
        description: "Source system from which data originated"
        tests:
          - not_null
          - accepted_values:
              values: ['ZOOM_API', 'ANALYTICS_SYSTEM']

  - name: bz_support_tickets
    description: "Bronze layer customer support requests and resolution"
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user who created the ticket"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: ticket_type
        description: "Type of support ticket"
        tests:
          - not_null
          - accepted_values:
              values: ['technical', 'billing', 'account', 'feature_request', 'bug_report']
      - name: resolution_status
        description: "Current status of ticket resolution"
        tests:
          - not_null
          - accepted_values:
              values: ['open', 'in_progress', 'resolved', 'closed', 'escalated']
      - name: open_date
        description: "Date when ticket was opened"
        tests:
          - not_null
      - name: source_system
        description: "Source system from which data originated"
        tests:
          - not_null
          - accepted_values:
              values: ['SUPPORT_SYSTEM', 'ZENDESK', 'MANUAL_ENTRY']

  - name: bz_billing_events
    description: "Bronze layer financial transactions and billing activities"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - unique
          - not_null
      - name: user_id
        description: "Reference to user associated with billing event"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: event_type
        description: "Type of billing event"
        tests:
          - not_null
          - accepted_values:
              values: ['subscription', 'usage', 'refund', 'upgrade', 'downgrade']
      - name: amount
        description: "Monetary amount for the billing event"
        tests:
          - not_null
      - name: event_date
        description: "Date when the billing event occurred"
        tests:
          - not_null
      - name: source_system
        description: "Source system from which data originated"
        tests:
          - not_null
          - accepted_values:
              values: ['ZOOM_API', 'BILLING_SYSTEM', 'MANUAL_ENTRY']

  - name: bz_licenses
    description: "Bronze layer license assignments and entitlements"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - unique
          - not_null
      - name: license_type
        description: "Type of license"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Education']
      - name: assigned_to_user_id
        description: "User ID to whom license is assigned"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_date
        description: "License validity start date"
        tests:
          - not_null
      - name: source_system
        description: "Source system from which data originated"
        tests:
          - not_null
          - accepted_values:
              values: ['ZOOM_API', 'LICENSE_MANAGEMENT_SYSTEM']
```

### Custom SQL-based dbt Tests

#### 1. Test for Meeting Duration Logic
```sql
-- tests/assert_meeting_duration_logic.sql
SELECT *
FROM {{ ref('bz_meetings') }}
WHERE end_time IS NOT NULL 
  AND start_time IS NOT NULL 
  AND duration_minutes IS NOT NULL
  AND duration_minutes != DATEDIFF('minute', start_time, end_time)
```

#### 2. Test for Participant Session Logic
```sql
-- tests/assert_participant_session_logic.sql
SELECT *
FROM {{ ref('bz_participants') }}
WHERE join_time IS NOT NULL 
  AND leave_time IS NOT NULL 
  AND leave_time <= join_time
```

#### 3. Test for Feature Usage Date Consistency
```sql
-- tests/assert_feature_usage_date_consistency.sql
SELECT fu.*
FROM {{ ref('bz_feature_usage') }} fu
JOIN {{ ref('bz_meetings') }} m ON fu.meeting_id = m.meeting_id
WHERE fu.usage_date != DATE(m.start_time)
```

#### 4. Test for Billing Event Amount Logic
```sql
-- tests/assert_billing_refund_amounts.sql
SELECT *
FROM {{ ref('bz_billing_events') }}
WHERE event_type = 'refund'
  AND amount > 0
```

#### 5. Test for License Date Logic
```sql
-- tests/assert_license_date_logic.sql
SELECT *
FROM {{ ref('bz_licenses') }}
WHERE end_date IS NOT NULL 
  AND start_date IS NOT NULL 
  AND end_date <= start_date
```

#### 6. Test for Data Completeness
```sql
-- tests/assert_data_completeness.sql
WITH source_counts AS (
  SELECT 'USERS' as table_name, COUNT(*) as raw_count FROM {{ source('raw', 'users') }}
  UNION ALL
  SELECT 'MEETINGS' as table_name, COUNT(*) as raw_count FROM {{ source('raw', 'meetings') }}
  UNION ALL
  SELECT 'PARTICIPANTS' as table_name, COUNT(*) as raw_count FROM {{ source('raw', 'participants') }}
  UNION ALL
  SELECT 'FEATURE_USAGE' as table_name, COUNT(*) as raw_count FROM {{ source('raw', 'feature_usage') }}
  UNION ALL
  SELECT 'SUPPORT_TICKETS' as table_name, COUNT(*) as raw_count FROM {{ source('raw', 'support_tickets') }}
  UNION ALL
  SELECT 'BILLING_EVENTS' as table_name, COUNT(*) as raw_count FROM {{ source('raw', 'billing_events') }}
  UNION ALL
  SELECT 'LICENSES' as table_name, COUNT(*) as raw_count FROM {{ source('raw', 'licenses') }}
),
bronze_counts AS (
  SELECT 'USERS' as table_name, COUNT(*) as bronze_count FROM {{ ref('bz_users') }}
  UNION ALL
  SELECT 'MEETINGS' as table_name, COUNT(*) as bronze_count FROM {{ ref('bz_meetings') }}
  UNION ALL
  SELECT 'PARTICIPANTS' as table_name, COUNT(*) as bronze_count FROM {{ ref('bz_participants') }}
  UNION ALL
  SELECT 'FEATURE_USAGE' as table_name, COUNT(*) as bronze_count FROM {{ ref('bz_feature_usage') }}
  UNION ALL
  SELECT 'SUPPORT_TICKETS' as table_name, COUNT(*) as bronze_count FROM {{ ref('bz_support_tickets') }}
  UNION ALL
  SELECT 'BILLING_EVENTS' as table_name, COUNT(*) as bronze_count FROM {{ ref('bz_billing_events') }}
  UNION ALL
  SELECT 'LICENSES' as table_name, COUNT(*) as bronze_count FROM {{ ref('bz_licenses') }}
)
SELECT 
  s.table_name,
  s.raw_count,
  b.bronze_count,
  ABS(s.raw_count - b.bronze_count) as count_difference
FROM source_counts s
JOIN bronze_counts b ON s.table_name = b.table_name
WHERE s.raw_count != b.bronze_count
```

#### 7. Test for PII Data Validation
```sql
-- tests/assert_pii_data_validation.sql
SELECT *
FROM {{ ref('bz_users') }}
WHERE user_name IS NULL 
   OR email IS NULL 
   OR email NOT LIKE '%@%'
   OR LENGTH(user_name) < 2
```

#### 8. Test for Source System Consistency
```sql
-- tests/assert_source_system_consistency.sql
WITH all_source_systems AS (
  SELECT DISTINCT source_system FROM {{ ref('bz_users') }}
  UNION
  SELECT DISTINCT source_system FROM {{ ref('bz_meetings') }}
  UNION
  SELECT DISTINCT source_system FROM {{ ref('bz_participants') }}
  UNION
  SELECT DISTINCT source_system FROM {{ ref('bz_feature_usage') }}
  UNION
  SELECT DISTINCT source_system FROM {{ ref('bz_support_tickets') }}
  UNION
  SELECT DISTINCT source_system FROM {{ ref('bz_billing_events') }}
  UNION
  SELECT DISTINCT source_system FROM {{ ref('bz_licenses') }}
)
SELECT *
FROM all_source_systems
WHERE source_system NOT IN (
  'ZOOM_API', 'USER_MANAGEMENT_SYSTEM', 'MANUAL_ENTRY', 'MEETING_SYSTEM',
  'PARTICIPANT_TRACKING_SYSTEM', 'ANALYTICS_SYSTEM', 'SUPPORT_SYSTEM',
  'ZENDESK', 'BILLING_SYSTEM', 'LICENSE_MANAGEMENT_SYSTEM'
)
```

#### 9. Test for Timestamp Consistency
```sql
-- tests/assert_timestamp_consistency.sql
SELECT *
FROM {{ ref('bz_users') }}
WHERE load_timestamp IS NOT NULL 
  AND update_timestamp IS NOT NULL 
  AND update_timestamp < load_timestamp
```

#### 10. Test for Meeting Participant Consistency
```sql
-- tests/assert_meeting_participant_consistency.sql
SELECT p.*
FROM {{ ref('bz_participants') }} p
JOIN {{ ref('bz_meetings') }} m ON p.meeting_id = m.meeting_id
WHERE p.join_time IS NOT NULL 
  AND m.start_time IS NOT NULL 
  AND p.join_time < m.start_time
```

## Test Execution Strategy

### 1. Test Categories

#### Data Quality Tests
- **Primary Key Tests**: Uniqueness and not null constraints
- **Foreign Key Tests**: Referential integrity validation
- **Data Type Tests**: Format and type consistency
- **Business Rule Tests**: Domain-specific validation

#### Performance Tests
- **Row Count Tests**: Data completeness validation
- **Execution Time Tests**: Model performance monitoring
- **Resource Usage Tests**: Warehouse utilization tracking

#### Edge Case Tests
- **Null Value Tests**: Proper null handling
- **Boundary Value Tests**: Min/max value validation
- **Data Anomaly Tests**: Outlier detection

### 2. Test Execution Order

1. **Schema Tests**: Run basic data quality tests first
2. **Custom SQL Tests**: Execute business logic validation
3. **Cross-Model Tests**: Validate relationships between models
4. **Performance Tests**: Monitor execution metrics
5. **Data Completeness Tests**: Verify end-to-end data flow

### 3. Test Configuration

```yaml
# dbt_project.yml
name: 'zoom_bronze_pipeline'
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
  zoom_bronze_pipeline:
    bronze:
      +materialized: table
      +pre-hook: "INSERT INTO {{ ref('bz_data_audit') }} (source_table, load_timestamp, processed_by, status) VALUES ('{{ this.name }}', CURRENT_TIMESTAMP(), 'dbt', 'STARTED')"
      +post-hook: "UPDATE {{ ref('bz_data_audit') }} SET status = 'COMPLETED', processing_time = DATEDIFF('second', load_timestamp, CURRENT_TIMESTAMP()) WHERE source_table = '{{ this.name }}' AND status = 'STARTED'"

tests:
  +store_failures: true
  +schema: bronze_test_results
```

## Test Results Tracking

### 1. dbt Test Results

Test results are automatically tracked in dbt's `run_results.json` file and can be monitored through:

- **dbt Cloud**: Built-in test result dashboard
- **dbt Core**: Command line test result summary
- **Custom Monitoring**: Parse run_results.json for custom dashboards

### 2. Snowflake Audit Schema

Test execution metrics are stored in the Bronze audit table:

```sql
-- Query to monitor test execution
SELECT 
  source_table,
  load_timestamp,
  processed_by,
  processing_time,
  status
FROM bronze.bz_data_audit
WHERE DATE(load_timestamp) = CURRENT_DATE()
ORDER BY load_timestamp DESC;
```

### 3. Test Failure Handling

```sql
-- Query to identify test failures
SELECT *
FROM bronze_test_results.unique_bz_users_user_id
WHERE test_result = 'FAIL';
```

## Maintenance and Updates

### 1. Test Review Schedule
- **Weekly**: Review test execution results
- **Monthly**: Update test cases based on data patterns
- **Quarterly**: Comprehensive test suite review

### 2. Test Case Evolution
- Add new test cases for schema changes
- Update accepted values for domain changes
- Enhance performance tests for scale changes

### 3. Documentation Updates
- Maintain test case documentation
- Update business rule validation
- Document test failure resolution procedures

## Conclusion

This comprehensive test suite ensures the reliability, performance, and data quality of the Zoom Bronze Pipeline dbt models in Snowflake. The combination of YAML-based schema tests and custom SQL tests provides thorough coverage of:

- **Data Quality**: Ensuring data integrity and consistency
- **Business Rules**: Validating domain-specific requirements
- **Performance**: Monitoring execution efficiency
- **Edge Cases**: Handling exceptional scenarios
- **Compliance**: Maintaining PII and audit requirements

Regular execution of these tests will help maintain high-quality data pipelines and catch potential issues early in the development cycle, ensuring reliable data delivery to downstream Silver and Gold layer models.