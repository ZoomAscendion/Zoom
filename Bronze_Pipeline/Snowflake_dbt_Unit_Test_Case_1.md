_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive unit test cases for Zoom Bronze layer dbt models in Snowflake
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases - Zoom Bronze Layer Pipeline

## Overview

This document provides comprehensive unit test cases and corresponding dbt test scripts for the Zoom Bronze layer data pipeline. The tests validate data transformations, business rules, edge cases, and error handling for all Bronze layer models running in Snowflake.

## Test Strategy

The testing framework covers:
- **Data Quality**: Primary key uniqueness, null value handling, data type validation
- **Business Rules**: Domain value validation, referential integrity, transformation logic
- **Edge Cases**: Empty datasets, null values, invalid lookups, schema mismatches
- **Performance**: Deduplication logic, audit trail functionality, processing efficiency
- **Error Handling**: Failed relationships, unexpected values, data consistency

## Test Case List

### 1. BZ_USERS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_USERS_001 | Validate USER_ID uniqueness and not null | All USER_ID values are unique and not null |
| TC_BZ_USERS_002 | Validate EMAIL uniqueness and format | All EMAIL values are unique and follow valid email format |
| TC_BZ_USERS_003 | Validate PLAN_TYPE domain values | PLAN_TYPE contains only: Basic, Pro, Business, Enterprise, Education |
| TC_BZ_USERS_004 | Validate SOURCE_SYSTEM domain values | SOURCE_SYSTEM contains only: ZOOM_API, USER_MANAGEMENT_SYSTEM, MANUAL_ENTRY |
| TC_BZ_USERS_005 | Test deduplication logic | Latest record by LOAD_TIMESTAMP is retained for duplicate USER_ID |
| TC_BZ_USERS_006 | Validate audit timestamps | LOAD_TIMESTAMP is not null, UPDATE_TIMESTAMP can be null |
| TC_BZ_USERS_007 | Test null primary key filtering | Records with null USER_ID are excluded from final output |
| TC_BZ_USERS_008 | Validate data type consistency | All columns match expected Snowflake data types |

### 2. BZ_MEETINGS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_MEETINGS_001 | Validate MEETING_ID uniqueness and not null | All MEETING_ID values are unique and not null |
| TC_BZ_MEETINGS_002 | Validate HOST_ID foreign key relationship | All HOST_ID values exist in BZ_USERS.USER_ID (referential check) |
| TC_BZ_MEETINGS_003 | Validate START_TIME not null | All START_TIME values are not null |
| TC_BZ_MEETINGS_004 | Validate SOURCE_SYSTEM domain values | SOURCE_SYSTEM contains only: ZOOM_API, MEETING_SYSTEM |
| TC_BZ_MEETINGS_005 | Test deduplication logic | Latest record by LOAD_TIMESTAMP is retained for duplicate MEETING_ID |
| TC_BZ_MEETINGS_006 | Validate END_TIME logic | END_TIME can be null (ongoing meetings) |
| TC_BZ_MEETINGS_007 | Test duration calculation consistency | DURATION_MINUTES aligns with START_TIME and END_TIME when both present |
| TC_BZ_MEETINGS_008 | Validate timestamp sequence | START_TIME <= END_TIME when both are not null |

### 3. BZ_PARTICIPANTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_PARTICIPANTS_001 | Validate PARTICIPANT_ID uniqueness and not null | All PARTICIPANT_ID values are unique and not null |
| TC_BZ_PARTICIPANTS_002 | Validate MEETING_ID foreign key relationship | All MEETING_ID values exist in BZ_MEETINGS.MEETING_ID |
| TC_BZ_PARTICIPANTS_003 | Validate USER_ID foreign key relationship | All USER_ID values exist in BZ_USERS.USER_ID |
| TC_BZ_PARTICIPANTS_004 | Validate SOURCE_SYSTEM domain values | SOURCE_SYSTEM contains only: ZOOM_API, PARTICIPANT_TRACKING_SYSTEM |
| TC_BZ_PARTICIPANTS_005 | Test deduplication logic | Latest record by LOAD_TIMESTAMP is retained for duplicate PARTICIPANT_ID |
| TC_BZ_PARTICIPANTS_006 | Validate JOIN_TIME and LEAVE_TIME logic | LEAVE_TIME >= JOIN_TIME when both are not null |
| TC_BZ_PARTICIPANTS_007 | Test null handling for timestamps | JOIN_TIME and LEAVE_TIME can be null |
| TC_BZ_PARTICIPANTS_008 | Validate composite uniqueness | No duplicate (MEETING_ID, USER_ID) combinations |

### 4. BZ_FEATURE_USAGE Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_FEATURE_USAGE_001 | Validate USAGE_ID uniqueness and not null | All USAGE_ID values are unique and not null |
| TC_BZ_FEATURE_USAGE_002 | Validate MEETING_ID foreign key relationship | All MEETING_ID values exist in BZ_MEETINGS.MEETING_ID |
| TC_BZ_FEATURE_USAGE_003 | Validate FEATURE_NAME domain values | FEATURE_NAME contains only: screen_share, recording, chat, breakout_rooms, whiteboard |
| TC_BZ_FEATURE_USAGE_004 | Validate USAGE_COUNT non-negative | All USAGE_COUNT values are >= 0 |
| TC_BZ_FEATURE_USAGE_005 | Validate SOURCE_SYSTEM domain values | SOURCE_SYSTEM contains only: ZOOM_API, ANALYTICS_SYSTEM |
| TC_BZ_FEATURE_USAGE_006 | Test deduplication logic | Latest record by LOAD_TIMESTAMP is retained for duplicate USAGE_ID |
| TC_BZ_FEATURE_USAGE_007 | Validate USAGE_DATE not null | All USAGE_DATE values are not null |
| TC_BZ_FEATURE_USAGE_008 | Test data type for USAGE_COUNT | USAGE_COUNT is NUMBER(38,0) type |

### 5. BZ_SUPPORT_TICKETS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_SUPPORT_TICKETS_001 | Validate TICKET_ID uniqueness and not null | All TICKET_ID values are unique and not null |
| TC_BZ_SUPPORT_TICKETS_002 | Validate USER_ID foreign key relationship | All USER_ID values exist in BZ_USERS.USER_ID |
| TC_BZ_SUPPORT_TICKETS_003 | Validate TICKET_TYPE domain values | TICKET_TYPE contains only: technical, billing, account, feature_request, bug_report |
| TC_BZ_SUPPORT_TICKETS_004 | Validate RESOLUTION_STATUS domain values | RESOLUTION_STATUS contains only: open, in_progress, resolved, closed, escalated |
| TC_BZ_SUPPORT_TICKETS_005 | Validate SOURCE_SYSTEM domain values | SOURCE_SYSTEM contains only: SUPPORT_SYSTEM, ZENDESK, MANUAL_ENTRY |
| TC_BZ_SUPPORT_TICKETS_006 | Test deduplication logic | Latest record by LOAD_TIMESTAMP is retained for duplicate TICKET_ID |
| TC_BZ_SUPPORT_TICKETS_007 | Validate OPEN_DATE not null | All OPEN_DATE values are not null |
| TC_BZ_SUPPORT_TICKETS_008 | Test business rule consistency | Open tickets have valid status transitions |

### 6. BZ_BILLING_EVENTS Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_BILLING_EVENTS_001 | Validate EVENT_ID uniqueness and not null | All EVENT_ID values are unique and not null |
| TC_BZ_BILLING_EVENTS_002 | Validate USER_ID foreign key relationship | All USER_ID values exist in BZ_USERS.USER_ID |
| TC_BZ_BILLING_EVENTS_003 | Validate EVENT_TYPE domain values | EVENT_TYPE contains only: subscription, usage, refund, upgrade, downgrade |
| TC_BZ_BILLING_EVENTS_004 | Validate AMOUNT not null | All AMOUNT values are not null |
| TC_BZ_BILLING_EVENTS_005 | Validate SOURCE_SYSTEM domain values | SOURCE_SYSTEM contains only: ZOOM_API, BILLING_SYSTEM, MANUAL_ENTRY |
| TC_BZ_BILLING_EVENTS_006 | Test deduplication logic | Latest record by LOAD_TIMESTAMP is retained for duplicate EVENT_ID |
| TC_BZ_BILLING_EVENTS_007 | Validate EVENT_DATE not null | All EVENT_DATE values are not null |
| TC_BZ_BILLING_EVENTS_008 | Test amount format validation | AMOUNT values are in valid monetary format |

### 7. BZ_LICENSES Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_LICENSES_001 | Validate LICENSE_ID uniqueness and not null | All LICENSE_ID values are unique and not null |
| TC_BZ_LICENSES_002 | Validate LICENSE_TYPE domain values | LICENSE_TYPE contains only: Basic, Pro, Business, Enterprise, Education |
| TC_BZ_LICENSES_003 | Validate ASSIGNED_TO_USER_ID foreign key | All non-null ASSIGNED_TO_USER_ID values exist in BZ_USERS.USER_ID |
| TC_BZ_LICENSES_004 | Validate START_DATE not null | All START_DATE values are not null |
| TC_BZ_LICENSES_005 | Validate SOURCE_SYSTEM domain values | SOURCE_SYSTEM contains only: ZOOM_API, LICENSE_MANAGEMENT_SYSTEM |
| TC_BZ_LICENSES_006 | Test deduplication logic | Latest record by LOAD_TIMESTAMP is retained for duplicate LICENSE_ID |
| TC_BZ_LICENSES_007 | Validate date logic | END_DATE >= START_DATE when both are not null |
| TC_BZ_LICENSES_008 | Test nullable assignment | ASSIGNED_TO_USER_ID can be null (unassigned licenses) |

### 8. BZ_DATA_AUDIT Model Test Cases

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC_BZ_DATA_AUDIT_001 | Validate RECORD_ID uniqueness and not null | All RECORD_ID values are unique and not null |
| TC_BZ_DATA_AUDIT_002 | Validate SOURCE_TABLE not null | All SOURCE_TABLE values are not null |
| TC_BZ_DATA_AUDIT_003 | Validate LOAD_TIMESTAMP not null | All LOAD_TIMESTAMP values are not null |
| TC_BZ_DATA_AUDIT_004 | Validate STATUS domain values | STATUS contains only: INITIALIZED, STARTED, COMPLETED, FAILED |
| TC_BZ_DATA_AUDIT_005 | Test audit trail completeness | Each Bronze table operation has corresponding audit records |
| TC_BZ_DATA_AUDIT_006 | Validate PROCESSING_TIME logic | PROCESSING_TIME >= 0 for all records |
| TC_BZ_DATA_AUDIT_007 | Test PROCESSED_BY not null | All PROCESSED_BY values are not null |
| TC_BZ_DATA_AUDIT_008 | Validate audit sequence | STARTED status precedes COMPLETED/FAILED status |

## dbt Test Scripts

### Schema Tests (models/bronze/schema.yml)

```yaml
version: 2

sources:
  - name: raw
    description: "Raw data layer containing unprocessed data from various source systems"
    database: DB_POC_ZOOM
    schema: RAW
    tables:
      - name: users
        description: "Raw user profile and subscription information"
        columns:
          - name: user_id
            description: "Unique identifier for each user account"
            tests:
              - not_null
              - unique
          - name: email
            description: "Email address of the user"
            tests:
              - not_null
              - unique
          - name: plan_type
            description: "Type of Zoom plan the user is subscribed to"
            tests:
              - not_null
              - accepted_values:
                  values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Education']

      - name: meetings
        description: "Raw meeting information and details"
        columns:
          - name: meeting_id
            description: "Unique identifier for each meeting"
            tests:
              - not_null
              - unique
          - name: host_id
            description: "User ID of the meeting host"
            tests:
              - not_null
          - name: start_time
            description: "Timestamp when the meeting started"
            tests:
              - not_null

      - name: participants
        description: "Raw participant attendance information"
        columns:
          - name: participant_id
            description: "Unique identifier for each participant record"
            tests:
              - not_null
              - unique
          - name: meeting_id
            description: "Identifier linking to the meeting"
            tests:
              - not_null
          - name: user_id
            description: "Identifier of the participating user"
            tests:
              - not_null

      - name: feature_usage
        description: "Raw feature usage tracking data"
        columns:
          - name: usage_id
            description: "Unique identifier for each usage record"
            tests:
              - not_null
              - unique
          - name: meeting_id
            description: "Identifier linking to the meeting"
            tests:
              - not_null
          - name: feature_name
            description: "Name of the feature used"
            tests:
              - not_null
              - accepted_values:
                  values: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard']
          - name: usage_count
            description: "Number of times feature was used"
            tests:
              - not_null

      - name: support_tickets
        description: "Raw support ticket information"
        columns:
          - name: ticket_id
            description: "Unique identifier for each support ticket"
            tests:
              - not_null
              - unique
          - name: user_id
            description: "Identifier of the user who created the ticket"
            tests:
              - not_null
          - name: ticket_type
            description: "Category of the support ticket"
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

      - name: billing_events
        description: "Raw billing events and transactions"
        columns:
          - name: event_id
            description: "Unique identifier for each billing event"
            tests:
              - not_null
              - unique
          - name: user_id
            description: "Identifier linking to the user"
            tests:
              - not_null
          - name: event_type
            description: "Type of billing event"
            tests:
              - not_null
              - accepted_values:
                  values: ['subscription', 'usage', 'refund', 'upgrade', 'downgrade']
          - name: amount
            description: "Monetary amount of the event"
            tests:
              - not_null

      - name: licenses
        description: "Raw license information and assignments"
        columns:
          - name: license_id
            description: "Unique identifier for each license"
            tests:
              - not_null
              - unique
          - name: license_type
            description: "Type of Zoom license"
            tests:
              - not_null
              - accepted_values:
                  values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Education']
          - name: start_date
            description: "Date when license becomes active"
            tests:
              - not_null

models:
  - name: bz_data_audit
    description: "Comprehensive audit trail for all Bronze layer data operations"
    columns:
      - name: record_id
        description: "Auto-incrementing unique identifier for each audit record"
        tests:
          - not_null
          - unique
      - name: source_table
        description: "Name of the source table being processed"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when the audit record was created"
        tests:
          - not_null
      - name: processed_by
        description: "User or service account that processed the data"
        tests:
          - not_null
      - name: processing_time
        description: "Time taken to process the data in seconds"
        tests:
          - not_null
      - name: status
        description: "Status of the data processing operation"
        tests:
          - not_null
          - accepted_values:
              values: ['INITIALIZED', 'STARTED', 'COMPLETED', 'FAILED']

  - name: bz_users
    description: "Bronze layer table storing cleaned and deduplicated user profile information"
    columns:
      - name: user_id
        description: "Unique identifier for each user account"
        tests:
          - not_null
          - unique
      - name: user_name
        description: "Display name of the user"
        tests:
          - not_null
      - name: email
        description: "Email address of the user"
        tests:
          - not_null
          - unique
      - name: plan_type
        description: "Type of Zoom plan the user is subscribed to"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Education']
      - name: load_timestamp
        description: "Timestamp when the record was first loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system from which the data originated"
        tests:
          - not_null
          - accepted_values:
              values: ['ZOOM_API', 'USER_MANAGEMENT_SYSTEM', 'MANUAL_ENTRY']

  - name: bz_meetings
    description: "Bronze layer table storing cleaned and deduplicated meeting information"
    columns:
      - name: meeting_id
        description: "Unique identifier for each meeting"
        tests:
          - not_null
          - unique
      - name: host_id
        description: "User ID of the meeting host"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_time
        description: "Timestamp when the meeting started"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when the record was first loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system from which the data originated"
        tests:
          - not_null
          - accepted_values:
              values: ['ZOOM_API', 'MEETING_SYSTEM']

  - name: bz_participants
    description: "Bronze layer table storing cleaned participant attendance information"
    columns:
      - name: participant_id
        description: "Unique identifier for each participant record"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Identifier linking to the meeting"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: user_id
        description: "Identifier of the participating user"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: load_timestamp
        description: "Timestamp when the record was first loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system from which the data originated"
        tests:
          - not_null
          - accepted_values:
              values: ['ZOOM_API', 'PARTICIPANT_TRACKING_SYSTEM']

  - name: bz_feature_usage
    description: "Bronze layer table storing cleaned feature usage tracking data"
    columns:
      - name: usage_id
        description: "Unique identifier for each usage record"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Identifier linking to the meeting"
        tests:
          - not_null
          - relationships:
              to: ref('bz_meetings')
              field: meeting_id
      - name: feature_name
        description: "Name of the feature used"
        tests:
          - not_null
          - accepted_values:
              values: ['screen_share', 'recording', 'chat', 'breakout_rooms', 'whiteboard']
      - name: usage_count
        description: "Number of times feature was used"
        tests:
          - not_null
      - name: usage_date
        description: "Date when the feature usage occurred"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when the record was first loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system from which the data originated"
        tests:
          - not_null
          - accepted_values:
              values: ['ZOOM_API', 'ANALYTICS_SYSTEM']

  - name: bz_support_tickets
    description: "Bronze layer table storing cleaned support ticket information"
    columns:
      - name: ticket_id
        description: "Unique identifier for each support ticket"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Identifier of the user who created the ticket"
        tests:
          - not_null
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: ticket_type
        description: "Category of the support ticket"
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
        description: "Date when the support ticket was opened"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when the record was first loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system from which the data originated"
        tests:
          - not_null
          - accepted_values:
              values: ['SUPPORT_SYSTEM', 'ZENDESK', 'MANUAL_ENTRY']

  - name: bz_billing_events
    description: "Bronze layer table storing cleaned billing events and transactions"
    columns:
      - name: event_id
        description: "Unique identifier for each billing event"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Identifier linking to the user"
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
        description: "Monetary amount of the event"
        tests:
          - not_null
      - name: event_date
        description: "Date when the billing event occurred"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when the record was first loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system from which the data originated"
        tests:
          - not_null
          - accepted_values:
              values: ['ZOOM_API', 'BILLING_SYSTEM', 'MANUAL_ENTRY']

  - name: bz_licenses
    description: "Bronze layer table storing cleaned license information and assignments"
    columns:
      - name: license_id
        description: "Unique identifier for each license"
        tests:
          - not_null
          - unique
      - name: license_type
        description: "Type of Zoom license"
        tests:
          - not_null
          - accepted_values:
              values: ['Basic', 'Pro', 'Business', 'Enterprise', 'Education']
      - name: assigned_to_user_id
        description: "User ID to whom the license is assigned"
        tests:
          - relationships:
              to: ref('bz_users')
              field: user_id
      - name: start_date
        description: "Date when license becomes active"
        tests:
          - not_null
      - name: load_timestamp
        description: "Timestamp when the record was first loaded"
        tests:
          - not_null
      - name: source_system
        description: "Source system from which the data originated"
        tests:
          - not_null
          - accepted_values:
              values: ['ZOOM_API', 'LICENSE_MANAGEMENT_SYSTEM']
```

### Custom SQL-Based dbt Tests

#### 1. Test for Usage Count Non-Negative Values (tests/assert_usage_count_non_negative.sql)

```sql
-- Test to ensure all usage counts are non-negative
SELECT 
    USAGE_ID,
    USAGE_COUNT
FROM {{ ref('bz_feature_usage') }}
WHERE USAGE_COUNT < 0
```

#### 2. Test for Meeting Duration Logic (tests/assert_meeting_duration_logic.sql)

```sql
-- Test to validate meeting duration logic
SELECT 
    MEETING_ID,
    START_TIME,
    END_TIME,
    DURATION_MINUTES
FROM {{ ref('bz_meetings') }}
WHERE END_TIME IS NOT NULL 
  AND START_TIME IS NOT NULL
  AND DURATION_MINUTES IS NOT NULL
  AND ABS(DATEDIFF('minute', START_TIME, END_TIME) - TRY_CAST(DURATION_MINUTES AS NUMBER)) > 1
```

#### 3. Test for Participant Time Logic (tests/assert_participant_time_logic.sql)

```sql
-- Test to validate participant join/leave time logic
SELECT 
    PARTICIPANT_ID,
    JOIN_TIME,
    LEAVE_TIME
FROM {{ ref('bz_participants') }}
WHERE JOIN_TIME IS NOT NULL 
  AND LEAVE_TIME IS NOT NULL
  AND TRY_CAST(LEAVE_TIME AS TIMESTAMP) < TRY_CAST(JOIN_TIME AS TIMESTAMP)
```

#### 4. Test for License Date Logic (tests/assert_license_date_logic.sql)

```sql
-- Test to validate license start and end date logic
SELECT 
    LICENSE_ID,
    START_DATE,
    END_DATE
FROM {{ ref('bz_licenses') }}
WHERE END_DATE IS NOT NULL 
  AND START_DATE IS NOT NULL
  AND TRY_CAST(END_DATE AS DATE) < START_DATE
```

#### 5. Test for Deduplication Effectiveness (tests/assert_deduplication_effectiveness.sql)

```sql
-- Test to ensure deduplication is working correctly
WITH duplicate_check AS (
    SELECT 
        USER_ID,
        COUNT(*) as record_count
    FROM {{ ref('bz_users') }}
    GROUP BY USER_ID
    HAVING COUNT(*) > 1
)
SELECT 
    USER_ID,
    record_count
FROM duplicate_check
```

#### 6. Test for Audit Trail Completeness (tests/assert_audit_trail_completeness.sql)

```sql
-- Test to ensure audit trail is complete for all Bronze operations
WITH expected_tables AS (
    SELECT table_name FROM (
        VALUES 
        ('BZ_USERS'),
        ('BZ_MEETINGS'),
        ('BZ_PARTICIPANTS'),
        ('BZ_FEATURE_USAGE'),
        ('BZ_SUPPORT_TICKETS'),
        ('BZ_BILLING_EVENTS'),
        ('BZ_LICENSES')
    ) AS t(table_name)
),
actual_audit_tables AS (
    SELECT DISTINCT SOURCE_TABLE
    FROM {{ ref('bz_data_audit') }}
    WHERE STATUS = 'COMPLETED'
)
SELECT 
    e.table_name
FROM expected_tables e
LEFT JOIN actual_audit_tables a ON e.table_name = a.SOURCE_TABLE
WHERE a.SOURCE_TABLE IS NULL
```

#### 7. Test for Email Format Validation (tests/assert_email_format_validation.sql)

```sql
-- Test to validate email format in users table
SELECT 
    USER_ID,
    EMAIL
FROM {{ ref('bz_users') }}
WHERE EMAIL IS NOT NULL 
  AND NOT REGEXP_LIKE(EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
```

#### 8. Test for Processing Time Logic (tests/assert_processing_time_logic.sql)

```sql
-- Test to ensure processing times are reasonable
SELECT 
    SOURCE_TABLE,
    PROCESSING_TIME,
    LOAD_TIMESTAMP
FROM {{ ref('bz_data_audit') }}
WHERE PROCESSING_TIME < 0 
   OR PROCESSING_TIME > 3600  -- More than 1 hour seems unreasonable
```

## Test Execution Strategy

### 1. Pre-Deployment Testing
- Run all schema tests using `dbt test`
- Execute custom SQL tests for business logic validation
- Validate data quality metrics and thresholds
- Check audit trail completeness

### 2. Post-Deployment Validation
- Monitor data freshness and completeness
- Validate referential integrity across tables
- Check deduplication effectiveness
- Verify audit trail accuracy

### 3. Continuous Monitoring
- Set up automated test runs on schedule
- Monitor test results in dbt Cloud or CI/CD pipeline
- Alert on test failures or data quality issues
- Track test execution performance

## Test Data Scenarios

### Edge Case Testing

1. **Empty Source Tables**: Test behavior when source tables are empty
2. **Null Primary Keys**: Verify filtering of records with null primary keys
3. **Duplicate Records**: Test deduplication logic with various timestamp scenarios
4. **Invalid Domain Values**: Test handling of values outside accepted ranges
5. **Missing Foreign Keys**: Test behavior when referenced records don't exist
6. **Data Type Mismatches**: Test handling of incompatible data types
7. **Timestamp Edge Cases**: Test with null, future, and past timestamps
8. **Large Volume Testing**: Validate performance with large datasets

### Performance Testing

1. **Deduplication Performance**: Measure time for deduplication operations
2. **Audit Trail Overhead**: Assess impact of audit logging on performance
3. **Memory Usage**: Monitor memory consumption during processing
4. **Concurrency Testing**: Test multiple simultaneous executions

## Success Criteria

- **Data Quality**: 100% pass rate for uniqueness and not-null tests
- **Business Rules**: 100% compliance with domain value constraints
- **Referential Integrity**: All foreign key relationships validated
- **Deduplication**: No duplicate records in final output
- **Audit Trail**: Complete audit records for all operations
- **Performance**: Processing completes within acceptable time limits
- **Error Handling**: Graceful handling of edge cases and errors

## Maintenance and Updates

- Review and update test cases when business rules change
- Add new tests for additional data sources or transformations
- Monitor test performance and optimize as needed
- Update domain value lists when new values are introduced
- Maintain test documentation and execution procedures

This comprehensive testing framework ensures the reliability, accuracy, and performance of the Zoom Bronze layer dbt models in Snowflake, providing confidence in data quality and transformation logic throughout the data pipeline.